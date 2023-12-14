//
//  TestViewController.swift
//  yeodam
//
//  Created by Kaltour_Dawoon on 12/13/23.
//

import UIKit
import WebKit
import SnapKit

class TestViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        
        

        
        // Create WKWebView
        webView = WKWebView()
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        // Set up constraints to fill the entire view
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
//        webView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
        
        
        
        
        
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), configuration: configuration)
        
        view.addSubview(webView)
        
        
        // Load a URL
        if let url = URL(string: "https://yeodam.kr/") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    
    func setupLayout(){
        
        
    }
    
}

// MARK: - WKNavigationDelegate

// Optional: Implement WKNavigationDelegate methods if needed
// For example, you can use webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)

// Sample delegate method:
// func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//     print("Web page loaded successfully")
// }


// Usage
let viewController = TestViewController()
// You can present it, push it onto a navigation stack, or embed it in a container view controller
