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

extension ListNode: Hashable, Equatable {
   public func hash(into hasher: inout Hasher) {
     // 用于唯一标识
     hasher.combine(val)
     hasher.combine(ObjectIdentifier(self))
   }
   public static func ==(lhs: ListNode, rhs: ListNode) -> Bool {
     return lhs === rhs
   }
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
