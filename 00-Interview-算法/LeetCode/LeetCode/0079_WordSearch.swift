//
//  0079_WordSearch.swift
//  LeetCode
//
//  Created by Red-Fish on 2024/7/31.
//

import Foundation

/*
 给定一个 m x n 二维字符网格 board 和一个字符串单词 word 。如果 word 存在于网格中，返回 true ；否则，返回 false 。
 单词必须按照字母顺序，通过相邻的单元格内的字母构成，其中“相邻”单元格是那些水平相邻或垂直相邻的单元格。同一个单元格内的字母不允许被重复使用.
 */

public class WordSearch {
    public class func exist(_ board: [[Character]], _ word: String) -> Bool {
        guard board.count > 0 else { return false }
        
        var result: Bool = false
        var visited: [[Bool]] = Array(repeating: Array(repeating: false, count: board.first!.count), count: board.count)
        let wordArray: [Character] = Array(word)
        for i in 0..<board.count {
            for j in 0..<board[i].count {
                result = backtracking(board, wordArray, i , j, 0, &visited)
                if result == true {
                    return result
                }
            }
        }
        
        return result
    }
    
    public class func backtracking(_ board: [[Character]], _ array: [Character], _ i: Int, _ j: Int, _ index: Int, _ visits: inout [[Bool]]) -> Bool {
        
        if index >= array.count {
            return true
        }
        
        if i < 0 || j < 0 || i >= board.count || j >= board[i].count {
            return false
        }
        
        if board[i][j] != array[index] {
            return false
        }
        
        if visits[i][j] == true {
            return false
        }
        
        visits[i][j] = true
        
        if backtracking(board, array, i + 1, j, index + 1, &visits)
            || backtracking(board, array, i - 1, j, index + 1, &visits)
            || backtracking(board, array, i, j + 1, index + 1, &visits)
            || backtracking(board, array, i, i - 1, index + 1, &visits) {
            return true
        }
        
        visits[i][j] = false
        
        return false
    }
}
