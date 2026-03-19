# Data Layer

## Overview

Sparrow ships with a built-in data layer for Postgres. You define models as Swift structs, query with a type-safe DSL, and migrations are auto-generated from model changes. The interface is protocol-based so backend adapters (Supabase, Firebase, Convex) can be added without changing application code.

## Models

```swift
@Model
struct User {
    var id: UUID = UUID()
    var name: String
    var email: String
    var avatarURL: String?
    var isActive: Bool = true
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}
```

The `@Model` macro generates:
- `Codable` conformance
- `Identifiable` conformance (using `id`)
- Database table mapping (`users` table, snake_case column names)
- Timestamps auto-update (`updatedAt` is set automatically on save)
- Migration metadata (for auto-migration)

### Relationships

```swift
@Model
struct Post {
    var id: UUID = UUID()
    var title: String
    var body: String
    var authorId: UUID         // foreign key to User
    var createdAt: Date = Date()
}

// Querying with relationships
let posts = try await Post.query()
    .where(\.authorId == userId)
    .sorted(by: \.createdAt, .descending)
    .all()

// Loading the related user
let author = try await User.find(post.authorId)
```

Relationships start with explicit foreign keys and manual loading. A richer relationship API (`.belongsTo`, `.hasMany`, eager loading) builds on top of this.

## Querying

### Fetch All

```swift
let users = try await User.query().all()
```

### Filtering

```swift
let activeUsers = try await User.query()
    .where(\.isActive == true)
    .all()

// Multiple conditions (AND)
let results = try await User.query()
    .where(\.isActive == true)
    .where(\.name, .contains, "john")
    .all()

// OR conditions
let results = try await User.query()
    .where {
        $0.isActive == true || $0.email.contains("@company.com")
    }
    .all()
```

### Sorting

```swift
let sorted = try await User.query()
    .sorted(by: \.name)                          // ascending
    .sorted(by: \.createdAt, .descending)        // descending
    .all()
```

### Pagination

```swift
let page = try await User.query()
    .sorted(by: \.createdAt, .descending)
    .limit(20)
    .offset(40)
    .all()
```

### Count

```swift
let count = try await User.query()
    .where(\.isActive == true)
    .count()
```

### Find by ID

```swift
let user = try await User.find(userId)          // returns User?
let user = try await User.require(userId)       // returns User or throws .notFound
```

## Creating

```swift
var user = User(name: "Mikael", email: "mikael@example.com")
try await user.save()
// user.id is now set
```

## Updating

```swift
var user = try await User.require(userId)
user.name = "New Name"
try await user.save()
// user.updatedAt is automatically updated
```

## Deleting

```swift
let user = try await User.require(userId)
try await user.delete()

// Bulk delete
try await User.query()
    .where(\.isActive == false)
    .delete()
```

## Transactions

```swift
try await Database.transaction { db in
    var user = User(name: "Mikael", email: "mikael@example.com")
    try await user.save(on: db)

    var profile = Profile(userId: user.id, bio: "Hello!")
    try await profile.save(on: db)
}
// If either save fails, both are rolled back
```

## Migrations

Sparrow auto-generates migrations by comparing your current `@Model` definitions against the database schema.

```
$ sparrow migrate

Detected changes:
  + Create table 'users' (id, name, email, avatar_url, is_active, created_at, updated_at)
  + Create table 'posts' (id, title, body, author_id, created_at)
  + Add index on posts.author_id

Apply these migrations? [y/n]
```

Migration files are generated and stored in `Migrations/` for version control:

```swift
// Migrations/001_create_users.swift (auto-generated)
struct CreateUsers: Migration {
    func up(schema: Schema) async throws {
        try await schema.create("users") { table in
            table.uuid("id").primaryKey()
            table.string("name").notNull()
            table.string("email").notNull().unique()
            table.string("avatar_url").nullable()
            table.bool("is_active").notNull().default(true)
            table.timestamp("created_at").notNull()
            table.timestamp("updated_at").notNull()
        }
    }

    func down(schema: Schema) async throws {
        try await schema.drop("users")
    }
}
```

You can edit auto-generated migrations before applying them if needed (data migrations, custom SQL, etc.).

### Migration Commands

```
sparrow migrate              # apply pending migrations (interactive)
sparrow migrate --apply      # apply without confirmation (for CI)
sparrow migrate --rollback   # undo last migration
sparrow migrate --status     # show applied/pending migrations
```

## Database Configuration

In `Sparrow.toml`:

```toml
[database]
url = "postgres://localhost:5432/myapp"

[database.pool]
maxConnections = 20
```

Environment variable override:

```toml
[database]
url = "$DATABASE_URL"       # reads from environment
```

## Error Handling

Database errors throw typed errors:

```swift
do {
    try await user.save()
} catch DatabaseError.uniqueViolation(let column) {
    // email already exists
} catch DatabaseError.notFound {
    // record not found
} catch {
    // other database error
}
```

## Backend-Agnostic Design

The `@Model` and query interface are protocol-based. Additional adapters can be added without changing application code:

```toml
# Sparrow.toml — adapter examples

# Postgres (default)
[database]
adapter = "postgres"
url = "postgres://localhost:5432/myapp"

# Supabase
[database]
adapter = "supabase"
url = "https://your-project.supabase.co"
key = "$SUPABASE_KEY"

# Convex
[database]
adapter = "convex"
deploymentUrl = "$CONVEX_URL"
```

The application code (`User.query().where(...).all()`) stays the same regardless of which adapter is active. The adapter translates the query DSL to the backend's native query language.
