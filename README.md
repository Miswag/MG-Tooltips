# MGTooltips

[![Swift Version](https://img.shields.io/badge/swift-5.0-orange)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-iOS-orange)](https://developer.apple.com/ios/)
[![UIKit](https://img.shields.io/badge/UIKit-compatible-orange)](https://developer.apple.com/documentation/uikit)
[![CocoaPods](https://img.shields.io/cocoapods/v/MGTooltips)](https://cocoapods.org/pods/MGTooltips)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/license-MIT-blue)](https://opensource.org/licenses/MIT)

**MGTooltips** is a lightweight, customizable tooltip system for iOS, designed to guide users through app workflows with ease. It supports flexible configurations, seamless animations, and a developer-friendly API.

## ✨ Features

- **Customizable Appearance**: Adjust colors, fonts, corner radius, and arrow sizes to match your app's theme.
- **Directional Control**: Display tooltips in any direction: top, bottom, left, or right.
- **Step-by-Step Navigation**: Built-in support for previous, next, and completion buttons.
- **Target Highlighting**: Highlight the UI elements being explained to focus the user's attention.
- **Dynamic Arrow Positioning**: Smart arrow positioning to avoid overlapping UI elements.
- **Localization Support**: Fully localized button titles using String Catalogs `Localizable.xcstrings`. We welcome community contributions for additional language support! If you'd like to help translate MGTooltips into your language, please open a pull request or issue.
- **Animation Support**: Smooth appearance and disappearance animations.
- **SPM & CocoaPods**: Easy integration into your project.  

---

## 📥 Installation

### Swift Package Manager
1. Open your Xcode project.
2. Go to **File** > **Add Packages...**.
3. Enter this repo’s URL in the search field.
4. Select the package and confirm to add it to your project.

**Or just add the following line to your `Package.swift` file:**

```swift
dependencies: [
    .package(url: "https://github.com/miswag/mgtooltips.git", from: "1.0.0")
]
```

### CocoaPods

1. Add the following to your Podfile:

```ruby
pod 'MGTooltips', '~> 1.0.1'
```

2. Then, run the following command::
```ruby
pod install
```

## 🚀 Quick Start

```swift
import MGTooltips

// Create tooltip manager
let menuTooltips = MGTooltip()

// Create tooltip items
let tooltip1 = TooltipItem(
    target: buttonView,
    message: "Tap here to start",
    side: .top
)

let tooltip2 = TooltipItem(
    target: tableView,
    message: "Your content appears here",
    side: .bottom
)

// Add tooltips to manager
menuTooltips.appendTooltips([tooltip1, tooltip2])

// Start the sequence
menuTooltips.start()
```

## ⚙️ Customization

### Appearance

```swift
let tooltipManager = MGTooltip()

// Customize colors
tooltipManager.backgroundColor = .systemBackground
tooltipManager.textColor = .label
tooltipManager.buttonBackgroundColor = .systemBlue

// Customize sizes
tooltipManager.tooltipCornerRadius = 8
tooltipManager.arrowSize = CGSize(width: 16, height: 8)

// Customize fonts
tooltipManager.font = .systemFont(ofSize: 14)
tooltipManager.buttonFont = .systemFont(ofSize: 12, weight: .medium)
```

### Button Configuration

```swift
// Choose button configuration
tooltipManager.buttonConfiguration = .nextAndPrevious  // .none, .nextOnly

// Customize button appearance
tooltipManager.buttonCornerRadius = 12.5
tooltipManager.buttonBorderWidth = 1
tooltipManager.buttonBorderColor = .systemBlue
```

### Delegate Methods

```swift
extension ViewController: MGTooltipDelegate {
    func tooltipsDidStarted() {
        print("Tutorial started")
    }
    
    func tooltipDidShowed(at index: Int, item: TooltipItem) {
        print("Showing tooltip \(index)")
    }
    
    func tooltipDidDismissed(at index: Int, item: TooltipItem) {
        print("Dismissed tooltip \(index)")
    }
    
    func tooltipsDidCompleted() {
        print("Tutorial completed")
    }
}
```

## 🔄 One-Time Display

To show tooltips only once:

```swift
// Initialize with a unique key
let launchTooltips = MGTooltip(key: "firstLaunchTutorial")
```

## 📋 Requirements

- iOS 13.0+
- Swift 5.0+
- Xcode 13.0+

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

MGTooltips is available under the MIT license. See the LICENSE file for more info.

## 👨‍💻 Author

- 🔗 **LinkedIn**: [@Mosa Khaldun](https://linkedin.com/in/mosakh)  
- ✉️ **Email**: mosa.khaldun98@gmail.com

## Support

If you're having any problem, please [raise an issue](https://github.com/miswag/mgtooltips/issues/new) on GitHub.
