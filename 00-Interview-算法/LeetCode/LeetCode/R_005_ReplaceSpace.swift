//
//  R_005_ReplaceSpace.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/22.
//

import Foundation

public class ReplaceSpace {
    public class func replaceSpace(_ s: String) -> String {
        
        var arr = Array(s)
        
        var spaceCount = 0
        for (_, value) in s.enumerated() { // 判断空格的数量
            if value == " " {
                spaceCount += 1
            }
        }
        
        var left = s.count - 1 // 左指针，从原字符串尾部开始
        var right = s.count - 1 + spaceCount * 2 // 右指针，从扩容后的字符串尾部开始
        
        for _ in 0 ..< spaceCount * 2 { // 将原来字符串扩大，根据空格的数量 * 2
            arr.append(" ")
        }
        
        while left < right {
            
            if arr[left] == " " { // 替换空格
                
                arr[right] = "0"
                arr[right - 1] = "2"
                arr[right - 2] = "%"
                left -= 1
                right -= 3
            } else { // 一起往左偏移
                arr[right] = arr[left]
                left -= 1
                right -= 1
            }
        }
        
        return String(arr)
    }
}
