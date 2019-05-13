//
//  Service.swift
//  Login
//
//  Created by Qing ’s on 2019/5/13.
//  Copyright © 2019 Enroute. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ValidationService {
    static let instance = ValidationService()
    
    let minCharactersCount = 6
    
    // 这里面我们返回一个Observable对象，因为我们这个请求过程需要被监听
    func validateUsername(_ username: String) -> Observable<Result> {
        // 当字符等于0的时候什么都不做
        if username.isEmpty {
            return .just(.empty)
        }
        
        // 当字符小于6的时候返回failed
        if username.count < minCharactersCount {
            return .just(.failed(message: "号码长度至少6个字符"))
        }
        
        // 检测本地数据库中是否已经存在这个名字
        if usernameValid(username) {
            return .just(.failed(message: "账户已存在"))
        }
        
        return .just(.ok(message: "用户名可用"))
    }
    
    // 从本地数据库中检测用户名是否已经存在
    func usernameValid(_ username: String) -> Bool {
        let filePath = NSHomeDirectory() + "/Documents/users.plist"
        let userDic = NSDictionary(contentsOfFile: filePath)
        let usernameArray = userDic?.allKeys
        guard usernameArray != nil else {
            return false
        }
        
        if (usernameArray! as NSArray).contains(username ) {
            return true
        } else {
            return false
        }
    }
    
    func validatePassword(_ password: String) -> Result {
        if password.isEmpty {
            return .empty
        }
        
        if password.count < minCharactersCount {
            return .failed(message: "密码长度至少6个字符")
        }
        
        return .ok(message: "密码可用")
    }
    
    func validateRepeatedPassword(_ password: String, repeatedPasswordword: String) -> Result {
        if repeatedPasswordword.isEmpty {
            return .empty
        }
        
        if repeatedPasswordword == password {
            return .ok(message: "密码可用")
        }
        
        return .failed(message: "两次密码不一样")
    }
    
    func register(_ username: String, password: String) -> Observable<Result> {
        let userDic = [username: password]
        
        let filePath = NSHomeDirectory() + "/Documents/users.plist"
        
        if (userDic as NSDictionary).write(toFile: filePath, atomically: true) {
            return .just(.ok(message: "注册成功"))
        }
        return .just(.failed(message: "注册失败"))
    }
    
    func loginUsernameValid(_ username: String) -> Observable<Result> {
        if username.isEmpty {
            return .just(.empty)
        }
        
        if usernameValid(username) {
            return .just(.ok(message: "用户名可用"))
        }
        return .just(.failed(message: "用户名不存在"))
    }
    
    func login(_ username: String, password: String) -> Observable<Result> {
        let filePath = NSHomeDirectory() + "/Documents/users.plist"
        let userDic = NSDictionary(contentsOfFile: filePath)
        if let userPass = userDic?.object(forKey: username) as? String {
            if userPass == password {
                return .just(.ok(message: "登录成功"))
            }
        }
        return .just(.failed(message: "密码错误"))
    }
}
