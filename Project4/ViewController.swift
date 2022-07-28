//
//  ViewController.swift
//  Project4
//
//  Created by Mehmet Ergün on 2022-07-27.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    var progressView: UIProgressView!
    var websites: [Websites] =  [.apple, .google]
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = URL(string: "https://" + Websites.google.rawValue) else {
            print("Check Url")
            return
        }

        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "PAGES", style: .plain, target: self, action: #selector(openTapped))
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload) )
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        
        toolbarItems = [progressButton, spacer, refresh]
        navigationController?.isToolbarHidden = false
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
    }
    
    @objc func openTapped() {
        let alert = UIAlertController(title: "Open Page...", message: nil, preferredStyle: .actionSheet)
        
        for website in websites {
            alert.addAction(UIAlertAction(title: website.rawValue, style: .default, handler: openPage))
        }
        
//        let applePage = UIAlertAction(title: Websites.apple.rawValue, style: .default, handler: openPage)
//        let googlePage = UIAlertAction(title: Websites.google.rawValue, style: .default, handler: openPage)
        
//        alert.addAction(applePage)
//        alert.addAction(googlePage)
        
        alert.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(alert, animated: true, completion: nil)
        
        
    }
    
    func openPage(action: UIAlertAction) {
        guard let actionTitle = action.title else {return}
        let url = URL(string: "https://" + actionTitle)
        
        guard let clickUrl = url else {return}
        
        webView.load(URLRequest(url: clickUrl))
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    override  func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        
        if let host = url?.host {
            for website in websites {
                if host.contains(website.rawValue) {
                    decisionHandler(.allow)
                    return
                }
            }
        }
        decisionHandler(.cancel)
    }
    
    enum Websites: String {
        case apple = "apple.com"
        case google = "google.com"
    }

}

