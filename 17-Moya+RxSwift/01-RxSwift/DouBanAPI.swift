//
//  DouBanAPI.swift
//  01-RxSwift
//
//  Created by Qing ’s on 2018/12/13.
//  Copyright © 2018 Qing ’s. All rights reserved.
//

import Foundation
import Moya
import RxAtomic


//初始化豆瓣FM请求的provider
let DouBanProvider = MoyaProvider<DouBanAPI>()

/** 下面定义豆瓣FM请求的endpoints（供provider使用）**/
//请求分类
public enum DouBanAPI {
    case channels  //获取频道列表
    case playlist(String) //获取歌曲
    case uploadFile(value1: String, value2: Int, file1Data:Data, file2URL:URL) //上传文件
}

//请求配置
extension DouBanAPI: TargetType {
    public var baseURL: URL {
        switch self {
        case .channels:
            return URL(string: "https://www.douban.com")!
        case .playlist(_):
            return URL(string: "https://douban.fm")!
        case .uploadFile:
            return URL(string: "https://www.douban.com")!
        }
    }
    
    public var path: String {
        switch self {
        case .channels:
            return "/j/app/radio/channels"
        case .playlist(_):
            return "/j/mine/playlist"
        case .uploadFile:
            return "/upload.php"
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var task: Task {
        switch self {
        case .playlist(let channel):
            var params: [String: Any] = [:]
            params["channel"] = channel
            params["type"] = "n"
            params["from"] = "mainsite"
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case let .uploadFile(value1, value2, file1Data, file2URL):
            //字符串
            let strData = value1.data(using: .utf8)
            let formData1 = MultipartFormData(provider: .data(strData!), name: "value1")
            //数字
            let intData = String(value2).data(using: .utf8)
            let formData2 = MultipartFormData(provider: .data(intData!), name: "value2")
            //文件1
            let formData3 = MultipartFormData(provider: .data(file1Data), name: "file1",
                                              fileName: "haoqing.png", mimeType: "image/png")
            //文件2
            let formData4 = MultipartFormData(provider: .file(file2URL), name: "file2",
                                              fileName: "hao.png", mimeType: "image/png")
            
            let multipartData = [formData1, formData2, formData3, formData4]
            return .uploadMultipart(multipartData)
        default:
            return .requestPlain
        }
    }
    
    //这个就是做单元测试模拟的数据，只会在单元测试文件中有作用
    public var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
    
    //请求头
    public var headers: [String : String]? {
        return nil
    }
    
    
}


/*
//需要上传的文件
let file1URL = Bundle.main.url(forResource: "haoqing", withExtension: "png")!
let file1Data = try! Data(contentsOf: file1URL)
let file2URL = Bundle.main.url(forResource: "h", withExtension: "png")!
//通过Moya提交数据
MyServiceProvider.request(.uploadFile(value1: "haoqing", value2: 10,
                                      file1Data: file1Data, file2URL: file2URL)) {
                                        result in
                                        if case let .success(response) = result {
                                            //解析数据
                                            let data = try? response.mapString()
                                            print(data ?? "")
                                        }
}
*/


// http://www.hangge.com/blog/cache/detail_1806.html
