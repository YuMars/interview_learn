//
//  0023_MergeKSortedLists.swift
//  LeetCode
//
//  Created by Red-Fish on 2024/7/15.
//

import Foundation

/*
 给你一个链表数组，每个链表都已经按升序排列。请你将所有链表合并到一个升序链表中，返回合并后的链表。
 */

public class MergeKSortedLists {
    
    /// 依次合并2个链表法
    public  class func  mergeKLists(_ lists: [ListNode?]) -> ListNode? {
        let dummyNode: ListNode? = ListNode()
        var p = dummyNode
        
        for i in 0..<lists.count {
            p = mertSortList(p, lists[i])
        }
        
        return dummyNode?.next
        
    }
    
    class func mertSortList(_ list1: ListNode?, _ list2: ListNode?) -> ListNode? {
        
        var list1 = list1
        var list2 = list2
        let dummyNode: ListNode? = ListNode()
        var p = dummyNode
        while list1 != nil && list2 != nil {
            if list1!.val < list2!.val {
                p?.next = list1
                list1 = list1?.next
            } else {
                p?.next = list2
                list2 = list2?.next
            }
            p = p?.next
        }
        
        if list1 != nil {
            p?.next = list1
        }
        
        if list2 != nil {
            p?.next = list2
        }
        
        return dummyNode?.next
    }
    
    
    
    
    /// 分治法两两合并链表
}


