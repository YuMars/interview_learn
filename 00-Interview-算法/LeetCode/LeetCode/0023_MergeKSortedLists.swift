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
    
    
    /// 分治法两两合并链表
    public  class func  mergeKLists1(_ lists: [ListNode?]) -> ListNode? {
        return recureMerge(lists, 0, lists.count - 1)
    }
    
    public class func recureMerge(_ lists: [ListNode?], _ left: Int, _ right: Int) -> ListNode? {
        
        if left == right { return lists[left] }
        if left > right { return nil }
        let middle = (left + right) >> 1
        return mergeTwohList(recureMerge(lists, left, middle), recureMerge(lists, middle + 1, right))
    }
    
    public class func mergeTwohList(_ list1: ListNode?,_ list2: ListNode?) -> ListNode? {
        var dummyNode:ListNode? = ListNode()
        var p = dummyNode
        
        var list1 = list1
        var list2 = list2
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
    
    
    
    /// 依次合并2个链表法，迭代法
    public  class func  mergeKLists(_ lists: [ListNode?]) -> ListNode? {
        var dummyNode: ListNode? = nil
//        var p = dummyNode // 这里不能设置虚拟头节点，用虚拟头节点，最终指向的已经不是当时的p了
        
        for i in 0..<lists.count {
            dummyNode = mertSortList(dummyNode, lists[i])
        }
        
        return dummyNode
        
    }
    
    class func mertSortList(_ list1: ListNode?, _ list2: ListNode?) -> ListNode? {
        
        if list1 == nil || list2 == nil {
            return (list1 != nil) ? list1 : list1
        }
        
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
        
        print(dummyNode?.next?.val)
        
        return dummyNode?.next
    }
    
    
    
    
    
}


