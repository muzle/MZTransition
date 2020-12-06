//
//  ViewController.swift
//  MZTransition_Example
//
//  Created by muzle on 06.12.2020.
//

import UIKit
import MZTransition

class ViewController: UIViewController {

    private(set) var segmentControl: UISegmentedControl!
    private(set) var durationLabel: UILabel!
    private(set) var slider: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        self.segmentControl = UISegmentedControl()
        MZAlertControllerStyle.allCases.enumerated().forEach {
            segmentControl.insertSegment(withTitle: $0.element.rawValue, at: $0.offset, animated: false)
        }
        segmentControl.selectedSegmentIndex = 0
        
        self.slider = UISlider().apply {
            $0.minimumValue = 0
            $0.maximumValue = 4
            $0.value = 0.3
            $0.addTarget(self, action: #selector(durationChanged(_:)), for: .valueChanged)
        }
        
        durationLabel = UILabel().apply {
            $0.text = "duratio: \(slider.value)"
        }
        
        
        let buttons = MZAlertPosition.allCases.enumerated().map { (data) in
            UIButton().apply {
                $0.tag = data.offset
                $0.setTitle(data.element.rawValue, for: [])
                $0.addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchUpInside)
                $0.backgroundColor = .lightGray
                $0.layer.cornerRadius = 10
            }
        }
        
        let buttonsStackView = UIStackView(arrangedSubviews: buttons).apply {
            $0.spacing = 8
            $0.axis = .vertical
        }
        
        let stackView = UIStackView(arrangedSubviews: [slider, durationLabel, segmentControl, buttonsStackView]).apply {
            $0.spacing = 10
            $0.axis = .vertical
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(stackView)
        
        if #available(iOS 11, *) {
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        } else {
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16).isActive = true
        }
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    @objc func buttonDidTap(_ sender: UIControl) {
        let position = MZAlertPosition.allCases[sender.tag]
        let alertStyle = MZAlertControllerStyle.allCases[segmentControl.selectedSegmentIndex]
        
        let alert = MZAlertController(title: "Alert title", message: "MZAlertController\nMessage\n:)", style: alertStyle)
       
        alert.add(view: UITextField().apply {
            $0.placeholder = "name"
            $0.backgroundColor = .white
            $0.heightAnchor.constraint(equalToConstant: 44).isActive = true
        })
        
        let action = MZAlertAction(title: "ACTION", isCancel: false, handler: { _ in print("AlertAction") })
        
        let cancelAction = MZAlertAction(title: "Cancel Action", isCancel: true, handler: { _ in print("Cancel Action")  })
        alert.add(action: action)
        alert.add(action: cancelAction)
        
        let transitioningDelegate = MZPopUpTransitioningDelegate(presentionAnimationDuration: TimeInterval(slider.value), dissmissAnimationDuration: TimeInterval(slider.value), position: position, inset: .init(top: 130, left: 16, bottom: 130, right: 16))
        alert.modalPresentationStyle = .custom
        alert.transitioningDelegate = transitioningDelegate
        objc_setAssociatedObject(alert, "[\(arc4random())]", transitioningDelegate, .OBJC_ASSOCIATION_RETAIN)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func durationChanged(_ sender: UISlider) {
        durationLabel.text = "duration: \(sender.value)"
    }
}


protocol Appliable { }

extension Appliable {
    @discardableResult
    public func apply(closure: (Self) -> Void) -> Self {
        closure(self)
        return self
    }
}


extension NSObject: Appliable { }
