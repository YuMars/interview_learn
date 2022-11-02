//
//  0037_SudokuSolver.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/10/26.
//

import Foundation

/*
 编写一个程序，通过填充空格来解决数独问题。
 数独的解法需 遵循如下规则：
 数字 1-9 在每一行只能出现一次。
 数字 1-9 在每一列只能出现一次。
 数字 1-9 在每一个以粗实线分隔的 3x3 宫内只能出现一次。（请参考示例图）
 数独部分空格内已填入了数字，空白格用 '.' 表示。

 输入：board = [
 ["5","3",".",".","7",".",".",".","."],
 ["6",".",".","1","9","5",".",".","."],
 [".","9","8",".",".",".",".","6","."],
 ["8",".",".",".","6",".",".",".","3"],
 ["4",".",".","8",".","3",".",".","1"],
 ["7",".",".",".","2",".",".",".","6"],
 [".","6",".",".",".",".","2","8","."],
 [".",".",".","4","1","9",".",".","5"],
 [".",".",".",".","8",".",".","7","9"]]
 输出：[
 ["5","3","4","6","7","8","9","1","2"],
 ["6","7","2","1","9","5","3","4","8"],
 ["1","9","8","3","4","2","5","6","7"],
 ["8","5","9","7","6","1","4","2","3"],
 ["4","2","6","8","5","3","7","9","1"],
 ["7","1","3","9","2","4","8","5","6"],
 ["9","6","1","5","3","7","2","8","4"],
 ["2","8","7","4","1","9","6","3","5"],
 ["3","4","5","2","8","6","1","7","9"]]
 解释：输入的数独如上图所示，唯一有效的解决方案如下所示：
*/

public class SudokuSolver {
    
    public class func solveSudoku(_ board: inout [[Character]]) {
        // 判断对应格子的值是否合法
        backtracking1(&board)
    }
    
    @discardableResult
    public class func backtracking1(_ board: inout [[Character]]) -> Bool {
        for i in 0 ..< board[0].count { // i：行坐标
            for j in 0 ..< board[0].count { // j：列坐标
                guard board[i][j] == "." else { continue } // 跳过已填写格子
                // 填写格子
                for val in 1 ... 9 {
                    let charVal = Character("\(val)")
                    guard isValid1(row: i, col: j, val: charVal, board: &board) else { continue } // 跳过不合法的
                    board[i][j] = charVal // 填写
                    if backtracking1(&board) { return true }
                    board[i][j] = "." // 回溯：擦除
                }
                return false // 遍历完数字都不行
            }
        }
        return true // 没有不合法的，填写正确
    }
    
    public class func isValid1(row: Int, col: Int, val: Character, board: inout [[Character]]) -> Bool {
        // 行中是否重复
        for i in 0 ..< 9 {
            if board[row][i] == val { return false }
        }

        // 列中是否重复
        for j in 0 ..< 9 {
            if board[j][col] == val { return false }
        }

        // 9方格内是否重复
        let startRow = row / 3 * 3
        let startCol = col / 3 * 3
        for i in startRow ..< startRow + 3 {
            for j in startCol ..< startCol + 3 {
                if board[i][j] == val { return false }
            }
        }
        return true
    }
    
    public class func isValid(row: Int, col: Int, value: Character, board: inout [[Character]]) -> Bool {
        for i in 0 ..< 9 { // 遍历第i行，存在value说明value已经被占用，数字填充失败
            if board[row][i] == value {
                //print("第", row, "行", "第", i, "列:", board[row][i], "已经有")
                return false
            }
        }
        
        for i in 0 ..< 9 {// 遍历第i列，存在value说明value已经被占用，数字填充失败
            if board[i][col] == value {
                //print("第", i, "行", "第", col, "列:", board[i][col], "已经有")
                return false
            }
        }
        
        let startRow: Int = (row / 3) * 3 // 找到每3行的开头x坐标
        let startCol: Int = (col / 3) * 3 // 找到每3列的开头y左边
        for i in startRow ..< startRow + 3 {// 遍历3x3，存在value说明value已经被占用，数字填充失败
            for j in startCol ..< startCol + 3 {
                if board[i][j] == value { return false }
            }
        }
        //print("第", row, "行", "第", col, "列:", value, "确认")
        return true
    }
    
    @discardableResult
    public class func backtracking(board: inout [[Character]]) -> Bool {
        for i in 0 ..< board.count {
            for j in 0 ..< board[i].count {
                //print("第", i, "行", "第", j, "列:", board[i][j])
                guard board[i][j] == "." else { continue } // 当前是"."的才执行后面的逻辑
                for val in 1 ... 9 {
                    let char = Character("\(val)")
                    guard isValid(row: i, col: j, value: char, board: &board) else { continue } // 验证失败的跳过
                    board[i][j] = char
                    //print("第", i, "行", "第", j, "列:", "尝试:", char)
                    if backtracking(board: &board) {
                        //print("第", i, "行", "第", j, "列:", "匹配:", char)
                        return true
                    }
                    board[i][j] = "."
                }
                return false // 遍历完数字都不行
            }
        }
        return true
    }
    
    public class func solveSudoku2(_ board: inout [[Character]]) {
        // 有返回值，用false代表当前填的数字无效
        backtracking(board: &board)
    }
}
