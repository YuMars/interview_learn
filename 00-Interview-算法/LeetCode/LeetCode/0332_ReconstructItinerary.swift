//
//  0332_ReconstructItinerary.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/10/24.
//

import Foundation

/*
 给你一份航线列表 tickets ，其中 tickets[i] = [fromi, toi] 表示飞机出发和降落的机场地点。请你对该行程进行重新规划排序。
 所有这些机票都属于一个从 JFK（肯尼迪国际机场）出发的先生，所以该行程必须从 JFK 开始。如果存在多种有效的行程，请你按字典排序返回最小的行程组合。
 例如，行程 ["JFK", "LGA"] 与 ["JFK", "LGB"] 相比就更小，排序更靠前。
 假定所有机票至少存在一种合理的行程。且所有的机票 必须都用一次 且 只能用一次。
 
 示例 1：
 输入：tickets = [["MUC","LHR"],["JFK","MUC"],["SFO","SJC"],["LHR","SFO"]]
 输出：["JFK","MUC","LHR","SFO","SJC"]
 示例 2：
 输入：tickets = [["JFK","SFO"],["JFK","ATL"],["SFO","ATL"],["ATL","JFK"],["ATL","SFO"]]
 输出：["JFK","ATL","JFK","SFO","ATL","SFO"]
 解释：另一种有效的行程是 ["JFK","SFO","ATL","JFK","ATL","SFO"] ，但是它字典排序更大更靠后。
 */

public class RecontructItinerary {
    public class func findItinerary(_ tickets: [[String]]) -> [String] {
        if tickets.count == 0 { return [] }
        
        // 线路按照小到大排序
        let tickets = tickets.sorted { (arr1, arr2) -> Bool in
            if arr1[0] < arr2[0] {
                return true
            } else if arr1[0] > arr2[0] {
                return false
            }
            if arr1[1] < arr2[1] {
                return true
            } else if arr1[1] > arr2[1] {
                return false
            }
            return true
        }
        
        print("tickets", tickets)
        var path = ["JFK"]
        var used = [Bool](repeating: false, count: tickets.count)
        
        @discardableResult
        func backtracking() -> Bool{
            
            // 终止条件（机票全用）
            if path.count == tickets.count + 1 { return true }
            
            for i in 0 ..< tickets.count {
                // 跳过处理过或出发站不是path末尾站的线路，即筛选出未处理的又可以衔接path的线路
                //print("ticket", i, "--", tickets[i])
                guard !used[i], tickets[i][0] == path.last! else { continue }
                used[i] = true
                print("used",i,used)
                path.append(tickets[i][1])
                print("path - append", path.count,path)
                if backtracking() { return true}// 终止条件（机票没全用）
                path.removeLast()
                print("path - remove", path.count,path)
                used[i] = false
            }
            return false
        }
        
        backtracking()
        return path
    }
}
