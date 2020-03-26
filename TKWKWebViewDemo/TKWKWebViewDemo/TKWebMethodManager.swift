//
//  TKWebMethodManager.swift
//  TKWKWebViewDemo
//
//  Created by 王同科 on 2020/3/26.
//  Copyright © 2020 王同科. All rights reserved.
//

import UIKit

class TKWebMethodManager: NSObject {
    weak var vc: TestWKWebViewController?
    
    /// 执行方法
    ///
    /// - Parameters:
    ///   - name: 方法名字
    ///   - callback: 回调方法
    ///   - completionHandler: 回调
    func exeMethod(_ name: String, callback: String?, completionHandler: @escaping (String?) -> Void) {
        var returnStr = ""
        switch name {
        case "getUserPhone":
            returnStr = getUserPhone()
            break
        case "showShare":
            showShare(callback ?? "")
            break
        default:
            break
        }
        completionHandler(returnStr)
    }
    
    func getUserPhone() -> String{
        return "110119"
    }
    
    func showShare(_ paramStr: String) {
        DispatchQueue.main.async {
            guard let data = paramStr.data(using: .utf8) else {
                return
            }
            let param = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any]
            let shareData = param?["param"] as? String
            let callStr = param?["callback"] as? String ?? ""
            let ac1 = UIAlertAction.init(title: "取消", style: .cancel) { [weak self] (ac) in
                self?.vc?.webView?.evaluateJavaScript(callStr + "(false)", completionHandler: nil)
            }
            let ac2 = UIAlertAction.init(title: "确定", style: .default) { [weak self] (ac) in
                self?.vc?.webView?.evaluateJavaScript(callStr + "(true)", completionHandler: nil)
            }
            let alert = UIAlertController.init(title: "分享", message: shareData, preferredStyle: .alert)
            alert.addAction(ac1)
            alert.addAction(ac2)
            self.vc?.present(alert, animated: true, completion: nil)
        }
        
    }
}
