//
//  MGTooltipAppearance.swift
//  MGTooltips
//
//  Created by Miswag on 06/01/2025.
//

import UIKit

/// Defines the contract for how a tooltip should appear (fonts, colors, corner radii, etc.).
 protocol MGTooltipAppearance {
    var font: UIFont { get }
    var textColor: UIColor { get }
    var backgroundColor: UIColor { get }
    var tooltipCornerRadius: CGFloat { get }
    var arrowSize: CGSize { get }
    
    // Button appearance
    var buttonFont: UIFont { get }
    var buttonCornerRadius: CGFloat { get }
    var buttonTextColor: UIColor { get }
    var buttonBackgroundColor: UIColor { get }
    var buttonBorderColor: UIColor { get }
    var buttonBorderWidth: CGFloat { get }
    
    // Button configuration
    var buttonConfiguration: TooltipButtonConfiguration { get }
}
