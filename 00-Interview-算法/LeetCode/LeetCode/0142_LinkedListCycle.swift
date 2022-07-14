//
//  0142_LinkedListCycle.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/12.
//

import Foundation

public class LinkedListCycle {
    public class func detectCycle(_ head: ListNode?) -> ListNode? {
        
        if head == nil { return head }
        
        var fastNode: ListNode? = head
        var slowNode: ListNode? = head
        var flag: Bool = false
        
        while fastNode != nil {
            fastNode = fastNode?.next?.next
            slowNode = slowNode?.next
            
            if fastNode != nil && fastNode == slowNode { // 相遇了
                flag = true
                break
            }
        }
        
        if flag == false { return nil }
        
        fastNode = head
        while !(fastNode == slowNode) {
            fastNode = fastNode?.next
            slowNode = slowNode?.next
        }
        
        return fastNode
    }
}
