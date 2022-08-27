//
//  ViewController.swift
//  ExWebView
//
//  Created by 김종권 on 2022/08/27.
//

import UIKit
import WebKit

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    WKWebsiteDataStore.default()
      .fetchDataRecords(
        ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()
      ) { records in
        records
          .forEach {
            WKWebsiteDataStore.default()
              .removeData(
                ofTypes: $0.dataTypes,
                for: [$0],
                completionHandler: {}
              )
          }
      }
    
    WKWebViewConfiguration.includeCookie(
      cookies: [.init()],
      completion: { configuration in
        guard let config = configuration else { return }
        let webView = WKWebView(frame: .zero, configuration: config)
        print("쿠키가 세팅된 webView 완성", webView)
      })
  }
}

extension WKWebViewConfiguration {
  static func includeCookie(cookies: [HTTPCookie], completion: @escaping (WKWebViewConfiguration?) -> Void) {
    let config = WKWebViewConfiguration()
    let dataStore = WKWebsiteDataStore.nonPersistent()
    
    DispatchQueue.main.async {
      let waitGroup = DispatchGroup()
      
      for cookie in cookies {
        waitGroup.enter()
        dataStore.httpCookieStore.setCookie(cookie) {
          waitGroup.leave()
        }
      }
      
      waitGroup.notify(queue: DispatchQueue.main) {
        config.websiteDataStore = dataStore
        completion(config)
      }
    }
  }
}
