public enum TextContentType: Sendable {
    case username, password, email, name, givenName, familyName
    case nickname, telephone, address, city, state, postalCode
    case country, creditCardNumber, oneTimeCode, url, newPassword

    var autocompleteValue: String {
        switch self {
        case .username: "username"
        case .password: "current-password"
        case .email: "email"
        case .name: "name"
        case .givenName: "given-name"
        case .familyName: "family-name"
        case .nickname: "nickname"
        case .telephone: "tel"
        case .address: "street-address"
        case .city: "address-level2"
        case .state: "address-level1"
        case .postalCode: "postal-code"
        case .country: "country-name"
        case .creditCardNumber: "cc-number"
        case .oneTimeCode: "one-time-code"
        case .url: "url"
        case .newPassword: "new-password"
        }
    }
}

public struct TextContentTypeModifier: ViewModifier, Sendable {
    public let type: TextContentType
    public var htmlAttributes: [String: String] { ["autocomplete": type.autocompleteValue] }
}

extension View {
    public func textContentType(_ type: TextContentType) -> ModifiedView<Self, TextContentTypeModifier> {
        modifier(TextContentTypeModifier(type: type))
    }
}

public enum TextAutocapitalization: Sendable {
    case none, words, sentences, characters

    var htmlValue: String {
        switch self {
        case .none: "none"
        case .words: "words"
        case .sentences: "sentences"
        case .characters: "characters"
        }
    }
}

public struct AutocapitalizationModifier: ViewModifier, Sendable {
    public let style: TextAutocapitalization
    public var htmlAttributes: [String: String] { ["autocapitalize": style.htmlValue] }
}

extension View {
    public func textInputAutocapitalization(_ capitalization: TextAutocapitalization) -> ModifiedView<Self, AutocapitalizationModifier> {
        modifier(AutocapitalizationModifier(style: capitalization))
    }
}

public struct AutocorrectionModifier: ViewModifier, Sendable {
    public let disable: Bool
    public var htmlAttributes: [String: String] { ["autocorrect": disable ? "off" : "on"] }
}

extension View {
    public func disableAutocorrection(_ disable: Bool = true) -> ModifiedView<Self, AutocorrectionModifier> {
        modifier(AutocorrectionModifier(disable: disable))
    }

    public func autocorrectionDisabled(_ disabled: Bool = true) -> ModifiedView<Self, AutocorrectionModifier> {
        modifier(AutocorrectionModifier(disable: disabled))
    }
}

public enum SubmitLabel: Sendable {
    case done, go, join, next, returnKey, search, send, continueAction

    var enterkeyhintValue: String {
        switch self {
        case .done: "done"
        case .go: "go"
        case .join: "join"
        case .next: "next"
        case .returnKey: "enter"
        case .search: "search"
        case .send: "send"
        case .continueAction: "next"
        }
    }
}

public struct SubmitLabelModifier: ViewModifier, Sendable {
    public let label: SubmitLabel
    public var htmlAttributes: [String: String] { ["enterkeyhint": label.enterkeyhintValue] }
}

extension View {
    public func submitLabel(_ label: SubmitLabel) -> ModifiedView<Self, SubmitLabelModifier> {
        modifier(SubmitLabelModifier(label: label))
    }
}

public enum KeyboardType: Sendable {
    case `default`, asciiCapable, numbersAndPunctuation, url
    case numberPad, phonePad, emailAddress, decimalPad
    case twitter, webSearch

    var inputmodeValue: String {
        switch self {
        case .default: "text"
        case .asciiCapable: "text"
        case .numbersAndPunctuation: "text"
        case .url: "url"
        case .numberPad: "numeric"
        case .phonePad: "tel"
        case .emailAddress: "email"
        case .decimalPad: "decimal"
        case .twitter: "text"
        case .webSearch: "search"
        }
    }
}

public struct KeyboardTypeModifier: ViewModifier, Sendable {
    public let type: KeyboardType
    public var htmlAttributes: [String: String] { ["inputmode": type.inputmodeValue] }
}

extension View {
    public func keyboardType(_ type: KeyboardType) -> ModifiedView<Self, KeyboardTypeModifier> {
        modifier(KeyboardTypeModifier(type: type))
    }
}

public enum TextFieldStyle: Sendable {
    case automatic, plain, roundedBorder

    var cssClass: String {
        switch self {
        case .automatic: "input"
        case .plain: "input-plain"
        case .roundedBorder: "input-rounded"
        }
    }
}

public struct TextFieldStyleModifier: ViewModifier, Sendable {
    public let style: TextFieldStyle
    public var cssClasses: [String] { [style.cssClass] }
}

extension View {
    public func textFieldStyle(_ style: TextFieldStyle) -> ModifiedView<Self, TextFieldStyleModifier> {
        modifier(TextFieldStyleModifier(style: style))
    }
}
