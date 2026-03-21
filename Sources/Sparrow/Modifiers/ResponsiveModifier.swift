public enum DeviceCategory: Sendable {
    case phone, tablet, desktop
}

public struct HiddenOnDeviceModifier: ViewModifier, Sendable {
    public let device: DeviceCategory

    public var cssClasses: [String] {
        switch device {
        case .phone: ["hidden-phone"]
        case .tablet: ["hidden-tablet"]
        case .desktop: ["hidden-desktop"]
        }
    }
}

extension View {
    public func hidden(on device: DeviceCategory) -> ModifiedView<Self, HiddenOnDeviceModifier> {
        modifier(HiddenOnDeviceModifier(device: device))
    }
}

public struct VisibleOnDeviceModifier: ViewModifier, Sendable {
    public let device: DeviceCategory

    public var cssClasses: [String] {
        switch device {
        case .phone: ["visible-phone-only"]
        case .tablet: ["visible-tablet-only"]
        case .desktop: ["visible-desktop-only"]
        }
    }
}

extension View {
    public func visible(on device: DeviceCategory) -> ModifiedView<Self, VisibleOnDeviceModifier> {
        modifier(VisibleOnDeviceModifier(device: device))
    }
}
