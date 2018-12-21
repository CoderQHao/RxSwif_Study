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
import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    //负责对象销毁
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        way2()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SwiftCell")
    }

    func way1() {
        //获取数据
        DouBanProvider.rx.request(.channels)
            .subscribe { event in
                switch event {
                case let .success(response):
                    //数据处理
                    let str = String(data: response.data, encoding: String.Encoding.utf8)
                    print("返回的数据是：", str ?? "")
                case let .error(error):
                    print("数据请求失败!错误原因：", error)
                }
            }.disposed(by: disposeBag)
    }
    
    func way2() {
        DouBanProvider.rx.request(.channels)
            .subscribe(onSuccess: { (response) in
                //数据处理
                let str = String(data: response.data, encoding: String.Encoding.utf8)
                print("返回的数据是：", str ?? "")
            }) { (error) in
                print("数据请求失败!错误原因：", error)
        }.disposed(by: disposeBag)
    }

}

