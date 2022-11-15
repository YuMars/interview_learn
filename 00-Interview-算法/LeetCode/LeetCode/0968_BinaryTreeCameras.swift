//
//  0968_BinaryTreeCameras.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/11/14.
//

import Foundation
/*
 给定一个二叉树，我们在树的节点上安装摄像头。
 节点上的每个摄影头都可以监视其父对象、自身及其直接子对象
 计算监控树的所有节点所需的最小摄像头数量。
 示例 1：
 输入：[0,0,null,0,0] 输出：1
 解释：如图所示，一台摄像头足以监控所有节点。
 示例 2：
 输入：[0,0,null,0,null,0,null,null,0] 输出：2
 解释：需要至少两个摄像头来监视树的所有节点。 上图显示了摄像头放置的有效位置之一。
 */

public class BinaryTreeCameras {
    
    public func minCameraCover(_ root: TreeNode?) -> Int {
        
        func traversal(_ node: TreeNode?) -> Int {
            
            //0：该节点无覆盖
            //1：本节点有摄像头
            //2：本节点有覆盖
            
            // 空节点，该节点有覆盖
            if (node == nil) {
                return 2
            }
            
            let left: Int = traversal(node?.left) // 左
            let right: Int = traversal(node?.right) // 右
            
            // 左右节点都有覆盖
            if left == 2 && right == 2 {
                return 0
            }
            
            // 左右节点至少有一个无覆盖的情况
            // left == 0 && right == 0 左右节点无覆盖
            // left == 1 && right == 0 左节点有摄像头，右节点无覆盖
            // left == 0 && right == 1 左节点有无覆盖，右节点摄像头
            // left == 0 && right == 2 左节点无覆盖，右节点覆盖
            // left == 2 && right == 0 左节点覆盖，右节点无覆盖
            if left == 0 || right == 0 {
                result += 1
                return 1
            }
            
            // 左右节点至少有一个摄像头
            // left == 1 && right == 2 左节点有摄像头，右节点有覆盖
            // left == 2 && right == 1 左节点有覆盖，右节点有摄像头
            // left == 1 && right == 1 左右节点都有摄像头
            // 其他情况前段代码均已覆盖
            if left == 1 || right == 1 {
                return 2
            }
            
            // 中
            return -1
        }
        
        var result = 0
        // 头结点没有覆盖
        if traversal(root) == 0 {
            result += 1
        }
        return result
        
    }
    
    
}
