//
//  0019_RemoveNthNodeFromEndofList.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/5.
//

import Foundation

public class RemoveNthNodeFromEndofList {
    public class func removeNthFromEnd(_ head: ListNode?, _ n: Int) -> ListNode? {
        
        if head == nil { return head }
        
        let dummyNode: ListNode? = ListNode(-1)
        dummyNode?.next = head
        
        var leftNode: ListNode? = dummyNode
        var rightNode: ListNode? = dummyNode
        var index = 0
        while rightNode?.next != nil {
            
            if index == n {
                leftNode = leftNode?.next
                rightNode = rightNode?.next
            } else if (index > n) {
                break
            } else {
                rightNode = rightNode?.next
                index += 1
            }
            
            print("reuslt " + "\(String(describing: leftNode?.val))", "\(String(describing: rightNode?.val))", "\(String(describing: dummyNode?.val))")
        }
        
        leftNode?.next = leftNode?.next?.next
        return dummyNode?.next
    }
}
