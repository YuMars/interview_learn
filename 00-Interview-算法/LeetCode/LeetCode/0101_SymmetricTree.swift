//
//  0101_SymmetricTree.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/8/26.
//

import Foundation

public class SymmetricTree {
    
    // 递归
    public class func isSymmetric(_ root: TreeNode?) -> Bool {
        return isSymmetricT(root?.left, root?.right)
    }
    
    class func isSymmetricT(_ left: TreeNode?, _ right: TreeNode?) -> Bool {
        if left == nil && right == nil {
            return true
        } else if left == nil && right != nil {
            return false
        } else if left != nil && right == nil {
            return false
        } else if left?.val != right?.val {
            return false
        }
        
        // left 和 right 都不为空, 且数值也相等就递归
        let inSide = isSymmetricT(left?.right, right?.left)
        let outSide = isSymmetricT(left?.left, right?.right)
        return inSide && outSide
    }
    
    // 迭代-队列
    public class func isSymmetric2(_ root: TreeNode?) -> Bool {
        guard let _ = root else { return true }
        var queue = [TreeNode?]()
        queue.append(root?.left)
        queue.append(root?.right)
        while !queue.isEmpty {
            let t1 = queue.removeFirst()
            let t2 = queue.removeFirst()
            if t1 == nil && t2 == nil {
                continue
            }
            if t1 == nil || t2 == nil || t1?.val != t2?.val {
                return false
            }
            queue.append(t1?.left)
            queue.append(t2?.right)
            queue.append(t1?.right)
            queue.append(t2?.left)
        }
        return true
    }
    
    // 迭代-栈
    public class func isSymmetric3(_ root: TreeNode?) -> Bool {
        guard let root = root else {
                return true
            }
            var stack = [TreeNode?]()
            stack.append(root.left)
            stack.append(root.right)
            while !stack.isEmpty {
                let left = stack.removeLast()
                let right = stack.removeLast()
                
                if left == nil && right == nil {
                    continue
                }
                if left == nil || right == nil || left?.val != right?.val {
                    return false
                }
                stack.append(left!.left)
                stack.append(right!.right)
                stack.append(left!.right)
                stack.append(right!.left)
            }
            return true
    }
    
    // 递归解法逐一判断每一层值是否相等是否都为空
    public class func isSymmetric4(_ root: TreeNode?) -> Bool {
        return recursive(root?.left, root?.right)
    }
    
    public class func recursive(_ left: TreeNode?, _ right: TreeNode?) -> Bool{
        
        if left == nil && right == nil {
            return true
        } else if left == nil && right != nil {
            return false
        } else if left != nil && right == nil {
            return false
        } else if left?.val != right?.val {
            return false
        }
        
        var inside: Bool = recursive(left?.right, right?.left)
        var outside: Bool = recursive(left?.left, right?.right)
        return inside && outside
        
    }
    
    // 迭代解法-队列
    public class func isSymmetric5(_ root: TreeNode?) -> Bool {
        guard root != nil else {return true}
        
        var queue: [TreeNode?] = [TreeNode?]()
        queue.append(root?.left)
        queue.append(root?.right)
        
        while !queue.isEmpty {
            var left: TreeNode? = queue.removeFirst()
            var right: TreeNode? = queue.removeFirst()
            
            if left == nil && right == nil {
                continue
            } else if left != nil && right == nil {
                return false
            } else if left == nil && right != nil {
                return false
            } else if left?.val != right?.val {
                return false
            }
            
            queue.append(left?.left)
            queue.append(right?.right)
            queue.append(left?.right)
            queue.append(right?.left)

        }
        
        return true
    }
}
