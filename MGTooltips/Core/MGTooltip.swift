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
    // (All styling properties stored here directly)

    public var font: UIFont = .systemFont(ofSize: 14)
    public var textColor: UIColor = .label
    public var backgroundColor: UIColor = .white
    public var tooltipCornerRadius: CGFloat = 8
    public var arrowSize: CGSize = CGSize(width: 16, height: 8)
    
    public var buttonFont: UIFont = .systemFont(ofSize: 12)
    public var buttonCornerRadius: CGFloat = 12.5
    public var buttonTextColor: UIColor = .white
    public var buttonBackgroundColor: UIColor = .black
    public var buttonBorderColor: UIColor = .black
    public var buttonBorderWidth: CGFloat = 1
    
    // MARK: - Behavior & Configuration

    public var canTapScreenToDismiss: Bool = false
    public var overlayColor: UIColor = .black
    public var overlayOpacity: CGFloat = 0.5
    public var buttonConfiguration: TooltipButtonConfiguration = .nextAndPrevious
    
    // MARK: - Delegate
    
    /// Use this to get notified about lifecycle events like start, show, dismiss, complete.
    public weak var delegate: MGTooltipDelegate?
    
    // MARK: - Sequence Management
    
    private var tooltips: [TooltipItem] = []
    private var currentIndex: Int = 0
    
    // MARK: - UI References
    
    private var overlayView: MGOverlayView?
    private var tooltipView: MGTooltipView?
    private var snapshotView: UIView?
    
    // MARK: - UserDefaults Key
    
    private var tooltipKey: String?
    
    // MARK: - Init
    
    /// Initialize the tooltip manager with an optional userDefaults key.
    /// - Parameter key: If provided, once tooltips have been shown,
    ///                  we set a boolean in UserDefaults to skip next time.
    public init(key: String? = nil) {
        self.tooltipKey = key
    }
    
    // MARK: - Public Methods
    
    /// Append a single tooltip to the list.
    public func appendTooltip(_ item: TooltipItem) {
        tooltips.append(item)
    }
    
    /// Append multiple tooltips at once.
    public func appendTooltips(_ items: [TooltipItem]) {
        tooltips.append(contentsOf: items)
    }
    
    /// Start showing the tooltips from the beginning.
    public func start() {
        // If the tooltip list is empty, consider that 'completed' immediately.
        guard !tooltips.isEmpty else {
            delegate?.tooltipsDidCompleted()
            return
        }
        
        // If previously shown (via userDefaults), also skip and mark complete.
        if let key = tooltipKey, UserDefaults.standard.bool(forKey: key) {
            delegate?.tooltipsDidCompleted()
            return
        }
        
        // Reset current index and notify delegate that we are starting.
        currentIndex = 0
        delegate?.tooltipsDidStarted()
        
        // Begin by showing the first tooltip.
        showTooltip(at: currentIndex)
    }
    
    /// Immediately clear any visible tooltip and overlay.
    public func clearTooltipViews() {
        // If we are in the middle of the sequence,
        // we are effectively dismissing a tooltip at `currentIndex`.
        if currentIndex < tooltips.count {
            let item = tooltips[currentIndex]
            // Mark that the currently visible tooltip was dismissed.
            delegate?.tooltipDidDismissed(at: currentIndex, item: item)
        }
        
        // Remove overlay, tooltip view, snapshot from superview
        overlayView?.removeFromSuperview()
        overlayView = nil
        
        tooltipView?.removeFromSuperview()
        tooltipView = nil
        
        snapshotView?.removeFromSuperview()
        snapshotView = nil
    }
    
    // MARK: - Private Methods
    
    /// Show the tooltip at a given index in the sequence.
    private func showTooltip(at index: Int) {
        // If index is out of range, we've finished the sequence
        guard index < tooltips.count else {
            finishSequence()
            return
        }
        
        let item = tooltips[index]
        
        // 1. Resolve target
        guard let targetView = resolveTargetView(from: item.target) else {
            // If we fail to get a valid target, skip to the next tooltip.
            proceedToNextTooltip()
            return
        }
        
        // 2. Find key window
        guard let keyWindow = getKeyWindow() else {
            // If no valid window, skip
            proceedToNextTooltip()
            return
        }
        
        // 3. Convert target frame
        let targetFrame = targetView.convert(targetView.bounds, to: keyWindow)
        
        // 4. Create a snapshot so overlay can cut it out
        guard let snapshot = createSnapshot(for: targetView, frame: targetFrame) else {
            proceedToNextTooltip()
            return
        }
        keyWindow.addSubview(snapshot)
        self.snapshotView = snapshot
        
        // 5. Create the overlay
        let overlay = createOverlay(in: keyWindow, cutoutRect: targetFrame.insetBy(dx: -2, dy: -2))
        keyWindow.addSubview(overlay)
        overlay.alpha = 0
        self.overlayView = overlay
        
        // 6. If tap is allowed, add gesture
        if canTapScreenToDismiss {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
            overlay.addGestureRecognizer(tapGesture)
        }
        
        // 7. Create the tooltip bubble
        let tooltip = MGTooltipView(tooltipItem: item, targetFrame: targetFrame, manager: self)
        tooltip.onPrevious = { [weak self] in self?.showPreviousTooltip() }
        tooltip.onNext = { [weak self] in self?.showNextTooltip() }
        
        // 8. Update button states
        let isFirst = (currentIndex == 0)
        let isLast = (currentIndex == tooltips.count - 1)
        tooltip.updateButtons(isFirst: isFirst, isLast: isLast)
        
        // 9. Present the tooltip in the keyWindow
        tooltip.present(in: keyWindow)
        self.tooltipView = tooltip
        
        // 10. Animate overlay fade-in
        UIView.animate(withDuration: 0.5) {
            overlay.alpha = 1
        }
        
        // 11. Let the delegate know a tooltip was shown
        delegate?.tooltipDidShowed(at: index, item: item)
    }
    
    @objc private func overlayTapped() {
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
        // If there's a userDefaults key, mark as shown
        if let key = tooltipKey {
            UserDefaults.standard.setValue(true, forKey: key)
        }
        
        // All tooltips are done or skipped
        delegate?.tooltipsDidCompleted()
    }
    
    // MARK: - Helpers
    
    /// Extract a UIView from a target object (UIView, UIBarButtonItem, UITabBarItem, etc.).
    private func resolveTargetView(from target: Any) -> UIView? {
        if let view = target as? UIView {
            return view
        }
        
        if let barItem = target as? UIBarButtonItem,
           let barButtonView = barItem.value(forKey: "view") as? UIView {
            return barButtonView
        }
        
        if let tabBarItem = target as? UITabBarItem {
            // In practice, you'd find the matching UITabBarController, etc.
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
    
    /// Safely get the key window.
    private func getKeyWindow() -> UIWindow? {
        return UIApplication.shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })
    }
    
    /// Create a snapshot for highlighting the target.
    private func createSnapshot(for targetView: UIView, frame: CGRect) -> UIView? {
        guard let snapshot = targetView.snapshotView(afterScreenUpdates: false) else { return nil }
        snapshot.frame = frame
        return snapshot
    }
    
    /// Create the overlay view.
    private func createOverlay(in parent: UIView, cutoutRect: CGRect) -> MGOverlayView {
        let overlay = MGOverlayView(
            frame: parent.bounds,
            cutoutRect: cutoutRect,
            overlayColor: overlayColor,
            overlayOpacity: overlayOpacity,
            cornerRadius: 8
        )
        return overlay
    }
}
