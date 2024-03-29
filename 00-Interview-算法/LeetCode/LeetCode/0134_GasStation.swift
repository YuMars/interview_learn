//
//  0134_GasStation.swift
//  LeetCode
//
//  Created by Red-Fish on 2022/11/2.
//

import Foundation

/*
 在一条环路上有n个加油站，其中第i个加油站有汽油gas[i]升。
 你有一辆油箱容量无限的的汽车，从第i个加油站开往第i+1个加油站需要消耗汽油cost[i]升你从其中的一个加油站出发，开始时油箱为空。
 给定两个整数数组gas和cost如果你可以绕环路行驶一周则返回出发时加油站的编号否则返回-1。如果存在解，则保证它是唯一的。
 示例 1:
 输入: gas = [1,2,3,4,5], cost = [3,4,5,1,2] 输出: 3
 解释:
 从 3 号加油站(索引为 3 处)出发，可获得 4 升汽油。此时油箱有 = 0 + 4 = 4 升汽油
 开往 4 号加油站，此时油箱有 4 - 1 + 5 = 8 升汽油
 开往 0 号加油站，此时油箱有 8 - 2 + 1 = 7 升汽油
 开往 1 号加油站，此时油箱有 7 - 3 + 2 = 6 升汽油
 开往 2 号加油站，此时油箱有 6 - 4 + 3 = 5 升汽油
 开往 3 号加油站，你需要消耗 5 升汽油，正好足够你返回到 3 号加油站。
 因此，3 可为起始索引。
 示例 2:
 输入: gas = [2,3,4], cost = [3,4,3] 输出: -1
 解释:
 你不能从 0 号或 1 号加油站出发，因为没有足够的汽油可以让你行驶到下一个加油站。
 我们从 2 号加油站出发，可以获得 4 升汽油。 此时油箱有 = 0 + 4 = 4 升汽油
 开往 0 号加油站，此时油箱有 4 - 3 + 2 = 3 升汽油
 开往 1 号加油站，此时油箱有 3 - 3 + 3 = 3 升汽油
 你无法返回 2 号加油站，因为返程需要消耗 4 升汽油，但是你的油箱只有 3 升汽油。
 因此，无论怎样，你都不可能绕环路行驶一周。
 */

public class GasStation {
    
    public class func canCompleteCircuit(_ gas:[Int], _ cost: [Int]) -> Int {
        guard gas.count == cost.count, gas.count > 0, cost.count > 0 else { return -1 }
        
        var curSum = 0;
        var gasSum = 0;
        var start = 0;
        for  i in 0 ..< gas.count {
            curSum += gas[i] - cost[i];
            gasSum += gas[i] - cost[i];
            if (curSum < 0) {   // 当前累加rest[i]和 curSum一旦小于0
                start = i + 1;  // 起始位置更新为i+1
                curSum = 0;     // curSum从0开始
            }
        }
        if (gasSum < 0) { return -1 }; // 总汽油少于消耗量说明怎么走都不可能跑一圈了
        return start;
    
    }
    
    public class func canCompleteCircuit2(_ gas:[Int], _ cost: [Int]) -> Int {
        guard gas.count == cost.count, gas.count > 0, cost.count > 0 else { return -1 }
        
        for i in 0 ..< gas.count {
            var gasSurplus = gas[i] - cost[i]
            var index = (i + 1) % cost.count
            while gasSurplus > 0, index != i {
                gasSurplus += gas[index] - cost[index]
                index = (index + 1) % cost.count
            }
            if gasSurplus >= 0, index == i {
                return i
            }
        }
        return -1
    }
    
    public class func canCompleteCircuit3(_ gas:[Int], _ cost: [Int]) -> Int {
        guard gas.count == cost.count, gas.count > 0, cost.count > 0 else { return -1 }
        
        for i in 0 ..< gas.count {
            var gasSurplus: Int = 0
            for j in i ..< gas.count {
                gasSurplus += gas[j] - cost[j]
                if gasSurplus < 0 {
                    break
                }
            }
            
            if gasSurplus < 0 { continue }
            
            for j in 0 ..< i {
                gasSurplus += gas[j] - cost[j]
                if gasSurplus < 0 {
                    break
                }
            }
            
            if gasSurplus < 0 { continue }
            
            if gasSurplus >= 0{
                return i
            }
        }
        return -1
    }
}
