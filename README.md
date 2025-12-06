# Recipefy 🍳

**Turn Your Ingredients Into Delicious Meals**

Recipefy is an iOS app that uses AI-powered image recognition to identify ingredients from photos and generate personalized recipe suggestions. Simply snap a photo of your fridge, pantry, or ingredients, and let Recipefy do the rest. This app is developed for 67-443 Mobile App Development at Carnegie Mellon University, Fall 2025.

![Swift](https://img.shields.io/badge/Swift-5.0-orange)
![iOS](https://img.shields.io/badge/iOS-26.0+-green)
![Firebase](https://img.shields.io/badge/Firebase-12.4-yellow)
![Xcode](https://img.shields.io/badge/Xcode-26.0+-blue)

---

## 📱 Features

### Core Functionality
- **📸 Multi-Image Scanning** — Capture up to 5 photos per session (fridge, pantry, countertop)
- **🤖 AI Ingredient Recognition** — Powered by Google's Gemini 2.5 Flash for accurate identification
- **🍽️ Smart Recipe Generation** — Get unique recipes based on your available ingredients
- **❤️ Favorites** — Save and organize your favorite recipes
- **👤 User Profiles** — Track your recipes, ingredients, and cooking history

### Dietary Preferences
- **Diet Types** — Vegetarian, Vegan, Pescatarian, Gluten-Free, Dairy-Free, Low-Carb
- **Allergen Management** — Peanuts, Tree Nuts, Shellfish, Fish, Eggs, Dairy, Gluten, Soy, Sesame
- **Food Dislikes** — Exclude specific ingredients you don't enjoy
- **Cooking Time Limits** — Set maximum preparation time for recipes

### Authentication
- **Email/Password** — Traditional account creation with password reset
- **Sign in with Apple** — Native Apple authentication with secure nonce
- **Google Sign-In** — OAuth-based Google account integration

---

## 🛠️ Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **UI Framework** | SwiftUI (iOS 26) | Declarative, modern iOS interface |
| **Language** | Swift 5.0 | Type-safe, modern programming language |
| **Architecture** | MVVM + Controllers | Separation of concerns, testability |
| **AI/ML** | Firebase AI (Gemini 2.5 Flash) | Ingredient recognition, recipe generation |
| **Authentication** | Firebase Auth | Multi-provider auth (Email, Apple, Google) |
| **Database** | Cloud Firestore | Real-time NoSQL document storage |
| **Storage** | Firebase Storage | Image hosting for scanned ingredients |
| **Testing** | Swift Testing Framework | Modern, declarative test assertions |

### Key Dependencies
```
firebase-ios-sdk 12.4.0      — Core Firebase services
GoogleSignIn-iOS 9.0.0       — Google authentication
swift-protobuf 1.32.0        — Protocol buffer support
CryptoKit (native)           — SHA256 for Apple Sign-In nonce
```

---

## 🏗️ Architecture & Design Decisions

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        SwiftUI Views                         │
│  (HomeView, ScanView, RecipeView, SettingsView, etc.)       │
└─────────────────────────┬───────────────────────────────────┘
                          │ @EnvironmentObject
┌─────────────────────────▼───────────────────────────────────┐
│                      Controllers                             │
│  AuthController │ ScanController │ IngredientController │    │
│                 │ RecipeController │ NavigationState         │
└─────────────────────────┬───────────────────────────────────┘
                          │ Protocol-based DI
┌─────────────────────────▼───────────────────────────────────┐
│                     Service Layer                            │
│  GeminiService │ FirebaseFirestoreService │ StorageService  │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                   Firebase Backend                           │
│  Firestore │ Auth │ Storage │ AI (Gemini)                   │
└─────────────────────────────────────────────────────────────┘
```

### Design Decisions

#### 1. **Protocol-Oriented Service Layer**

All external services are abstracted behind protocols, enabling:
- **Testability** — Mock implementations for unit testing
- **Flexibility** — Swap implementations without changing business logic
- **Decoupling** — Controllers don't depend on concrete Firebase classes

```swift
protocol GeminiServiceProtocol {
  func analyzeIngredients(image: UIImage) async throws -> [Ingredient]
  func getRecipe(ingredients: [String]) async throws -> [Recipe]
}

protocol FirestoreServiceProtocol {
  func saveIngredients(scanId: String, ingredients: [Ingredient]) async throws -> [Ingredient]
  func loadRecipes(userId: String) async throws -> (recipes: [Recipe], scanId: String?)
  // ... more operations
}
```

#### 2. **@MainActor for Thread Safety**

All controllers and view-related classes are marked with `@MainActor` to ensure UI updates happen on the main thread:

```swift
@MainActor
final class RecipeController: ObservableObject {
  @Published var currentRecipes: [Recipe]?
  @Published var isRetrieving = false
  // ...
}
```

**Rationale:** Swift's strict concurrency model requires explicit main-thread guarantees for @Published properties. Using @MainActor at the class level eliminates race conditions and makes the code safer.

#### 3. **Environment Object State Sharing**

Controllers are shared across the app using SwiftUI's environment:

```swift
@main
struct RecipefyApp: App {
  @StateObject private var authController = AuthController()
  @StateObject private var scanController = ScanController(...)
  @StateObject private var ingredientController = IngredientController(...)
  @StateObject private var recipeController = RecipeController(...)

  var body: some Scene {
    WindowGroup {
      NavigationBarView()
        .environmentObject(authController)
        .environmentObject(scanController)
        .environmentObject(ingredientController)
        .environmentObject(recipeController)
    }
  }
}
```

**Rationale:** This ensures a single source of truth across all views and tabs, enabling seamless data flow when navigating between screens.

#### 4. **Scan-to-Recipe Data Flow**

The app maintains data association between scans and their generated content:

```
Scan (images) → ScanController.currentScanId
      ↓
Ingredients → IngredientController.currentScanId  
      ↓
Recipes → RecipeController.lastGeneratedScanId
```

**Rationale:** This ensures recipes are never mixed from different scanning sessions, preventing confusing user experiences.

#### 5. **Robust Category Parsing**

AI responses can be unpredictable. The `IngredientCategory` enum includes fuzzy matching:

```swift
static func from(string: String) -> IngredientCategory {
  let normalized = string.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
  switch normalized {
  case "vegetable", "vegetables", "veggie", "veggies", "veg":
    return .vegetables
  case "protein", "proteins", "meat", "meats":
    return .proteins
  // ... more variations
  default:
    return .other
  }
}
```

**Rationale:** Gemini might return "Veggies" instead of "Vegetables". Graceful fallback prevents crashes and ensures all ingredients are categorized.

#### 6. **Parallel Image Analysis**

Multiple images are analyzed concurrently using Swift's structured concurrency:

```swift
let allIngredients = try await withThrowingTaskGroup(of: [Ingredient].self) { group in
  for image in images {
    group.addTask {
      try await self.geminiService.analyzeIngredients(image: image)
    }
  }
  
  var results: [Ingredient] = []
  for try await ingredients in group {
    results.append(contentsOf: ingredients)
  }
  return results
}
```

**Rationale:** Users can scan fridge + pantry + countertop. Processing them in parallel reduces wait time from ~30s to ~10s for 3 images.

#### 7. **Dietary Preferences in AI Prompts**

User preferences are injected directly into AI prompts:

```swift
func toPromptString() -> String {
  var prompt = "\n\nUSER DIETARY PREFERENCES:\n"
  
  if !dietTypes.isEmpty {
    prompt += "- Diet Types: \(dietTypes.map { $0.displayName }.joined(separator: ", "))\n"
  }
  
  if !allergies.isEmpty {
    prompt += "- ALLERGIES (CRITICAL - MUST AVOID): \(allergies.map { $0.rawValue }.joined(separator: ", "))\n"
  }
  
  prompt += "\nIMPORTANT: Generate recipes that strictly respect these dietary constraints.\n"
  return prompt
}
```

**Rationale:** This approach leverages Gemini's instruction-following capabilities rather than post-filtering recipes, resulting in more relevant suggestions.

#### 8. **Simulator Camera Support**

Development on simulators is enabled through mock camera support:

```swift
if SimulatorCameraSupport.isRunningOnSimulator {
  capturedImage = SimulatorCameraSupport.generateMockIngredientImage()
  return
}
```

**Rationale:** Camera hardware is unavailable on simulators. Mock images allow full flow testing without a physical device.

#### 9. **Firestore Connection Pre-warming**

Cold start latency is reduced by warming up Firestore on app launch:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions...) -> Bool {
  FirebaseApp.configure()
  
  // Pre-warm Firestore connection
  Task {
    let db = Firestore.firestore()
    _ = try? await db.collection("_warmup").document("ping").getDocument()
  }
  
  return true
}
```

**Rationale:** First Firestore request can take 2-3 seconds for connection setup. Pre-warming hides this latency behind the splash screen.

#### 10. **Batch Firestore Operations**

Ingredients are saved using batched writes for atomicity and performance:

```swift
func saveIngredients(scanId: String, ingredients: [Ingredient]) async throws -> [Ingredient] {
  let batch = db.batch()
  
  for ingredient in ingredients {
    let docRef = ingredientsCollection.document()
    batch.setData(ingredientData, forDocument: docRef)
  }
  
  try await batch.commit()
  return ingredientsWithIds
}
```

**Rationale:** A single batch commit is faster and ensures all-or-nothing saves, preventing partial data states.

---

## 📂 Project Structure

```
Recipefy/
├── Recipefy/
│   ├── RecipefyApp.swift              # App entry point & DI setup
│   ├── AppDelegate.swift              # Firebase initialization
│   │
│   ├── Models/
│   │   ├── User.swift                 # AppUser with auth providers
│   │   ├── Recipe.swift               # Recipe with nutrition data
│   │   ├── Ingredient.swift           # Ingredient with categories
│   │   ├── Scan.swift                 # Image scan metadata
│   │   ├── DietaryPreferences.swift   # Diet types, allergies, dislikes
│   │   └── MeasurementUnit.swift      # Standardized units
│   │
│   ├── Controllers/
│   │   ├── AuthController.swift       # Authentication state & operations
│   │   ├── ScanController.swift       # Image capture & upload
│   │   ├── IngredientController.swift # AI analysis & CRUD
│   │   ├── RecipeController.swift     # Recipe generation & favorites
│   │   └── NavigationState.swift      # Tab selection state
│   │
│   ├── Data/
│   │   ├── GeminiService.swift        # AI ingredient/recipe analysis
│   │   ├── GeminiServiceProtocol.swift
│   │   ├── FirebaseFirestoreService.swift
│   │   ├── FirestoreServiceProtocol.swift
│   │   ├── FirebaseStorageService.swift
│   │   ├── StorageService.swift       # Protocol for storage
│   │   ├── FirebaseScanRepository.swift
│   │   ├── ScanRepository.swift       # Protocol for scan persistence
│   │   └── FireStorePaths.swift       # Firestore path constants
│   │
│   ├── Views/
│   │   ├── LandingView.swift          # Onboarding screen
│   │   ├── AuthView.swift             # Login/signup UI
│   │   ├── HomeView.swift             # Dashboard with quick actions
│   │   ├── NavigationBarView.swift    # Tab bar container
│   │   ├── ScanView.swift             # Camera interface
│   │   ├── ReviewScansView.swift      # Photo review before analysis
│   │   ├── IngredientListView.swift   # Detected ingredients
│   │   ├── IngredientFormView.swift   # Add/edit ingredient
│   │   ├── RecipeView.swift           # Recipe generation trigger
│   │   ├── RecipeCardsView.swift      # Swipeable recipe cards
│   │   ├── RecipeDetailView.swift     # Full recipe view
│   │   ├── FavoriteRecipesView.swift  # Saved recipes
│   │   ├── SettingsView.swift         # Profile & preferences
│   │   ├── EditProfileView.swift      # Name, email, password
│   │   ├── PreferencesView.swift      # Dietary settings
│   │   ├── EmptyStateView.swift       # Reusable empty state
│   │   ├── Camera/
│   │   │   ├── CameraManager.swift    # AVFoundation wrapper
│   │   │   ├── CameraPreviewView.swift
│   │   │   ├── CameraOverlays.swift   # Grid overlay
│   │   │   └── SimulatorCameraSupport.swift
│   │   └── ... (Help, Privacy, Terms views)
│   │
│   ├── Helpers/
│   │   └── AppleSignInHelper.swift    # Nonce generation, SHA256
│   │
│   └── Assets.xcassets/               # App icons, images
│
├── RecipefyTests/                     # Unit tests
│   ├── RecipeControllerTests.swift
│   ├── IngredientControllerTests.swift
│   ├── AuthControllerErrorTests.swift
│   ├── DietaryPreferencesTests.swift
│   ├── CameraTests.swift
│   └── ... (18 test files)
│
└── RecipefyUITests/                   # UI tests
    ├── RecipefyUITests.swift
    └── RecipefyUITestsLaunchTests.swift
```

---

## 🚀 Getting Started

### Prerequisites
- Xcode 26.0+
- iOS 26.0+ device or simulator
- Firebase project with:
  - Authentication (Email, Apple, Google)
  - Cloud Firestore
  - Firebase Storage
  - Firebase AI (Gemini API enabled)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/Recipefy.git
   cd Recipefy
   ```

2. **Open the Xcode project**
   ```bash
   open Recipefy/Recipefy.xcodeproj
   ```

3. **Configure Firebase**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Download `GoogleService-Info.plist`
   - Replace the existing plist in `Recipefy/Recipefy/`
   - Enable Authentication providers (Email, Apple, Google)
   - Enable Cloud Firestore and Storage
   - Enable Gemini API in Firebase AI

4. **Configure Google Sign-In**
   - Add the reversed client ID from `GoogleService-Info.plist` to URL schemes in `Info.plist`

5. **Configure Sign in with Apple**
   - Add "Sign in with Apple" capability in Xcode
   - Configure in Apple Developer portal

6. **Build and Run**
   - Select your target device or simulator
   - Press `⌘R` to build and run

---

## 🧪 Testing

The project uses Swift's modern Testing framework with **240+ unit tests** across 18 test files, implementing mock-based dependency injection for fast, deterministic testing.

### Testing Philosophy

> **Test your code, not the SDK.** We trust that Firebase and Gemini work — our tests verify our business logic.

All tests are:
- **Fast** — No network calls; all tests run in under 5 seconds
- **Deterministic** — Same input always produces same output
- **Independent** — Each test can run alone without dependencies

### What IS Tested

| Category | Coverage | Files |
|----------|----------|-------|
| **Models** | 95-100% | Recipe, Ingredient, Scan, User, DietaryPreferences, MeasurementUnit |
| **Controllers** | 75-85% | RecipeController, IngredientController, ScanController, NavigationState |
| **Helpers/Utils** | 95-100% | AppleSignInHelper, FireStorePaths |
| **View Logic** | 80-90% | Validation logic, data formatting, share text generation |
| **Camera State** | 90%+ | CameraManager state machine, simulator detection |

**Why these are tested:**
- Models contain core business logic used throughout the app
- Controller business logic is tested via dependency injection with mocks
- Pure helper functions are easy to test with high value
- View validation logic is critical for data integrity

### What is NOT Tested (and Why)

| Category | Reason |
|----------|--------|
| **Firebase SDK Calls** | Would require mocking entire Firebase SDK; slow and brittle; Firebase is already tested by Google |
| **Gemini AI API Calls** | Non-deterministic AI responses; costs money per call; requires API keys; response *parsing* IS tested with mock data |
| **SwiftUI View Rendering** | Unit tests don't render UI; this is covered by UI tests and manual QA |
| **App Lifecycle** | Thin wrappers around Firebase/SwiftUI initialization; rarely changes |

### Dependency Injection Architecture

Controllers accept protocols, not concrete types, enabling mock injection in tests:

```swift
// Protocol defines the contract
protocol GeminiServiceProtocol {
  func analyzeIngredients(image: UIImage) async throws -> [Ingredient]
  func getRecipe(ingredients: [String]) async throws -> [Recipe]
}

// Production uses real service
let controller = RecipeController(
  geminiService: GeminiService(),           // Real AI
  firestoreService: FirebaseFirestoreService()  // Real database
)

// Tests use mock service
let controller = RecipeController(
  geminiService: MockGeminiService(),       // Returns test data
  firestoreService: MockFirestoreService()  // No network calls
)
```

### Mock Service Example

```swift
class MockGeminiService: GeminiServiceProtocol {
  var mockRecipes: [Recipe] = []
  var shouldThrowError = false
  
  func getRecipe(ingredients: [String]) async throws -> [Recipe] {
    if shouldThrowError { throw GeminiError.noResponse }
    return mockRecipes
  }
}
```

### Test Files (18 total)

```
RecipefyTests/
├── Models
│   ├── RecipeTests.swift          (14 tests)
│   ├── IngredientTests.swift      (12 tests)
│   ├── ScanTests.swift            (11 tests)
│   ├── AppUserTests.swift         (8 tests)
│   ├── DietaryPreferencesTests.swift (33 tests)
│   └── MeasurementUnitTests.swift (10 tests)
├── Controllers
│   ├── RecipeControllerTests.swift     (22 tests)
│   ├── IngredientControllerTests.swift (17 tests)
│   ├── ScanControllerTests.swift       (9 tests)
│   ├── NavigationStateTests.swift      (12 tests)
│   └── AuthControllerErrorTests.swift  (10 tests)
├── Views
│   ├── HomeViewTests.swift           (6 tests)
│   ├── AuthViewTests.swift           (8 tests)
│   ├── IngredientFormViewTests.swift (9 tests)
│   └── RecipeDetailViewTests.swift   (11 tests)
├── Helpers
│   ├── AppleSignInHelperTests.swift  (15 tests)
│   └── FirestorePathsTests.swift     (5 tests)
└── Camera
    └── CameraTests.swift             (22 tests)
```

### Running Tests

In Xcode, press `⌘U` to run all tests, or use the Test Navigator (`⌘6`) to run individual test files or methods.

### Coverage Target

| Scope | Target |
|-------|--------|
| Models | 95-100% |
| Business Logic | 85-95% |
| **Overall** | **85-90%** |

*Note: 100% coverage is not the goal — untested Firebase/Gemini wrappers are intentional. Testing SDK calls adds complexity without value.*

---

## 📊 Data Model

### Firestore Collections

```
users/
  └── {userId}/
      ├── displayName, email, photoURL, authProvider
      └── preferences/
          └── dietary/
              ├── dietTypes: [String]
              ├── allergies: [String]
              ├── dislikes: [String]
              └── maxCookingTime: Int

scans/
  └── {scanId}/
      ├── userId, imagePaths, status, createdAt
      └── ingredients/
          └── {ingredientId}/
              ├── name, quantity, unit, category

recipes/
  └── {recipeId}/
      ├── title, description, ingredients, steps
      ├── calories, servings, cookMin
      ├── protein, carbs, fat, fiber, sugar
      ├── createdBy, sourceScanId, favorited
      └── createdAt
```

---

## 🎨 UI/UX Design

- **Color Theme** — Green accent (`#5CB85C`) representing fresh, healthy cooking
- **Typography** — SF Pro with semantic sizing for hierarchy
- **Navigation** — 5-tab structure (Home, Ingredients, Scan, Recipes, Settings)
- **Empty States** — Informative messages with relevant icons
- **Loading States** — Progress indicators with status text
- **Cards** — Rounded corners, subtle shadows, gesture-friendly

---

## 👥 Team

| Name | Role |
|------|------|
| Streak Honey | Lead Developer, Architecture |
| Abdallah Abdaljalil | Authentication, UI/UX |
| Yuqi Zou | AI Integration, Ingredient Analysis |
| Jonas Oh | Recipe Generation, Navigation |

---

## 📄 License

This project was developed for 67-443 Mobile App Development at Carnegie Mellon University, Fall 2025.

---

## 🔮 Future Enhancements

- [ ] Offline mode with local recipe caching
- [ ] Recipe sharing via deep links
- [ ] Shopping list generation from recipes
- [ ] Nutritional goal tracking
- [ ] Community recipe contributions
- [ ] Voice-guided cooking mode
