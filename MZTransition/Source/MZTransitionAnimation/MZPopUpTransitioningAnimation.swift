//
//  MZPopUpTransitioningAnimation.swift
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

/// `MZPopUpTransitioningAnimation` - view present/dissmiss PopUp animtaion from Top/Bottom/Center
final internal class MZPopUpTransitioningAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    /// `duration` - animation duration
    let duration: TimeInterval
    /// `presentationDirection` - UIViewController presentation/dissmiss animation direction
    let presentationDirection: MZTransitioningAnimationDirection
    /// `direction` - UIViewController view projection position
    let direction: Direction
    /// `inset` - expected margins for the view
    let inset: UIEdgeInsets
    
    
    /// `MZPopUpTransitioningAnimation` - init
    /// - Parameters:
    ///   - duration: animation duration
    ///   - presentationDirection: UIViewController presentation/dissmiss animation direction
    ///   - direction: UIViewController view projection position
    ///   - inset: expected margins for the view, will set in UIViewControllerTransitioningDelegate
    init(duration: TimeInterval, presentationDirection: MZTransitioningAnimationDirection, direction: Direction, inset: UIEdgeInsets) {
        self.duration = duration
        self.presentationDirection = presentationDirection
        self.direction = direction
        self.inset = inset
        super.init()
    }
    
    /// `Direction` - UIViewController view projection position
    enum Direction {
        /// `top` - presentation from top to bottom with UIViewController view height
        case top
        /// `bottom` - presentation from bottom to top with UIViewController view height
        case bottom
        /// `center` - presentation from bottom to screen center
        case center
        
        /// - Parameter position: MZAlertController position
        init(alertPosition position: MZAlertPosition) {
            switch position {
            case .bottom:   self = .bottom
            case .center:   self = .center
            case .top:      self = .top
            }
        }
    }
    
    /// create transition animation
    /// - Parameter context: transition inforamation
    /// - Returns: animator for transition
    private func makeAnimator(context: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        let view = context.view(forKey: presentationDirection == .present ? .to : .from)!
        let vc = context.viewController(forKey: presentationDirection == .present ? .to : .from)!
        let frame = presentationDirection == .present ? context.finalFrame(for: vc) : context.initialFrame(for: vc)
        
        let height: CGFloat = {
            switch direction {
            case .top, .bottom: return frame.height + inset.top + inset.bottom
            case .center:       return (context.containerView.bounds.height + frame.height) / 2
            }
        }()
        
        let yOffset = direction == .top ? -height : height
        
        if presentationDirection == .present {
            view.frame = {
                switch direction {
                case .top:
                    return frame.offsetBy(dx: 0, dy: yOffset)
                    
                case .bottom, .center:
                    return frame.offsetBy(dx: 0, dy: yOffset)
                }
            }()
        }
        
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) {
            view.frame = self.presentationDirection == .present ? frame : frame.offsetBy(dx: 0, dy: yOffset)
        }
        
        animator.addCompletion { (_) in
            context.completeTransition(!context.transitionWasCancelled)
        }
        
        return animator
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        makeAnimator(context: transitionContext).startAnimation()
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        return makeAnimator(context: transitionContext)
    }
}
