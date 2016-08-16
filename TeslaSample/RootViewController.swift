//
//  RootViewController.swift
//  Tesla
//
//  Created by Sergey Zenchenko on 8/9/16.
//  Copyright © 2016 Techery. All rights reserved.
//

import UIKit
import RxSwift
import WebKit
import Tesla

enum API {
    class GoogleAction : HTTPAction<String> {
        let path = Path("https://google.com/")
        let method = HTTPMethod.GET
        
        let query = QueryField<String>("q")
        
        let acceptsHeader = Header("accepts", "json")
        
        init(_ q:String) {
            super.init()
            query.value = q
        }
    }
}

extension UIActivityIndicatorView {
    func observePipe<T>(actionPipe:ActionPipe<T>) {
        actionPipe.observe().observeOn(MainScheduler.instance).subscribeNext { [weak self] (actionState) in
            if case .Running(_) = actionState {
                self?.startAnimating()
            } else {
                self?.stopAnimating()
            }
        }
    }
}

enum Root {
    
    class ViewController : UIViewController {
        
        let tesla = Tesla([HTTPActionService()])
        let googlePipe:ActionPipe<API.GoogleAction>
        
        lazy var webviewView:WKWebView = {
            let tv = WKWebView(frame: self.view.frame)
            tv.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            return tv
        }()
        
        init() {
            self.googlePipe = tesla.createPipe(API.GoogleAction.self)
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            self.view.backgroundColor = UIColor.white
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Reload", style: .plain, target: self, action: #selector(reload))
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
            
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            
            indicator.hidesWhenStopped = true
            indicator.observePipe(actionPipe: self.googlePipe)
            
            self.navigationItem.titleView = indicator
            
            self.view.addSubview(self.webviewView)
            
            self.googlePipe.observe().observeOn(MainScheduler.instance).subscribeNext { (actionState) in
                switch actionState {
                case .Success(let action):
                    self.webviewView.loadHTMLString(action.result.value ?? "", baseURL: URL(string: "https://google.com/"))
                case .Error(_, _):
                    self.webviewView.loadHTMLString("", baseURL: nil)
                case .Running(_):
                    break
                }
            }
        }
        
        func reload() {
            self.googlePipe.send(API.GoogleAction("janet"))
        }
        
        func cancel() {
            self.googlePipe.cancelLatest()
        }
    }

}

