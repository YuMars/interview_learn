//
//  0002_AddTwoNumbers.swift
//  LeetCode
//
//  Created by Red-Fish on 2024/7/10.
//

import Foundation

/*
 给你两个 非空 的链表，表示两个非负的整数。它们每位数字都是按照 逆序 的方式存储的，并且每个节点只能存储 一位 数字。
 请你将两个数相加，并以相同形式返回一个表示和的链表。
 你可以假设除了数字 0 之外，这两个数都不会以 0 开头。
 
 [2,4,3]
 [5,6,4]
 
 ->
 
 342+465=708
 */


public class AddTwoNumbers {
    
    public class func addTwoNumbers(_ l1: ListNode?, _ l2: ListNode?) -> ListNode? {
        var listNode1 = l1
        var listNode2 = l2
        var dummy: ListNode? = ListNode()
        var resultList = dummy
        var needUp: Bool = false
        
        while listNode1 != nil || listNode2 != nil {
            let node:ListNode = ListNode((listNode1?.val ?? 0) + (listNode2?.val ?? 0) + (needUp ? 1 : 0))
            needUp = false
            
            if node.val >= 10 {
                node.val -= 10
                needUp = true
            }
            
            //print("1:",listNode1?.val ?? 0, "2:", listNode2?.val ?? 0, "sum:",node.val)
            
            resultList?.next = node
            resultList = resultList?.next ?? ListNode(0)
            
            listNode1 = listNode1?.next
            listNode2 = listNode2?.next
        }
        
        if needUp == true {
            resultList?.next = ListNode(1)
        }
        
        return dummy?.next
    }
    
    class func listNodeReversed(_ listNode: ListNode?) -> ListNode? {
        var pre:ListNode? = nil
        var cur:ListNode? = listNode
        while cur != nil {
            let next = cur?.next
            cur?.next = pre
            pre = cur
            cur = next
        }
        return pre
    }
    
}
