//
//  TestWKWebViewController.swift
//  TKWKWebViewDemo
//
//  Created by 王同科 on 2020/3/26.
//  Copyright © 2020 王同科. All rights reserved.
//

import UIKit
import WebKit

class TestWKWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate  {

    var webView: WKWebView!
    lazy var jsManager: TKWebMethodManager = {
        let m = TKWebMethodManager()
        return m
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebView()
        jsManager.vc = self
    }
    
    func loadWebView() {
        
        let configuration = WKWebViewConfiguration()
        // 添加TKApp替代方法
        let tkapp = WKUserScript.init(source: getJSString(), injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
        // 添加js调用
        configuration.userContentController.addUserScript(tkapp)
        webView = WKWebView(frame: self.view.frame, configuration: configuration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        
//       加载本地html
        let path = Bundle.main.path(forResource: "test", ofType: "html") ?? ""
        if let r = URL.init(string: path, relativeTo: URL.init(fileURLWithPath: Bundle.main.bundlePath)) {
            let request = URLRequest(url: r)
            self.webView.load(request)
        }
    }
    /// 获取要注入js事件
    func getJSString() -> String {
        let name = "jsMethod.js"
            guard let path = Bundle.main.path(forResource: name, ofType: nil),
                let data = NSData(contentsOfFile: path)
                else {
                    return ""
            }
            let mStr = String.init(data: data as Data, encoding: .utf8) ?? ""
        return mStr
    }
    
    deinit {
        print("wkwebviewC deinit")
    }

}
/// web代理
extension TestWKWebViewController {
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        jsManager.exeMethod(prompt, callback: defaultText, completionHandler: completionHandler)
    }
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController.init(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "确定", style: .default, handler: { (ac) in
            completionHandler()
        }))
        self.present(alert, animated: true) { }
    }
}
