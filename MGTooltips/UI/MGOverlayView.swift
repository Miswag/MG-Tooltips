//
//  MGOverlayView.swift
//  MGTooltips
//
//  Created by Moses Kh. on 01/12/2024.
//

import UIKit

/// A semi-transparent overlay with a "cutout" around the target area.
class MGOverlayView: UIView {
    
    private var cutoutRect: CGRect
    private var cornerRadius: CGFloat
    
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
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let path = UIBezierPath(rect: rect)
        let cutoutPath = UIBezierPath(
            roundedRect: cutoutRect,
            cornerRadius: cornerRadius
        )
        path.append(cutoutPath)
        path.usesEvenOddFillRule = true
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        maskLayer.fillColor = UIColor.black.cgColor
        
        layer.mask = maskLayer
    }
}
