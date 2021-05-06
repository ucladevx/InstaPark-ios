//
//  FeedbackFormViewController.swift
//  InstaPark
//
//  Created by Yili Liu on 5/5/21.
//

import UIKit
import WebKit

class FeedbackFormViewController: UIViewController , WKNavigationDelegate{

    var webView: WKWebView!
    var backBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .purple
        button.addTarget(self, action: #selector(didTapBackBtn), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let topBar = UIView(frame: .init(x: 0, y: 0, width: self.view.frame.width, height: 40))
        topBar.backgroundColor = .white
        self.view.addSubview(topBar)
        backBtn.frame = .init(x: 15, y: 5, width: 30, height: 30)
        topBar.addSubview(backBtn)

        webView = WKWebView(frame: .init(x: 0, y: 40, width: self.view.frame.width, height: self.view.frame.height - 40))
        webView.navigationDelegate = self
        view.addSubview(webView)
        let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSe_KXDtthg8eI_FF2seSYHujRSaBCMt54nb01y0k_RBX5soVw/viewform?usp=sf_link")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        webView.showsLargeContentViewer = true
    }
    
    @objc func didTapBackBtn() {
        dismiss(animated: true)
    }

}
