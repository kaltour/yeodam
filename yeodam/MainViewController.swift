//
//  MainViewController.swift
//  yeodam
//
//  Created by Kaltour_Dawoon on 12/12/23.
//

import UIKit
import SafariServices
import WebKit
import SnapKit


class MainViewController: UIViewController {
    
    
    var safariViewController : SFSafariViewController?
    
    
    var webView: WKWebView = {
        let wv = WKWebView()
        
        return wv
    }()

//    var webViews = [WKWebView]()
    //    var webView = WKWebView()
    
    //    @IBOutlet weak var webView: WKWebView!
//    var webView: WKWebView!
    
    let refreshControl = UIRefreshControl()
    private var isFirstLoad: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true // fasle값으로하면 더블터치 X
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        var webView = WKWebView(frame: .zero, configuration: configuration)
        print("###RUNNING###")
        view = webView
        
        
        
        let screenSize: CGRect = UIScreen.main.bounds
        webView = createWebView(frame: screenSize, configuration: WKWebViewConfiguration())
        
        webView.allowsBackForwardNavigationGestures = true
        
        refreshControl.addTarget(self, action: #selector(refreshWebView(_:)), for: UIControl.Event.valueChanged)
        
        webView.scrollView.addSubview(refreshControl)
        webView.scrollView.bounces = true
        webView.allowsLinkPreview = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        let request = URLRequest(url: RealURL.myURL!) //let request = URLRequest(url: myURL!)
        
        webView.load(request)
        
        
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

    }
    
//    func layoutSetup() {
//        view.addSubview(webView)
//        webView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//    }

    @objc func refreshWebView( _ sender: UIRefreshControl) {
        print("###REFRESH###")
        webView.reload()
        sender.endRefreshing()
    }
    
//    override func loadView() {
//        super.loadView()
//        
//        //        webView = WKWebView(frame: self.container.bounds)
//        //        self.container.addSubview(webView)
//        let webConfiguration = WKWebViewConfiguration()
//        webConfiguration.allowsInlineMediaPlayback = true
//        
//        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
//        
//        webView = WKWebView(frame: .zero, configuration: webConfiguration)
//        let screenSize: CGRect = UIScreen.main.bounds
//        
//        
//        webView.allowsLinkPreview = false
//        
//        self.webView.configuration.dataDetectorTypes = .all
//        if #available(iOS 14.0, *) {
//            webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
//        } else {
//            // Fallback on earlier versions
//        }
//        webView.configuration.preferences.javaScriptEnabled = true
//        
//        webView.navigationDelegate = self
//        
//        webView.translatesAutoresizingMaskIntoConstraints = false
//        self.view.addSubview(webView)
//    }
    
}

extension MainViewController:WKNavigationDelegate, WKUIDelegate {
    
    func createWebView(frame: CGRect, configuration: WKWebViewConfiguration) -> WKWebView {
        let webView = WKWebView(frame: frame, configuration: configuration)
        configuration.allowsInlineMediaPlayback = true
        
        // set delegate
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        // 화면에 추가
        self.view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.top.equalTo(view).offset(5) // 탑만 세이프 영역
            make.trailing.leading.bottom.equalToSuperview()
        }
        // 웹뷰 목록에 추가
//        self.webViews.append(webView)
        
        // 그 외 서비스 환경에 최적화된 뷰 설정하기
        
        return webView
    }
    
    
//    func webView(_ webView: WKWebView,
//                 createWebViewWith configuration: WKWebViewConfiguration,
//                 for navigationAction: WKNavigationAction,
//                 windowFeatures: WKWindowFeatures
//    ) -> WKWebView? {
//        
//        guard let frame = self.webViews.last?.frame else {
//            print("웹뷰 라스트 프레임")
//            return nil
//        }
//        // 웹뷰를 생성하여 리턴하면 현재 웹뷰와 parent 관계가 형성됩니다.
//        return createWebView(frame: frame, configuration: configuration)
//    }
    
//    func destroyCurrentWebView() {
//        // 웹뷰 목록과 화면에서 제거하기
//        self.webViews.popLast()?.removeFromSuperview()
//        
//    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler()
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(nil)
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(false)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
//    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
//        // 중복적으로 리로드가 일어나지 않도록 처리 필요.
//        webView.reload()
//    }
    

    
}
