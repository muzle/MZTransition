//
//  MZAlertControllerStyle.swift
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

/// `MZAlertControllerStyle` - Default styles for MZAlertController
public enum MZAlertControllerStyle: String, CaseIterable, MZAlertControllerStyleType {
    /// `error` - style for showing error
    case error
    /// `success` - style for showing succes action
    case success
    /// `space` - simple sttle
    case space
    
    public var alertStyle: MZAlertViewStyleType? {
        switch self {
        case .error: return AlertViewStyle.makeErrorAlertStyle()
        case .success: return AlertViewStyle.makeSuccessAlertStyle()
        case .space: return AlertViewStyle.makeSpaceAlertStyle()
        }
    }
    
    public var headerFont: UIFont? {
        return .systemFont(ofSize: 20, weight: .medium)
    }
    
    public var headerTextColor: UIColor? {
        switch self {
        case .error, .success: return .white
        case .space: return .white
        }
    }
    
    public var messageFont: UIFont? {
        return .systemFont(ofSize: 18, weight: .regular)
    }
    
    public var messageTextColor: UIColor? {
        switch self {
        case .error, .success: return .white
        case .space: return .white
        }
    }
    
    
    public var actionStyle: MZAlertActionStyleType? {
        switch self {
        case .error: return MZAlertActionStyle.makeErrorStyle(isCancel: false)
        case .success: return MZAlertActionStyle.makeSuccessStyle(isCancel: false)
        case .space: return MZAlertActionStyle.makeSpaceStyle(isCancel: false)
        }
    }
    
    public var cancelActionStyle: MZAlertActionStyleType? {
        switch self {
        case .error: return MZAlertActionStyle.makeErrorStyle(isCancel: true)
        case .success: return MZAlertActionStyle.makeSuccessStyle(isCancel: true)
        case .space: return MZAlertActionStyle.makeSpaceStyle(isCancel: true)
        }
    }
}


internal struct AlertViewStyle: MZAlertViewStyleType {
    var backgroundColor: UIColor?
    var layerBorderColor: CGColor?
    var layerCornerRadius: CGFloat?
    var layerBorderWidth: CGFloat?
    var gradientLayerColors: [CGColor]?
    var gradientLayerStartPoint: CGPoint?
    var gradientLayerEndPoint: CGPoint?
    
    static func makeErrorAlertStyle() -> Self {
        return .init(backgroundColor: nil,
                     layerBorderColor: #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1).cgColor,
                     layerCornerRadius: 10,
                     layerBorderWidth: 1.4,
                     gradientLayerColors: [#colorLiteral(red: 0.6962680221, green: 0.1809307635, blue: 0.04184839875, alpha: 1), #colorLiteral(red: 0.9104546905, green: 0.2699238658, blue: 0.05714132637, alpha: 1)].map { $0.cgColor },
                     gradientLayerStartPoint: .init(x: 0, y: 0),
                     gradientLayerEndPoint: .init(x: 1, y: 1))
    }
    
    static func makeSuccessAlertStyle() -> Self {
        return .init(backgroundColor: nil,
                     layerBorderColor: #colorLiteral(red: 0.177161932, green: 0.2940426767, blue: 0.2056961656, alpha: 1).cgColor,
                     layerCornerRadius: 10,
                     layerBorderWidth: 1.4,
                     gradientLayerColors: [#colorLiteral(red: 0.2285082638, green: 0.4307082295, blue: 0.2638035715, alpha: 1), #colorLiteral(red: 0.3846128583, green: 0.8176801205, blue: 0.4362654388, alpha: 1)].map { $0.cgColor },
                     gradientLayerStartPoint: .init(x: 0, y: 0),
                     gradientLayerEndPoint: .init(x: 1, y: 1))
    }
    
    static func makeSpaceAlertStyle() -> Self {
        return .init(backgroundColor: nil,
                     layerBorderColor: #colorLiteral(red: 0.4608412981, green: 0.5032046437, blue: 0.6036131382, alpha: 1).cgColor,
                     layerCornerRadius: 10,
                     layerBorderWidth: 1.4,
                     gradientLayerColors: [#colorLiteral(red: 0.4608412981, green: 0.5032046437, blue: 0.6036131382, alpha: 1), #colorLiteral(red: 0.836928606, green: 0.8608877063, blue: 0.9030273557, alpha: 1)].map { $0.cgColor },
                     gradientLayerStartPoint: .init(x: 0, y: 0),
                     gradientLayerEndPoint: .init(x: 1, y: 1))
    }
}



internal struct MZAlertActionStyle: MZAlertActionStyleType {
    var font: UIFont?
    var textColor: UIColor?
    var backgroundColor: UIColor?
    var layerBorderColor: CGColor?
    var layerCornerRadius: CGFloat?
    var layerBorderWidth: CGFloat?
    var gradientLayerColors: [CGColor]?
    var gradientLayerStartPoint: CGPoint?
    var gradientLayerEndPoint: CGPoint?
    
    static func makeSuccessStyle(isCancel: Bool) -> Self {
        return .init(font: .systemFont(ofSize: 20, weight: .medium),
                     textColor: .white,
                     backgroundColor: #colorLiteral(red: 0.2285082638, green: 0.4307082295, blue: 0.2638035715, alpha: 1),
                     layerBorderColor: nil,
                     layerCornerRadius: 10,
                     layerBorderWidth: 1,
                     gradientLayerColors: nil,
                     gradientLayerStartPoint: nil,
                     gradientLayerEndPoint: nil)
    }
    
    static func makeErrorStyle(isCancel: Bool) -> Self {
        return .init(font: .systemFont(ofSize: 20, weight: .medium),
                     textColor: .white,
                     backgroundColor: #colorLiteral(red: 0.6778083444, green: 0.1271287799, blue: 0.04232269526, alpha: 1),
                     layerBorderColor: nil,
                     layerCornerRadius: 10,
                     layerBorderWidth: 1,
                     gradientLayerColors: nil,
                     gradientLayerStartPoint: nil,
                     gradientLayerEndPoint: nil)
    }
    
    static func makeSpaceStyle(isCancel: Bool) -> Self {
        return .init(font: .systemFont(ofSize: 20, weight: .medium),
                     textColor: .white,
                     backgroundColor: #colorLiteral(red: 0.4608412981, green: 0.5032046437, blue: 0.6036131382, alpha: 1),
                     layerBorderColor: nil,
                     layerCornerRadius: 10,
                     layerBorderWidth: 1,
                     gradientLayerColors: nil,
                     gradientLayerStartPoint: nil,
                     gradientLayerEndPoint: nil)
    }
}
