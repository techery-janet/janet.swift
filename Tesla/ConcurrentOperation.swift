//
//  ConcurrentOperation.swift
//  Tesla
//
//  Created by Sergey Zenchenko on 8/16/16.
//  Copyright © 2016 Techery. All rights reserved.
//

import Foundation

class ConcurrentOperation : Operation {
    
    enum State {
        case Ready, Executing, Finished
        func keyPath() -> String {
            switch self {
            case .Ready:
                return "isReady"
            case .Executing:
                return "isExecuting"
            case .Finished:
                return "isFinished"
            }
        }
    }
    
    var state = State.Ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath())
            willChangeValue(forKey: state.keyPath())
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath())
            didChangeValue(forKey: state.keyPath())
        }
    }
    
    override var isReady: Bool {
        return super.isReady && state == .Ready
    }
    
    override var isExecuting: Bool {
        return state == .Executing
    }
    
    override var isFinished: Bool {
        return state == .Finished
    }
    
    override var isAsynchronous: Bool {
        return true
    }
}
