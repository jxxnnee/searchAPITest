//
//  WebViewController.swift
//  searchAPITest
//
//  Created by 민경준 on 22/09/2019.
//  Copyright © 2019 민경준. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    var wikiURL : String = "https://www.naver.com"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.request(url: wikiURL)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func modalDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func request(url : String) {
        self.webView.load(URLRequest(url: URL(string: url)!))
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
