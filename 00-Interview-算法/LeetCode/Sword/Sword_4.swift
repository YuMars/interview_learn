//
//  Sword_4.swift
//  LeetCode
//
//  Created by Red-Fish on 2024/4/25.
//

import Foundation

/*
 LCR150
 一棵圣诞树记作根节点为 root 的二叉树，节点值为该位置装饰彩灯的颜色编号。请按照如下规则记录彩灯装饰结果：
 第一层按照从左到右的顺序记录
 除第一层外每一层的记录顺序均与上一层相反。即第一层为从左到右，第二层为从右到左。
 
 [8,17,21,18,null,null,6]
 
 1.
 */

public class Sword_4 {
    public func decorateRecord(_ root: TreeNode?) -> [[Int]] {
        
        guard root != nil else { return [] }
        
        var resultArray = [[Int]]()
        var queue = [TreeNode]()
        queue.append(root!)
        var level: Int = 0
        
        while queue.isEmpty == false {
            var temp:[Int] = [Int]()
            
            for _ in 0..<queue.count {
                let node: TreeNode = queue.removeFirst()
                temp.append(node.val)
                
                if let leftNode = node.left {
                    print("left:" , leftNode.val)
                    queue.append(leftNode)
                }
                
                if let rightNode = node.right {
                    print("right:",rightNode.val)
                    queue.append(rightNode)
                }
            }
            
            print(temp)
            
            if level % 2 == 0 {
                resultArray.append(temp.reversed())
            } else {
                resultArray.append(temp)
            }
            
            level += 1
        }
        
        return resultArray
    }
}
