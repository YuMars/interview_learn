//
//  0225_ImplementStackUsingQueues.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/27.
//

import Foundation

class Queue {
    var arr: [Int]
    
    init() {
        arr = [Int]()
    }
    
    func push(_ x: Int) {
        arr.append(x)
    }
    
    // 删除队列前面的元素然后返回
    func pop() -> Int {
        if arr.isEmpty {
            return -1
        }
        return arr.removeFirst()
    }
    
    // 返回前面的元素
    func peek() -> Int {
        if arr.isEmpty {
            return -1
        }
        return arr.first!
    }
    
    // 队列是否为空
    func empty() -> Bool {
        return arr.isEmpty
    }
    
    // 返回队列的数量
    func count() -> Int {
        return arr.count
    }
}

// 单队列实现栈
public class Stack {

    var queue: Queue
    
    init() {
        queue = Queue()
    }
    
    // 将元素 x 压入栈顶。
    func push(_ x: Int) {
        queue.push(x)
    }
    
    // 移除并返回栈顶元素
    func pop() -> Int {
        if queue.empty() {
            return -1
        }
        
        for _ in 1 ..< queue.count() { // 移除 除了第0个元素
            queue.push(queue.pop())
        }
        return queue.pop()
    }
    
    // 返回栈顶元素。
    func top() -> Int {
        if queue.empty() {
            return -1
        }
        let res = pop()
        push(res)
        return res
    }
    
    
    // 如果栈是空的，返回 true ；否则，返回 false 。
    func empty() -> Bool {
        return queue.empty()
    }
}

// 双队列实现栈
public class MyStack2 {
    var queue1: Queue
    var queue2: Queue
    
    init() {
        queue1 = Queue()
        queue2 = Queue()
    }
    
    
    func push(_ x: Int) {
        queue1.push(x)
    }
    
    func pop() -> Int {
        if queue1.empty() {
            return -1
        }
        
        while queue1.count() > 1 {
            queue2.push(queue1.pop())
        }
        
        let res = queue1.pop()
        while queue2.empty() == false {
            queue1.push(queue2.pop())
        }
        return res
    }
    
    func top() -> Int {
        if queue1.empty() {
            return -1
        }
        
        let res = pop()
        push(res)
        return res
    }
    
    func empty() -> Bool {
        return queue1.empty() && queue2.empty()
    }
}
