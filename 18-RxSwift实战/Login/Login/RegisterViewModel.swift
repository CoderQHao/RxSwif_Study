//
//  RegisterViewModel.swift
//  Login
//
//  Created by Qing ’s on 2019/5/13.
//  Copyright © 2019 Enroute. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class RegisterViewModel {
    // input: 初始值为""
    let username = BehaviorRelay<String>(value: "")
    let password = BehaviorRelay<String>(value: "")
    let repeatPassword = BehaviorRelay<String>(value: "")
    let registerTaps = PublishSubject<Void>()
    
    // output:
    let usernameUsable: Observable<Result> // 用户名是否可用
    let passwordUsable: Observable<Result>  // 密码是否可用
    let repeatPasswordUsable: Observable<Result> // 密码确定是否正确
    let registerButtonEnabled: Observable<Bool>
    let registerResult: Observable<Result>
    
    init() {
        let service = ValidationService.instance
        
        usernameUsable = username.asObservable()
            .flatMapLatest { username in
                return service.validateUsername(username)
                .observeOn(MainScheduler.instance)
                .catchErrorJustReturn(.failed(message: "usernam检测出错"))
            }.share(replay: 1)
        
        passwordUsable = password.asObservable()
            .map { password in
                return service.validatePassword(password)
            }
        
        repeatPasswordUsable = Observable.combineLatest(password.asObservable(), repeatPassword.asObservable()) {
            return service.validateRepeatedPassword($0, repeatedPasswordword: $1)
        }
        
        registerButtonEnabled = Observable.combineLatest(usernameUsable, passwordUsable, repeatPasswordUsable) { (username, password, repeatPassword) in
            username.isValid && password.isValid && repeatPassword.isValid
        }
        .distinctUntilChanged()
        .share(replay: 1)
        
        let usernameAndPassword = Observable.combineLatest(username.asObservable(), password.asObservable()) { ($0, $1) }
        
        registerResult = registerTaps.asObserver().withLatestFrom(usernameAndPassword)
            .flatMapLatest { (username, password) in
                return service.register(username, password: password)
                .observeOn(MainScheduler.instance)
                .catchErrorJustReturn(.failed(message: "注册出错"))
                .share(replay: 1)
            }
    }

}
