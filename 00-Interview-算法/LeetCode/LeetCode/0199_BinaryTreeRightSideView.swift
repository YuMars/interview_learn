//
//  0199_BinaryTreeRightSideView.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/8/17.
//

import Foundation

public class BinaryTreeRightSideView {
    public class func rightSideView(_ root: TreeNode?) -> [Int] {
        var res = [Int]()
        guard let _ = root else { return res }
        
        var queue = [root]
        while !queue.isEmpty {
            let count = queue.count
            for index in 0..<queue.count {
                
                let node = queue.removeFirst()
                
                if index == count - 1 {
                    print(index , node!.val)
                    res.append(node!.val)
                }
                
                if let node = node?.left {
                    queue.append(node)
                }
                
                if let node = node?.right {
                    queue.append(node)
                }
            }
        }
        return res
    }
}
