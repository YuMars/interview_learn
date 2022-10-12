//
//  0017_LetterCombinationsOfAPhoneNumber.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/10/12.
//

import Foundation

public class LetterCombinationsOfAPhoneNumber {
    public class func letterCombinations(_ digits: String) -> [String] {
        let letterMap = [
            "", // 0
            "", // 1
            "abc", //2 开始
            "def",
            "ghi",
            "jkl",
            "mno",
            "pqrs",
            "tuv",
            "wxyz"
        ]
        
        let baseCode = ("0" as Character).asciiValue!
        let digits = digits.map { c in
            guard let code = c.asciiValue else { return -1 }
            return Int(code - baseCode)
        }.filter { c in
            return (c >= 2 && c <= 9)
        }
        
        guard !digits.isEmpty else { return []}
        
        var result = [String]()
        var s = ""
        func backtracking(index: Int) {
            // 结束条件
            if index == digits.count {
                result.append(s)
                return
            }
            
            let letters = letterMap[digits[index]]
            for letter in letters {
                s.append(letter)
                backtracking(index: index + 1)
                s.removeLast()
            }
        }
        backtracking(index: 0)
        return result
    }
    
}
