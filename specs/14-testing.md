# Testing

## Overview

Sparrow ships a built-in test runner. You test views in isolation, test data operations, and test full page rendering. Tests use Swift's built-in testing framework (`swift-testing`).

## Running Tests

```
sparrow test                    # run all tests
sparrow test Views/             # run tests in a directory
sparrow test --filter "Login"   # run tests matching a name
```

## View Testing

Test that a view renders the expected HTML given specific inputs:

```swift
import SparrowTesting

@Test
func profileCardRendersUserName() async throws {
    let user = User(name: "Mikael", email: "mikael@test.com")
    let html = try render(ProfileCard(user: user))

    #expect(html.contains(text: "Mikael"))
    #expect(html.contains(tag: "h2", withClass: "font-title"))
    #expect(html.contains(tag: "img", withAttribute: "alt", value: "Mikael"))
}

@Test
func profileCardShowsBadgeForVerifiedUsers() async throws {
    let user = User(name: "Mikael", email: "mikael@test.com", isVerified: true)
    let html = try render(ProfileCard(user: user))

    #expect(html.contains(selector: ".badge-success"))
}

@Test
func profileCardHidesBadgeForUnverifiedUsers() async throws {
    let user = User(name: "Mikael", email: "mikael@test.com", isVerified: false)
    let html = try render(ProfileCard(user: user))

    #expect(!html.contains(selector: ".badge-success"))
}
```

### The `render()` Function

`render(someView)` takes any `View` and returns a `RenderedHTML` object that supports:

```swift
html.contains(text: "...")                              // text content exists
html.contains(tag: "h2")                                // element exists
html.contains(tag: "h2", withClass: "font-title")       // element with class
html.contains(tag: "img", withAttribute: "src", value: "...") // attribute match
html.contains(selector: ".badge-success")                // CSS selector match
html.text                                                // full text content (no tags)
html.raw                                                 // raw HTML string
```

## State Testing

Test that state changes produce the expected re-render:

```swift
@Test
func counterIncrements() async throws {
    let session = try TestSession(Counter())

    // Initial state
    var html = session.currentHTML
    #expect(html.contains(text: "Count: 0"))

    // Simulate button click
    try await session.click("#increment_button")

    // After state change
    html = session.currentHTML
    #expect(html.contains(text: "Count: 1"))
}
```

### TestSession

`TestSession` simulates a full server-side session with state management:

```swift
let session = try TestSession(MyView())

// Simulate interactions
try await session.click("#element_id")
try await session.input("#text_field_id", value: "hello")
try await session.submit("#form_id", values: ["email": "a@b.com"])
try await session.navigate("/other-page")

// Inspect state
let html = session.currentHTML
let patches = session.lastPatches     // the diff patches from last interaction
```

## Data Layer Testing

Test database operations against a real test database:

```swift
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
        // Seed data
        try await User(name: "Active", email: "a@test.com", isActive: true).save(on: db)
        try await User(name: "Inactive", email: "b@test.com", isActive: false).save(on: db)

        let active = try await User.query(on: db)
            .where(\.isActive == true)
            .all()

        #expect(active.count == 1)
        #expect(active[0].name == "Active")
    }
}
```

### Test Database

`withTestDatabase` creates an isolated test database:
- Creates a temporary Postgres database (or schema) for each test
- Runs all pending migrations
- Executes the test
- Drops the database after the test completes
- Tests run in parallel with isolated databases

Configuration in `Sparrow.toml`:

```toml
[test.database]
url = "postgres://localhost:5432/myapp_test"
```

## Auth Testing

```swift
@Test
func dashboardRequiresAuth() async throws {
    let session = try TestSession(MyApp())

    // Unauthenticated — should redirect
    try await session.navigate("/dashboard")
    #expect(session.currentURL == "/login")
}

@Test
func dashboardShowsUserName() async throws {
    let session = try TestSession(MyApp())

    // Authenticate
    try await session.signIn(email: "mikael@test.com", password: "password123")

    try await session.navigate("/dashboard")
    #expect(session.currentHTML.contains(text: "Welcome, Mikael"))
}
```

## Route Testing

```swift
@Test
func homePageReturns200() async throws {
    let response = try await testRequest(.GET, "/")
    #expect(response.status == .ok)
    #expect(response.html.contains(text: "Welcome"))
}

@Test
func notFoundPageReturns404() async throws {
    let response = try await testRequest(.GET, "/nonexistent")
    #expect(response.status == .notFound)
}
```

## Component Preview (#Preview)

Sparrow supports `#Preview` macros for visual component testing in development:

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

### IDE Extension

A VS Code / Zed extension that shows previews in a side panel next to the code, updating live as you edit.

## Test File Organization

Test files can live anywhere in the project with a `Tests` suffix or in a `Tests/` directory:

```
MyApp/
  Views/
    ProfileCard.swift
    ProfileCardTests.swift     # co-located with the component
  Tests/
    AuthTests.swift            # or in a dedicated directory
    DataTests.swift
```

Sparrow discovers test files by the `@Test` macro usage.
