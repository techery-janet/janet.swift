//
//  HTTPService.swift
//  Tesla
//
//  Created by Sergey Zenchenko on 8/14/16.
//  Copyright © 2016 Techery. All rights reserved.
//

import Foundation
import RxSwift

public class HTTPActionService : TypedActionService {
    public typealias ActionType = HTTPActionWireframe
  
    public var callback:ActionServiceCallback?
    
    let operationQueue:OperationQueue
    
    public init(concurrentOperationsCount:Int = 1) {
        self.operationQueue = OperationQueue()
        self.operationQueue.maxConcurrentOperationCount = concurrentOperationsCount
    }
    
    public func acceptsType(_ actionType:Any.Type) -> Bool {
        return actionType is HTTPActionWireframe.Type || actionType.self == HTTPActionWireframe.self
    }
    
    public func executeAction(_ action:HTTPActionWireframe) throws {
        guard let callback = self.callback else {
            fatalError("Callback is not setup for service: \(self)")
        }
        
        self.operationQueue.addOperation(HTTPActionOperation(action: action, callback: callback))
    }
    
    public func cancel(_ action: TeslaAction) {
        self.operationQueue.operations.forEach { (op) in
            if let httpOp = op as? HTTPActionOperation {
                if httpOp.action === action {
                    httpOp.cancel()
                }
            }
        }
    }
}
