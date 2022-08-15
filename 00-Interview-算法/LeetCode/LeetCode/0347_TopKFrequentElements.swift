//
//  0347_TopKFrequentElements.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/8/10.
//

import Foundation

public class TopKFrequentElement {
    public class func topKFrequent(_ nums: [Int], _ k: Int) -> [Int] {
        var result:[Int] = [Int]()
        var hashMap: [Int:Int] = [Int : Int]()
        for (_,item) in nums.enumerated() {
            hashMap[item] = (hashMap[item] ?? 0) + 1
        }
        
        var bucket:[[Int]] = Array(repeating: [], count: nums.count + 1)
        
        for key in hashMap.keys {
            bucket[hashMap[key]!].append(key)
        }
        
        for i in (0..<bucket.count).reversed() {
            result.append(contentsOf: bucket[i])
            //result.appen(bucket[i])
        }
        
        return Array(result[0..<k])
    }
}
