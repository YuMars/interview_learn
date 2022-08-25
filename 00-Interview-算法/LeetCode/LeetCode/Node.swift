//
//  Node.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/8/17.
//

import Foundation

public class Node {
    public var val: Int
    public var children: [Node]
    public init(_ val: Int) {
        self.val = val
        self.children = []
        
        self.left = nil
        self.right = nil
        self.next = nil
    }
    
    public var left: Node?
    public var right: Node?
    public var next: Node?
}

