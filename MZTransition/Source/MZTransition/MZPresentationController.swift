//
//  MZPresentationController.swift
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

/// `MZPresentationController` - base UIPresentationController
internal class MZPresentationController: UIPresentationController {
    /// keyboard has showing
    private(set) var keyboardShown: Bool = false
    /// Keyboard height
    private(set) var keyboardHeight: CGFloat = 0
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        if presentedViewController.asMZCustomPresentedViewController()?.shouldRegisterKeyboard?() != false {
            addNotificationObservers()
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        if completed { removeNotificationObservers() }
    }
    
    
    
    //MARK: - register device notifications -
    
    /// Register keyboard and device notififications
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willChangeKeyboardFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    /// Remove all registered observers
    private func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    /// Device orientation notification listener
    /// - Parameter sender: Notification
    @objc func orientationChanged(_ sender: Notification) {
        keyboardHeight = sender.keyboardHeight ?? 0
    }
    
    /// Keyboard will show notification listener
    /// - Parameter sender: Notification
    @objc func willShowKeyboard(_ sender: Notification) {
        keyboardShown = true
        keyboardHeight = sender.keyboardHeight ?? 0
        keyboardChangeState()
    }
    
    /// Keyboard will hide notification listener
    /// - Parameter sender: Notification
    @objc func willHideKeyboard(_ sender: Notification) {
        keyboardShown = false
        keyboardHeight = sender.keyboardHeight ?? 0
        keyboardChangeState()
    }
    
    /// Keyboard will change frame notification listener
    /// - Parameter sender: Notification
    @objc func willChangeKeyboardFrame(_ sender: Notification) {
        keyboardHeight = sender.keyboardHeight ?? 0
    }
    
    /// Keyboard did change state
    @objc func keyboardChangeState() { }
}

