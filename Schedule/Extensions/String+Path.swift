//
//  String+Path.swift
//  ios-FMDB-demo
//
//  Created by OkuderaYuki on 2017/03/14.
//  Copyright © 2017年 YukiOkudera. All rights reserved.
//

import Foundation

public extension String {
    
    private var ns: NSString {
        return (self as NSString)
    }
    
    public func appendingPathComponent(_ str: String) -> String {
        return ns.appendingPathComponent(str)
    }
}
