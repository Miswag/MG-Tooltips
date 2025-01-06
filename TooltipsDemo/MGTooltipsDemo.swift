//
//  MGTooltipsDemo.swift
//  TooltipsDemo
//
//  Created by Miswag on 06/01/2025.
//

import UIKit
import MGTooltips

class MGTooltipsDemo: UIViewController {
    
    let button = UIButton(type: .system)
    let label = UILabel()
    let viewBox = UIView()
    var navigationButton: UIBarButtonItem!
    
    var tooltip: TooltipManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupTooltips()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Button Setup
        button.setTitle("Show Tooltips", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(showTooltips), for: .touchUpInside)
        
        // Label Setup
        label.text = "Tooltip on Label"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Box View Setup
        viewBox.backgroundColor = .systemTeal
        viewBox.layer.cornerRadius = 10
        viewBox.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to View
        view.addSubview(button)
        view.addSubview(label)
        view.addSubview(viewBox)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            viewBox.widthAnchor.constraint(equalToConstant: 100),
            viewBox.heightAnchor.constraint(equalToConstant: 100),
            viewBox.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            viewBox.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Tooltips Demo"
        navigationButton = UIBarButtonItem(title: "Help", style: .plain, target: self, action: #selector(showTooltips))
        navigationItem.rightBarButtonItem = navigationButton
    }
    
    private func setupTooltips() {
        // Tooltip on Label
        let labelTooltip = TooltipItem(
            target: label,
            message: "This is a label tooltip.",
            side: .bottom
        )
        
        // Tooltip on Box View
        let boxTooltip = TooltipItem(
            target: viewBox,
            message: "This is a tooltip on the box view.",
            side: .top
        )
        
        // Tooltip on Button
        let buttonTooltip = TooltipItem(
            target: button,
            message: "Click here to see more tooltips!",
            side: .top
        )
        
        // Tooltip on Navigation Button
        let navTooltip = TooltipItem(
            target: navigationButton as Any,
            message: "This is a tooltip for the navigation item.",
            side: .bottom
        )
        
        // Initialize Tooltip Manager
        tooltip = TooltipManager(tooltips: [labelTooltip, boxTooltip, buttonTooltip, navTooltip])
        tooltip?.onCompletion = {
            print("All tooltips completed!")
        }
        
        // Start Tooltip Sequence
        tooltip?.start()
    }
    
    @objc private func showTooltips() {
        setupTooltips()
    }
}
