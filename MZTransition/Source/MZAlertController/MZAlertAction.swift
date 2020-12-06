//
//  MZAlertAction.swift
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

/// `MZAlertAction` - MZAlertController stylized button
final public class MZAlertAction: UIControl {
    
    //MARK: - UI Components -
    public let label = UILabel()
    let isCancel: Bool
    private weak var gradientLayer: CAGradientLayer?
    
    
    /// `completion` - tap completion
    private var completion: ((MZAlertAction) -> Void)?
    
    
    /// Create custom UIController specially for MZAlertController
    /// - Parameters:
    ///   - title: action text
    ///   - isCancel: cancel action have another style
    ///   - handler: completion block of action tap
    public init(title: String, isCancel: Bool, handler: ((MZAlertAction) -> Void)?) {
        label.text = title
        completion = handler
        self.isCancel = isCancel
        super.init(frame: .zero)
        commonInit()
    }
    
    @available(*, unavailable)
    override init(frame: CGRect) {
        fatalError("init(frame: ) has not been implemented")
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var intrinsicContentSize: CGSize {
        return .init(width: bounds.width, height: 40)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = bounds
    }
    
    internal func setup(style: MZAlertActionStyleType?) {
        backgroundColor = style?.backgroundColor ?? .clear
        label.apply {
            $0.font = style?.font ?? .systemFont(ofSize: 18, weight: .medium)
            $0.textAlignment = .center
            $0.textColor = style?.textColor
        }
        
        layer.apply {
            $0.cornerRadius = style?.layerCornerRadius ?? 0
            $0.borderWidth = style?.layerBorderWidth ?? 0
            $0.borderColor = style?.layerBorderColor ?? UIColor.clear.cgColor
        }
        
        if let colors = style?.gradientLayerColors, !colors.isEmpty {
            let gradientLayer = CAGradientLayer().apply {
                $0.frame = bounds
                $0.colors = colors
                $0.startPoint = style?.gradientLayerStartPoint ?? .init(x: 1, y: 1)
                $0.endPoint = style?.gradientLayerEndPoint ?? .init(x: 0, y: 0)
                $0.cornerRadius = layer.cornerRadius
            }
            
            layer.insertSublayer(gradientLayer, at: 0)
            self.gradientLayer = gradientLayer
        }
    }
}


private extension MZAlertAction {
    func commonInit() {
        [label].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
        addTarget(self, action: #selector(animateDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(animateUp), for: [.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside])
    }
    
    @objc func didTap(_ sender: MZAlertAction) {
        completion?(sender)
    }
    
    @objc func animateUp() {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction], animations: {
            self.transform = .identity
        }) { (_) in }
    }
    
    @objc func animateDown() {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction], animations: {
            self.transform = .init(scaleX: 0.97, y: 0.97)
        }) { (_) in }
    }
}

