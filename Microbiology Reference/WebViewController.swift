//
//  WebViewController.swift
//  Pathology Reference
//
//  Created by Cole Denkensohn on 11/12/17.
//  Copyright © 2017 Denkensohn. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, UIScrollViewDelegate, WKNavigationDelegate {
    
    @IBOutlet var myWebView: WKWebView!
    @IBOutlet weak var pageTitle: UINavigationItem!
    
    var passedURL:String = "Passed Website URL"
    var passedTitle:String = "Web Resource"
    
    @IBAction func actionButton(_ sender: Any) {

        // Open link in Safari rather than within app for full functionality
        let url = URL(string: passedURL)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func closeButton(_ sender: Any) {
        // Close view
        self.dismiss(animated: true, completion: nil)
    }
    
    //Create Activity Indicator
    let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        myActivityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        myActivityIndicator.stopAnimating()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        if currentReachabilityStatus == .notReachable { // If user has no internet
            // Notify user of updated data
            let alert = UIAlertController(title: "No Internet", message: "Network connection required to view online resources.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if currentReachabilityStatus != .notReachable { // Ensure user has internet
            
            // Load URL
            if let url = URL(string: passedURL){
                let req = NSURLRequest(url: url)
                self.myWebView.load(req as URLRequest)
            } else{
                // Note: Some valid links cause a nil error. csCopy and addingPercentEncoding fix the formatting for such links, but they break for formatting for other links. That is why we first try the standard link and then fix it if nil is returned.
                let csCopy = CharacterSet(bitmapRepresentation: CharacterSet.urlPathAllowed.bitmapRepresentation)
                let url = URL(string: passedURL.addingPercentEncoding(withAllowedCharacters: csCopy)!)!
                let req = NSURLRequest(url: url)
                self.myWebView.load(req as URLRequest)
            }
            
            self.myWebView.navigationDelegate = self
            
            // Start activity indicator
            myActivityIndicator.center = self.view.center
            self.myWebView.addSubview(myActivityIndicator)
            myActivityIndicator.startAnimating()
            
        }
        
        // Prepare Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        pageTitle.title = passedTitle
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
