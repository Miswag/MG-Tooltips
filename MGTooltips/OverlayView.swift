//
//  OverlayView.swift
//  MGTooltips
//
//  Created by Moses Kh. on 01/12/2024.
//

import UIKit

class OverlayView: UIView {
    private var cutoutRect: CGRect
    
    init(frame: CGRect, cutoutRect: CGRect) {
        self.cutoutRect = cutoutRect
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    private func setupView() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        isOpaque = false
        isUserInteractionEnabled = true
        createMaskLayer()
    }
    
    private func createMaskLayer() {
        let path = UIBezierPath(rect: bounds)
        let cutoutPath = UIBezierPath(roundedRect: cutoutRect, cornerRadius: 8)
        path.append(cutoutPath)
        path.usesEvenOddFillRule = true
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        maskLayer.fillColor = UIColor.black.cgColor
        
        layer.mask = maskLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        createMaskLayer()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let path = UIBezierPath(rect: rect)
        let cutoutPath = UIBezierPath(roundedRect: cutoutRect, cornerRadius: 8)
        path.append(cutoutPath)
        path.usesEvenOddFillRule = true
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        maskLayer.fillColor = UIColor.black.cgColor
        
        layer.mask = maskLayer
    }
}

