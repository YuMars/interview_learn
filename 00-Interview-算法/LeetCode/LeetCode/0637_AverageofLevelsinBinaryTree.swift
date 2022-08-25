//
//  0637_AverageofLevelsinBinaryTree.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/8/17.
//

import Foundation

public class AverageofLevelsinBinaryTree {
    public class func averageOfLevels(_ root: TreeNode?) -> [Double] {
        var res = [Double]()
        guard let _ = root else { return res }
        var queue:[TreeNode?] = [root]
        while !queue.isEmpty {
            var total: Double = 0
            let count: Int = queue.count
            for _ in 0..<queue.count {
                let node = queue.removeFirst()
                total += Double(node!.val)
                
                if let node = node?.left {
                    queue.append(node)
                }
                
                if let node = node?.right {
                    queue.append(node)
                }
            }
            
            res.append(Double(total / Double(count)))
        }
        
        return res
    }
}
