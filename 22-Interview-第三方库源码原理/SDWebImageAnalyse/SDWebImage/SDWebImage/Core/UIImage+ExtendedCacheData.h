/*
* This file is part of the SDWebImage package.
* (c) Olivier Poitrey <rs@dailymotion.com>
* (c) Fabrice Aneche
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import <Foundation/Foundation.h>
#import "SDWebImageCompat.h"

@interface UIImage (ExtendedCacheData)

/**
 Read and Write the extended object and bind it to the image. Which can hold some extra metadata like Image's scale factor, URL rich link, date, etc.
 The extended object should conforms to NSCoding, which we use `NSKeyedArchiver` and `NSKeyedUnarchiver` to archive it to data, and write to disk cache.
 @note The disk cache preserve both of the data and extended data with the same cache key. For manual query, use the `SDDiskCache` protocol method `extendedDataForKey:` instead.
 @note You can specify arbitrary object conforms to NSCoding (NSObject protocol here is used to support object using `NS_ROOT_CLASS`, which is not NSObject subclass). If you load image from disk cache, you should check the extended object class to avoid corrupted data.
 @warning This object don't need to implements NSSecureCoding (but it's recommended),  because we allows arbitrary class.
 读取和写入扩展对象,并将其绑定到图像。它可以保存一些额外的元数据,如图像的比例因子、丰富的链接URL、日期等。
  扩展对象应符合NSCoding,我们使用`NSKeyedArchiver`和`NSKeyedUnarchiver`将其归档为数据,并写入磁盘缓存。
 @note 磁盘缓存同时保留数据和扩展数据与相同的缓存键。对于手动查询,请使用`SDDiskCache`协议方法`extendedDataForKey:`。
  @note 您可以指定符合NSCoding的任意对象(这里使用NSObject协议是为了支持使用`NS_ROOT_CLASS`的对象,它不是NSObject子类)。如果从磁盘缓存加载图像,应检查扩展对象类以避免损坏的数据。
  @warning 此对象不需要实现NSSecureCoding(但推荐),因为我们允许任意类。
 */
@property (nonatomic, strong, nullable) id<NSObject, NSCoding> sd_extendedObject;

@end
