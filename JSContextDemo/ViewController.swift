//
//  ViewController.swift
//  JSContextDemo
//
//  Created by Krzysztof Deneka on 06.02.2017.
//  Copyright © 2017 biz.blastar.jscontextdemo. All rights reserved.
//

import UIKit
import JavaScriptCore

class ViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var webview: UIWebView!
    @IBOutlet weak var textfield: UITextField!

    var authenticated: SSLAuthenticate?
    var urlSession: URLSession?
    override func viewDidLoad() {
        super.viewDidLoad()
        webview.delegate = self
        let urlStr = "https://hacnm2g:123456@www.hkg2vl1716.p2g.netd2.hsbc.com.hk/app-mobile"
//        let url = Bundle.main.url(forResource: "web", withExtension: "html")
        let url = URL(string: urlStr)
        webview.loadRequest(URLRequest(url: url!))
    }

    @IBAction func textfieldChanged(_ sender: UITextField) {
        self.webview.stringByEvaluatingJavaScript(from: "changeText('"+sender.text!+"')")

    }

    func webViewDidStartLoad(_ webView: UIWebView) {
        let ctx = webview.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as! JSContext
        ctx.setObject(unsafeBitCast(AppTokenActivation.self, to: AnyObject.self), forKeyedSubscript: "appTokenActivation" as (NSCopying & NSObjectProtocol)!)
        let textChanged: @convention(block) (String) -> () =
        { newtext in
            print("text changed \(newtext)")
            self.textfield.text = newtext
        }
        ctx.setObject(unsafeBitCast(textChanged, to: AnyObject.self), forKeyedSubscript: "textChanged" as (NSCopying & NSObjectProtocol)!)
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {}

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if authenticated == nil {
            authenticated = .neverAuthenticate
            let configuration = URLSessionConfiguration.default

            urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
            let dataTask = urlSession?.dataTask(with: request, completionHandler: { (_, _, error) in
                webView.loadRequest(request)
                if error != nil {
                    print(error?.localizedDescription ?? "")
                } else {
                    //                    let str = String(data: data!, encoding: String.Encoding.utf8)
                    print("访问成功")
                    //                    print(str)
                }
            })
            dataTask?.resume()
            return false
        }
        return true
    }

}

extension ViewController: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let credential = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, credential)
            return
        } else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic {
            let credential = URLCredential(user: "hacnm2g", password: "123456", persistence: URLCredential.Persistence.forSession)
            completionHandler(.useCredential, credential)
            return
        }
        completionHandler(.performDefaultHandling, nil)
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        authenticated = .alwaysAuthenticate
    }
}


@objc protocol CommunicationProtocol: JSExport {
    static func callNative(_ mytext: String)
    static func successActivated()
}

@objc class AppTokenActivation: NSObject, CommunicationProtocol {
    class func callNative(_ mytext: String) {
        print("Native function called \(mytext)")
    }

    class func successActivated() {
        print("successActiviated")
    }

}
