//
//  ListNode.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/2.
//

import Foundation

public class YNode<T> {
    public var val: T?
    public var nextNode: YNode?
    public init() { self.val = nil; self.nextNode = nil; }
    public init(_ val: T) { self.val = val; self.nextNode = nil; }
    public init(_ val: T, _ nextNode: YNode?) { self.val = val; self.nextNode = nextNode; }
}

extension YNode: CustomStringConvertible {
    public var description: String {
        guard let nextNode = nextNode else {
            return "\(String(describing: val))"
        }
        return "\(String(describing: val)) -> " + String(describing: nextNode)
    }
}

public struct YListNode<T> {
    public var head: YNode<T>?
    public var size: NSInteger = 0
    public var isEmpty: Bool {
        return head == nil
    }
}

extension YListNode: CustomStringConvertible {
    public var description: String {
        guard let head = head else {
            return "Empty list"
        }
        return String(describing: head)
    }
}

extension YListNode {
    
    /// 头部添加节点
    mutating func pushNode(val: T) {
        let node = YNode(val, head)
        node.nextNode = head
        head = node
        size += 1
    }
    
    /// 尾部增加节点
    mutating func appendNode(val: T) {
        let node = YNode(val, nil)
        let tail = self.getNode(at: size - 1)
        if tail == nil {
            head = node
        } else {
            tail?.nextNode = node
        }
        size += 1
    }
    
    /// 获取某个节点
    mutating func getNode(at index: NSInteger) -> YNode<T>? {
        if isEmpty || head == nil || size == 0 || index < 0 || !(index < size) {
            return nil
        }
        
        var location: NSInteger = 0
        var nextNode = head
        while nextNode != nil {
            if index == location {
                return nextNode
            }
            nextNode = nextNode?.nextNode
            location += 1
        }
        return nil
    }
    
    /// 删除某个节点
    mutating func removeNode(at index: NSInteger) -> Bool {
        if isEmpty || head == nil || size == 0 || index < 0 || !(index < size) {
            return false
        }
        
        if index == 0 {
            let mid = head?.nextNode
            head = mid
            size -= 1
            return true
        }
        
        var location: NSInteger = 1
        var middleNode: YNode<T> = head!
        while middleNode.nextNode != nil {
            if index == location {
                let middle = middleNode.nextNode?.nextNode
                middleNode.nextNode = middle
                size -= 1
                return true
            }
            middleNode = middleNode.nextNode!
            location += 1
        }
        
        return false
    }
    
    /// 反转单向链表
    mutating func reverseList() {
        if isEmpty { return }
        
        var preNode: YNode<T>? = nil
        var currentNode: YNode<T> = head!
        
        while currentNode.nextNode != nil {
            let nextNode: YNode<T> = currentNode.nextNode!
            currentNode.nextNode = preNode
            preNode = currentNode
            currentNode = nextNode
        }
        currentNode.nextNode = preNode
        head = currentNode
    }
}


