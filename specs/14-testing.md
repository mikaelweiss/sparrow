# Testing

## Overview

Sparrow ships a built-in test runner focused on business logic. The UI is its own test — you look at it. Automated tests cover the things you can't see: data operations, auth flows, business rules, and route behavior. Tests use Swift's built-in testing framework (`swift-testing`).

## Philosophy

**Don't test the UI.** If a button is the wrong color, you'll see it. If a layout is broken, you'll see it. Writing assertions about HTML structure and CSS classes creates brittle tests that break when you change a font size. The `#Preview` system (see below) is the right tool for visual verification.

**Test what matters:**
- Data layer: queries return correct results, mutations persist correctly, constraints work
- Auth: sign-in succeeds with valid credentials, fails with invalid ones, guards block unauthorized access
- Business logic: computed values are correct, state transitions are valid, edge cases are handled
- Routes: the right page renders for the right URL, auth redirects work, 404s fire

## Running Tests

```
sparrow test                    # run all tests
sparrow test Models/            # run tests in a directory
sparrow test --filter "Login"   # run tests matching a name
```

## Data Layer Testing

Test database operations against a real test database:

```swift
import SparrowTesting

@Test
func createUserSavesToDatabase() async throws {
    try await withTestDatabase { db in
        var user = User(name: "Test", email: "test@example.com")
        try await user.save(on: db)

        let fetched = try await User.find(user.id, on: db)
        #expect(fetched?.name == "Test")
    }
}

@Test
func queryFiltersCorrectly() async throws {
    try await withTestDatabase { db in
        try await User(name: "Active", email: "a@test.com", isActive: true).save(on: db)
        try await User(name: "Inactive", email: "b@test.com", isActive: false).save(on: db)

        let active = try await User.query(on: db)
            .where(\.isActive == true)
            .all()

        #expect(active.count == 1)
        #expect(active[0].name == "Active")
    }
}

@Test
func uniqueEmailConstraint() async throws {
    try await withTestDatabase { db in
        var user1 = User(name: "First", email: "same@test.com")
        try await user1.save(on: db)

        var user2 = User(name: "Second", email: "same@test.com")
        #expect(throws: DatabaseError.uniqueViolation("email")) {
            try await user2.save(on: db)
        }
    }
}
```

### Test Database

`withTestDatabase` creates an isolated test database:
- Creates a temporary database (or schema) for each test
- Runs all pending migrations
- Executes the test
- Drops the database after the test completes
- Tests run in parallel with isolated databases

Configuration:

```swift
// In App config or test setup
TestDatabase(.postgres("postgres://localhost:5432/myapp_test"))
```

## Auth Testing

```swift
@Test
func signInWithValidCredentials() async throws {
    try await withTestAuth { auth in
        try await auth.register(email: "test@example.com", password: "password123", name: "Test")
        try await auth.signOut()

        let session = try await auth.signIn(email: "test@example.com", password: "password123")
        #expect(session.user.email == "test@example.com")
    }
}

@Test
func signInWithWrongPasswordFails() async throws {
    try await withTestAuth { auth in
        try await auth.register(email: "test@example.com", password: "password123", name: "Test")
        try await auth.signOut()

        #expect(throws: AuthError.invalidCredentials) {
            try await auth.signIn(email: "test@example.com", password: "wrong")
        }
    }
}

@Test
func dashboardRequiresAuth() async throws {
    let session = try TestSession(MyApp())

    try await session.navigate("/dashboard")
    #expect(session.currentURL == "/login")
}

@Test
func dashboardShowsUserName() async throws {
    let session = try TestSession(MyApp())

    try await session.signIn(email: "mikael@test.com", password: "password123")
    try await session.navigate("/dashboard")
    #expect(session.currentHTML.contains(text: "Welcome, Mikael"))
}
```

## Business Logic Testing

Test your domain logic directly — computed properties, validation rules, state machines:

```swift
@Test
func cartTotalCalculation() async throws {
    var state = AppState()
    state.cartItems = [
        CartItem(name: "Widget", price: 9.99, quantity: 2),
        CartItem(name: "Gadget", price: 24.99, quantity: 1),
    ]

    #expect(state.cartTotal == 44.97)
}

@Test
func discountCodeApplied() async throws {
    var state = AppState()
    state.cartItems = [CartItem(name: "Widget", price: 100, quantity: 1)]
    state.discountCode = "SAVE20"

    #expect(state.discountedTotal == 80)
}

@Test
func emptyCartHasZeroTotal() async throws {
    let state = AppState()
    #expect(state.cartTotal == 0)
}
```

## Route Testing

```swift
@Test
func homePageReturns200() async throws {
    let response = try await testRequest(.GET, "/")
    #expect(response.status == .ok)
}

@Test
func notFoundPageReturns404() async throws {
    let response = try await testRequest(.GET, "/nonexistent")
    #expect(response.status == .notFound)
}

@Test
func redirectWorks() async throws {
    let response = try await testRequest(.GET, "/old-path")
    #expect(response.status == .redirect)
    #expect(response.headers["Location"] == "/new-path")
}
```

## State Testing

Test that state changes produce the expected behavior:

```swift
@Test
func counterIncrements() async throws {
    let session = try TestSession(Counter())

    #expect(session.currentHTML.contains(text: "Count: 0"))

    try await session.click("#increment_button")
    #expect(session.currentHTML.contains(text: "Count: 1"))
}
```

### TestSession

`TestSession` simulates a full server-side session:

```swift
let session = try TestSession(MyView())

// Simulate interactions
try await session.click("#element_id")
try await session.input("#text_field_id", value: "hello")
try await session.submit("#form_id", values: ["email": "a@b.com"])
try await session.navigate("/other-page")

// Inspect
let html = session.currentHTML
let patches = session.lastPatches
```

Use `TestSession` when you need to test interaction flows — not to assert on HTML structure.

## Component Preview (#Preview)

`#Preview` is the right tool for visual verification. It replaces UI tests.

```swift
struct ProfileCard: View {
    var user: User
    var body: some View { /* ... */ }
}

#Preview("Default") {
    ProfileCard(user: .sample)
}

#Preview("Verified User") {
    ProfileCard(user: .sampleVerified)
}

#Preview("Long Name") {
    ProfileCard(user: User(name: "A Very Long Username That Might Break Layout", email: "test@test.com"))
}
```

### Preview Server

```
sparrow preview                 # start preview server
```

Opens a browser page showing all `#Preview` blocks, organized by component. Each preview renders in isolation with controls to:
- Switch between light/dark mode
- Resize the viewport (phone/tablet/desktop)
- View the generated HTML

## Test File Organization

Test files can live anywhere in the project with a `Tests` suffix or in a `Tests/` directory:

```
MyApp/
  Models/
    User.swift
    UserTests.swift            # co-located with the model
  Tests/
    AuthTests.swift            # or in a dedicated directory
    CartLogicTests.swift
```

Sparrow discovers test files by the `@Test` macro usage.
