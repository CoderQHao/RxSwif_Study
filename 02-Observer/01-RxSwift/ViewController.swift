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

    // 负责对象销毁
    let disposeBag = DisposeBag()
    let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
    override func viewDidLoad() {
        super.viewDidLoad()
//        way1()
//        way2()
//        way3()
        way4()
        
//        buttonSelected()
//        customBind()
        button.rx.tap
            .subscribe(onNext: {
                print("按钮点击")
            }).disposed(by: disposeBag)
    }
    
    // 在 bind 方法中创建
    func way1() {
        observable.map { "当前索引数：\($0)"}.bind { [weak self] (text) in
            // 收到发出的索引数后显示到label上
            self?.label.text = text
            }.disposed(by: disposeBag)
    }

    // 使用 AnyObserver 创建观察者 配合 bindTo 方法使用
    func way2() {
        let observer: AnyObserver<String> = AnyObserver { [weak self] (event) in
            switch event {
            case .next(let text):
                self?.label.text = text
            default:
                break
            }
        }
        observable.map { "当前索引数：\($0)" }.bind(to: observer).disposed(by: disposeBag)
    }
    
    // 使用 Binder 创建观察者
    // 不会处理错误事件
    // 确保绑定都是在给定 Scheduler 上执行（默认 MainScheduler）
    // 一旦产生错误事件，在调试环境下将执行 fatalError，在发布环境下将打印错误信息。
    func way3() {
        let observer: Binder<String> = Binder(label) { (view, text) in
            view.text = text
        }
        
        observable.map { "当前索引数：\($0)" }.bind(to: observer).disposed(by: disposeBag)
    }
    
    // RxSwift 自带的可绑定属性
    func way4() {
        observable.map { "当前索引数：\($0)" }.bind(to: label.rx.text).disposed(by: disposeBag)
    }
    
    func buttonSelected() {
       let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        observable.map { $0 % 2 == 0 }.bind(to: button.rx.isEnabled).disposed(by: disposeBag)
    }
    
    // 自定义可绑定属性
    func customBind() {
        // Observable序列（每隔0.5秒钟发出一个索引数）
        let observable = Observable<Int>.interval(0.5, scheduler: MainScheduler.instance)
        observable
            .map { CGFloat($0) }
            .bind(to: label.rx.fontSize) // 根据索引数不断变放大字体
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: UILabel {
    public var fontSize: Binder<CGFloat> {
        return Binder(self.base) { label, fontSize in
            label.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
}
