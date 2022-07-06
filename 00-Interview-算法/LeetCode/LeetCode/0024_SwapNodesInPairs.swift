//
//  0024_SwapNodesInPairs.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/4.
//

import Foundation

public class SwapNodesInPairs {
    public class func swapPairs(_ head: ListNode?) -> ListNode? {
        if head == nil || head?.next == nil { return head }
        
        let resultNode: ListNode? = head?.next
        
        var preNode: ListNode? = nil
        var currentNode: ListNode? = head
        var nextNode: ListNode? = head?.next
        
        
        while currentNode != nil && nextNode != nil {
            currentNode?.next = nextNode?.next
            nextNode?.next = currentNode
            preNode?.next = nextNode
            
            preNode = currentNode
            currentNode = currentNode?.next
            nextNode = currentNode?.next
            
            print("reuslt" + "\(String(describing: preNode?.val))", "\(String(describing: currentNode?.val))", "\(String(describing: nextNode?.val))")
        }
        return resultNode
    }
    
    public class func swapPairs2(_ head: ListNode?) -> ListNode? {
        if head == nil || head?.next == nil { return head }
        
        let nexNode: ListNode? = head?.next
        let newNode = swapPairs2(nexNode?.next)
        nexNode?.next = head
        head?.next = newNode
        return nexNode
    }
}
