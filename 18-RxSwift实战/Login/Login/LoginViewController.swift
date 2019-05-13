//
//  LoginViewController.swift
//  Login
//
//  Created by Qing ’s on 2019/5/13.
//  Copyright © 2019 Enroute. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    let disposeBag = DisposeBag()
    var viewModel: LoginViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = LoginViewModel(input: (username: usernameTextField.rx.text.orEmpty.asDriver(),
                                           password: passwordTextField.rx.text.orEmpty.asDriver(),
                                           loginTaps: loginButton.rx.tap.asDriver()),
                                           service: ValidationService.instance)
        
        viewModel.usernameUsable
            .drive(usernameLabel.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.loginButtonEnabled
            .drive(onNext:{ [unowned self] valid in
                self.loginButton.isEnabled = valid
                self.loginButton.alpha = valid ? 1.0 : 0.5
            })
            .disposed(by: disposeBag)
        
        viewModel.loginResult
            .drive(onNext: { [unowned self] result in
                switch result {
                case let .ok(message):
                    self.performSegue(withIdentifier: "container", sender: self)
                    self.showAlert(message: message)
                case .empty:
                    self.showAlert(message: "")
                case let .failed(message):
                    self.showAlert(message: message)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func showAlert(message: String) {
        let action = UIAlertAction(title: "确定", style: .default, handler: nil)
        let alertViewController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertViewController.addAction(action)
        present(alertViewController, animated: true, completion: nil)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
}
