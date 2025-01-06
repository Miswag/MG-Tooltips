//
//  Untitled.swift
//  MGTooltips
//
//  Created by Moses Kh. on 01/12/2024.
//

import UIKit

public class TooltipManager {
    
    public var tooltips: [TooltipItem] = []
    public var currentIndex = 0
    public var overlayView: UIView?
    public var tooltipView: TooltipView?
    public var snapshotView: UIView?
    
    var tooltipButtonConfg: TooltipButtonConfiguration = .nextAndPrevious
    public var onCompletion: (() -> Void)?
    
    // UserDefaults key to prevent repeated displays
    private var tooltipKey: String?
    
    var canTapScreen: Bool = false
    
    public init(tooltips: [TooltipItem]) {
        self.tooltips = tooltips
    }
    
    /// Configure the manager with a unique key.
    /// If this key has been shown before, the tooltips won't appear again.
    public func setKey(with key: String) {
        self.tooltipKey = key
    }
    
    public func configureTooltip(buttonConfig: TooltipButtonConfiguration, canTapScreen: Bool) {
        self.tooltipButtonConfg = buttonConfig
        self.canTapScreen = canTapScreen
    }
    
    public func start() {
        if let key = tooltipKey, UserDefaults.standard.bool(forKey: key) {
            onCompletion?()
            return
        }
        
        showTooltip(at: currentIndex)
    }
    
    public func clearTooltipViews() {
        overlayView?.gestureRecognizers?.forEach { overlayView?.removeGestureRecognizer($0) }
        overlayView?.removeFromSuperview()
        overlayView = nil
        
        tooltipView?.removeFromSuperview()
        tooltipView = nil
        
        snapshotView?.removeFromSuperview()
        snapshotView = nil
    }
    
    private func showTooltip(at index: Int) {
        guard index < tooltips.count else {
            finishSequence()
            return
        }
        
        let tooltip = tooltips[index]
        let target = tooltip.target
        
        var targetView: UIView?
        
        // Check target type and try to obtain a UIView reference
        if let view = target as? UIView {
            targetView = view
        } else if let item = target as? UIBarButtonItem,
                  let barButtonView = item.value(forKey: "view") as? UIView {
            targetView = barButtonView
        } else if let item = target as? UITabBarItem,
                  let tabBarController = UIApplication.shared.windows.first?.rootViewController as? UITabBarController,
                  let index = tabBarController.tabBar.items?.firstIndex(of: item),
                  let tabBarButton = tabBarController.tabBar.subviews[safe: index + 1] {
            targetView = tabBarButton
        }
        
        guard let targetView = targetView else {
            proceedToNextTooltip()
            return
        }
        
        guard let keyWindow = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else {
            proceedToNextTooltip()
            return
        }
        
        let targetFrame = targetView.convert(targetView.bounds, to: keyWindow)
        
        guard let snapshotView = targetView.snapshotView(afterScreenUpdates: false) else {
            proceedToNextTooltip()
            return
        }
        snapshotView.frame = targetFrame
        keyWindow.addSubview(snapshotView)
        self.snapshotView = snapshotView
        
        // Overlay
        let overlayView = OverlayView(frame: keyWindow.bounds, cutoutRect: targetFrame.insetBy(dx: -2, dy: -2))
        overlayView.alpha = 0
        keyWindow.addSubview(overlayView)
        self.overlayView = overlayView
        
        // Tooltip
        if canTapScreen {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
            overlayView.addGestureRecognizer(tapGesture)
        }
        
        let tooltipView = TooltipView(tooltipItem: tooltip, targetFrame: targetFrame, buttonConfig: tooltipButtonConfg)
        
        // Set button actions
        tooltipView.onPrevious = { [weak self] in
            self?.showPreviousTooltip()
        }
        tooltipView.onNext = { [weak self] in
            self?.showNextTooltip()
        }
        
        // Update buttons based on position
        let isFirst = currentIndex == 0
        let isLast = currentIndex == tooltips.count - 1
        tooltipView.updateButtons(isFirst: isFirst, isLast: isLast)
        
        tooltipView.present(in: keyWindow)
        self.tooltipView = tooltipView
        
        // Animate with smoother transitions
        UIView.animate(withDuration: 0.5, animations: {
            overlayView.alpha = 1
        })
    }
    
    @objc private func overlayTapped() {
        showNextTooltip()
    }
    
    public func showPreviousTooltip() {
        clearTooltipViews()
        currentIndex = max(0, currentIndex - 1)
        showTooltip(at: currentIndex)
    }
    
    public func showNextTooltip() {
        clearTooltipViews()
        currentIndex += 1
        if currentIndex < tooltips.count {
            showTooltip(at: currentIndex)
        } else {
            finishSequence()
        }
    }
    
    public func proceedToNextTooltip() {
        clearTooltipViews()
        currentIndex += 1
        if currentIndex < tooltips.count {
            showTooltip(at: currentIndex)
        } else {
            finishSequence()
        }
    }
    
    private func finishSequence() {
        // Mark the tooltip sequence as shown if there's a key
        if let key = tooltipKey {
            UserDefaults.standard.setValue(true, forKey: key)
        }
        
        onCompletion?()
    }
}
