//
//  0049_GroupAnagrams.swift
//  LeetCode
//
//  Created by Red-Fish on 2024/7/24.
//

import Foundation

/*
 给你一个字符串数组，请你将 字母异位词 组合在一起。可以按任意顺序返回结果列表。
 字母异位词 是由重新排列源单词的所有字母得到的一个新单词。
 */

public class GroupAnagrams {
    
    /// key value解法
    public class func groupAnagrams(_ strs: [String]) -> [[String]] {
        var resultMap: [String : [String]] = [String : [String]]() // key是strs的某个字符串排序后的结果，比如"eat" -> 字符串排序后是"aet",最红
        
        for i in 0..<strs.count {
            let arr: [Character] = Array(strs[i]).sorted()   // 单个字符串排序后的结果
            let key: String = String(arr)      // 上面的数组变成字符串类型的key
            var didExitArray: [String] = resultMap[key] ?? [String]() // 判断rresultMap中有没有key对应的字符串，没有的话就添加新类型的key，有的话就在院线arr
            didExitArray.append(strs[i])
            resultMap[key] = didExitArray
            
        }
        
        return Array(resultMap.values)
    }
    
    /// 计数解法
    /// 将字符串排序然后根据出现的字母和次数组成新的字符串，判断是否出现过tea -> a1e1t1
    
}
