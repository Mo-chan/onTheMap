//
//  WebViewController.swift
//  ontheMap
//
//  Created by Mohammad Awwad on 8/30/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import Foundation
import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var webView: UIWebView!
    
    var urlRequest: URLRequest? = nil
    var requestToken: String? = nil
    var completionHandler : ((_ success: Bool, _ errorString: String?) -> Void)? = nil
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        
        self.navigationItem.title = "Sign-in"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(WebViewController.cancelAuth))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if urlRequest != nil {
            self.webView.loadRequest(urlRequest!)
        }
    }
    
    func cancelAuth() {
        dismiss(animated: true, completion: nil)
    }
    
}
