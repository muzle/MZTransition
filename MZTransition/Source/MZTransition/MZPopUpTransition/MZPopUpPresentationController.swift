//
//  MZPopUpPresentationController.swift
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

final internal class MZPopUpPresentationController: MZPresentationController {
    /// `position` presentation position
    let position: MZAlertPosition
    /// UIViewController view frame padding
    let inset: UIEdgeInsets
    private var dissmissInProgress = false
    private let dimmingViewType: MZPresentationAnimationViewType.Type?
    weak var transitionManager: MZPopUpTransitionManager?
    private(set) var dimmingBackgroundView:  MZPresentationAnimationViewType?
    
    
    /// PopUp presentation controller
    /// - Parameters:
    ///   - position: presentation position
    ///   - inset: UIViewController view frame padding
    ///   - presentedViewController: The view controller being presented modally.
    ///   - presenting: The view controller whose content represents the starting point of the transition.
    ///   - dimmingViewType: animated background view type
    init(position: MZAlertPosition, inset: UIEdgeInsets, presentedViewController: UIViewController, presenting: UIViewController?, dimmingViewType: MZPresentationAnimationViewType.Type?) {
        self.position = position
        self.inset = inset
        self.dimmingViewType = dimmingViewType
        super.init(presentedViewController: presentedViewController, presenting: presenting)
    }
    
    override var shouldPresentInFullscreen: Bool {
        return false
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let bounds = containerView?.bounds else { return .zero }
        return CGRect(x: 0,
                      y: estimateYPoisition(),
                      width: bounds.width,
                      height: contentHeight).inset(by: inset)
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        guard !dissmissInProgress else { return }
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        containerView?.addSubview(presentedView!)
        
        if let dimmingViewType = self.dimmingViewType {
            let view = dimmingViewType.init(frame: containerView?.bounds ?? .zero)
            self.dimmingBackgroundView = view
            transitionManager?.bind(dimingView: view)
            containerView?.insertSubview(view, at: 0)
        }
        
        transitionAnimation { [unowned self] in self.dimmingBackgroundView?.presentationAnimation() }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        if completed { transitionManager?.presentationTransitionDidEnd = true }
        if !completed { dimmingBackgroundView?.removeFromSuperview() }
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        dissmissInProgress = true
        transitionAnimation { [unowned self] in self.dimmingBackgroundView?.dissmissAnimation() }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        dissmissInProgress = false
        if completed { dimmingBackgroundView?.removeFromSuperview() }
    }
    
    
    private func transitionAnimation(_ closure: @escaping (() -> Void)) {
        guard let coordinator = presentedViewController.transitionCoordinator else { closure(); return }
        coordinator.animate(alongsideTransition: { (_) in
            closure()
        }) { (_) in }
    }
    
    override func orientationChanged(_ sender: Notification) {
        super.orientationChanged(sender)
        dimmingBackgroundView?.apply {
            $0.frame = containerView?.bounds ?? .zero
        }
    }
    
    override func keyboardChangeState() {
        super.keyboardChangeState()
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
}




//MARK: -
private extension MZPopUpPresentationController {
    var viewHeight: CGFloat {
        if let height = (presentedViewController as? MZCustomPresentedViewController)?.prefferedContentHeight?() {
            return height
        }
        guard
            let bounds = containerView?.bounds,
            let presentedView = presentedView
            else { return 0 }
        
        
        let targetSize = CGSize(
            width: bounds.width - (inset.left + inset.right),
            height: UIView.layoutFittingCompressedSize.height)
        
        return presentedView.systemLayoutSizeFitting(targetSize).height
    }
    
    var contentHeight: CGFloat {
        return min(viewHeight + inset.top + inset.bottom, containerView?.bounds.height ?? UIScreen.main.bounds.height)
    }
    
    func estimateYPoisition() -> CGFloat {
        let viewHeight = self.viewHeight
        let contentHeight = self.contentHeight
        let boundsHeight = containerView?.bounds.height ?? 0
        let minY: CGFloat = {
            switch position {
            case .top:      return 0
            case .bottom:   return boundsHeight - contentHeight
            case .center:   return (boundsHeight - contentHeight) / 2
            }
        }()
        
        guard keyboardShown else { return minY }
        
        let keyboardMinY = boundsHeight - (keyboardHeight + viewHeight + inset.top)
        return min(minY, keyboardMinY)
    }
}

