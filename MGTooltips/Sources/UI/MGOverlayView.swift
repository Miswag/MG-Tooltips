//
//  MGOverlayView.swift
//  MGTooltips
//
//  Created by Moses Kh. on 01/12/2024.
//

import UIKit

/// A semi-transparent overlay with a "cutout" around the specified target area.
class MGOverlayView: UIView {
    
    // MARK: - Properties
    
    private var cutoutRect: CGRect
    private var cornerRadius: CGFloat
    
    // MARK: - Initialization
    
    /// Initializes a new overlay view used to dim the background while highlighting a specific rectangle.
    /// - Parameters:
    ///   - frame: The frame of this overlay (usually the entire screen).
    ///   - cutoutRect: The rectangle that should remain transparent.
    ///   - overlayColor: The primary overlay color (commonly .black or .label).
    ///   - overlayOpacity: The opacity for the overlay color.
    ///   - cornerRadius: The corner radius for the cutout rectangle.
    init(
        frame: CGRect,
        cutoutRect: CGRect,
        overlayColor: UIColor,
        overlayOpacity: CGFloat,
        cornerRadius: CGFloat
    ) {
        self.cutoutRect = cutoutRect
        self.cornerRadius = cornerRadius
        super.init(frame: frame)
        
        backgroundColor = overlayColor.withAlphaComponent(overlayOpacity)
        isOpaque = false
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    // MARK: - Drawing
    
    /// Draws a rectangular path and appends a smaller cutout path, using the even-odd fill rule to create a transparent area.
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let path = UIBezierPath(rect: rect)
        let cutoutPath = UIBezierPath(roundedRect: cutoutRect, cornerRadius: cornerRadius)
        path.append(cutoutPath)
        path.usesEvenOddFillRule = true
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        maskLayer.fillColor = UIColor.black.cgColor
        
        layer.mask = maskLayer
    }
}
