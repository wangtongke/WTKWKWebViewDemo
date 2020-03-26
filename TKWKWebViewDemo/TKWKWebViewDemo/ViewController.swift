//
//  ViewController.swift
//  TKWKWebViewDemo
//
//  Created by 王同科 on 2020/3/26.
//  Copyright © 2020 王同科. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    func configView() {
        view.backgroundColor = .white
        let testOne = UIButton.init(type: .custom)
        testOne.backgroundColor = .black
        testOne.frame = CGRect(x: 100, y: 200, width: 150, height: 40)
        testOne.center.x = self.view.center.x
        testOne.setTitle("测试UIWebView", for: .normal)
        testOne.addTarget(self, action: #selector(goToUIWebView), for: .touchUpInside)
        self.view.addSubview(testOne)
        
        let testTwo = UIButton.init(type: .custom)
        testTwo.backgroundColor = .black
        testTwo.frame = CGRect(x: 100, y: 350, width: 150, height: 35)
        testTwo.center.x = self.view.center.x
        testTwo.setTitle("测试WKWebView", for: .normal)
        testTwo.addTarget(self, action: #selector(goToWKWebView), for: .touchUpInside)
        self.view.addSubview(testTwo)
    }
    
    @objc func goToUIWebView() {
        let vc = TestUIWebViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc func goToWKWebView() {
        let vc = TestWKWebViewController()
        navigationController?.pushViewController(vc, animated: true)
    }


}

