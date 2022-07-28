//
//  1047_RemoveAllAdjacentDuplicatesInString.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/28.
//

import Foundation

public class RemoveAllAdjacentDuplicatesInString {
    public class func removeDuplicates(_ s: String) -> String {
        var stack = [Character]()
        for char in s {
            if stack.last == char {
                stack.removeLast()
            } else {
                stack.append(char)
            }
        }
        return String(stack)
    }
}
