# Authentication

## Overview

Sparrow ships built-in authentication with an adapter pattern that matches the data layer. The view-level API is always the same — `auth.signIn()`, `@Environment(\.currentUser)`, `.authenticated()` — regardless of which auth backend is active.

## Auth Adapters

Pick your auth backend in the App config:

```swift
@main
struct MyApp: App {
    var config: some Config {
        Auth(.builtin)
        // or
        Auth(.convex)
        // or
        Auth(.supabase("$SUPABASE_URL", key: "$SUPABASE_KEY"))
    }
}
```

### Built-In Adapter (`.builtin`)

Session-based auth with your configured database as the session store. Email/password. No external auth provider required. This is the self-hosted, zero-dependency option.

- Passwords hashed with bcrypt (cost factor 12)
- Sessions stored in a `sparrow_sessions` table (auto-created)
- Session ID in an HTTP-only, secure, SameSite cookie
- CSRF tokens automatically embedded in forms

### Convex Adapter (`.convex`)

Uses Convex's built-in auth system. Supports email/password and OAuth providers through Convex's auth configuration.

### Supabase Adapter (`.supabase`)

Uses Supabase Auth. Supports email/password, magic links, OAuth providers, and phone auth through Supabase's auth configuration.

### Adapter Protocol

```swift
protocol AuthAdapter {
    func signIn(email: String, password: String) async throws -> AuthSession
    func register(email: String, password: String, metadata: [String: Any]) async throws -> AuthSession
    func signOut(session: AuthSession) async throws
    func validateSession(_ token: String) async throws -> AuthUser?
    func changePassword(session: AuthSession, current: String, new: String) async throws
}
```

## User Model

Sparrow provides a built-in `AuthUser` protocol. You extend it with your own fields:

```swift
@Model
struct User: AuthUser {
    var id: UUID = UUID()
    var email: String
    var passwordHash: String          // managed by Sparrow, never set directly
    var name: String
    var avatarURL: String?
    var isActive: Bool = true
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}
```

The `AuthUser` protocol requires `id`, `email`, and `passwordHash`. Sparrow handles password hashing, session management, and cookie handling.

Note: When using Convex or Supabase adapters, `passwordHash` is managed by the external service. The field exists on the protocol for the built-in adapter but is ignored by external adapters.

## Protecting Routes

### Page-Level Auth

```swift
Routes {
    // Public
    Page("/") { HomeView() }
    Page("/login") { LoginView() }
    Page("/register") { RegisterView() }

    // Authenticated — redirects to /login if not authenticated
    RouteGroup {
        Page("/dashboard") { DashboardView() }
        Page("/settings") { SettingsView() }
        Page("/profile") { ProfileView() }
    }
    .authenticated()
    .unauthenticatedRedirect("/login")
}
```

### Component-Level Auth Check

```swift
struct NavBar: View {
    @Environment(\.currentUser) var currentUser   // User? — nil if not logged in

    var body: some View {
        HStack {
            NavigationLink("Home", destination: "/")
            Spacer()
            if let user = currentUser {
                Text(user.name)
                Button("Logout") { logout() }
            } else {
                NavigationLink("Login", destination: "/login")
            }
        }
    }
}
```

`currentUser` is automatically injected into the environment by Sparrow. It's `nil` when not authenticated. This works the same regardless of auth adapter.

## Built-In Auth Views

Sparrow provides default login and registration views that use the design system. You can use them as-is or build your own.

### Using Defaults

```swift
Routes {
    Page("/login") { SparrowLoginView() }
    Page("/register") { SparrowRegisterView() }
}
```

These render a styled login/register form with email, password, validation, and error handling. They match the active theme.

### Custom Auth Views

```swift
struct LoginView: View {
    @State var email = ""
    @State var password = ""
    @State var error: String?
    @Environment(\.auth) var auth

    var body: some View {
        Form {
            if let error {
                ErrorBanner(message: error)
            }
            TextField("Email", text: $email)
                .textFieldStyle(.outlined)
            SecureField("Password", text: $password)
                .textFieldStyle(.outlined)
            Button("Sign In", style: .primary) {
                do {
                    try await auth.signIn(email: email, password: password)
                } catch AuthError.invalidCredentials {
                    error = "Invalid email or password"
                } catch {
                    error = "Something went wrong"
                }
            }
        }
        .frame(maxWidth: 400)
        .padding(24)
    }
}
```

## Auth API

The `auth` environment object provides the same API regardless of adapter:

```swift
@Environment(\.auth) var auth

// Sign in
try await auth.signIn(email: email, password: password)

// Register
try await auth.register(email: email, password: password, name: name)

// Sign out
try await auth.signOut()

// Current user (same as @Environment(\.currentUser))
let user = auth.currentUser    // User?
```

## Sessions

Session behavior varies by adapter but the developer-facing behavior is consistent:

| Behavior | Built-In | Convex | Supabase |
|---|---|---|---|
| Storage | Database table | Convex-managed | Supabase-managed |
| Token delivery | HTTP-only cookie | HTTP-only cookie | HTTP-only cookie |
| Default duration | 30 days | Convex default | Supabase default |
| Validation | Every request | Every request | Every request |

### Session Configuration (Built-In Adapter)

```swift
Auth(.builtin, session: .init(
    duration: .days(30),
    secureCookies: true    // auto-enabled in production
))
```

## Password Handling (Built-In Adapter)

- Passwords are hashed with bcrypt (cost factor 12)
- Sparrow provides `auth.register()` and `auth.signIn()` — the developer never hashes passwords manually
- `passwordHash` on the User model is write-protected: it can't be set directly, only through `auth.register()` or `auth.changePassword()`
- Password change:
  ```swift
  try await auth.changePassword(
      currentPassword: oldPassword,
      newPassword: newPassword
  )
  ```

### Password Requirements (Built-In Adapter)

```swift
Auth(.builtin, password: .init(
    minLength: 8,
    requireUppercase: false,
    requireNumber: false,
    requireSpecial: false
))
```

These are intentionally relaxed defaults. The developer can tighten them. Sparrow validates passwords at registration and password change time, returning `AuthError.weakPassword` with a human-readable message.

## Auth Errors

```swift
enum AuthError: Error {
    case invalidCredentials        // wrong email or password
    case emailAlreadyExists        // registration with existing email
    case unauthenticated           // no active session
    case sessionExpired            // session timed out
    case weakPassword(String)      // password doesn't meet requirements
    case adapterError(String)      // adapter-specific error
}
```

All adapters map their native errors to these common types.

## CSRF Protection

Sparrow automatically includes CSRF tokens in forms and validates them on submission. The developer doesn't need to think about this. The token is embedded in the HTML by the renderer and validated by the server on form submission events. This works with all auth adapters.

## OAuth Providers

OAuth support varies by adapter:

### Built-In Adapter

```swift
Auth(.builtin, oauth: [
    .google(clientId: "$GOOGLE_CLIENT_ID", clientSecret: "$GOOGLE_CLIENT_SECRET"),
    .github(clientId: "$GITHUB_CLIENT_ID", clientSecret: "$GITHUB_CLIENT_SECRET"),
    .apple(clientId: "$APPLE_CLIENT_ID", teamId: "$APPLE_TEAM_ID"),
])
```

Sparrow handles the OAuth flow, callback routes, and user creation/linking.

### Convex / Supabase Adapters

OAuth is configured in the respective service's dashboard. Sparrow surfaces the sign-in buttons:

```swift
Button("Sign in with Google", style: .ghost) {
    try await auth.signIn(provider: .google)
}
```

## Role-Based Access Control

```swift
RouteGroup {
    Page("/admin") { AdminView() }
}
.authenticated()
.requireRole(.admin)
```

Roles are stored on the User model and checked by the router middleware. This works the same regardless of auth adapter.
