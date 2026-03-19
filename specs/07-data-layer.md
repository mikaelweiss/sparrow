# Data Layer

## Overview

Sparrow's data layer is adapter-based. You define models as Swift structs, query with a type-safe DSL, and the adapter translates to the backend's native query language. Switch databases by changing one line of config. Your application code never changes.

The frontend doesn't care about the database implementation. It either gets the data or gets an error.

## Adapter Architecture

The data layer has two parts:

1. **The interface** — `@Model`, query DSL, `save()`, `delete()`, etc. This is what the developer writes against. It never changes regardless of backend.
2. **The adapter** — Translates the interface to a specific backend (Postgres, Convex, Supabase). The developer picks one in their App config and never thinks about it again.

```swift
@main
struct MyApp: App {
    var config: some Config {
        Database(.postgres("postgres://localhost:5432/myapp"))
        // or
        Database(.convex("$CONVEX_URL"))
        // or
        Database(.supabase("https://your-project.supabase.co", key: "$SUPABASE_KEY"))
    }
}
```

That's it. Everything downstream — models, queries, migrations — works the same.

### Built-In Adapters

| Adapter | Backend | Self-Hosted | Notes |
|---|---|---|---|
| `.postgres(url)` | PostgreSQL | Yes | Full SQL, migrations, raw query escape hatch |
| `.convex(url)` | Convex | No (hosted) | Real-time sync, serverless, no migrations needed |
| `.supabase(url, key:)` | Supabase | Optional | Postgres under the hood, adds real-time + auth |

### Adapter Protocol

Third-party adapters can be written by conforming to `DatabaseAdapter`:

```swift
protocol DatabaseAdapter {
    func find<M: Model>(_ type: M.Type, id: UUID) async throws -> M?
    func query<M: Model>(_ type: M.Type) -> QueryBuilder<M>
    func save<M: Model>(_ model: inout M) async throws
    func delete<M: Model>(_ model: M) async throws
    func transaction(_ work: (any DatabaseAdapter) async throws -> Void) async throws
}
```

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
- Backend mapping metadata (table name, column names for SQL adapters; collection name for document adapters)
- Timestamps auto-update (`updatedAt` is set automatically on save)

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

The query DSL is the same regardless of adapter. The adapter translates it.

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

Note: Transactions are adapter-dependent. Postgres supports full ACID transactions. Convex uses optimistic concurrency. Supabase uses Postgres transactions. The API is the same — the guarantees vary by backend. This is documented per-adapter.

## Migrations

Migrations are adapter-specific. Not all backends need them.

### Postgres Adapter

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

#### Migration Commands

```
sparrow migrate              # apply pending migrations (interactive)
sparrow migrate --apply      # apply without confirmation (for CI)
sparrow migrate --rollback   # undo last migration
sparrow migrate --status     # show applied/pending migrations
```

### Convex Adapter

No migrations. Convex is schemaless — `@Model` definitions are enforced at the application level. Sparrow validates data on read/write against your model definitions.

### Supabase Adapter

Uses Postgres migrations under the hood. Same migration commands as the Postgres adapter.

## Database Configuration

Configuration lives in your App struct:

```swift
@main
struct MyApp: App {
    var config: some Config {
        // Postgres (self-hosted)
        Database(.postgres("$DATABASE_URL"))

        // Convex (hosted)
        Database(.convex("$CONVEX_URL"))

        // Supabase (hosted or self-hosted)
        Database(.supabase("$SUPABASE_URL", key: "$SUPABASE_KEY"))
    }
}
```

Environment variables are referenced with `$` prefix and resolved at runtime.

### Connection Pool (Postgres/Supabase)

```swift
Database(.postgres("$DATABASE_URL", pool: .init(maxConnections: 20)))
```

## Error Handling

Database errors throw typed errors regardless of adapter:

```swift
do {
    try await user.save()
} catch DatabaseError.uniqueViolation(let field) {
    // email already exists
} catch DatabaseError.notFound {
    // record not found
} catch DatabaseError.connectionFailed {
    // can't reach the database
} catch {
    // other database error
}
```

Each adapter maps its native errors to these common types. If an adapter doesn't support a specific error type (e.g., Convex doesn't have unique constraints in the same way), it maps to the closest equivalent or a generic `DatabaseError.adapterError(String)`.
