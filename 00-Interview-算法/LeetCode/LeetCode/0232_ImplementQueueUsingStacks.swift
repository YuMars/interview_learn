//
//  0232_ImplementQueueUsingStacks.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/27.
//

import Foundation

public class MyQueue {
    
    var stackIn = [Int]()
    var stackOut = [Int]()
    
    init() {
        
    }
    
    // 元素 x 推到队列的末尾
    func push(_ x: Int) {
        stackIn.append(x)
    }
    
    // 从队列的开头移除并返回元素
    func pop() -> Int {
        if stackOut.isEmpty { // 输出栈为空，把输入栈全部导入
            while !stackIn.isEmpty {
                stackOut.append(stackIn.popLast()!)
            }
        }
        return stackOut.popLast() ?? -1
    }
    
    // 返回队列开头的元素
    func peek() -> Int {
        let res = pop()
        stackOut.append(res)
        return res
    }
    
    // 如果队列为空，返回 true ；否则，返回 false
    func empty() -> Bool {
        return stackIn.isEmpty && stackOut.isEmpty
    }
}
