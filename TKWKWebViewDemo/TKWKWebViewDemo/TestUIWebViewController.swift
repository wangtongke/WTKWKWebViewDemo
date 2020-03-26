//
//  TestUIWebViewController.swift
//  TKWKWebViewDemo
//
//  Created by 王同科 on 2020/3/26.
//  Copyright © 2020 王同科. All rights reserved.
//

import UIKit
import JavaScriptCore

class TestUIWebViewController: UIViewController, UIWebViewDelegate {

    var webView: UIWebView!
    var jsInstance = WebViewJSInstance()
    override func viewDidLoad() {
        super.viewDidLoad()
        jsInstance.vc = self
        webView = UIWebView.init(frame: self.view.frame)
        webView.delegate = self
        webView.delegate = self
        self.view.addSubview(webView)
        
         guard let path = Bundle.main.path(forResource: "test", ofType: "html"),
            let url = URL(string: path) else {
                return
        }
        
        webView.loadRequest(URLRequest(url: url))
    }
    
    func qqq(_ webView: UIWebView){
           
        
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        let con = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext
        con?.setObject(jsInstance, forKeyedSubscript: "TKApp" as NSCopying & NSObjectProtocol)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let con = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext
        con?.setObject(jsInstance, forKeyedSubscript: "TKApp" as NSCopying & NSObjectProtocol)
    }
   
    
    deinit {
        let con = webView?.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext
        con?.setObject(nil, forKeyedSubscript: "TKApp" as NSCopying & NSObjectProtocol)
        print("uiwebviewC deinit")
    }
}

@objc protocol WebViewJSExports : JSExport {
    func getUserPhone() -> String
    func showShare(_ param: JSValue, _ callBack: JSValue)
}

@objc class WebViewJSInstance: NSObject, WebViewJSExports {
    weak var vc: TestUIWebViewController?
    override init() {
        super.init()
    }
    func getUserPhone() -> String{
        return "110119"
    }
    
    func showShare(_ param: JSValue, _ callBack: JSValue) {
        DispatchQueue.main.async {
            let paramsJson = param.toString()
            let callStr = callBack.toString() ?? ""
            let ac1 = UIAlertAction.init(title: "取消", style: .cancel) { [weak self] (ac) in
                self?.vc?.webView?.stringByEvaluatingJavaScript(from: callStr + "(false)")
            }
            let ac2 = UIAlertAction.init(title: "确定", style: .default) { [weak self] (ac) in
                self?.vc?.webView?.stringByEvaluatingJavaScript(from: callStr + "(true)")
            }
            let alert = UIAlertController.init(title: "分享", message: paramsJson, preferredStyle: .alert)
            alert.addAction(ac1)
            alert.addAction(ac2)
            self.vc?.present(alert, animated: true, completion: nil)
        }
        
    }
}


