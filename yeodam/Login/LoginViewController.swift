//
//  LoginViewController.swift
//  yeodam
//
//  Created by Kaltour_Dawoon on 12/19/23.
//
//⭐️⭐️⭐️⭐️⭐️⭐️⭐️
import UIKit
import AuthenticationServices
import WebKit

class LoginViewController: UIViewController {

     var webView: WKWebView!
     
     override func viewDidLoad() {
         super.viewDidLoad()
         
         setWebView()
     }
    
     override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         
         load()
     }

     func setWebView() {
         let contentController = WKUserContentController()
         
         // Bridge 등록
         contentController.add(self, name: "back")
         contentController.add(self, name: "outLink")
         
         let configuration = WKWebViewConfiguration()
         configuration.userContentController = contentController
         
         webView = WKWebView(frame: .zero, configuration: configuration)
         view.addSubview(webView)
         
         webView.translatesAutoresizingMaskIntoConstraints = false
         webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
         webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
         webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
         webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
     }

     func load() {
         if let url = Bundle.main.url(forResource: "Example", withExtension: "html") {
             webView.loadFileURL(url, allowingReadAccessTo: url)
         }
     }
}

extension LoginViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "back":
            
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email] //유저로 부터 알 수 있는 정보들(name, email)
                   
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
            
//            let alert = UIAlertController(title: nil, message: "Back 버튼 클릭", preferredStyle: .alert)
//            let action = UIAlertAction(title: "확인", style: .default, handler: nil)
//            alert.addAction(action)
//            self.present(alert, animated: true, completion: nil)
        case "outLink":
            guard let outLink = message.body as? String, let url = URL(string: outLink) else {
                return
            }
            
            let alert = UIAlertController(title: "OutLink 버튼 클릭", message: "URL : \(outLink)", preferredStyle: .alert)
            let openAction = UIAlertAction(title: "링크 열기", style: .default) { _ in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            alert.addAction(openAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
        default:
            break
        }
    }
}
extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding{
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    //로그인 성공
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // You can create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            var email = appleIDCredential.email
            
            if  let authorizationCode = appleIDCredential.authorizationCode,
                let identityToken = appleIDCredential.identityToken,
                let authCodeString = String(data: authorizationCode, encoding: .utf8),
                let identifyTokenString = String(data: identityToken, encoding: .utf8) {
                print("authorizationCode: \(authorizationCode)")
                print("identityToken: \(identityToken)")
                print("authCodeString: \(authCodeString)")
                print("identifyTokenString: \(identifyTokenString)")
            }
            
            
            print("useridentifier: \(userIdentifier)")
            print("fullName: \(fullName)")
            print("email: \(email)")
            
            
            

            //Move to MainPage
            let validVC = SignValidViewController()
            
            validVC.modalPresentationStyle = .fullScreen
            present(validVC, animated: true, completion: nil)
            
            

            
            
        case let passwordCredential as ASPasswordCredential:
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            print("username: \(username)")
            print("password: \(password)")
            
        default:
            break
        }
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 로그인 실패(유저의 취소도 포함)
        print("login failed - \(error.localizedDescription)")
    }
}
