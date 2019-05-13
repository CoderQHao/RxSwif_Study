//
//  LoginViewModel.swift
//  Login
//
//  Created by Qing ’s on 2019/5/13.
//  Copyright © 2019 Enroute. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class LoginViewModel {
    // output:
    let usernameUsable: Driver<Result>
    let loginButtonEnabled: Driver<Bool>
    let loginResult: Driver<Result>
    
    init(input: (username: Driver<String>, password: Driver<String>, loginTaps: Driver<Void>), service: ValidationService) {
        usernameUsable = input.username
            .flatMapLatest { username in
                return service.loginUsernameValid(username)
                    .asDriver(onErrorJustReturn: .failed(message: "连接server失败"))
        }
        
        let usernameAndPassword = Driver.combineLatest(input.username, input.password) { ($0, $1) }
        
        loginResult = input.loginTaps.withLatestFrom(usernameAndPassword)
            .flatMapLatest { (username, password) in
                return service.login(username, password: password)
                    .asDriver(onErrorJustReturn: .failed(message: "连接server失败"))
        }
        
        loginButtonEnabled = input.password
            .map { !$0.isEmpty }
            .asDriver()
    }
}
