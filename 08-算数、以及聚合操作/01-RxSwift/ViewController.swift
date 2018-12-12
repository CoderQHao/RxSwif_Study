//
//  ViewController.swift
//  01-RxSwift
//
//  Created by Qing ’s on 2018/11/28.
//  Copyright © 2018 Qing ’s. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    
    //负责对象销毁
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        concat()
    }
    
    // 该操作符先把一个序列转成一个数组，并作为一个单一的事件发送，然后结束。
    func toArray() {
        Observable.of(1, 2, 3)
            .toArray()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        // [1, 2, 3]
    }
    
    /*
     reduce 接受一个初始值，和一个操作符号。
     reduce 将给定的初始值，与序列里的每个值进行累计运算。得到一个最终结果，并将其作为单个值发送出去。
     */
    func reduce() {
        Observable.of(1, 2, 3, 4, 5)
            .reduce(0, accumulator: +)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        // 15
    }
    
    /*
     concat 会把多个 Observable 序列合并（串联）为一个 Observable 序列。
     并且只有当前面一个 Observable 序列发出了 completed 事件，才会开始发送下一个 Observable 序列事件。
     */
    func concat() {
        let subject1 = BehaviorSubject(value: 1)
        let subject2 = BehaviorSubject(value: 2)
        
        let variable = Variable(subject1)
        variable.asObservable()
            .concat()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        subject2.onNext(3)
        subject2.onNext(4)
        subject1.onNext(1)
        subject1.onNext(1)
        subject1.onCompleted()
        
        variable.value = subject2
        subject2.onNext(5)
        // 1 1 1 4 5
    }
    
}
    










