//
//  Protocol.swift
//  Login
//
//  Created by Qing ’s on 2019/5/13.
//  Copyright © 2019 Enroute. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum Result {
    case ok(message: String)
    case empty
    case failed(message: String)
}

extension Result {
    var isValid: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
}

extension Result {
    var textColor: UIColor {
        switch self {
        case .ok:
            return UIColor(red: 138.0 / 255.0, green: 221.0 / 255.0, blue: 109.0 / 255.0, alpha: 1.0)
        case .empty:
            return UIColor.black
        case .failed:
            return UIColor.red
        }
    }
}

extension Result {
    var description: String {
        switch self {
        case let .ok(message):
            return message
        case .empty:
            return ""
        case let .failed(message):
            return message
        }
    }
}

extension Reactive where Base: UILabel {
    // 让验证结果（Result类型）可以绑定到label上
    var validationResult: Binder<Result> {
        return Binder(base) { label, result in
            label.textColor = result.textColor
            label.text = result.description
        }
    }
}

extension Reactive where Base: UITextField {
    var inputEnabled: Binder<Result> {
        return Binder(base) { textField, value in
            textField.isEnabled = value.isValid
        }
    }
}

extension Reactive where Base: UIBarButtonItem {
    var tapEnabled: Binder<Result> {
        return Binder(base) { button, value in
            button.isEnabled = value.isValid
        }
    }
}
