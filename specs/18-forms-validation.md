# Forms & Validation

## Overview

Forms in Sparrow handle user input, validation, and submission. Validation is declarative, runs on the server, and produces accessible error messages automatically.

## Basic Form

```swift
struct ContactForm: View {
    @State var name = ""
    @State var email = ""
    @State var message = ""
    @State var submitted = false

    var body: some View {
        if submitted {
            Text("Thanks for your message!")
                .foreground(.success)
        } else {
            Form {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                TextEditor(text: $message)
                    .frame(minHeight: 100)
                Button("Send", style: .primary) {
                    try await sendMessage(name: name, email: email, message: message)
                    submitted = true
                }
            }
        }
    }
}
```

## Validation

### Declarative Validators

```swift
TextField("Email", text: $email)
    .validate(.required, message: "Email is required")
    .validate(.email, message: "Enter a valid email")

TextField("Username", text: $username)
    .validate(.required)
    .validate(.minLength(3), message: "At least 3 characters")
    .validate(.maxLength(20))
    .validate(.pattern(/^[a-zA-Z0-9_]+$/), message: "Letters, numbers, and underscores only")

SecureField("Password", text: $password)
    .validate(.required)
    .validate(.minLength(8))
```

### Built-In Validators

| Validator | Description |
|---|---|
| `.required` | Field must not be empty |
| `.email` | Valid email format |
| `.url` | Valid URL format |
| `.minLength(n)` | Minimum character count |
| `.maxLength(n)` | Maximum character count |
| `.pattern(regex)` | Matches a regex pattern |
| `.numeric` | Contains only numbers |
| `.range(min...max)` | Numeric value within range |
| `.custom((String) -> Bool)` | Custom validation function |

### Validation Timing

Validation runs on the server when:
1. The user submits the form (always)
2. The user blurs a field (optional, enabled by default)
3. The user types (optional, debounced)

```swift
TextField("Email", text: $email)
    .validate(.email)
    .validateOn(.submit)          // only on form submit
    .validateOn(.blur)            // on blur (default)
    .validateOn(.input)           // on every input (debounced)
```

### Validation Display

Validation errors appear below the input automatically:

```html
<div class="form-field">
    <label for="email">Email</label>
    <input id="email" type="text" aria-invalid="true" aria-describedby="email_error" class="input-error">
    <p id="email_error" role="alert" class="form-error">Enter a valid email</p>
</div>
```

The error text is styled with the `.error` color from the design system. The input gets an error border. Screen readers announce the error.

### Form-Level Validation

```swift
Form {
    TextField("Password", text: $password)
    TextField("Confirm", text: $confirm)
}
.validate {
    if password != confirm {
        FormError("Passwords don't match")
    }
}
```

### Preventing Submission

The form's submit button is automatically disabled when validation fails:

```swift
Form {
    TextField("Email", text: $email)
        .validate(.required)
        .validate(.email)

    Button("Submit", style: .primary) {
        // This only runs if all validations pass
        try await createAccount(email: email)
    }
}
```

The `Button` inside a `Form` automatically knows it's a submit button. It checks all validations before executing the action. If validation fails, errors are shown and the action doesn't run.

## Form State

Access the form's validation state:

```swift
struct SignupForm: View {
    @State var email = ""
    @State var password = ""

    var body: some View {
        Form { form in
            TextField("Email", text: $email)
                .validate(.required)
                .validate(.email)

            SecureField("Password", text: $password)
                .validate(.required)
                .validate(.minLength(8))

            HStack {
                Button("Cancel", style: .ghost) { /* ... */ }
                Button("Sign Up", style: .primary) {
                    try await signUp(email: email, password: password)
                }
                .disabled(!form.isValid)
            }
        }
    }
}
```

## Multi-Step Forms

```swift
struct OnboardingForm: View {
    @State var step = 1
    @State var name = ""
    @State var email = ""
    @State var plan: Plan = .free

    var body: some View {
        VStack {
            ProgressView(value: Double(step), total: 3)

            switch step {
            case 1:
                Form {
                    TextField("Name", text: $name)
                        .validate(.required)
                    Button("Next") { step = 2 }
                }
                .transition(.slide(.trailing))
            case 2:
                Form {
                    TextField("Email", text: $email)
                        .validate(.required)
                        .validate(.email)
                    Button("Next") { step = 3 }
                }
                .transition(.slide(.trailing))
            case 3:
                Form {
                    Picker("Plan", selection: $plan) {
                        Text("Free").tag(Plan.free)
                        Text("Pro").tag(Plan.pro)
                    }
                    Button("Complete", style: .primary) {
                        try await createAccount(name: name, email: email, plan: plan)
                    }
                }
                .transition(.slide(.trailing))
            default:
                EmptyView()
            }
        }
    }
}
```

## File Uploads

```swift
struct AvatarUpload: View {
    @State var selectedFile: FileUpload?

    var body: some View {
        Form {
            FilePicker("Choose avatar", selection: $selectedFile)
                .accept(.images)
                .maxSize(.megabytes(5))

            if let file = selectedFile {
                Text("Selected: \(file.name)")
                Button("Upload", style: .primary) {
                    try await uploadAvatar(file: file)
                }
            }
        }
    }
}
```

File uploads work by:
1. The `FilePicker` renders an `<input type="file">`
2. When a file is selected, the client runtime uploads it to a server endpoint via HTTP (not WebSocket — binary data over WebSocket is inefficient)
3. The server receives the file and makes it available to the event handler
4. File metadata (name, size, type) is sent over WebSocket for immediate UI feedback
