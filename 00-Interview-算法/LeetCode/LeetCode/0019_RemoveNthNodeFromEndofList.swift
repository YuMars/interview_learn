//
//  0019_RemoveNthNodeFromEndofList.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/5.
//

import Foundation

/*
 给你一个链表，删除链表的倒数第 n 个结点，并且返回链表的头结点。
 */

public class RemoveNthNodeFromEndofList {

    /// 双指针解法-快慢指针-> 先移动n+1步法
    public class func removeNthFromEnd1(_ head: ListNode?, _ n: Int) -> ListNode? {
        var n = n + 1 // 要删除倒数第n个节点，先找到倒数第n+1
        var dummyNode: ListNode? = ListNode(-1)
        dummyNode?.next = head
        var slowNode: ListNode? = dummyNode
        var fastNode: ListNode? = dummyNode
        
        while n > 0 && fastNode != nil {
            n -= 1
            fastNode = fastNode?.next
        }
        
        while fastNode != nil {
            fastNode = fastNode?.next
            slowNode = slowNode?.next
        }
        
        slowNode?.next = slowNode?.next?.next
        
        return dummyNode?.next
    }
    
    // 双指针-同时移动
    public class func removeNthFromEnd(_ head: ListNode?, _ n: Int) -> ListNode? {
        
        if head == nil { return head }
        
        let dummyNode: ListNode? = ListNode(-1)
        dummyNode?.next = head
        
        var leftNode: ListNode? = dummyNode
        var rightNode: ListNode? = dummyNode
        var index = 0
        while rightNode?.next != nil { // 通过next提前找到了n+1的位置
            
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
