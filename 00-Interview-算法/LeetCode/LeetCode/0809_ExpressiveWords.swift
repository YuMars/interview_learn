//
//  0809_ExpressiveWords.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/11/25.
//

import Foundation

public class ExpressiveWords {
    public class func expressiveWords(_ s: String, _ words: [String]) -> Int {
        
        
        func compare(string: String, targetString: String) -> Bool {
            var string = Array(string)
            var targetString = Array(targetString)
            var i = 0
            var j = 0
            while (i < string.count && j < targetString.count) {
                
                if (string[i] != targetString[j]) {
                    return false
                }
                
                var char: Character = string[i]
                var cnti:Int = 0
                while (i < string.count && string[i] == char) {
                    cnti += 1
                    i += 1
                }
                var cntj:Int = 0
                while (j < targetString.count && targetString[j] == char) {
                    cntj += 1
                    j += 1;
                }
                if (cnti < cntj) {
                    return false
                }
                if (cnti != cntj && cnti < 3) {
                    return false
                }
            }
            return i == string.count && j == targetString.count;
        }
        
        var result: Int = 0
        
        for string in words {
            if compare(string: s, targetString: string) {
                result += 1
            }
        }
        return result;
    }
}


