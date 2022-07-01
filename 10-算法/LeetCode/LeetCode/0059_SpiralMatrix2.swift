//
//  0059_SpiralMatrix2.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/1.
//

import Foundation

class SpiralMatrix2 {
    /*
     n = 2
     [[1,2],
      [4,3]]
     
     n = 3
     [[1,2,3],
      [8,9,4],
      [7,6,5]
     
     n = 4
     [[1,  2,  3,  4],
      [12, 13, 14, 5],
      [11, 16, 15, 6],
      [10,  9,  8, 7],]
     
     n = 5
     [[1,  2,  3,  4, 5],
      [16, 17, 18, 19, 6],
      [15, 24, 25, 20, 7],
      [14, 23, 22, 21, 8],
      [13, 12, 11, 10, 9],]
     */
    public class func generateMatrix(_ n: Int) -> [[Int]] {
        
        var resultArray: Array = Array(repeating: Array(repeating: 0, count: n), count: n)
        var offsetX: Int = 0
        var offsetY: Int = 0
        var turnCount: Int = 1
        var count:Int = 1
        while turnCount < (2 * n) {
            // 左->右 1 5
            
            offsetX = turnCount / 4
            offsetY = turnCount / 4
            
            if turnCount % 4 == 1 {
                
                let num = (turnCount - 1) / 4 // 第几圈-1
                let a = n - (num * 2) - 1    // 所在圈的宽度 - 1
                for _ in 0..<a {
                    resultArray[offsetY][offsetX] = count
                    offsetX += 1
                    count += 1
                }
                
                turnCount += 1
            }
            
            // 上->下 2 6
            if turnCount % 4 == 2 {
                let num = (turnCount - 1) / 4
                let a = n - (num * 2) - 1
                for _ in 0..<a {
                    resultArray[offsetY][offsetX] = count
                    offsetY += 1
                    count += 1
                }
                turnCount += 1
            }
            
            // 右->左 3 7
            if turnCount % 4 == 3 {
                let num = (turnCount - 1) / 4
                let a = n - (num * 2) - 1
                for _ in 0..<a {
                    
                    resultArray[offsetY][offsetX] = count
                    offsetX -= 1
                    count += 1
                }
                turnCount += 1
            }
            
            // 下->上 4 8
            if turnCount % 4 == 0 {
                let num = (turnCount - 1) / 4
                let a = n - (num * 2) - 1
                for index in 0..<a {
                    resultArray[offsetY][offsetX] = count
                    
                    if index + 1 != a{
                        offsetY -= 1
                    }
                    count += 1
                }
                turnCount += 1
            }
        }
        
        if n % 2 != 0 {
            resultArray[n / 2][n / 2] = n * n
        }
        
        for item in resultArray {
            print(item)
        }
        
        print("\n")
        return resultArray
    }
}
