//
//  MGTooltipDelegate.swift
//  MGTooltips
//
//  Created by Miswag on 06/01/2025.
//

import UIKit

/// Delegate to track or modify the tooltip lifecycle.
public protocol MGTooltipDelegate: AnyObject {
    /// Called once, right after `start()` is invoked and before showing the first tooltip.
    func tooltipsDidStarted()
    
    /// Called right after the tooltip at `index` is shown.
    /// - Parameters:
    ///   - index: The index of the current tooltip in the sequence.
    ///   - item: The `TooltipItem` that was shown.
    func tooltipDidShowed(at index: Int, item: TooltipItem)
    
    /// Called right after the tooltip at `index` is dismissed.
    /// - Parameters:
    ///   - index: The index of the current tooltip in the sequence.
    ///   - item: The `TooltipItem` that was dismissed.
    func tooltipDidDismissed(at index: Int, item: TooltipItem)
    
    /// Called once all tooltips in the sequence have finished or were skipped.
    func tooltipsDidCompleted()
}
