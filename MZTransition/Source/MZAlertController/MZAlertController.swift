//
//  MZAlertController.swift
//
//  MZTransition
//  Created by Eugene(voragomod@icloud.com) on 06.12.2020.
//
//  Copyright © 2020 Eugene Rudakov.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

/// `MZAlertController` - easily modifiable UIViewController similar to UIAlertController
public final class MZAlertController: UIViewController {
    /// `style` - style of MZAlertController
    private let style:          MZAlertControllerStyleType
    
    //MARK: - UI elements -
    private let stackView:      UIStackView
    private var gradientLayer:  CAGradientLayer?
    private lazy var scrollView = UIScrollView(frame: view.bounds)
    public private(set) var titleLabel:    UILabel?
    public private(set) var messageLabel:  UILabel?
    
    
    
    /// Create MZAlertController with title, message and defined stype
    ///
    /// - Important: if title or message is nil UILabel will not be created
    ///
    /// - Parameters:
    ///   - title: titile of MZAlertController
    ///   - message: message of MZAlertController
    ///   - style: enum with defined styles
    public convenience init(title: String?, message: String?, style: MZAlertControllerStyle) {
        self.init(title: title, message: message, alertStyle: style)
    }
    
    
    /// Create MZAlertController with title, message and custom stype
    ///
    /// - Important: if title or message is nil UILabel will not be created
    ///
    /// - Parameters:
    ///   - title: titile of MZAlertController
    ///   - message: message of MZAlertController
    ///   - alertStyle: enum with defined styles
    ///
    ///   - Important: if title or message is nil UILabel will not be created
    public init(title: String?, message: String?, alertStyle: MZAlertControllerStyleType) {
        self.style = alertStyle
        
        if let title = title {
            titleLabel = UILabel().apply {
                $0.text = title
                $0.numberOfLines = 0
                $0.textAlignment = .center
                $0.textColor = alertStyle.headerTextColor
                $0.font = alertStyle.headerFont
                $0.isUserInteractionEnabled = true
            }
        }
        
        if let message = message {
            messageLabel = UILabel().apply {
                $0.text = message
                $0.numberOfLines = 0
                $0.textAlignment = .center
                $0.textColor = alertStyle.messageTextColor
                $0.font = alertStyle.messageFont
                $0.isUserInteractionEnabled = true
            }
        }
        
        self.stackView = UIStackView(arrangedSubviews: [titleLabel, messageLabel].compactMap { $0 }).apply {
            $0.axis = .vertical
            $0.spacing = 16
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:, bundle:) has not been implemented")
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // if the keyboard is shown and screen hiding starts the keyboard will be hidden
        view.endEditing(true)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
    }
    
    
    
    /// adding a action to MZAlertController
    /// - Parameter action: custom UIControl
    public func add(action: MZAlertAction) {
        action.apply {
            $0.addTarget(self, action: #selector(actionDidTap(_:)), for: .touchUpInside)
            $0.setup(style: $0.isCancel ? style.cancelActionStyle : style.actionStyle)
        }
        stackView.insertArrangedSubview(action, at: stackView.arrangedSubviews.count)
    }
    
    
    /// adding a UIView to MZAlertController
    /// - Parameter view:
    public func add(view: UIView) {
        stackView.insertArrangedSubview(view, at: stackView.arrangedSubviews.count)
    }
}



//MARK: -
private extension MZAlertController {
    func commonInit() {
        view.apply {
            $0.backgroundColor = style.alertStyle?.backgroundColor ?? UIColor.clear
        }
        
        view.layer.apply {
            $0.cornerRadius = style.alertStyle?.layerCornerRadius ?? 0
            $0.borderWidth = style.alertStyle?.layerBorderWidth ?? 0
            $0.borderColor = style.alertStyle?.layerBorderColor ?? UIColor.clear.cgColor
        }
        
        gradientLayer = CAGradientLayer().apply {
            $0.colors = style.alertStyle?.gradientLayerColors ?? []
            $0.frame = view.bounds
            $0.cornerRadius = view.layer.cornerRadius
            $0.startPoint = style.alertStyle?.gradientLayerStartPoint ?? .init(x: 1, y: 1)
            $0.endPoint = style.alertStyle?.gradientLayerEndPoint ?? .init(x: 0, y: 0)
            view.layer.insertSublayer($0, at: 0)
        }
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        
        let contentView = UIView(frame: view.bounds)
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).apply { $0.priority = .init(250) },

            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    /// UIViewController will dissmiss after action tap
    @objc func actionDidTap(_ sender: UIControl) {
        dismiss(animated: true, completion: nil)
    }
}



//MARK: -
extension MZAlertController: MZCustomPresentedViewController {
    public func getScrollView() -> UIScrollView {
        return scrollView
    }
}


