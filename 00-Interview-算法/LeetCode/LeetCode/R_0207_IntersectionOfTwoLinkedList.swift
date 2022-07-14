//
//  R_0207_IntersectionOfTwoLinkedList.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/12.
//

import Foundation

public class IntersectionOfTwoLinkedList {
    public class func getIntersectionNode(_ headA: ListNode?, _ headB: ListNode?) -> ListNode? {
        var curA: ListNode? = headA
        var curB: ListNode? = headB
        
        // 计算长度
        var lenA: Int = 0
        var lenB: Int = 0
        
        while curA != nil {
            lenA += 1
            curA = curA?.next
        }
        
        while curB != nil {
            lenB += 1
            curB = curB?.next
        }
        
        curA = headA
        curB = headB
        // 更换位置，让curA是最长链表的头
        if lenB > lenA {
            let tempLen = lenA
            lenA = lenB
            lenB = tempLen
            
            let tempNode = curA
            curB = curA
            curA = tempNode
        }
        
        // 计算长度差
        var gap = lenA - lenB
        
        // 尾部对齐
        while gap > 0 {
            gap -= 1
            curA = curA?.next
        }
        
        while curA != nil {
            if curA == curB {
                return curA
            }
            
            curA = curA?.next
            curB = curB?.next
        }
        
        return nil
    }
}
