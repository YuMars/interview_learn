//
//  0454_4Sum.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/7/19.
//

import Foundation

public class FourSum2 {
    
    /// 暴力解法
    public class func fourSumCount(_ nums1: [Int], _ nums2: [Int], _ nums3: [Int], _ nums4: [Int]) -> Int {
        
        var count = 0
        for i in 0 ..< nums1.count {
            for j in 0 ..< nums2.count {
                for k in 0 ..< nums3.count {
                    for l in 0 ..< nums4.count {
                        if nums1[i] + nums2[j] + nums3[k] + nums4[l] == 0 {
                            count += 1
                        }
                    }
                }
            }
        }
        
        return count
    }
    
    /// 哈希解法
    public class func fourSumCount2(_ nums1: [Int], _ nums2: [Int], _ nums3: [Int], _ nums4: [Int]) -> Int {
        
        var count = 0
        var mapAB = [Int : Int]()
        
        // 1. 将 1 和 2 数组元素和 进行合并
        for i in 0 ..< nums1.count {
            for j in 0 ..< nums2.count {
                let key = nums1[i] + nums2[j]
                mapAB[key] = (mapAB[key] ?? 0) + 1
            }
        }
        
        var mapCD = [Int : Int]()
        
        // 2. 将 3 和 4 数组元素和 进行合并
        for i in 0 ..< nums3.count {
            for j in 0 ..< nums4.count {
                let key = nums3[i] + nums4[j]
                mapCD[key] = (mapCD[key] ?? 0) + 1
            }
        }
        
        // 3. 匹配结果
        for key in mapAB.keys {
            guard let value = mapCD[-key] else {
                continue
            }
            count += mapAB[key]! * value // 12对应的次数 x 34对应的次数
        }
        
        return count
    }
}
