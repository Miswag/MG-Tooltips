//
//  TooltipComponents.swift
//  MGTooltips
//
//  Created by Moses Kh. on 01/12/2024.
//

import UIKit

public enum TooltipSide {
    case top, bottom, left, right
}

public enum TooltipButtonConfiguration {
    case none
    case nextOnly
    case nextAndPrevious
}

/// Represents a single tooltip target, message, and position side.
public struct TooltipItem {
    public let target: Any      // can be UIView, UIBarButtonItem, UITabBarItem, etc.
    public let message: String
    public let side: TooltipSide
    
    public init(target: Any, message: String, side: TooltipSide) {
        self.target = target
        self.message = message
        self.side = side
    }
}
