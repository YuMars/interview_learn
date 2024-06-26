/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "SDWebImageCompat.h"
#import "SDWebImageOperation.h"
#import "SDWebImageDefine.h"
#import "SDImageCoder.h"

/// Image Cache Type
typedef NS_ENUM(NSInteger, SDImageCacheType) {
    /**
     * For query and contains op in response, means the image isn't available in the image cache
     * For op in request, this type is not available and take no effect.
     * 对查询和包含响应中的op,意味着图像在图像缓存中不可用
     * 对请求中的op,此类型不可用并无效。
     */
    SDImageCacheTypeNone,
    /**
     * For query and contains op in response, means the image was obtained from the disk cache.
     * For op in request, means process only disk cache.
     * 对查询和包含响应中的op,意味着图像是从磁盘缓存获得的。
     * 对请求中的op,意味着仅处理磁盘缓存。
     */
    SDImageCacheTypeDisk,
    /**
     * For query and contains op in response, means the image was obtained from the memory cache.
     * For op in request, means process only memory cache.
     * 对查询和包含响应中的op,意味着图像是从内存缓存获得的。
     * 对请求中的op,意味着仅处理内存缓存。
     */
    SDImageCacheTypeMemory,
    /**
     * For query and contains op in response, this type is not available and take no effect.
     * For op in request, means process both memory cache and disk cache.
     * 对查询和包含响应中的op,此类型不可用并无效。
     * 对请求中的op,意味着同时处理内存缓存和磁盘缓存。
     */
    SDImageCacheTypeAll
};

typedef void(^SDImageCacheCheckCompletionBlock)(BOOL isInCache);
typedef void(^SDImageCacheQueryDataCompletionBlock)(NSData * _Nullable data);
typedef void(^SDImageCacheCalculateSizeBlock)(NSUInteger fileCount, NSUInteger totalSize);
typedef NSString * _Nullable (^SDImageCacheAdditionalCachePathBlock)(NSString * _Nonnull key);
typedef void(^SDImageCacheQueryCompletionBlock)(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType);
typedef void(^SDImageCacheContainsCompletionBlock)(SDImageCacheType containsCacheType);

/**
 This is the built-in decoding process for image query from cache.
 @note If you want to implement your custom loader with `queryImageForKey:options:context:completion:` API, but also want to keep compatible with SDWebImage's behavior, you'd better use this to produce image.
 
 @param imageData The image data from the cache. Should not be nil
 @param cacheKey The image cache key from the input. Should not be nil
 @param options The options arg from the input
 @param context The context arg from the input
 @return The decoded image for current image data query from cache
 */
FOUNDATION_EXPORT UIImage * _Nullable SDImageCacheDecodeImageData(NSData * _Nonnull imageData, NSString * _Nonnull cacheKey, SDWebImageOptions options, SDWebImageContext * _Nullable context);

/// 从加载上下文选项和缓存键获取解码选项。这是web加载部分与解码部分(不依赖)之间的内置转换。
/// @param context The context arg from the input
/// @param options The options arg from the input
/// @param cacheKey The image cache key from the input. Should not be nil
FOUNDATION_EXPORT SDImageCoderOptions * _Nonnull SDGetDecodeOptionsFromContext(SDWebImageContext * _Nullable context, SDWebImageOptions options, NSString * _Nonnull cacheKey);

/// Set the decode options to the loading context options. This is the built-in translate between the web loading part from the decoding part (which does not depends on).
/// @param mutableContext The context arg to override
/// @param mutableOptions The options arg to override
/// @param decodeOptions The image decoding options
FOUNDATION_EXPORT void SDSetDecodeOptionsToContext(SDWebImageMutableContext * _Nonnull mutableContext, SDWebImageOptions * _Nonnull mutableOptions, SDImageCoderOptions * _Nonnull decodeOptions);

/**
 This is the image cache protocol to provide custom image cache for `SDWebImageManager`.
 Though the best practice to custom image cache, is to write your own class which conform `SDMemoryCache` or `SDDiskCache` protocol for `SDImageCache` class (See more on `SDImageCacheConfig.memoryCacheClass & SDImageCacheConfig.diskCacheClass`).
 However, if your own cache implementation contains more advanced feature beyond `SDImageCache` itself, you can consider to provide this instead. For example, you can even use a cache manager like `SDImageCachesManager` to register multiple caches.
 */
@protocol SDImageCache <NSObject>

@required
/**
 Query the cached image from image cache for given key. The operation can be used to cancel the query.
 If image is cached in memory, completion is called synchronously, else asynchronously and depends on the options arg (See `SDWebImageQueryDiskSync`)

 @param key The image cache key
 @param options A mask to specify options to use for this query
 @param context A context contains different options to perform specify changes or processes, see `SDWebImageContextOption`. This hold the extra objects which `options` enum can not hold. Pass `.callbackQueue` to control callback queue
 @param completionBlock The completion block. Will not get called if the operation is cancelled
 @return The operation for this query
 */
- (nullable id<SDWebImageOperation>)queryImageForKey:(nullable NSString *)key
                                             options:(SDWebImageOptions)options
                                             context:(nullable SDWebImageContext *)context
                                          completion:(nullable SDImageCacheQueryCompletionBlock)completionBlock API_DEPRECATED_WITH_REPLACEMENT("queryImageForKey:options:context:cacheType:completion:", macos(10.10, API_TO_BE_DEPRECATED), ios(8.0, API_TO_BE_DEPRECATED), tvos(9.0, API_TO_BE_DEPRECATED), watchos(2.0, API_TO_BE_DEPRECATED));

@optional
/**
 Query the cached image from image cache for given key. The operation can be used to cancel the query.
 If image is cached in memory, completion is called synchronously, else asynchronously and depends on the options arg (See `SDWebImageQueryDiskSync`)

 @param key The image cache key
 @param options A mask to specify options to use for this query
 @param context A context contains different options to perform specify changes or processes, see `SDWebImageContextOption`. This hold the extra objects which `options` enum can not hold. Pass `.callbackQueue` to control callback queue
 @param cacheType Specify where to query the cache from. By default we use `.all`, which means both memory cache and disk cache. You can choose to query memory only or disk only as well. Pass `.none` is invalid and callback with nil immediately.
 @param completionBlock The completion block. Will not get called if the operation is cancelled
 @return The operation for this query
 */
- (nullable id<SDWebImageOperation>)queryImageForKey:(nullable NSString *)key
                                             options:(SDWebImageOptions)options
                                             context:(nullable SDWebImageContext *)context
                                           cacheType:(SDImageCacheType)cacheType
                                          completion:(nullable SDImageCacheQueryCompletionBlock)completionBlock;

@required
/**
 Store the image into image cache for the given key. If cache type is memory only, completion is called synchronously, else asynchronously.

 @param image The image to store
 @param imageData The image data to be used for disk storage
 @param key The image cache key
 @param cacheType The image store op cache type
 @param completionBlock A block executed after the operation is finished
 */
- (void)storeImage:(nullable UIImage *)image
         imageData:(nullable NSData *)imageData
            forKey:(nullable NSString *)key
         cacheType:(SDImageCacheType)cacheType
        completion:(nullable SDWebImageNoParamsBlock)completionBlock API_DEPRECATED_WITH_REPLACEMENT("storeImage:imageData:forKey:options:context:cacheType:completion:", macos(10.10, API_TO_BE_DEPRECATED), ios(8.0, API_TO_BE_DEPRECATED), tvos(9.0, API_TO_BE_DEPRECATED), watchos(2.0, API_TO_BE_DEPRECATED));

@optional
/**
 Store the image into image cache for the given key. If cache type is memory only, completion is called synchronously, else asynchronously.

 @param image The image to store
 @param imageData The image data to be used for disk storage
 @param key The image cache key
 @param options A mask to specify options to use for this store
 @param context The context options to use. Pass `.callbackQueue` to control callback queue
 @param cacheType The image store op cache type
 @param completionBlock A block executed after the operation is finished
 */
- (void)storeImage:(nullable UIImage *)image
         imageData:(nullable NSData *)imageData
            forKey:(nullable NSString *)key
           options:(SDWebImageOptions)options
           context:(nullable SDWebImageContext *)context
         cacheType:(SDImageCacheType)cacheType
        completion:(nullable SDWebImageNoParamsBlock)completionBlock;

#pragma mark - Deprecated because SDWebImageManager does not use these APIs
/**
 Remove the image from image cache for the given key. If cache type is memory only, completion is called synchronously, else asynchronously.

 @param key The image cache key
 @param cacheType The image remove op cache type
 @param completionBlock A block executed after the operation is finished
 */
- (void)removeImageForKey:(nullable NSString *)key
                cacheType:(SDImageCacheType)cacheType
               completion:(nullable SDWebImageNoParamsBlock)completionBlock API_DEPRECATED("No longer use. Cast to cache instance and call its API", macos(10.10, API_TO_BE_DEPRECATED), ios(8.0, API_TO_BE_DEPRECATED), tvos(9.0, API_TO_BE_DEPRECATED), watchos(2.0, API_TO_BE_DEPRECATED));

/**
 Check if image cache contains the image for the given key (does not load the image). If image is cached in memory, completion is called synchronously, else asynchronously.

 @param key The image cache key
 @param cacheType The image contains op cache type
 @param completionBlock A block executed after the operation is finished.
 */
- (void)containsImageForKey:(nullable NSString *)key
                  cacheType:(SDImageCacheType)cacheType
                 completion:(nullable SDImageCacheContainsCompletionBlock)completionBlock API_DEPRECATED("No longer use. Cast to cache instance and call its API", macos(10.10, API_TO_BE_DEPRECATED), ios(8.0, API_TO_BE_DEPRECATED), tvos(9.0, API_TO_BE_DEPRECATED), watchos(2.0, API_TO_BE_DEPRECATED));

/**
 Clear all the cached images for image cache. If cache type is memory only, completion is called synchronously, else asynchronously.

 @param cacheType The image clear op cache type
 @param completionBlock A block executed after the operation is finished
 */
- (void)clearWithCacheType:(SDImageCacheType)cacheType
                completion:(nullable SDWebImageNoParamsBlock)completionBlock API_DEPRECATED("No longer use. Cast to cache instance and call its API", macos(10.10, API_TO_BE_DEPRECATED), ios(8.0, API_TO_BE_DEPRECATED), tvos(9.0, API_TO_BE_DEPRECATED), watchos(2.0, API_TO_BE_DEPRECATED));

@end
