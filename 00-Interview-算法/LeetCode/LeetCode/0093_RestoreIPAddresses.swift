//
//  0093_RestoreIPAddresses.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/10/18.
//

import Foundation

/*
 有效 IP 地址 正好由四个整数（每个整数位于 0 到 255 之间组成，且不能含有前导 0），整数之间用 '.' 分隔。

 例如："0.1.2.201" 和 "192.168.1.1" 是 有效 IP 地址，但是 "0.011.255.245"、"192.168.1.312" 和 "192.168@1.1" 是 无效 IP 地址。
 给定一个只包含数字的字符串 s ，用以表示一个 IP 地址，返回所有可能的有效 IP 地址，这些地址可以通过在 s 中插入 '.' 来形成。你 不能 重新排序或删除 s 中的任何数字。你可以按 任何 顺序返回答案。
 
 输入：s = "101023"
 输出：["1.0.10.23","1.0.102.3","10.1.0.23","10.10.2.3","101.0.2.3"]
 */

public class RestoreIPAddresses {
    public class func restoreIpAddresses(_ s: String) -> [String] {
        
        // 1.回溯分割数字
        // 2.判断分割之后数字是否是是ip的合法范围
        // 3.匹配的结果放入数组
        
        func isIpAddress(string: [Character], startIndex: Int, endIndex:Int) -> Bool { // 传入字符串，判断是否合法
            guard startIndex <= endIndex, startIndex >= 0, endIndex < string.count else { return false }
            if string[startIndex] == "0", startIndex != endIndex { return false}
            let string: String = String(string[startIndex ... endIndex])
            let value:Int = Int(string)!
            guard 0 <= value, value <= 255 else { return false}
            return true
        }
        
        var characterArr = Array(s)
        
        for i in 0 ..< characterArr.count { // 验证每个字符合法
            let character = characterArr[i]
            guard character >= "0", character <= "9" else {return []} // 非数字不合法
        }
        
        var result = [String]()
        
        func backtracking(startIndex: Int, pointCount: Int) {
            if pointCount == 3 {
                if isIpAddress(string: characterArr, startIndex: startIndex, endIndex: characterArr.count - 1) {
                    result.append(String(characterArr))
                    return
                }
            }
            
            for i in startIndex ..< characterArr.count {
                // print("progress---" + "characterArr" + "\(characterArr)", "---startIndex---", startIndex, "i---", i)
                if isIpAddress(string: characterArr, startIndex: startIndex, endIndex: i) {
                    characterArr.insert(".", at: i + 1)
                    // print("before-----" + "characterArr" + "\(characterArr)", "---startIndex---", startIndex, "i---", i)
                    backtracking(startIndex: i + 2, pointCount: pointCount + 1)// 加"."
                    characterArr.remove(at: i + 1)
                    // print("after------" + "characterArr" + "\(characterArr)")
                } else {
                    break // 不是就结束
                }
            }
        }
        backtracking(startIndex: 0, pointCount: 0)
        return result
    }
}
