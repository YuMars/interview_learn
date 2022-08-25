//
//  0107_BinaryTreeLevelOrderTraversal2.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/8/17.
//

import Foundation

public class BinaryTreeLevelOrderTraversal2 {
    public class func levelOrderBottom(_ root: TreeNode?) -> [[Int]] {
        var res = [[Int]]()
        guard let _ = root else { return res }
        
        var queue:[TreeNode?] = [root!]
        while !queue.isEmpty {
            var nextLevelArray = [Int]()
            
            for _ in 0..<queue.count {
                let node = queue.removeFirst()
                nextLevelArray.append(node!.val)
                if let node = node?.left {
                    queue.append(node)
                }
                
                if let node = node?.right {
                    queue.append(node)
                }
            }
            res.append(nextLevelArray)
        }
        return res.reversed()
    }
}
