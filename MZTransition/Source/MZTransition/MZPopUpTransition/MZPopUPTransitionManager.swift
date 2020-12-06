//
//  MZPopUPTransitionManager.swift
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

final internal class MZPopUpTransitionManager: UIPercentDrivenInteractiveTransition {
    /// `position` - UIViewController presentation style
    let position: MZAlertPosition
    
    /// `presentedViewController`- presented UIViewController
    private weak var presentedViewController: UIViewController?
    
    /// `pan`- gesture recognizer for dissmiss handling
    private weak var pan: UIPanGestureRecognizer?
    
    /// `inset` - view indents
    private let inset: UIEdgeInsets
    
    /// `decelerationRate` - parameter for calculating the destination point
    private lazy var decelerationRate = UIScrollView.DecelerationRate.fast.rawValue
    
    /// `presentationTransitionDidEnd` - parameter will be set when the controller presentation is complete
    var presentationTransitionDidEnd = false {
        willSet {
            if newValue { presentedViewController?.asMZCustomPresentedViewController()?.getScrollView?().isScrollEnabled = true }
        }
    }
    
    /// `panHasStarted` - parameter will be set to true when interaction dismiss starts
    private(set) var panHasStarted = false
    
    /// `touchByRegisteredView` - parameter to start dismiss regardless of the UIScrollView position
    private var touchByRegisteredView = false
    
    
    init(position: MZAlertPosition, inset: UIEdgeInsets) {
        self.inset = inset
        self.position = position
        super.init()
    }
    
    override var wantsInteractiveStart: Bool {
        get { presentationTransitionDidEnd ? pan?.state == .began : false }
        set {  }
    }
    
    /// registering a presented UIViewController for gesture processing
    /// - Parameter viewController: presented UIViewController
    func bind(viewController: UIViewController) {
        presentationTransitionDidEnd = false
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.maximumNumberOfTouches = 1
        pan.cancelsTouchesInView = false
        pan.delegate = self
        self.pan = pan
        
        viewController.view.addGestureRecognizer(pan)
        viewController.asMZCustomPresentedViewController()?.getScrollView?().isScrollEnabled = false
        self.presentedViewController = viewController
    }
    
    /// registering a presented UIViewController for gesture processing
    /// - Parameter dimingView: dimming background view
    func bind(dimingView: UIView?) {
        if let view = dimingView {
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dimmingViewDidTap)))
        }
    }
    
    private var presentedViewFrame: CGRect {
        return presentedViewController?.view.frame ?? .zero
    }
    
    var popupMax: CGFloat {
        switch position {
        case .top, .bottom:
            let height = (presentedViewController?.view.frame.height ?? 0) + inset.top + inset.bottom
            return height
        case .center:
            let viewHeight = presentedViewController?.view.frame.height ?? 0
            let containerHeight = presentedViewController?.presentationController?.containerView?.bounds.height ?? 0
            return (containerHeight + viewHeight) / 2
        }
    }
    
    /// function for dissmiss UIViewController when UIViewController contains UIScrollView
    func scrollViewCanBeDissmised() -> Bool {
        guard let scrollView = (presentedViewController as? MZCustomPresentedViewController)?.getScrollView?() else { return true }
        
        switch position {
        case .top:
            let max = scrollView.contentSize.height - scrollView.frame.height
            scrollView.bounces = scrollView.contentOffset.y < max
            return scrollView.contentOffset.y >= max
            
        case .bottom, .center:
            scrollView.bounces = (scrollView.contentOffset.y > 0)
            return scrollView.contentOffset.y <= 0
        }
    }
}



//MARK: -
private extension MZPopUpTransitionManager {
    @objc func dimmingViewDidTap(_ sender: UITapGestureRecognizer) {
        guard presentedViewController?.asMZCustomPresentedViewController()?.canBeDismissedUsingInteration?() != false else { return }
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        guard presentedViewController?.asMZCustomPresentedViewController()?.canBeDismissedUsingInteration?() != false else { return }
        presentationTransitionDidEnd ? handleDissmiss(sender) : handlePresentation(sender)
    }
    
    func handlePresentation(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            pause()
            
        case .changed:
            let increment = -translationProgress(sender, popupMax: popupMax)
            update(percentComplete + increment)
            
        case .ended, .cancelled:
            let projection = projectionPoint(sender, decelerationRate: decelerationRate)
            checkForDissmiss(position: position, project: projection, max: popupMax, percentComplete: 1 - percentComplete) ? cancel() : finish()
            
        case .failed:
            cancel()
            
        default:
            break
        }
    }
    
    func handleDissmiss(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            pause()
            panHasStarted = true
            if percentComplete == 0 {
                presentedViewController?.dismiss(animated: true, completion: nil)
            }
            
        case .changed:
            guard scrollViewCanBeDissmised() || touchByRegisteredView else {
                sender.setTranslation(.zero, in: sender.view)
                return
            }
            let progress = (position == .top ? -1 : 1) * translationProgress(sender, popupMax: popupMax)
            update(percentComplete + progress)
            
        case .ended, .cancelled:
            panHasStarted = false
            let projection = projectionPoint(sender, decelerationRate: decelerationRate, locationYOffset: position == .top ? 0 : popupMax)
            
            let shouldDissmiss = checkForDissmiss(
                position: position,
                project: projection,
                max: popupMax,
                percentComplete: percentComplete)
            
            shouldDissmiss ? finish() : cancel()
            
        case .failed:
            panHasStarted = false
            cancel()
            
        default:
            break
        }
    }
    
    
    
    func checkForDissmiss(position: MZAlertPosition, project: CGPoint, max: CGFloat, percentComplete: CGFloat) -> Bool {
        return position == .top ? project.y < max / 2 : project.y > max / 2 || percentComplete > 0.5
    }
    
    func translationProgress(_ pan: UIPanGestureRecognizer, popupMax max: CGFloat) -> CGFloat {
        let offset = pan.translation(in: pan.view).y / max
        pan.setTranslation(.zero, in: pan.view)
        return offset
    }
    
    func projectionPoint(_ pan: UIPanGestureRecognizer, decelerationRate: CGFloat, locationYOffset yOffset: CGFloat = 0) -> CGPoint {
        let velocity = pan.velocity(in: pan.view)
        let location = pan.location(in: pan.view)
        let loc = CGPoint(x: location.x, y: yOffset + location.y)
        let project = loc - velocity / (1000 * log(decelerationRate))
        return project
    }
}








//MARK: -
extension MZPopUpTransitionManager: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let notRegisteredViews = presentedViewController?.asMZCustomPresentedViewController()?.notRegisteredViews?() ?? []
        guard !notRegisteredViews.contains(where: { $0 === touch.view || touch.view?.isDescendant(of: $0) == true }) else { return false }
        
        let registeredViews = presentedViewController?.asMZCustomPresentedViewController()?.registeredViews?() ?? []
        touchByRegisteredView = registeredViews.contains(where: { $0 === touch.view || touch.view?.isDescendant(of: $0) == true })
        
        return true
    }
}

