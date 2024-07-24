//
//  0048_RotateImage.swift
//  LeetCode
//
//  Created by Red-Fish on 2024/7/22.
//

import Foundation

/*
 给定一个 n × n 的二维矩阵 matrix 表示一个图像。请你将图像顺时针旋转 90 度。
 你必须在 原地 旋转图像，这意味着你需要直接修改输入的二维矩阵。请不要 使用另一个矩阵来旋转图像。
 
 方法一
 矩阵内坐标(row,col)转90度之后的位置是(col, n - row - 1)
 方法二
 matrix[row][col] 水平轴翻转 matrix[n−row−1][col]
 matrix[row][col] 主对角线翻转 matrix[col][row]
 
  
 */

public class RotateImage {
    public class func rotate(_ matrix: inout [[Int]]) {
        
        let n = matrix.count
        var arr = Array(repeating: Array(repeating: 0, count: n), count: n)
        
        for row in 0..<matrix.count {
            for col in 0..<matrix[row].count {
                arr[col][matrix.count - row - 1] = matrix[row][col]
            }
        }
        
        matrix = arr
    }
}
