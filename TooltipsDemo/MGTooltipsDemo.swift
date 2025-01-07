//
//  MGTooltipsDemo.swift
//  TooltipsDemo
//
//  Created by Miswag on 06/01/2025.
//

import UIKit
import MGTooltips

import UIKit

class MGTooltipsDemo: UIViewController {
    
    private let label = UILabel()
    private let boxView = UIView()
    private let button = UIButton(type: .system)
    private var navBarButton: UIBarButtonItem!
    
    private var tooltipManager: MGTooltip?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        label.text = "This is a label"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        boxView.backgroundColor = .systemTeal
        boxView.layer.cornerRadius = 10
        boxView.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle("Show Tooltips", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(showTooltips), for: .touchUpInside)
        
        view.addSubview(label)
        view.addSubview(boxView)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            boxView.widthAnchor.constraint(equalToConstant: 100),
            boxView.heightAnchor.constraint(equalToConstant: 100),
            boxView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            boxView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navBarButton = UIBarButtonItem(title: "Help", style: .plain, target: self, action: #selector(showTooltips))
        navigationItem.rightBarButtonItem = navBarButton
    }
    
    @objc private func showTooltips() {
        tooltipManager = MGTooltip()
        tooltipManager?.buttonConfiguration = .nextOnly
        tooltipManager?.canTapScreenToDismiss = true
        tooltipManager?.delegate = self
        
        let labelTooltip = TooltipItem(
            target: label,
            message: "Here is some info about the label.",
            side: .bottom
        )
        let boxTooltip = TooltipItem(
            target: boxView,
            message: "This teal box can be anything you want.",
            side: .top
        )
        let buttonTooltip = TooltipItem(
            target: button,
            message: "Tap here to show all tooltips!",
            side: .top
        )
        let navTooltip = TooltipItem(
            target: navBarButton as Any,
            message: "This is a tooltip on the nav bar button.",
            side: .bottom
        )
        
        tooltipManager?.appendTooltips([labelTooltip, boxTooltip, buttonTooltip, navTooltip])
        
        tooltipManager?.start()
    }
}

extension MGTooltipsDemo: MGTooltipDelegate {
    func tooltipsDidStarted() {
        print("tooltips started")
    }
    
    func tooltipDidShowed(at index: Int, item: MGTooltips.TooltipItem) {
        print("tooltip \(index) is showed")
    }
    
    func tooltipDidDismissed(at index: Int, item: MGTooltips.TooltipItem) {
        print("tooltip \(index) is dismissed")
    }
    
    func tooltipsDidCompleted() {
        print("All tooltips completed!")
    }
}
