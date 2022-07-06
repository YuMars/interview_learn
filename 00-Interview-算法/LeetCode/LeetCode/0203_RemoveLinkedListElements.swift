//
//  0203_RemoveLinkedListElements.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/3.
//

import Foundation

public class ListNode {
    public var val: Int
    public var next: ListNode?
    public init() { self.val = 0; self.next = nil; }
    public init(_ val: Int) { self.val = val; self.next = nil; }
    public init(_ val: Int, _ next: ListNode?) { self.val = val; self.next = next; }
}


class RemoveLinkedListElements {
    public class func removeElements(_ head: ListNode?, _ val: Int) -> ListNode? {
        let node = ListNode()
        node.next = head
        var currentNode = node
        while let curNext = currentNode.next {
            if curNext.val == val {
                currentNode.next = curNext.next
            } else {
                currentNode = curNext
            }
        }
        return node.next
    }
}
