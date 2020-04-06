//
//  TKWebMethod.swift
//  TKWKWebViewDemo
//
//  Created by 王同科 on 2020/3/26.
//  Copyright © 2020 王同科. All rights reserved.
//

import UIKit
@objcMembers
class TKWebMethod: NSObject {
    weak var vc: TestWKWebViewController?

    func getUserPhone() -> String{
        return "110119"
    }
    
    func showShare(_ param: String, _ callStr: String) -> CGFloat {
        DispatchQueue.main.async {
            let ac1 = UIAlertAction.init(title: "取消", style: .cancel) { [weak self] (ac) in
                self?.vc?.webView?.evaluateJavaScript(callStr + "(false)", completionHandler: nil)
            }
            let ac2 = UIAlertAction.init(title: "确定", style: .default) { [weak self] (ac) in
                self?.vc?.webView?.evaluateJavaScript(callStr + "(true)", completionHandler: nil)
            }
            let alert = UIAlertController.init(title: "分享", message: param, preferredStyle: .alert)
            alert.addAction(ac1)
            alert.addAction(ac2)
            self.vc?.present(alert, animated: true, completion: nil)
        }
        return 0.1
    }
    
    func showToast(_ msg: String, _ duration: String) -> Int {
        print("showToast")
        print(msg + "\(duration)")
        return 6
    }
    
    func aaaaaa() -> Float {
        return 0.1
    }
    
    func debuglog(_ str: String) {
        debugPrint(str)
    }
    
    deinit {
        debugPrint("TKWebMethod deinit")
    }
}
