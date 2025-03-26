//
//  MGTooltipAppearance.swift
//  MGTooltips
//
//  Created by Miswag on 06/01/2025.
//

import UIKit

/// Defines the contract for how a tooltip should appear (fonts, colors, corner radii, etc.).
/// - Note: Conformance to this protocol ensures you can read styling properties
///   for the tooltip's appearance without exposing direct mutations.
protocol MGTooltipAppearance {
    
    // MARK: - General Appearance
    
    /// The primary font used for tooltip text.
    var font: UIFont { get }
    
    /// The primary text color of the tooltip message.
    var textColor: UIColor { get }
    
    /// The background color of the tooltip bubble.
    var backgroundColor: UIColor { get }
    
    /// The corner radius of the tooltip bubble.
    var tooltipCornerRadius: CGFloat { get }
    
    /// The size of the tooltip arrow.
    var arrowSize: CGSize { get }
    
    // MARK: - Button Appearance
    
    /// The font used for previous/next/complete buttons.
    var buttonFont: UIFont { get }
    
    /// The corner radius for the tooltip buttons.
    var buttonCornerRadius: CGFloat { get }
    
    /// The text color for the tooltip buttons.
    var buttonTextColor: UIColor { get }
    
    /// The background color of the tooltip buttons.
    var buttonBackgroundColor: UIColor { get }
    
    /// The border color for the tooltip buttons.
    var buttonBorderColor: UIColor { get }
    
    /// The border width for the tooltip buttons.
    var buttonBorderWidth: CGFloat { get }
    
    // MARK: - Button Configuration
    
    /// The configuration of the tooltip buttons (none, nextOnly, or nextAndPrevious).
    var buttonConfiguration: TooltipButtonConfiguration { get }
    
    /// Determines whether the overlay should cut out the target view area.
    /// When true, the target view will be visible through the overlay.
    /// When false, the overlay will cover the entire screen without a cutout.
    var shouldCutTarget: Bool { get }
    
    // Custom titles for buttons
    var nextButtonTitle: String { get }
    var previousButtonTitle: String { get }
    var completeButtonTitle: String { get }
    
}
