//
//  Actions.swift
//  Tesla
//
//  Created by Sergey Zenchenko on 8/9/16.
//  Copyright © 2016 Techery. All rights reserved.
//

import Foundation

public class TeslaActionWithResult<R> : TeslaAction {
    public let result = Response<R>()
    
    public init() {
        
    }
}

public protocol HTTPActionWireframe : TeslaAction {
    
}

public class HTTPAction<R> : TeslaActionWithResult<R>, HTTPActionWireframe {
    
}

public enum HTTPMethod : String {
    case GET
    case POST
    case PUT
    case DELETE
    case HEAD
}

public protocol NamedProperty : Property {
    var name:String { get }
}

public class NamedField<T> : PropertyDecorator<T>, NamedProperty {
    public let name:String
    let isOptional:Bool
    
    public init(_ name:String, isOptional:Bool) {
        self.name = name
        self.isOptional = isOptional
    }
    
    public init(_ name:String) {
        self.name = name
        self.isOptional = false
    }
}

public protocol FormFieldProperty : NamedProperty {}
public class FormField<T> : NamedField<T>, FormFieldProperty {}

public protocol QueryFieldProperty : NamedProperty {}
public class QueryField<T>  : NamedField<T>, QueryFieldProperty {}

public protocol PathFieldProperty : NamedProperty {}
public class PathField<T>  : NamedField<T>, PathFieldProperty {}


public class Header : NamedField<String> {
    public init(_ name: String, _ val:String) {
        super.init(name)
        self.value = val
    }
}

public struct Path  {
    let value:String
    
    public init(_ value:String) {
        self.value = value
    }
}

public protocol BodyProperty : ReadonlyProperty {}
public struct Body<T> : BodyProperty {
    let value:T
    
    public init(_ value:T) {
        self.value = value
    }
    
    public func get() -> Any? {
        return self.value
    }
    
    public func valueType() -> Any.Type {
        return T.self
    }
}

public protocol ResponseProperty : Property {}
public class Response<T> : PropertyDecorator<T>, ResponseProperty {
    let code:Int
    
    public init(code:Int = 0) {
        self.code = code
    }
}
