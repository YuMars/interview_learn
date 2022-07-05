//
//  0206_ReverseLinkedList.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/4.
//

import Foundation

public class ReverseLinkedList {
    
    // 双指针
    public class func reverseList(_ head: ListNode?) -> ListNode? {
        
        if head == nil || head?.next == nil { return head }
        
        var preNode: ListNode?
        var currentNode: ListNode? = head!
        
        while currentNode != nil {
            let nextNode = currentNode?.next
            currentNode?.next = preNode
            preNode = currentNode
            currentNode = nextNode
        }
        
        return preNode
    }
    
    // 递归
    public class func reverseList2(_ head: ListNode?) -> ListNode? {
        self.reverse(pre: nil, cur: head)
    }
    
    private class func reverse(pre: ListNode?, cur: ListNode?) -> ListNode? {
        if cur == nil { return pre }

        let nextNode: ListNode? = cur?.next
        cur?.next = pre
        return reverse(pre: cur, cur: nextNode)
    }
}
