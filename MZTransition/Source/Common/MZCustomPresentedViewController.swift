//
//  MZCustomPresentedViewController.swift
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

/// `MZCustomPresentedViewController` - protocol for managing a custom presentation
@objc public protocol MZCustomPresentedViewController {
    
    /// height of the presented UIViewController
    /// - Returns: best UIViewController view height
    @objc optional func prefferedContentHeight() -> CGFloat
    
    
    /// Is it possible to hide the controller using interaction, returns true by default
    /// - Returns: return true if need dissmiss UIViewController by swipe
    @objc optional func canBeDismissedUsingInteration() -> Bool
    
    
    /// views that need to be registered regardless of the uiscrollview state
    /// - Important: view must be marked as isUserInteractionEnabled = true
    /// - Returns: array of registered views
    @objc optional func registeredViews() -> [UIView]
    
    
    /// views that need't to be registered regardless of the uiscrollview state
    /// - Important: view must be marked as isUserInteractionEnabled = true
    /// - Returns: array of registered views
    @objc optional func notRegisteredViews() -> [UIView]
    
    
    /// registration of events of appearance/hide the keyboard, returns true by default
    /// - Returns: true  if need register keyboard notifications and false if needn't
    @objc optional func shouldRegisterKeyboard() -> Bool
    
    
    /// Necessary scrollview to properly handle hiding the UIController if there is One
    /// - Returns: scrollView
    @objc optional func getScrollView() -> UIScrollView
}


internal extension UIViewController {
    func asMZCustomPresentedViewController() -> MZCustomPresentedViewController? {
        return self as? MZCustomPresentedViewController
    }
}
