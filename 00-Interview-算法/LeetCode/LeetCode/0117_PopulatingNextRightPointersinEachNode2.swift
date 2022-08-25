//
//  0117_PopulatingNextRightPointersinEachNode2.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/8/18.
//

import Foundation

public class PopulatingNextRightPointersinEachNode2 {
    public class func connect(_ root: Node?) -> Node? {
        guard let _ = root else { return root }
        
        var queue = [root]
        while !queue.isEmpty {
            
            let count: Int = queue.count
            var previous, currrent: Node!
            
            for index in 0..<count {
                if index == 0 {
                    previous = queue.removeFirst()
                    currrent = previous
                } else {
                    currrent = queue.removeFirst()
                    previous.next = currrent
                    previous = currrent
                }
                
                if let node = currrent.left {
                    queue.append(node)
                }
                
                if let node = currrent.right {
                    queue.append(node)
                }
            }
            previous.next = nil
        }
        return root
    }
}
