//
//  MainViewController.swift
//  yeodam
//
//  Created by Kaltour_Dawoon on 12/12/23.
//

import UIKit
import WebKit
import SnapKit
import Firebase
import FirebaseAnalytics

class MainViewController: UIViewController {
    var isScrolling = false
    var wkWebView: WKWebView!
    
    let refreshControl = UIRefreshControl()

    var webView: WKWebView = {
        let wv = WKWebView()
        return wv
    }()
    
    var myView: UIView = {
        let mv = UIView()
        return mv
    }()

    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(myView)
        myView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        Analytics.logEvent("iOSViewControlllerLoad", parameters: nil)
        
//        setupLayout()
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        if #available(iOS 14.5, *) {
            webConfiguration.preferences.isTextInteractionEnabled = false
        } else {
            // Fallback on earlier versions
        }
        
//        wkWebView = WKWebView(frame: CGRect(x: 0, y: 70, width: view.frame.width, height: self.view.bounds.height - 75), configuration: webConfiguration)
        
        let statusBarHeight = UIApplication.shared.statusBarFrame.height + 5
        
        wkWebView = WKWebView(frame: CGRect(x: 0, y: statusBarHeight, width: view.frame.width, height: self.view.frame.height - statusBarHeight), configuration: webConfiguration)

        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
        wkWebView.configuration.allowsInlineMediaPlayback = true
//        wkWebView?.backgroundColor = .white
        wkWebView.scrollView.bounces = false

        
        
        //        webUIView.addSubview(wkWebView!)
        //MARK: URL
        let url = URL(string: "https://yeodam.kr/")!
        wkWebView.load(URLRequest(url: url))
        
        wkWebView.allowsBackForwardNavigationGestures = true
        refreshControl.addTarget(self, action: #selector(refreshWebView(_:)), for: UIControl.Event.valueChanged)
        
        wkWebView.scrollView.addSubview(refreshControl)
        wkWebView.scrollView.bounces = true
//        wkWebView.scrollView.delegate = self
        wkWebView.allowsLinkPreview = false
        wkWebView.configuration.preferences.javaScriptEnabled = true
        wkWebView.translatesAutoresizingMaskIntoConstraints = true
        
    
        
        view.addSubview(wkWebView!)

    }
    
    func setupLayout(){
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(100)
        }
    }

    @objc func refreshWebView( _ sender: UIRefreshControl) {
        print("###REFRESH###")
        wkWebView.reload()
        sender.endRefreshing()
    }
}

extension MainViewController:WKNavigationDelegate, WKUIDelegate {
    
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        if let url = navigationAction.request.url, url.scheme != "http" && url.scheme != "https" {
            UIApplication.shared.open(url, options: [:]) { (success) in
                if !(success) {
                    
                }
            }
            print("외부 결제 앱 이동")
        }

        if let urlStr = navigationAction.request.url?.absoluteString {
            print("URL STRING: \(urlStr)")
        }
        print(navigationAction.request.url?.absoluteString ?? "")
//        HTTPCookieStorage.setWKCookie(webView){completion in
//
//            var request = navigationAction.request
//            let cookies = HTTPCookie.requestHeaderFields(with: HTTPCookieStorage.shared.cookies(for: request.url!)!)
//            if let value = cookies["Cookie"]{
//                NSLog("webView Cookies : \(value)")
//                request.addValue(value, forHTTPHeaderField: "Cookie")
//            }
//        }
        //                decisionHandler(.allow)
        // 카카오 SDK가 호출하는 커스텀 스킴인 경우 open(_ url:) 메소드를 호출합니다.
        if let url = navigationAction.request.url
            , ["kakaokompassauth","kakaoplus","storylink"].contains(url.scheme) {
            // 카카오톡, 카스, 밴드 실행, 디바이스에 해당 앱이 안깔려있으면 실행X 앱스토어로 이동하는 코드를 넣어야될듯
            UIApplication.shared.open(url, options: [:], completionHandler: nil)

            print("\(navigationAction.request.url) 외부 앱 이동")
            decisionHandler(.cancel)
            return
        }

        else if let url = navigationAction.request.url {
            
            if ["tel", "sms"].contains(url.scheme) && UIApplication.shared.canOpenURL(url) { // 전화 및 문자 스킴 발동
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
        
        if navigationAction.navigationType == .linkActivated  { // a blank 처리
            if let url = navigationAction.request.url,
               let host = url.host, !host.hasPrefix("yeodam.kr"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                print(url)
                print("외부 사파리로 열기")
                //                decisionHandler(.cancel)
                return
            } else {
                print("웹뷰 안에서 이동")
                //decisionHandler(.allow)
                return
            }
        } else {
            print("아무것도 클릭하지 않음")
            //            decisionHandler(.allow)
            return
        }
        // 서비스 상황에 맞는 나머지 로직을 구현.
        //        decisionHandler(.allow)
    }
    
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            completionHandler()
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in
            completionHandler(nil)
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in
            completionHandler(false)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        // 중복적으로 리로드가 일어나지 않도록 처리 필요.
        webView.reload()
    }
    

    
}

//extension MainViewController: UIScrollViewDelegate {
//    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        guard !isScrolling else { return }
//        isScrolling = true
//        
//        if scrollView.contentOffset.y <= 0 {
//            scrollView.contentOffset = CGPoint.zero
//        }
//        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height {
//            let offset = CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentSize.height - scrollView.bounds.size.height)
//            scrollView.setContentOffset(offset, animated: false)
//        }
//        
//        isScrolling = false
//    }
//    
//}
