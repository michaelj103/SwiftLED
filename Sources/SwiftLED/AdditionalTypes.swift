//
//  AdditionalTypes.swift
//  
//
//  Created by Michael Brandt on 4/5/23.
//

public struct Size {
    public let width: Int
    public let height: Int
    
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
}

public struct Color {
    public let r: UInt8
    public let g: UInt8
    public let b: UInt8
    
    public init(r: UInt8, g: UInt8, b: UInt8) {
        self.r = r
        self.g = g
        self.b = b
    }
}

public struct Pixel {
    public let x: Int32
    public let y: Int32
    
    public init(x: Int32, y: Int32) {
        self.x = x
        self.y = y
    }
}
