//
//  MGTooltipView.swift
//  MGTooltips
//
//  Created by Moses Kh. on 01/12/2024.
//

import UIKit

/// The actual tooltip bubble with arrow, message label, optional buttons, etc.
class MGTooltipView: UIView {
    
    // MARK: - UI Elements
    
    private let messageLabel = UILabel()
    private let contentView = UIView()
    private let arrowView = UIView()
    
    private let previousButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let buttonStackView = UIStackView()
    
    // Callbacks
    var onPrevious: (() -> Void)?
    var onNext: (() -> Void)?
    
    // Constraints
    private var arrowCenterXConstraint: NSLayoutConstraint?
    private var arrowCenterYConstraint: NSLayoutConstraint?
    private var buttonStackCenterXConstraint: NSLayoutConstraint?
    private var buttonStackLeadingConstraint: NSLayoutConstraint?
    
    let widthMin: CGFloat = 160
    let widthMax: CGFloat = 200
    
    // Tooltip data
    private let side: TooltipSide
    private let targetFrame: CGRect
    private var referenceView: UIView?
    
    // Appearance/Manager
    /// Note: We cast the manager as `MGTooltipAppearance & AnyObject` so we can read the styling (including button config).
    private weak var manager: (MGTooltipAppearance & AnyObject)?
    
    // State
    private var isFirst = true
    private var isLast = false
    
    // MARK: - Init
    
    init(tooltipItem: TooltipItem, targetFrame: CGRect, manager: MGTooltipAppearance & AnyObject) {
        self.side = tooltipItem.side
        self.targetFrame = targetFrame
        self.manager = manager
        super.init(frame: .zero)
        
        messageLabel.text = tooltipItem.message
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
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
        
        // Common button styling
        [previousButton, nextButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.titleLabel?.font = appearance.buttonFont
            $0.layer.cornerRadius = appearance.buttonCornerRadius
            $0.layer.masksToBounds = true
            $0.layer.borderColor = appearance.buttonBorderColor.cgColor
            $0.layer.borderWidth = appearance.buttonBorderWidth
            $0.widthAnchor.constraint(equalToConstant: 70).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 25).isActive = true
            $0.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
        
        // Previous
        previousButton.setTitle("previous.button".localized(), for: .normal)
        previousButton.setTitleColor(appearance.buttonBorderColor, for: .normal)
        previousButton.backgroundColor = .clear
        
        // Next
        nextButton.setTitle("next.button".localized(), for: .normal)
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
    
    // MARK: - Layout (Unchanged)
    
    private func layoutUI() {
        contentView.addSubview(messageLabel)
        
        if manager?.buttonConfiguration != TooltipButtonConfiguration.none {
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
        
        if manager?.buttonConfiguration != TooltipButtonConfiguration.none {
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
        
        if side == .top {
            NSLayoutConstraint.activate([
                contentView.topAnchor.constraint(equalTo: topAnchor),
                arrowView.topAnchor.constraint(equalTo: contentView.bottomAnchor),
                arrowView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        } else { // bottom
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
        
        if side == .left {
            NSLayoutConstraint.activate([
                contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                arrowView.leadingAnchor.constraint(equalTo: contentView.trailingAnchor),
                arrowView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        } else { // right
            NSLayoutConstraint.activate([
                arrowView.leadingAnchor.constraint(equalTo: leadingAnchor),
                contentView.leadingAnchor.constraint(equalTo: arrowView.trailingAnchor),
                contentView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        }
    }
    
    // MARK: - Drawing Arrow
    
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
    
    // MARK: - Adjust Arrow Position (unchanged)
    
    private func adjustArrowPosition() {
        guard let appearance = manager else { return }
        let tooltipFrame = frame
        
        switch side {
        case .top, .bottom:
            let targetMidX = targetFrame.midX
            let tooltipMinX = tooltipFrame.minX
            var arrowCenterX = targetMidX - tooltipMinX
            let halfWidth = appearance.arrowSize.width / 2
            let minX = halfWidth + 8
            let maxX = tooltipFrame.width - halfWidth - 8
            arrowCenterX = max(minX, min(arrowCenterX, maxX))
            arrowCenterXConstraint?.constant = arrowCenterX - tooltipFrame.width / 2
            
        case .left, .right:
            let targetMidY = targetFrame.midY
            let tooltipMinY = tooltipFrame.minY
            var arrowCenterY = targetMidY - tooltipMinY
            let halfHeight = appearance.arrowSize.width / 2
            let minY = halfHeight + 8
            let maxY = tooltipFrame.height - halfHeight - 8
            arrowCenterY = max(minY, min(arrowCenterY, maxY))
            arrowCenterYConstraint?.constant = arrowCenterY - tooltipFrame.height / 2
        }
        
        layoutIfNeeded()
    }
    
    // MARK: - Public
    
    public func present(in parentView: UIView) {
        // EXACT original logic from your snippet
        parentView.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        
        // Create a reference view placed exactly where targetFrame is
        let referenceView = UIView()
        referenceView.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(referenceView)
        self.referenceView = referenceView
        
        // Position the referenceView at targetFrame
        NSLayoutConstraint.activate([
            referenceView.leftAnchor.constraint(equalTo: parentView.leftAnchor, constant: targetFrame.origin.x),
            referenceView.topAnchor.constraint(equalTo: parentView.topAnchor, constant: targetFrame.origin.y),
            referenceView.widthAnchor.constraint(equalToConstant: targetFrame.size.width),
            referenceView.heightAnchor.constraint(equalToConstant: targetFrame.size.height)
        ])
        
        let padding: CGFloat = 8
        var constraints: [NSLayoutConstraint] = []
        
        switch side {
        case .top:
            constraints.append(bottomAnchor.constraint(equalTo: referenceView.topAnchor, constant: -padding))
            let centerXConstraint = centerXAnchor.constraint(equalTo: referenceView.centerXAnchor)
            centerXConstraint.priority = .defaultHigh
            constraints.append(centerXConstraint)
        case .bottom:
            constraints.append(topAnchor.constraint(equalTo: referenceView.bottomAnchor, constant: padding))
            let centerXConstraint = centerXAnchor.constraint(equalTo: referenceView.centerXAnchor)
            centerXConstraint.priority = .defaultHigh
            constraints.append(centerXConstraint)
        case .left:
            constraints.append(trailingAnchor.constraint(equalTo: referenceView.leftAnchor, constant: -padding))
            let centerYConstraint = centerYAnchor.constraint(equalTo: referenceView.centerYAnchor)
            centerYConstraint.priority = .defaultHigh
            constraints.append(centerYConstraint)
        case .right:
            constraints.append(leadingAnchor.constraint(equalTo: referenceView.rightAnchor, constant: padding))
            let centerYConstraint = centerYAnchor.constraint(equalTo: referenceView.centerYAnchor)
            centerYConstraint.priority = .defaultHigh
            constraints.append(centerYConstraint)
        }
        
        constraints += [
            leftAnchor.constraint(greaterThanOrEqualTo: parentView.leftAnchor, constant: padding),
            rightAnchor.constraint(lessThanOrEqualTo: parentView.rightAnchor, constant: -padding),
            topAnchor.constraint(greaterThanOrEqualTo: parentView.topAnchor, constant: padding),
            bottomAnchor.constraint(lessThanOrEqualTo: parentView.bottomAnchor, constant: -padding)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        parentView.layoutIfNeeded()
        
        // Adjust arrow position once final frame is known
        adjustArrowPosition()
        
        // Animate the tooltip in
        animateIn()
    }
    
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
            nextButton.setTitle(isLast ? "complete.button".localized() : "next.button".localized(), for: .normal)
        case .nextAndPrevious:
            previousButton.isHidden = isFirst
            nextButton.setTitle(isLast ? "complete.button".localized() : "next.button".localized(), for: .normal)
        }
        
        updateButtonStack()
    }
    
    // MARK: - Private
    
    private func updateButtonStack() {
        guard let appearance = manager else { return }
        let config = appearance.buttonConfiguration
        
        previousButton.isHidden = (config != .nextAndPrevious) || isFirst
        nextButton.setTitle(isLast ? "complete.button".localized() : "next.button".localized(), for: .normal)
        
        buttonStackLeadingConstraint?.isActive = false
        buttonStackCenterXConstraint?.isActive = false
        
        if previousButton.isHidden {
            // Only next button visible
            buttonStackLeadingConstraint?.isActive = true
            buttonStackView.alignment = .leading
            buttonStackView.distribution = .fill
        } else {
            // Both next & previous
            buttonStackCenterXConstraint?.isActive = true
            buttonStackView.alignment = .fill
            buttonStackView.distribution = .fillEqually
        }
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        if sender == previousButton {
            onPrevious?()
        } else if sender == nextButton {
            onNext?()
        }
    }
    
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
        
        // Update corner radius if changed dynamically
        guard let appearance = manager else { return }
        contentView.layer.cornerRadius = appearance.tooltipCornerRadius
    }
}
