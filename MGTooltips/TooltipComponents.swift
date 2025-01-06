//
//  TooltipComponents.swift
//  MGTooltips
//
//  Created by Moses Kh. on 01/12/2024.
//

import UIKit

public enum TooltipSide {
    case top
    case bottom
    case left
    case right
}

public struct TooltipItem {
    let target: Any
    let message: String
    let side: TooltipSide
    
    public init(target: Any, message: String, side: TooltipSide) {
        self.target = target
        self.message = message
        self.side = side
    }
}

/// Extension to safely access collection elements.
public extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

public enum TooltipButtonConfiguration {
    case none
    case nextOnly
    case nextAndPrevious
}
