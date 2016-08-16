//
//  HTTPActionOperation.swift
//  Tesla
//
//  Created by Sergey Zenchenko on 8/16/16.
//  Copyright © 2016 Techery. All rights reserved.
//

import Foundation

class HTTPActionOperation : ConcurrentOperation {
    
    public let action:HTTPActionWireframe
    
    let actionScheme:HTTPActionScheme
    let callback:ActionServiceCallback
    var activeTask:URLSessionDataTask?
    
    init(action:HTTPActionWireframe, callback:ActionServiceCallback) {
        self.action = action
        self.actionScheme = HTTPActionScheme.createFrom(action: action)
        self.callback = callback
    }
    
    override func start() {
        onStart()
        
        let request = createRequest(from: self.actionScheme)!
        let session = URLSession.shared
        
        self.activeTask = session.dataTask(with: request, completionHandler: self.onTaskFinished)
        self.activeTask?.resume()
    }
    
    func onStart() {
        self.state = .Executing
        self.callback.onStart(self.action)
    }
    
    func onSuccess() {
        self.callback.onSuccess(self.action)
        self.state = .Finished
    }
    
    func onError(_ error:Error) {
        self.callback.onError(self.action, error: error)
        self.state = .Finished
    }
    
    func onProgress(_ progress:Float) {
        self.callback.onProgress(self.action, progress: progress)
    }
    
    func onTaskFinished(data:Data?, response:URLResponse?, error:Error?) {
        if let err = error {
            onError(err)
        } else {
            if let responseData = data {
                if let responseString = String(data: responseData, encoding: String.Encoding.ascii) {
                    do {
                        
                        if let responseProperty = actionScheme.responses.first {
                            try responseProperty.set(responseString)
                        }
                        
                        onSuccess()
                    } catch {
                        onError(error)
                    }
                }
            }
        }
    }
    
    override func cancel() {
        self.activeTask?.cancel()
    }
    
    private func createQueryString(from scheme:HTTPActionScheme) -> String {
        let queryParams = scheme.queryFields.map { (prop:QueryFieldProperty) -> String in
            if let value = prop.get() {
                return "\(prop.name)=\(value)"
            }
            
            return ""
        }
        
        let queryString = queryParams.joined(separator: "&")
        
        if !queryString.isEmpty {
            return "?\(queryString)"
        } else {
            return ""
        }
    }
    
    private func createURL(from scheme:HTTPActionScheme) -> URL? {
        let urlString = scheme.path.value + createQueryString(from: scheme)
        
        let url = URL(string: urlString)
        
        return url
    }
    
    private func setHeaders(from scheme:HTTPActionScheme, to request:URLRequest) -> URLRequest {
        
        var mutableRequest = request
        
        scheme.requestHeaders.forEach({ (header) in
            if let value = header.value {
                mutableRequest.addValue(value, forHTTPHeaderField: header.name)
            }
        })
        
        return mutableRequest
    }
    
    private func createRequest(from scheme:HTTPActionScheme) -> URLRequest? {
        if let url = createURL(from: scheme) {
            var request = URLRequest(url: url)
            
            request.httpMethod = scheme.method.rawValue
            
            request = setHeaders(from: scheme, to: request)
            
            return request
        }
        
        return nil
    }
}
