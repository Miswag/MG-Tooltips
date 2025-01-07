//
//  MGTooltip.swift
//  MGTooltips
//
//  Created by Moses Kh. on 01/12/2024.
//

import UIKit

/// Main manager that orchestrates displaying a series of tooltips.
public class MGTooltip: MGTooltipAppearance {
    
    // MARK: - Conformance to MGTooltipAppearance
    
    public var font: UIFont = .systemFont(ofSize: 14)
    public var textColor: UIColor = .black
    public var backgroundColor: UIColor = .white
    public var tooltipCornerRadius: CGFloat = 8
    public var arrowSize: CGSize = CGSize(width: 16, height: 8)
    
    public var buttonFont: UIFont = .systemFont(ofSize: 12)
    public var buttonCornerRadius: CGFloat = 12.5
    public var buttonTextColor: UIColor = .white
    public var buttonBackgroundColor: UIColor = .black
    public var buttonBorderColor: UIColor = UIColor.black
    public var buttonBorderWidth: CGFloat = 1
    
    public var canTapScreenToDismiss: Bool = false
    public var overlayColor: UIColor = .label
    public var overlayOpacity: CGFloat = 0.5
    public var buttonConfiguration: TooltipButtonConfiguration = .nextAndPrevious
    
    // MARK: - Delegate
    
    /// The `MGTooltipDelegate` for receiving tooltip lifecycle events.
    public weak var delegate: MGTooltipDelegate?
    
    // MARK: - Internal Data
    
    private var tooltips: [TooltipItem] = []
    private var currentIndex: Int = 0
    
    // Overlay & Tooltip references
    private var overlayView: MGOverlayView?
    private var tooltipView: MGTooltipView?
    private var snapshotView: UIView?
    
    // For optional one-time display
    private var tooltipKey: String?
    
    // MARK: - Initialization
    
    /// Initialize the tooltip manager with an optional userDefaults key.
    /// If the key has been used before, the tooltips will not display again.
    /// - Parameter key: A unique key to identify if tooltips have been shown.
    public init(key: String? = nil) {
        self.tooltipKey = key
    }
    
    // MARK: - Public Methods
    
    /// Appends a single tooltip item to the sequence.
    public func appendTooltip(_ item: TooltipItem) {
        tooltips.append(item)
    }
    
    /// Appends multiple tooltip items to the sequence.
    public func appendTooltips(_ items: [TooltipItem]) {
        tooltips.append(contentsOf: items)
    }
    
    /// Starts the tooltip display sequence from the first item.
    public func start() {
        // If there are no tooltips, end the sequence.
        guard !tooltips.isEmpty else {
            delegate?.tooltipsDidCompleted()
            return
        }
        
        // Check if tooltips were already shown previously.
        if let key = tooltipKey, UserDefaults.standard.bool(forKey: key) {
            delegate?.tooltipsDidCompleted()
            return
        }
        
        // Begin the sequence.
        currentIndex = 0
        delegate?.tooltipsDidStarted()
        showTooltip(at: currentIndex)
    }
    
    /// Clears any visible tooltip and overlay immediately.
    public func clearTooltipViews() {
        // If we have a tooltip currently active, mark it as dismissed.
        if currentIndex < tooltips.count {
            let item = tooltips[currentIndex]
            delegate?.tooltipDidDismissed(at: currentIndex, item: item)
        }
        
        // Remove references & subviews.
        overlayView?.removeFromSuperview()
        overlayView = nil
        
        tooltipView?.removeFromSuperview()
        tooltipView = nil
        
        snapshotView?.removeFromSuperview()
        snapshotView = nil
    }
    
    // MARK: - Private Methods
    
    /// Shows the tooltip at the specified index in the sequence.
    private func showTooltip(at index: Int) {
        guard index < tooltips.count else {
            finishSequence()
            return
        }
        
        let tooltipItem = tooltips[index]
        
        // 1. Resolve the target view.
        guard let targetView = resolveTargetView(from: tooltipItem.target) else {
            proceedToNextTooltip()
            return
        }
        
        // 2. Retrieve the key window.
        guard let keyWindow = getKeyWindow() else {
            proceedToNextTooltip()
            return
        }
        
        // 3. Calculate target frame relative to the key window.
        let targetFrame = targetView.convert(targetView.bounds, to: keyWindow)
        
        // 4. Create a snapshot for highlighting the target.
        guard let snapshot = createSnapshot(for: targetView, frame: targetFrame) else {
            proceedToNextTooltip()
            return
        }
        keyWindow.addSubview(snapshot)
        self.snapshotView = snapshot
        
        // 5. Create the overlay with a cutout around the target frame.
        //    Increase/decrease the inset if you want a bigger highlight region.
        let overlay = createOverlay(in: keyWindow, cutoutRect: targetFrame.insetBy(dx: -4, dy: -4))
        keyWindow.addSubview(overlay)
        overlay.alpha = 0
        self.overlayView = overlay
        
        // 6. Optionally, allow screen taps to dismiss or move to the next tooltip.
        if canTapScreenToDismiss {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
            overlay.addGestureRecognizer(tapGesture)
        }
        
        // 7. Create the actual tooltip view.
        let tooltipView = MGTooltipView(tooltipItem: tooltipItem, targetFrame: targetFrame, manager: self)
        tooltipView.onPrevious = { [weak self] in
            self?.showPreviousTooltip()
        }
        tooltipView.onNext = { [weak self] in
            self?.showNextTooltip()
        }
        
        // 8. Update button states (first or last in the sequence).
        let isFirst = (index == 0)
        let isLast = (index == tooltips.count - 1)
        tooltipView.updateButtons(isFirst: isFirst, isLast: isLast)
        
        // 9. Present the tooltip view in the key window.
        tooltipView.present(in: keyWindow)
        self.tooltipView = tooltipView
        
        // 10. Animate the overlay fade-in.
        UIView.animate(withDuration: 0.5) {
            overlay.alpha = 1
        }
        
        // 11. Notify the delegate that a tooltip was shown.
        delegate?.tooltipDidShowed(at: index, item: tooltipItem)
    }
    
    @objc private func overlayTapped() {
        // Move to the next tooltip on screen tap.
        showNextTooltip()
    }
    
    private func showPreviousTooltip() {
        clearTooltipViews()
        currentIndex = max(0, currentIndex - 1)
        showTooltip(at: currentIndex)
    }
    
    private func showNextTooltip() {
        clearTooltipViews()
        currentIndex += 1
        if currentIndex < tooltips.count {
            showTooltip(at: currentIndex)
        } else {
            finishSequence()
        }
    }
    
    private func proceedToNextTooltip() {
        clearTooltipViews()
        currentIndex += 1
        if currentIndex < tooltips.count {
            showTooltip(at: currentIndex)
        } else {
            finishSequence()
        }
    }
    
    private func finishSequence() {
        // Mark as shown if there's a userDefaults key.
        if let key = tooltipKey {
            UserDefaults.standard.setValue(true, forKey: key)
        }
        delegate?.tooltipsDidCompleted()
    }
    
    // MARK: - Helper Functions
    
    /// Attempts to resolve the target into a UIView.
    /// - Parameter target: A UIView, UIBarButtonItem, or UITabBarItem.
    /// - Returns: The corresponding UIView, or `nil` if it cannot be found.
    private func resolveTargetView(from target: Any) -> UIView? {
        if let view = target as? UIView {
            return view
        }
        
        if let barItem = target as? UIBarButtonItem,
           let barButtonView = barItem.value(forKey: "view") as? UIView {
            return barButtonView
        }
        
        if let tabBarItem = target as? UITabBarItem {
            // Attempt to find the matching UITabBarController & subview.
            if let tabBarController = UIApplication.shared
                .connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .compactMap({ $0.rootViewController })
                .compactMap({ $0 as? UITabBarController })
                .first,
               let items = tabBarController.tabBar.items,
               let index = items.firstIndex(of: tabBarItem),
               index + 1 < tabBarController.tabBar.subviews.count {
                let tabBarButton = tabBarController.tabBar.subviews[index + 1]
                return tabBarButton
            }
        }
        
        return nil
    }
    
    /// Retrieves the current key window.
    private func getKeyWindow() -> UIWindow? {
        return UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
    
    /// Creates a snapshot of the target view for highlighting.
    private func createSnapshot(for targetView: UIView, frame: CGRect) -> UIView? {
        guard let snapshot = targetView.snapshotView(afterScreenUpdates: false) else { return nil }
        snapshot.frame = frame
        return snapshot
    }
    
    /// Creates a semi-transparent overlay with a cutout around `cutoutRect`.
    private func createOverlay(in parent: UIView, cutoutRect: CGRect) -> MGOverlayView {
        let overlay = MGOverlayView(
            frame: parent.bounds,
            cutoutRect: cutoutRect,
            overlayColor: overlayColor,
            overlayOpacity: overlayOpacity,
            cornerRadius: 5
        )
        return overlay
    }
}
