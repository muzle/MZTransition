//
//  MZZoomTransitioningAnimation.swift
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

/// `MZZoomTransitioningAnimation` - view present/dissmiss zoom animtaion
final internal class MZZoomTransitioningAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    /// `duration` - animation duration
    let duration: TimeInterval
    /// `presentationDirection` - UIViewController presentation/dissmiss animation direction
    let presentationDirection: MZTransitioningAnimationDirection
    
    
    /// `MZZoomTransitioningAnimation` - init
    /// - Parameters:
    ///   - duration: animation duration
    ///   - presentationDirection: UIViewController presentation/dissmiss animation direction
    init(duration: TimeInterval, presentationDirection: MZTransitioningAnimationDirection) {
        self.duration = duration
        self.presentationDirection = presentationDirection
        super.init()
    }
    
    
    /// create transition animation
    /// - Parameter context: transition inforamation
    /// - Returns: animator for transition
    private func makeAnimator(context: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        let view = context.view(forKey: presentationDirection == .present ? .to : .from)!
        
        if presentationDirection == .present {
            view.alpha = 0
            view.transform = .init(scaleX: 0.1, y: 0.1)
        }
        
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) {
            view.alpha = self.presentationDirection == .present ? 1 : 0
            view.transform = self.presentationDirection == .present ? .identity : .init(scaleX: 0.1, y: 0.1)
        }
        
        animator.addCompletion { (position) in
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
}
