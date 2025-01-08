//
//  MGTooltipsDemo.swift
//  TooltipsDemo
//
//  Created by Miswag on 06/01/2025.
//

import UIKit
import MGTooltips

class DemoTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstVC = UINavigationController(rootViewController: FirstTabViewController())
        let secondVC = SecondTabViewController()
        let thirdVC = ThirdTabViewController()
        firstVC.tabBarItem = UITabBarItem(title: "First", image: UIImage(systemName: "1.circle"), tag: 0)
        secondVC.tabBarItem = UITabBarItem(title: "Second", image: UIImage(systemName: "2.circle"), tag: 1)
        thirdVC.tabBarItem = UITabBarItem(title: "Third", image: UIImage(systemName: "3.circle"), tag: 2)
        
        viewControllers = [firstVC, secondVC, thirdVC]
    }
}


// MARK: - First Tab
class FirstTabViewController: UIViewController {
    
    // MARK: UI Elements
    
    private var leftNavButton: UIBarButtonItem!
    private var firstRightNavButton: UIBarButtonItem!
    private var secondRightNavButton: UIBarButtonItem!
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Main Title"
        lbl.font = UIFont.boldSystemFont(ofSize: 24)
        lbl.textAlignment = .center
        return lbl
    }()
    
    private let descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Description label with useful information."
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        return lbl
    }()
    
    private let demoBox: UIView = {
        let view = UIView()
        view.backgroundColor = .systemTeal
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let tooltipButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Show Tooltips", for: .normal)
        return btn
    }()
    
    private let rightContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let leftContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let rightLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Right"
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.textAlignment = .center
        return lbl
    }()
    
    private let leftLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Left"
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.textAlignment = .center
        return lbl
    }()
    
    // MARK: Tooltip Manager
    private var tooltipManager: MGTooltip?
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        tooltipButton.addTarget(self, action: #selector(showTooltips), for: .touchUpInside)
    }
    
    // MARK: Setup UI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(demoBox)
        view.addSubview(tooltipButton)
        view.addSubview(leftContainer)
        view.addSubview(rightContainer)
        leftContainer.addSubview(leftLabel)
        rightContainer.addSubview(rightLabel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Title Label
        titleLabel.frame = CGRect(x: (view.bounds.width - titleLabel.intrinsicContentSize.width) / 2, y: view.safeAreaInsets.top + 24, width: titleLabel.intrinsicContentSize.width, height: titleLabel.intrinsicContentSize.height)
        
        // Info Label
        let infoLabelWidth = view.bounds.width - 48
        descriptionLabel.frame = CGRect(x: 24,y: titleLabel.frame.maxY + 16,width: infoLabelWidth,height: descriptionLabel.intrinsicContentSize.height)
        
        // Teal Box
        let tealBoxWidth: CGFloat = 120
        let tealBoxHeight: CGFloat = 120
        demoBox.frame = CGRect(x: (view.bounds.width - tealBoxWidth) / 2, y: (view.bounds.height - tealBoxHeight) / 2 - 20, width: tealBoxWidth, height: tealBoxHeight)
        
        // Action Button
        tooltipButton.frame = CGRect(x: (view.bounds.width - tooltipButton.intrinsicContentSize.width) / 2, y: demoBox.frame.maxY + 24, width: tooltipButton.intrinsicContentSize.width, height: tooltipButton.intrinsicContentSize.height)
        
        // Right View
        let rightViewWidth: CGFloat = 100
        let rightViewHeight: CGFloat = 60
        rightContainer.frame = CGRect(x: view.bounds.width - rightViewWidth - 24, y: view.bounds.height - rightViewHeight - view.safeAreaInsets.bottom - 24, width: rightViewWidth, height: rightViewHeight)
        
        // Left View
        let leftViewWidth: CGFloat = 100
        let leftViewHeight: CGFloat = 60
        leftContainer.frame = CGRect(x: 24, y: view.bounds.height - leftViewHeight - view.safeAreaInsets.bottom - 24, width: leftViewWidth, height: leftViewHeight)
        
        // Right View Label
        rightLabel.frame = rightContainer.bounds
        // Left View Label
        leftLabel.frame = leftContainer.bounds
    }

    
    private func setupNavigationBar() {
        leftNavButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: nil
        )
        
        firstRightNavButton = UIBarButtonItem(
            image: UIImage(systemName: "bell"),
            style: .plain,
            target: self,
            action: nil
        )
        
        secondRightNavButton = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .plain,
            target: self,
            action: nil
        )
        
        navigationItem.leftBarButtonItem = leftNavButton
        navigationItem.rightBarButtonItems = [secondRightNavButton, firstRightNavButton]
    }
    
    // MARK: Show Tooltips
    @objc private func showTooltips() {
        tooltipManager = MGTooltip()
        tooltipManager?.buttonConfiguration = .nextAndPrevious
        tooltipManager?.canTapScreenToDismiss = true
        tooltipManager?.delegate = self
        
        let tooltips = [
            TooltipItem(target: leftNavButton.customView ?? leftNavButton as Any, message: "This is the left navigation button.", side: .bottom),
            TooltipItem(target: firstRightNavButton.customView ?? firstRightNavButton as Any, message: "This is the notifications button.", side: .bottom),
            TooltipItem(target: secondRightNavButton.customView ?? secondRightNavButton as Any, message: "This is the settings button.", side: .bottom),
            TooltipItem(target: titleLabel, message: "This is the main title.", side: .bottom),
            TooltipItem(target: descriptionLabel, message: "This label provides information.", side: .bottom),
            TooltipItem(target: demoBox, message: "This is a demonstration box.", side: .top),
            TooltipItem(target: tooltipButton, message: "Click here to show tooltips again.", side: .top),
            TooltipItem(target: leftContainer, message: "This is the left container.", side: .right),
            TooltipItem(target: leftLabel, message: "Label inside the left container.", side: .top),
            TooltipItem(target: rightContainer, message: "This is the right container.", side: .left),
            TooltipItem(target: rightLabel, message: "Label inside the right container.", side: .top)
        ]
        
        tooltipManager?.appendTooltips(tooltips)
        
        guard let tabBar = tabBarController?.tabBar else { return }
        let tabBarSubviews = tabBar.subviews.filter { $0 is UIControl }
        
        if tabBarSubviews.indices.contains(0) {
            tooltipManager?.appendTooltip(TooltipItem(target: tabBarSubviews[0], message: "This is the First Tab.", side: .top))
        }
        if tabBarSubviews.indices.contains(1) {
            tooltipManager?.appendTooltip(TooltipItem(target: tabBarSubviews[1], message: "This is the Second Tab.", side: .top))
        }
        if tabBarSubviews.indices.contains(2) {
            tooltipManager?.appendTooltip(TooltipItem(target: tabBarSubviews[2], message: "This is the Third Tab.", side: .top))
        }
        
        tooltipManager?.start()
    }
}



// MARK: - MGTooltipDelegate
extension FirstTabViewController: MGTooltipDelegate {
    func tooltipsDidStarted() {
        print("First tab tooltips started")
    }
    
    func tooltipDidShowed(at index: Int, item: TooltipItem) {
        print("First tab tooltip \(index) showed")
    }
    
    func tooltipDidDismissed(at index: Int, item: TooltipItem) {
        print("First tab tooltip \(index) dismissed")
    }
    
    func tooltipsDidCompleted() {
        print("First tab tooltips completed")
    }
}

// MARK: - Second Tab
class SecondTabViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Second Tab"
        lbl.font = UIFont.boldSystemFont(ofSize: 24)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

import UIKit

// MARK: - Third Tab
class ThirdTabViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Third Tab"
        lbl.font = UIFont.boldSystemFont(ofSize: 24)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
