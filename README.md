# MGTooltips

[![Swift Version](https://img.shields.io/badge/swift-5.0-orange)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-iOS-orange)](https://developer.apple.com/ios/)
[![UIKit](https://img.shields.io/badge/UIKit-compatible-orange)](https://developer.apple.com/documentation/uikit)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen)](https://swift.org/package-manager/)
[![Version](https://img.shields.io/badge/version-1.3.0-blue)](https://github.com/miswag/mgtooltips/releases)
[![License](https://img.shields.io/badge/license-MIT-blue)](https://opensource.org/licenses/MIT)

**MGTooltips** is a lightweight, customizable tooltip system for iOS, designed to guide users through app workflows with ease. It supports flexible configurations, seamless animations, and a developer-friendly API.

## 📱 Demo 

https://github.com/user-attachments/assets/8d1cdcc6-e403-494f-b3f3-a0f11b98a3ed

## ✨ Features

- **Customizable Appearance**: Adjust colors, fonts, corner radius, and arrow sizes to match your app's theme.
- **Directional Control**: Display tooltips in any direction: top, bottom, left, or right.
- **Step-by-Step Navigation**: Built-in support for previous, next, and completion buttons.
- **Target Highlighting**: Highlight the UI elements being explained to focus the user's attention.
- **Dynamic Arrow Positioning**: Smart arrow positioning to avoid overlapping UI elements.
- **Localization Support**: Fully localized button titles using String Catalogs `Localizable.xcstrings`. We welcome community contributions for additional language support! If you'd like to help translate MGTooltips into your language, please open a pull request or issue.
- **Animation Support**: Smooth appearance and disappearance animations.
- **SPM**: Easy integration into your project.  

---

## 📥 Installation

### Swift Package Manager
1. Open your Xcode project.
2. Go to **File** > **Add Packages...**.
3. Enter this repo's URL in the search field.
4. Select the package and confirm to add it to your project.

**Or just add the following line to your `Package.swift` file:**

```swift
dependencies: [
    .package(url: "https://github.com/miswag/mgtooltips.git", from: "1.3.0")
]
```

### Manual Installation (Including Demo)
1. Clone the repository::
```ruby
  git clone https://github.com/miswag/mgtooltips.git
```
2. Drag and drop the MGTooltips folder from the cloned repository into your Xcode project.
3. Ensure the MGTooltips module is included in your target's Build Phases under Compile Sources.
4. To explore the demo:
   - Open the MGTooltips.xcodeproj file from the cloned repository.
   - Build and run the demo to see the full capabilities of the tooltip system.

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

// Control overlay behavior
tooltipManager.shouldCutTarget = false // Disable cutout in overlay
tooltipManager.canTapScreenToDismiss = true // Allow tapping anywhere to proceed
tooltipManager.overlayOpacity = 0.7 // Adjust the opacity of the overlay
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
> [!TIP]
> Fork the repository, and create a feature branch.

## 📄 License

MGTooltips is available under the MIT license. See the LICENSE file for more info.

## 👨‍💻 Author

- 🔗 **LinkedIn**: [@Mosa Khaldun](https://linkedin.com/in/mosakh)  
- ✉️ **Email**: mosa.khaldun@miswag.com

## Support

If you're having any problem, please [raise an issue](https://github.com/miswag/mgtooltips/issues/new) on GitHub.
