// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Assets {
    internal static let _01leftTabBar = ImageAsset(name: "01leftTabBar")
    internal static let _02rightTabBar = ImageAsset(name: "02rightTabBar")
    internal static let _03onboardingBlue = ImageAsset(name: "03onboardingBlue")
    internal static let _04onboardingRed = ImageAsset(name: "04onboardingRed")
    internal static let _05placeholderTracker = ImageAsset(name: "05placeholderTracker")
    internal static let _06plus = ImageAsset(name: "06plus")
    internal static let _07Logo = ImageAsset(name: "07Logo")
    internal static let _08plusWhite = ImageAsset(name: "08plusWhite")
    internal static let _08plusWhite1 = ImageAsset(name: "08plusWhite1")
    internal static let _09cellBorder = ImageAsset(name: "09cellBorder")
    internal static let _10chevron = ImageAsset(name: "10chevron")
    internal static let _11done = ImageAsset(name: "11done")
    internal static let _12placeholderNoStatistic = ImageAsset(name: "12placeholderNoStatistic")
    internal static let _13placeholderNoResult = ImageAsset(name: "13placeholderNoResult")
    internal static let _14checkmark = ImageAsset(name: "14checkmark")
    internal static let _15pin = ImageAsset(name: "15pin")
    internal static let _16decrement = ImageAsset(name: "16decrement")
    internal static let _17increment = ImageAsset(name: "17increment")
    internal static let accentColor = ColorAsset(name: "AccentColor")
  }
  internal enum Colors {
    internal static let color0 = ColorAsset(name: "color0")
    internal static let color1 = ColorAsset(name: "color1")
    internal static let color10 = ColorAsset(name: "color10")
    internal static let color11 = ColorAsset(name: "color11")
    internal static let color12 = ColorAsset(name: "color12")
    internal static let color13 = ColorAsset(name: "color13")
    internal static let color14 = ColorAsset(name: "color14")
    internal static let color15 = ColorAsset(name: "color15")
    internal static let color16 = ColorAsset(name: "color16")
    internal static let color17 = ColorAsset(name: "color17")
    internal static let color2 = ColorAsset(name: "color2")
    internal static let color3 = ColorAsset(name: "color3")
    internal static let color4 = ColorAsset(name: "color4")
    internal static let color5 = ColorAsset(name: "color5")
    internal static let color6 = ColorAsset(name: "color6")
    internal static let color7 = ColorAsset(name: "color7")
    internal static let color8 = ColorAsset(name: "color8")
    internal static let color9 = ColorAsset(name: "color9")
    internal static let myBackground = ColorAsset(name: "myBackground")
    internal static let myBlack = ColorAsset(name: "myBlack")
    internal static let myBlue = ColorAsset(name: "myBlue")
    internal static let myCellBorderColor = ColorAsset(name: "myCellBorderColor")
    internal static let myCreateButtonColorLocked = ColorAsset(name: "myCreateButtonColorLocked")
    internal static let myDatePickerBackground = ColorAsset(name: "myDatePickerBackground")
    internal static let myGray = ColorAsset(name: "myGray")
    internal static let myLightGrey = ColorAsset(name: "myLightGrey")
    internal static let myRed = ColorAsset(name: "myRed")
    internal static let myTranspatent = ColorAsset(name: "myTranspatent")
    internal static let myWhite = ColorAsset(name: "myWhite")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal private(set) lazy var swiftUIColor: SwiftUI.Color = {
    SwiftUI.Color(asset: self)
  }()
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Color {
  init(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
