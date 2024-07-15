//
//  0021_MergeTwoSortedLists.swift
//  LeetCode
//
//  Created by Red-Fish on 2024/7/13.
//

import Foundation

/*
 将两个升序链表合并为一个新的升序链表并返回。
 新链表是通过拼接给定的两个链表的所有节点组成的。
 */

public class MergeTwoSortedLists {
    
    /// 双指针解法 [1,2,4] [1,3,4]
    /// 主要处理边界值的情况x
    public class func mergeTwoLists(_ list1: ListNode?, _ list2: ListNode?) -> ListNode? {
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
}
