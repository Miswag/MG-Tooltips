//
//  Untitled 2.swift
//  MGTooltips
//
//  Created by Moses Kh. on 01/12/2024.
//

import UIKit

public class TooltipView: UIView {
    
    // MARK: - Properties
    
    public let messageLabel = UILabel()
    public let arrowSize = CGSize(width: 16, height: 8)
    public let side: TooltipSide
    public let targetFrame: CGRect
    
    public let contentView = UIView()
    public let arrowView = UIView()
    public var referenceView: UIView?
    
    public let previousButton = UIButton(type: .system)
    public let nextButton = UIButton(type: .system)
    public let buttonStackView = UIStackView()
    
    var onPrevious: (() -> Void)?
    var onNext: (() -> Void)?
    
    public var arrowCenterXConstraint: NSLayoutConstraint?
    public var arrowCenterYConstraint: NSLayoutConstraint?
    
    public var minimumWidthConstraint: NSLayoutConstraint?
    public var maximumWidthConstraint: NSLayoutConstraint?
    
    public let buttonConfig: TooltipButtonConfiguration
    
    public var isFirst = true
    public var isLast = false
    
    public var buttonStackCenterXConstraint: NSLayoutConstraint?
    public var buttonStackLeadingConstraint: NSLayoutConstraint?
    
    // MARK: - Initializers
    
    public init(tooltipItem: TooltipItem, targetFrame: CGRect, buttonConfig: TooltipButtonConfiguration) {
        self.side = tooltipItem.side
        self.targetFrame = targetFrame
        self.buttonConfig = buttonConfig
        super.init(frame: .zero)
        self.messageLabel.text = tooltipItem.message
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupView() {
        setupMessageLabel()
        setupContentView()
        setupArrowView()
        configureButtons()
        setupButtonStackView()
        addSubviews()
        setupConstraints()
        drawArrow()
    }
    
    private func setupMessageLabel() {
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.textColor = .label
        messageLabel.textAlignment = .natural
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupContentView() {
        contentView.backgroundColor = .white
        contentView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupArrowView() {
        arrowView.backgroundColor = .clear
        arrowView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureButtons() {
        [previousButton, nextButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            $0.layer.cornerRadius = 12.5
            $0.layer.masksToBounds = true
            $0.widthAnchor.constraint(equalToConstant: 70).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 25).isActive = true
            $0.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
        
        previousButton.setTitle("tooltip.previous", for: .normal)
        previousButton.setTitleColor(.label, for: .normal)
        previousButton.layer.borderColor = UIColor.black.cgColor
        previousButton.layer.borderWidth = 1
        previousButton.backgroundColor = .clear
        
        nextButton.setTitle("tooltip.next", for: .normal)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.backgroundColor = .black
    }
    
    private func setupButtonStackView() {
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 5
        buttonStackView.distribution = .fillEqually
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.addArrangedSubview(previousButton)
        buttonStackView.addArrangedSubview(nextButton)
    }
    
    private func addSubviews() {
        contentView.addSubview(messageLabel)
        if buttonConfig != .none {
            contentView.addSubview(buttonStackView)
        }
        addSubview(contentView)
        addSubview(arrowView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
        ])
        
        if buttonConfig != .none {
            buttonStackLeadingConstraint = buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)
            buttonStackCenterXConstraint = buttonStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
            
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
        
        // Constraints for contentView and arrowView
        setupConstraintsForSide()
    }
    
    private func setupConstraintsForSide() {
        switch side {
        case .top, .bottom:
            setWidthConstraints(minWidth: 160, maxWidth: 200, priority: .required)
            setupVerticalConstraints()
            arrowCenterXConstraint = arrowView.centerXAnchor.constraint(equalTo: centerXAnchor)
            arrowCenterXConstraint?.isActive = true
        case .left, .right:
            setWidthConstraints(minWidth: 160, maxWidth: 200, priority: UILayoutPriority(750))
            setupHorizontalConstraints()
            arrowCenterYConstraint = arrowView.centerYAnchor.constraint(equalTo: centerYAnchor)
            arrowCenterYConstraint?.isActive = true
        }
    }
    
    private func setWidthConstraints(minWidth: CGFloat, maxWidth: CGFloat, priority: UILayoutPriority) {
        minimumWidthConstraint = contentView.widthAnchor.constraint(greaterThanOrEqualToConstant: minWidth)
        minimumWidthConstraint?.isActive = true
        
        maximumWidthConstraint = contentView.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth)
        maximumWidthConstraint?.isActive = true
    }
    
    private func setupVerticalConstraints() {
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            arrowView.widthAnchor.constraint(equalToConstant: arrowSize.width),
            arrowView.heightAnchor.constraint(equalToConstant: arrowSize.height)
        ])
        
        if side == .top {
            NSLayoutConstraint.activate([
                contentView.topAnchor.constraint(equalTo: topAnchor),
                arrowView.topAnchor.constraint(equalTo: contentView.bottomAnchor),
                arrowView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        } else { // .bottom
            NSLayoutConstraint.activate([
                arrowView.topAnchor.constraint(equalTo: topAnchor),
                contentView.topAnchor.constraint(equalTo: arrowView.bottomAnchor),
                contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
    }
    
    private func setupHorizontalConstraints() {
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            arrowView.widthAnchor.constraint(equalToConstant: arrowSize.height),
            arrowView.heightAnchor.constraint(equalToConstant: arrowSize.width)
        ])
        
        if side == .left {
            NSLayoutConstraint.activate([
                contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                arrowView.leadingAnchor.constraint(equalTo: contentView.trailingAnchor),
                arrowView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        } else { // .right
            NSLayoutConstraint.activate([
                arrowView.leadingAnchor.constraint(equalTo: leadingAnchor),
                contentView.leadingAnchor.constraint(equalTo: arrowView.trailingAnchor),
                contentView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        }
    }
    
    private func drawArrow() {
        let path = UIBezierPath()
        let arrowPoints = getArrowPoints(for: side)
        path.move(to: arrowPoints[0])
        path.addLine(to: arrowPoints[1])
        path.addLine(to: arrowPoints[2])
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = contentView.backgroundColor?.cgColor
        
        arrowView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        arrowView.layer.addSublayer(shapeLayer)
    }
    
    private func getArrowPoints(for side: TooltipSide) -> [CGPoint] {
        switch side {
        case .top:
            return [
                CGPoint(x: 0, y: 0),
                CGPoint(x: arrowSize.width / 2, y: arrowSize.height),
                CGPoint(x: arrowSize.width, y: 0)
            ]
        case .bottom:
            return [
                CGPoint(x: 0, y: arrowSize.height),
                CGPoint(x: arrowSize.width / 2, y: 0),
                CGPoint(x: arrowSize.width, y: arrowSize.height)
            ]
        case .left:
            return [
                CGPoint(x: 0, y: 0),
                CGPoint(x: arrowSize.height, y: arrowSize.width / 2),
                CGPoint(x: 0, y: arrowSize.width)
            ]
        case .right:
            return [
                CGPoint(x: arrowSize.height, y: 0),
                CGPoint(x: 0, y: arrowSize.width / 2),
                CGPoint(x: arrowSize.height, y: arrowSize.width)
            ]
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        buttonStackView.axis = .horizontal
        contentView.layer.cornerRadius = contentView.frame.height * 0.10
        contentView.layer.masksToBounds = true
        layoutIfNeeded()
    }
    
    private func adjustArrowPosition() {
        let tooltipFrame = self.frame
        switch side {
        case .top, .bottom:
            let targetMidX = targetFrame.midX
            let tooltipMinX = tooltipFrame.minX
            var arrowCenterX = targetMidX - tooltipMinX
            let arrowHalfWidth = arrowSize.width / 2
            let minX = arrowHalfWidth + 8
            let maxX = tooltipFrame.width - arrowHalfWidth - 8
            arrowCenterX = max(minX, min(arrowCenterX, maxX))
            arrowCenterXConstraint?.constant = arrowCenterX - tooltipFrame.width / 2
            
        case .left, .right:
            let targetMidY = targetFrame.midY
            let tooltipMinY = tooltipFrame.minY
            var arrowCenterY = targetMidY - tooltipMinY
            let arrowHalfHeight = arrowSize.width / 2
            let minY = arrowHalfHeight + 8
            let maxY = tooltipFrame.height - arrowHalfHeight - 8
            arrowCenterY = max(minY, min(arrowCenterY, maxY))
            arrowCenterYConstraint?.constant = arrowCenterY - tooltipFrame.height / 2
        }
        
        layoutIfNeeded()
    }
    
    func present(in parentView: UIView) {
        parentView.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        
        let referenceView = UIView()
        referenceView.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(referenceView)
        self.referenceView = referenceView
        
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
        
        // Adjust arrow position after layout
        adjustArrowPosition()
        
        // Animate in
        animateIn()
    }
    
    public override func removeFromSuperview() {
        super.removeFromSuperview()
        referenceView?.removeFromSuperview()
        referenceView = nil
    }
    
    func updateButtons(isFirst: Bool, isLast: Bool) {
        self.isFirst = isFirst
        self.isLast = isLast
        
        switch buttonConfig {
        case .none:
            previousButton.isHidden = true
            nextButton.isHidden = true
        case .nextOnly:
            previousButton.isHidden = true
            nextButton.setTitle(isLast ? "tooltip.complete" : "tooltip.next", for: .normal)
        case .nextAndPrevious:
            previousButton.isHidden = isFirst
            nextButton.setTitle(isLast ? "tooltip.complete" : "tooltip.next", for: .normal)
        }
        updateButtonStack()
    }
    
    private func updateButtonStack() {
        previousButton.isHidden = (buttonConfig != .nextAndPrevious) || isFirst
        nextButton.setTitle(isLast ? "tooltip.complete" : "tooltip.next", for: .normal)
        
        buttonStackLeadingConstraint?.isActive = false
        buttonStackCenterXConstraint?.isActive = false
        
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
    
    @objc private func buttonTapped(_ sender: UIButton) {
        if sender == previousButton {
            onPrevious?()
        } else if sender == nextButton {
            onNext?()
        }
    }
    
    // MARK: - Animations
    
    func animateIn() {
        self.alpha = 0
        self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        
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
}
