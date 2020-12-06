//
//  MZPopUpTransitioningDelegate.swift
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

public class MZPopUpTransitioningDelegate: NSObject {
    
    /// `transitionManager` - manager for handling interaction dissmiss UIViewConroller
    private lazy var transitionManager = MZPopUpTransitionManager(position: position, inset: inset)
    public let presentionAnimationDuration: TimeInterval
    public let dissmissAnimationDuration:   TimeInterval
    public let position:                    MZAlertPosition
    public let inset:                       UIEdgeInsets
    public let dimmingViewType:             MZPresentationAnimationViewType.Type?
    
    
    /// `MZAlertTransitioningDelegate` init
    /// - Parameters:
    ///   - presentionAnimationDuration: presentation duration
    ///   - dissmissAnimationDuration: dissmiss duration
    ///   - position: style of UIViewController presentation
    ///   - inset: UIViewController view padding
    ///   - dimmingViewType: background UIView type
    public init(presentionAnimationDuration: TimeInterval = 0.3, dissmissAnimationDuration: TimeInterval = 0.3, position: MZAlertPosition, inset: UIEdgeInsets, dimmingViewType: MZPresentationAnimationViewType.Type? = MZDimmingBackgroundView.self) {
        self.presentionAnimationDuration = presentionAnimationDuration
        self.dissmissAnimationDuration = dissmissAnimationDuration
        self.position = position
        self.inset = inset
        self.dimmingViewType = dimmingViewType
        super.init()
    }
}




//MARK: -
extension MZPopUpTransitioningDelegate: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        transitionManager.bind(viewController: presented)
        let pc = MZPopUpPresentationController(position: position, inset: inset, presentedViewController: presented, presenting: presenting ?? source, dimmingViewType: dimmingViewType)
        pc.transitionManager = transitionManager
        return pc
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch position {
        case .top, .bottom:
            return MZPopUpTransitioningAnimation(duration: presentionAnimationDuration, presentationDirection: .present, direction: .init(alertPosition: position), inset: inset)
            
        case .center:
            return MZZoomTransitioningAnimation(duration: presentionAnimationDuration, presentationDirection: .present)
        }
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch position {
        case .top, .bottom:
            return MZPopUpTransitioningAnimation(duration: dissmissAnimationDuration, presentationDirection: .dissmiss, direction: .init(alertPosition: position), inset: inset)
            
        case .center:
            if transitionManager.panHasStarted {
                return MZPopUpTransitioningAnimation(duration: dissmissAnimationDuration, presentationDirection: .dissmiss, direction: .init(alertPosition: position), inset: inset)
            } else {
                return MZZoomTransitioningAnimation(duration: dissmissAnimationDuration, presentationDirection: .dissmiss)
            }
        }
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        switch position {
        case .bottom, .top: return transitionManager
        case .center:       return nil
        }
    }

    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return transitionManager
    }
}

