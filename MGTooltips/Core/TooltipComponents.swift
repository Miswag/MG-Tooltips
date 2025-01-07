//
//  TooltipComponents.swift
//  MGTooltips
//
//  Created by Moses Kh. on 01/12/2024.
//

import UIKit

/// Represents the side from which the tooltip arrow should appear.
public enum TooltipSide {
    case top, bottom, left, right
}

/// Configuration options for the tooltip buttons.
public enum TooltipButtonConfiguration {
    case none
    case nextOnly
    case nextAndPrevious
}

/// Represents a single tooltip’s data: the target UI element, message, and positioning side.
public struct TooltipItem {
    /// The target can be a `UIView`, `UIBarButtonItem`, or `UITabBarItem`.
    public let target: Any
    /// The message displayed in the tooltip.
    public let message: String
    /// The side from which the tooltip arrow appears.
    public let side: TooltipSide
    
    /// Initializes a new `TooltipItem`.
    /// - Parameters:
    ///   - target: The UI element or bar item that the tooltip points to.
    ///   - message: The text to display in the tooltip.
    ///   - side: The side from which the arrow appears.
    public init(target: Any, message: String, side: TooltipSide) {
        self.target = target
        self.message = message
        self.side = side
    }
}
