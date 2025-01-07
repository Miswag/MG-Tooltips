//
//  MGTooltipView.swift
//  MGTooltips
//
//  Created by Moses Kh. on 01/12/2024.
//

import UIKit

/// The actual tooltip bubble containing the message, arrow, and optional buttons.
class MGTooltipView: UIView {
    
    // MARK: - Constants
    
    /// The minimum width for the tooltip bubble.
    /// - Note: Ensures that the tooltip does not shrink below this width for better readability.
    let widthMin: CGFloat = 160

    /// The maximum width for the tooltip bubble.
    /// - Note: Ensures that the tooltip does not exceed this width to maintain a consistent design and avoid overlapping other UI elements.
    let widthMax: CGFloat = 200
    
    /// The localized title for the "Next" button in the tooltip.
    /// - Note: This string is fetched from the `Localizable.strings` file in the framework bundle.
    let nextButtonTitle: String = NSLocalizedString("next.button", bundle: .frameworkBundle, comment: "Title for the 'Next' button in tooltips.")

    /// The localized title for the "Previous" button in the tooltip.
    /// - Note: This string is fetched from the `Localizable.strings` file in the framework bundle.
    let previousButtonTitle: String = NSLocalizedString("previous.button", bundle: .frameworkBundle, comment: "Title for the 'Previous' button in tooltips.")

    /// The localized title for the "Complete" button in the tooltip, displayed when on the last tooltip in the sequence.
    /// - Note: This string is fetched from the `Localizable.strings` file in the framework bundle.
    let completeButtonTitle: String = NSLocalizedString("complete.button", bundle: .frameworkBundle, comment: "Title for the 'Complete' button in tooltips, used for the final step.")

    // MARK: - UI Elements
    
    private let messageLabel = UILabel()
    private let contentView = UIView()
    private let arrowView = UIView()
    
    private let previousButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let buttonStackView = UIStackView()
    
    // MARK: - Callbacks
    
    /// Callback invoked when the 'previous' button is pressed.
    var onPrevious: (() -> Void)?
    
    /// Callback invoked when the 'next' or 'complete' button is pressed.
    var onNext: (() -> Void)?
    
    // MARK: - Constraints
    
    private var arrowCenterXConstraint: NSLayoutConstraint?
    private var arrowCenterYConstraint: NSLayoutConstraint?
    private var buttonStackCenterXConstraint: NSLayoutConstraint?
    private var buttonStackLeadingConstraint: NSLayoutConstraint?
    
    // MARK: - Tooltip Data
    
    private let side: TooltipSide
    private let targetFrame: CGRect
    private var referenceView: UIView?
    
    // MARK: - Appearance/Manager
    
    /// The manager also conforms to `MGTooltipAppearance` to provide styling properties.
    private weak var manager: (MGTooltipAppearance & AnyObject)?
    
    // MARK: - State
    
    private var isFirst = true
    private var isLast = false
    
    // MARK: - Initialization
    
    /// Creates a new MGTooltipView.
    /// - Parameters:
    ///   - tooltipItem: The data (message, side, etc.) for this tooltip.
    ///   - targetFrame: The frame of the target in the parent window.
    ///   - manager: Conforms to `MGTooltipAppearance` for styling.
    init(
        tooltipItem: TooltipItem,
        targetFrame: CGRect,
        manager: MGTooltipAppearance & AnyObject
    ) {
        self.side = tooltipItem.side
        self.targetFrame = targetFrame
        self.manager = manager
        super.init(frame: .zero)
        
        messageLabel.text = tooltipItem.message
        setupView() // sets up subviews and constraints
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    /// Sets up all subviews and constraints. Does not modify layout logic.
    private func setupView() {
        setupMessageLabel()
        setupContentView()
        setupArrowView()
        setupButtons()
        setupButtonStackView()
        layoutUI()
        drawArrow()
    }
    
    private func setupMessageLabel() {
        guard let appearance = manager else { return }
        messageLabel.numberOfLines = 0
        messageLabel.font = appearance.font
        messageLabel.textColor = appearance.textColor
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupContentView() {
        guard let appearance = manager else { return }
        contentView.backgroundColor = appearance.backgroundColor
        contentView.layer.cornerRadius = appearance.tooltipCornerRadius
        contentView.layer.masksToBounds = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupArrowView() {
        arrowView.backgroundColor = .clear
        arrowView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupButtons() {
        guard let appearance = manager else { return }
        
        // Apply common button styling
        [previousButton, nextButton].forEach {
            configureCommonButtonStyles($0, appearance: appearance)
        }
        
        // Configure the 'previous' button
        configurePreviousButton(appearance)
        
        // Configure the 'next' button
        configureNextButton(appearance)
    }
    
    /// Applies shared styles to all tooltip buttons (previous/next).
    private func configureCommonButtonStyles(_ button: UIButton, appearance: MGTooltipAppearance) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = appearance.buttonFont
        button.layer.cornerRadius = appearance.buttonCornerRadius
        button.layer.masksToBounds = true
        button.layer.borderColor = appearance.buttonBorderColor.cgColor
        button.layer.borderWidth = appearance.buttonBorderWidth
        button.widthAnchor.constraint(equalToConstant: 70).isActive = true
        button.heightAnchor.constraint(equalToConstant: 25).isActive = true
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    }
    
    /// Configures the 'previous' button style and title.
    private func configurePreviousButton(_ appearance: MGTooltipAppearance) {
        previousButton.setTitle(previousButtonTitle, for: .normal)
        previousButton.setTitleColor(appearance.buttonBorderColor, for: .normal)
        previousButton.backgroundColor = .clear
    }
    
    /// Configures the 'next' button style and title.
    private func configureNextButton(_ appearance: MGTooltipAppearance) {
        nextButton.setTitle(nextButtonTitle, for: .normal)
        nextButton.setTitleColor(appearance.buttonTextColor, for: .normal)
        nextButton.backgroundColor = appearance.buttonBackgroundColor
    }
    
    private func setupButtonStackView() {
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 5
        buttonStackView.distribution = .fillEqually
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.addArrangedSubview(previousButton)
        buttonStackView.addArrangedSubview(nextButton)
    }
    
    // MARK: - Layout
    
    /// Sets up the tooltip layout constraints. **No logic changes**, just refactoring for clarity.
    private func layoutUI() {
        guard let manager = manager else { return }
        
        contentView.addSubview(messageLabel)
        
        // Only add the stack view if config is not `.none`.
        if manager.buttonConfiguration != .none {
            contentView.addSubview(buttonStackView)
        }
        
        addSubview(contentView)
        addSubview(arrowView)
        
        // Label constraints
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        ])
        
        // Button stack constraints if needed
        if manager.buttonConfiguration != .none {
            buttonStackLeadingConstraint = buttonStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 12
            )
            buttonStackCenterXConstraint = buttonStackView.centerXAnchor.constraint(
                equalTo: contentView.centerXAnchor
            )
            
            NSLayoutConstraint.activate([
                buttonStackView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8),
                buttonStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
                buttonStackCenterXConstraint!
            ])
        } else {
            NSLayoutConstraint.activate([
                messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
            ])
        }
        
        // Depending on side, set up vertical or horizontal layout.
        switch side {
        case .top, .bottom:
            setupVerticalLayout()
            arrowCenterXConstraint = arrowView.centerXAnchor.constraint(equalTo: centerXAnchor)
            arrowCenterXConstraint?.isActive = true
            
        case .left, .right:
            setupHorizontalLayout()
            arrowCenterYConstraint = arrowView.centerYAnchor.constraint(equalTo: centerYAnchor)
            arrowCenterYConstraint?.isActive = true
        }
    }
    
    private func setupVerticalLayout() {
        guard let appearance = manager else { return }
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            arrowView.widthAnchor.constraint(equalToConstant: appearance.arrowSize.width),
            arrowView.heightAnchor.constraint(equalToConstant: appearance.arrowSize.height),
            
            contentView.widthAnchor.constraint(greaterThanOrEqualToConstant: widthMin),
            contentView.widthAnchor.constraint(lessThanOrEqualToConstant: widthMax)
        ])
        
        // Top vs. bottom constraints
        if side == .top {
            NSLayoutConstraint.activate([
                contentView.topAnchor.constraint(equalTo: topAnchor),
                arrowView.topAnchor.constraint(equalTo: contentView.bottomAnchor),
                arrowView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        } else {
            // bottom
            NSLayoutConstraint.activate([
                arrowView.topAnchor.constraint(equalTo: topAnchor),
                contentView.topAnchor.constraint(equalTo: arrowView.bottomAnchor),
                contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
    }
    
    private func setupHorizontalLayout() {
        guard let appearance = manager else { return }
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            arrowView.widthAnchor.constraint(equalToConstant: appearance.arrowSize.height),
            arrowView.heightAnchor.constraint(equalToConstant: appearance.arrowSize.width),
            
            contentView.widthAnchor.constraint(greaterThanOrEqualToConstant: widthMin),
            contentView.widthAnchor.constraint(lessThanOrEqualToConstant: widthMax)
        ])
        
        // Left vs. right constraints
        if side == .left {
            NSLayoutConstraint.activate([
                contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                arrowView.leadingAnchor.constraint(equalTo: contentView.trailingAnchor),
                arrowView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        } else {
            // right
            NSLayoutConstraint.activate([
                arrowView.leadingAnchor.constraint(equalTo: leadingAnchor),
                contentView.leadingAnchor.constraint(equalTo: arrowView.trailingAnchor),
                contentView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        }
    }
    
    // MARK: - Drawing Arrow
    
    /// Draws the arrow shape based on the `side` and the arrow size.
    private func drawArrow() {
        guard let appearance = manager else { return }
        let arrowW = appearance.arrowSize.width
        let arrowH = appearance.arrowSize.height
        
        let path = UIBezierPath()
        
        switch side {
        case .top:
            path.move(to: .zero)
            path.addLine(to: CGPoint(x: arrowW / 2, y: arrowH))
            path.addLine(to: CGPoint(x: arrowW, y: 0))
        case .bottom:
            path.move(to: CGPoint(x: 0, y: arrowH))
            path.addLine(to: CGPoint(x: arrowW / 2, y: 0))
            path.addLine(to: CGPoint(x: arrowW, y: arrowH))
        case .left:
            path.move(to: .zero)
            path.addLine(to: CGPoint(x: arrowH, y: arrowW / 2))
            path.addLine(to: CGPoint(x: 0, y: arrowW))
        case .right:
            path.move(to: CGPoint(x: arrowH, y: 0))
            path.addLine(to: CGPoint(x: 0, y: arrowW / 2))
            path.addLine(to: CGPoint(x: arrowH, y: arrowW))
        }
        path.close()
        
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.fillColor = appearance.backgroundColor.cgColor
        
        arrowView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        arrowView.layer.addSublayer(shape)
    }
    
    // MARK: - Adjust Arrow Position
    
    /// Adjusts the arrow's center based on the target frame to prevent it from going out of bounds.
    private func adjustArrowPosition() {
        guard let appearance = manager else { return }
        
        let tooltipFrame = frame
        
        switch side {
        case .top, .bottom:
            let targetMidX = targetFrame.midX
            let tooltipMinX = tooltipFrame.minX
            var arrowCenterX = targetMidX - tooltipMinX
            let halfWidth = appearance.arrowSize.width / 2
            
            // Keep the arrow within the tooltip’s horizontal bounds.
            let minX = halfWidth + 8
            let maxX = tooltipFrame.width - halfWidth - 8
            arrowCenterX = max(minX, min(arrowCenterX, maxX))
            
            arrowCenterXConstraint?.constant = arrowCenterX - (tooltipFrame.width / 2)
            
        case .left, .right:
            let targetMidY = targetFrame.midY
            let tooltipMinY = tooltipFrame.minY
            var arrowCenterY = targetMidY - tooltipMinY
            let halfHeight = appearance.arrowSize.width / 2
            
            // Keep the arrow within the tooltip’s vertical bounds.
            let minY = halfHeight + 8
            let maxY = tooltipFrame.height - halfHeight - 8
            arrowCenterY = max(minY, min(arrowCenterY, maxY))
            
            arrowCenterYConstraint?.constant = arrowCenterY - (tooltipFrame.height / 2)
        }
        
        layoutIfNeeded()
    }
    
    // MARK: - Public
    
    /// Presents the tooltip in the specified parent view, anchoring it to `targetFrame`.
    /// - Parameter parentView: The view in which the tooltip will be shown.
    public func present(in parentView: UIView) {
        parentView.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        
        // Create a reference view placed exactly at targetFrame.
        let refView = UIView(frame: .zero)
        refView.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(refView)
        self.referenceView = refView
        
        NSLayoutConstraint.activate([
            refView.leftAnchor.constraint(equalTo: parentView.leftAnchor, constant: targetFrame.origin.x),
            refView.topAnchor.constraint(equalTo: parentView.topAnchor, constant: targetFrame.origin.y),
            refView.widthAnchor.constraint(equalToConstant: targetFrame.size.width),
            refView.heightAnchor.constraint(equalToConstant: targetFrame.size.height)
        ])
        
        // Standard padding around the tooltip, ensuring it fits within `parentView`.
        let padding: CGFloat = 8
        var constraints: [NSLayoutConstraint] = []
        
        switch side {
        case .top:
            constraints.append(bottomAnchor.constraint(equalTo: refView.topAnchor, constant: -padding))
            let centerX = centerXAnchor.constraint(equalTo: refView.centerXAnchor)
            centerX.priority = .defaultHigh
            constraints.append(centerX)
            
        case .bottom:
            constraints.append(topAnchor.constraint(equalTo: refView.bottomAnchor, constant: padding))
            let centerX = centerXAnchor.constraint(equalTo: refView.centerXAnchor)
            centerX.priority = .defaultHigh
            constraints.append(centerX)
            
        case .left:
            constraints.append(rightAnchor.constraint(equalTo: refView.leftAnchor, constant: -padding))
            let centerY = centerYAnchor.constraint(equalTo: refView.centerYAnchor)
            centerY.priority = .defaultHigh
            constraints.append(centerY)
            
        case .right:
            constraints.append(leftAnchor.constraint(equalTo: refView.rightAnchor, constant: padding))
            let centerY = centerYAnchor.constraint(equalTo: refView.centerYAnchor)
            centerY.priority = .defaultHigh
            constraints.append(centerY)
        }
        
        // Clamp the tooltip within parentView’s bounds.
        constraints += [
            leftAnchor.constraint(greaterThanOrEqualTo: parentView.leftAnchor, constant: padding),
            rightAnchor.constraint(lessThanOrEqualTo: parentView.rightAnchor, constant: -padding),
            topAnchor.constraint(greaterThanOrEqualTo: parentView.topAnchor, constant: padding),
            bottomAnchor.constraint(lessThanOrEqualTo: parentView.bottomAnchor, constant: -padding)
        ]
        
        NSLayoutConstraint.activate(constraints)
        parentView.layoutIfNeeded()
        
        // Adjust arrow position after final layout.
        adjustArrowPosition()
        
        // Animate the tooltip in.
        animateIn()
    }
    
    /// Updates the display of the previous/next/complete buttons based on the tooltip’s position in the sequence.
    /// - Parameters:
    ///   - isFirst: True if this is the first tooltip in the sequence.
    ///   - isLast: True if this is the last tooltip in the sequence.
    public func updateButtons(isFirst: Bool, isLast: Bool) {
        self.isFirst = isFirst
        self.isLast = isLast
        
        guard let appearance = manager else { return }
        let config = appearance.buttonConfiguration
        
        switch config {
        case .none:
            previousButton.isHidden = true
            nextButton.isHidden = true
            
        case .nextOnly:
            previousButton.isHidden = true
            nextButton.setTitle(getNextButtonText(isLast: isLast), for: .normal)
            
        case .nextAndPrevious:
            previousButton.isHidden = isFirst
            nextButton.setTitle(getNextButtonText(isLast: isLast), for: .normal)
        }
        
        updateButtonStack()
    }
    
    // MARK: - Private
    
    /// Returns the appropriate text for the next button, whether "Complete" or "Next".
    private func getNextButtonText(isLast: Bool) -> String {
        return isLast ? completeButtonTitle : nextButtonTitle
    }
    
    /// Applies final layout rules for the button stack (leading or center alignment).
    private func updateButtonStack() {
        guard let appearance = manager else { return }
        let config = appearance.buttonConfiguration
        
        previousButton.isHidden = (config != .nextAndPrevious) || isFirst
        nextButton.setTitle(getNextButtonText(isLast: isLast), for: .normal)
        
        // Deactivate both constraints before choosing one.
        buttonStackLeadingConstraint?.isActive = false
        buttonStackCenterXConstraint?.isActive = false
        
        // If previous is hidden, align next button to the leading edge; otherwise center them.
        if previousButton.isHidden {
            buttonStackLeadingConstraint?.isActive = true
            buttonStackView.alignment = .leading
            buttonStackView.distribution = .fill
        } else {
            buttonStackCenterXConstraint?.isActive = true
            buttonStackView.alignment = .fill
            buttonStackView.distribution = .fillEqually
        }
    }
    
    /// Handles button taps for previous/next/complete actions.
    @objc private func buttonTapped(_ sender: UIButton) {
        if sender == previousButton {
            onPrevious?()
        } else if sender == nextButton {
            onNext?()
        }
    }
    
    /// Animates the tooltip’s appearance.
    private func animateIn() {
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options: [.curveEaseOut],
            animations: {
                self.alpha = 1
                self.transform = .identity
            },
            completion: nil
        )
    }
    
    public override func removeFromSuperview() {
        super.removeFromSuperview()
        referenceView?.removeFromSuperview()
        referenceView = nil
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        // Update corner radius dynamically if changed.
        guard let appearance = manager else { return }
        contentView.layer.cornerRadius = appearance.tooltipCornerRadius
    }
}
