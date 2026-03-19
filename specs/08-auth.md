# Authentication

## Overview

Sparrow ships built-in authentication. Session-based auth with Postgres as the session store. Email/password by default. No external auth provider required.

## User Model

Sparrow provides a built-in `AuthUser` model. You extend it with your own fields:

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

The `AuthUser` protocol requires `id`, `email`, and `passwordHash`. Sparrow handles password hashing (bcrypt), session management, and cookie handling.

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

`currentUser` is automatically injected into the environment by Sparrow. It's `nil` when not authenticated.

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

The `auth` environment object provides:

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

- Sessions are stored in Postgres (a `sparrow_sessions` table, auto-created)
- Session ID is stored in an HTTP-only, secure, SameSite cookie
- Sessions expire after a configurable duration (default: 30 days)
- The session is validated on every WebSocket connection and HTTP request

Configuration in `Sparrow.toml`:

```toml
[auth]
sessionDuration = "30d"          # 30 days
cookieName = "sparrow_session"
secureCookies = true              # requires HTTPS (auto-enabled in production)
```

## Password Handling

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

## Auth Errors

```swift
enum AuthError: Error {
    case invalidCredentials        // wrong email or password
    case emailAlreadyExists        // registration with existing email
    case unauthenticated           // no active session
    case sessionExpired            // session timed out
    case weakPassword(String)      // password doesn't meet requirements
}
```

## Password Requirements

Default requirements (configurable):

```toml
[auth.password]
minLength = 8
requireUppercase = false
requireNumber = false
requireSpecial = false
```

These are intentionally relaxed defaults. The developer can tighten them. Sparrow validates passwords at registration and password change time, returning `AuthError.weakPassword` with a human-readable message.

## CSRF Protection

Sparrow automatically includes CSRF tokens in forms and validates them on submission. The developer doesn't need to think about this. The token is embedded in the HTML by the renderer and validated by the server on form submission events.

## Additional Auth Features

- OAuth providers (Google, GitHub, Apple)
- Email verification
- Password reset via email
- Two-factor authentication (TOTP)
- Role-based access control (`@RequiresRole(.admin)`)
- Organization-based access
- Rate limiting on auth endpoints
