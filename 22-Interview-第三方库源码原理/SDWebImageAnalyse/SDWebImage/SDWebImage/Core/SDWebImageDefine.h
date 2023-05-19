/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageCompat.h"

typedef void(^SDWebImageNoParamsBlock)(void);
typedef NSString * SDWebImageContextOption NS_EXTENSIBLE_STRING_ENUM;
typedef NSDictionary<SDWebImageContextOption, id> SDWebImageContext;
typedef NSMutableDictionary<SDWebImageContextOption, id> SDWebImageMutableContext;

#pragma mark - Image scale

/**
 Return the image scale factor for the specify key, supports file name and url key.
 This is the built-in way to check the scale factor when we have no context about it. Because scale factor is not stored in image data (It's typically from filename).
 However, you can also provide custom scale factor as well, see `SDWebImageContextImageScaleFactor`.

 @param key The image cache key
 @return The scale factor for image
 */
FOUNDATION_EXPORT CGFloat SDImageScaleFactorForKey(NSString * _Nullable key);

/**
 Scale the image with the scale factor for the specify key. If no need to scale, return the original image.
 This works for `UIImage`(UIKit) or `NSImage`(AppKit). And this function also preserve the associated value in `UIImage+Metadata.h`.
 @note This is actually a convenience function, which firstly call `SDImageScaleFactorForKey` and then call `SDScaledImageForScaleFactor`, kept for backward compatibility.

 @param key The image cache key
 @param image The image
 @return The scaled image
 */
FOUNDATION_EXPORT UIImage * _Nullable SDScaledImageForKey(NSString * _Nullable key, UIImage * _Nullable image);

/**
 Scale the image with the scale factor. If no need to scale, return the original image.
 This works for `UIImage`(UIKit) or `NSImage`(AppKit). And this function also preserve the associated value in `UIImage+Metadata.h`.
 
 @param scale The image scale factor
 @param image The image
 @return The scaled image
 */
FOUNDATION_EXPORT UIImage * _Nullable SDScaledImageForScaleFactor(CGFloat scale, UIImage * _Nullable image);

#pragma mark - WebCache Options

/// WebCache options
typedef NS_OPTIONS(NSUInteger, SDWebImageOptions) {
    /**
     * By default, when a URL fail to be downloaded, the URL is blacklisted so the library won't keep trying.
     * This flag disable this blacklisting.
     * 当URL失败下载时,该URL会被列入黑名单,以便库不会一直尝试。
     * 此标志禁用此黑名单。
     */
    SDWebImageRetryFailed = 1 << 0,
    
    /**
     * By default, image downloads are started during UI interactions, this flags disable this feature,
     * leading to delayed download on UIScrollView deceleration for instance.
     * 图像下载在UI交互期间开始,此标志禁用此功能,
     * 导致UIScrollView减速时的延迟下载。
     */
    SDWebImageLowPriority = 1 << 1,
    
    /**
     * This flag enables progressive download, the image is displayed progressively during download as a browser would do.
     * By default, the image is only displayed once completely downloaded.
     * 此标志启用渐进式下载,图像在下载过程中逐渐显示,就像浏览器所做的那样。
     * 默认情况下,仅在完全下载后显示图像。
     */
    SDWebImageProgressiveLoad = 1 << 2,
    
    /**
     * Even if the image is cached, respect the HTTP response cache control, and refresh the image from remote location if needed.
     * The disk caching will be handled by NSURLCache instead of SDWebImage leading to slight performance degradation.
     * This option helps deal with images changing behind the same request URL, e.g. Facebook graph api profile pics.
     * If a cached image is refreshed, the completion block is called once with the cached image and again with the final image.
     *
     * Use this flag only if you can't make your URLs static with embedded cache busting parameter.
     *
     *即使图像已缓存,也要遵循HTTP响应缓存控制,并在需要时从远程位置刷新图像。
     * 磁盘缓存将由NSURLCache而不是SDWebImage处理,这会略微降低性能。
     * 此选项可帮助处理位于同一请求URL背后的图像发生变化的情况,例如Facebook graph api配置文件图片。
     * 如果刷新缓存的图像,完成块将先调用缓存的图像,然后再调用最终图像。
     *
     * 只有在无法使您的URL静态并嵌入缓存清除参数的情况下,才使用此标志。
     */
    SDWebImageRefreshCached = 1 << 3,
    
    /**
     * In iOS 4+, continue the download of the image if the app goes to background. This is achieved by asking the system for
     * extra time in background to let the request finish. If the background task expires the operation will be cancelled.
     * 在iOS 4+中,如果应用程序进入后台,继续下载图像。这是通过请求系统提供额外的后台时间来完成请求来实现的。如果后台任务过期,操作将被取消
     */
    SDWebImageContinueInBackground = 1 << 4,
    
    /**
     * Handles cookies stored in NSHTTPCookieStore by setting
     * NSMutableURLRequest.HTTPShouldHandleCookies = YES;
     * 通过设置NSMutableURLRequest.HTTPShouldHandleCookies = YES来处理NSHTTPCookieStore中的cookie;
     */
    SDWebImageHandleCookies = 1 << 5,
    
    /**
     * Enable to allow untrusted SSL certificates.
     * Useful for testing purposes. Use with caution in production.
     * 启用以允许不受信任的SSL证书。
     * 用于测试目的。在生产中谨慎使用。
     */
    SDWebImageAllowInvalidSSLCertificates = 1 << 6,
    
    /**
     * By default, images are loaded in the order in which they were queued. This flag moves them to
     * the front of the queue.
     * 默认情况下,图像按照它们排队的顺序加载。此标志将它们移动到
     * 队列的前面。
     */
    SDWebImageHighPriority = 1 << 7,
    
    /**
     * By default, placeholder images are loaded while the image is loading. This flag will delay the loading
     * of the placeholder image until after the image has finished loading.
     * @note This is used to treate placeholder as an **Error Placeholder** but not **Loading Placeholder** by defaults. if the image loading is cancelled or error, the placeholder will be always set.
     * @note Therefore, if you want both **Error Placeholder** and **Loading Placeholder** exist, use `SDWebImageAvoidAutoSetImage` to manually set the two placeholders and final loaded image by your hand depends on loading result.
     * 默认情况下,加载图像时显示占位符图像。此标志将推迟加载
     * 直到图像完成加载之后显示占位符图像。
     * @note 这用于将占位符视为***错误占位符***而不是***加载占位符***,默认情况下。如果图像加载被取消或出现错误,占位符将始终设置。
     * @note 因此,如果你同时想要***错误占位符***和***加载占位符***,请使用`SDWebImageAvoidAutoSetImage`手动设置两个占位符和最终加载的图像,这取决于加载结果。
     */
    SDWebImageDelayPlaceholder = 1 << 8,
    
    /**
     * We usually don't apply transform on animated images as most transformers could not manage animated images.
     * Use this flag to transform them anyway.
     * 我们通常不对动画图像应用变换,因为大多数变换器无法处理动画图像。
     * 使用此标志无论如何对它们进行变换。
     */
    SDWebImageTransformAnimatedImage = 1 << 9,
    
    /**
     * By default, image is added to the imageView after download. But in some cases, we want to
     * have the hand before setting the image (apply a filter or add it with cross-fade animation for instance)
     * Use this flag if you want to manually set the image in the completion when success
     * 默认情况下,图像在下载后添加到图像视图。但在某些情况下,我们希望
     * 在设置图像之前拥有手部(例如应用过滤器或添加交叉渐变动画)
     * 如果要在成功时手动设置图像,请使用此标志
     */
    SDWebImageAvoidAutoSetImage = 1 << 10,
    
    /**
     * By default, images are decoded respecting their original size.
     * This flag will scale down the images to a size compatible with the constrained memory of devices.
     * To control the limit memory bytes, check `SDImageCoderHelper.defaultScaleDownLimitBytes` (Defaults to 60MB on iOS)
     * This will actually translate to use context option `.imageThumbnailPixelSize` from v5.5.0 (Defaults to (3966, 3966) on iOS). Previously does not.
     * This flags effect the progressive and animated images as well from v5.5.0. Previously does not.
     * @note If you need detail controls, it's better to use context option `imageThumbnailPixelSize` and `imagePreserveAspectRatio` instead.
     * 默认情况下,图像按照其原始大小解码。
     * 此标志将缩小图像到设备受限内存兼容的大小。
     * 要控制限制内存字节,请检查`SDImageCoderHelper.defaultScaleDownLimitBytes`(在iOS上默认为60MB)
     * 这实际上对应于v5.5.0中使用的上下文选项`.imageThumbnailPixelSize`(在iOS上默认为(3966,3966))。以前不会。
     * 此标志从v5.5.0开始影响渐进式和动画图像。以前不会。
     * @note 如果需要详细控制,最好使用上下文选项`imageThumbnailPixelSize`和`imagePreserveAspectRatio`代替。
     */
    SDWebImageScaleDownLargeImages = 1 << 11,
    
    /**
     * By default, we do not query image data when the image is already cached in memory. This mask can force to query image data at the same time. However, this query is asynchronously unless you specify `SDWebImageQueryMemoryDataSync`
     * 默认情况下,当图像已经缓存在内存中时,我们不查询图像数据。此掩码可以强制同时查询图像数据。但是,除非指定`SDWebImageQueryMemoryDataSync`,否则此查询是异步的。
     */
    SDWebImageQueryMemoryData = 1 << 12,
    
    /**
     * By default, when you only specify `SDWebImageQueryMemoryData`, we query the memory image data asynchronously. Combined this mask as well to query the memory image data synchronously.
     * @note Query data synchronously is not recommend, unless you want to ensure the image is loaded in the same runloop to avoid flashing during cell reusing.
     * 默认情况下,当您仅指定`SDWebImageQueryMemoryData`时,我们异步查询内存中的图像数据。结合此掩码也可以同步查询内存中的图像数据。
     * @note 同步查询数据不建议,除非您要确保图像加载到同一运行循环中以避免在重用单元期间出现闪烁。
     */
    SDWebImageQueryMemoryDataSync = 1 << 13,
    
    /**
     * By default, when the memory cache miss, we query the disk cache asynchronously. This mask can force to query disk cache (when memory cache miss) synchronously.
     * @note These 3 query options can be combined together. For the full list about these masks combination, see wiki page.
     * @note Query data synchronously is not recommend, unless you want to ensure the image is loaded in the same runloop to avoid flashing during cell reusing.
     * * 默认情况下,当内存缓存未命中时,我们异步查询磁盘缓存。此掩码可以强制在内存缓存未命中时同步查询磁盘缓存。
     * @note 这3个查询选项可以结合使用。有关这些掩码组合的完整列表,请参见wiki页面。
     * @note 同步查询数据不建议,除非您要确保图像加载到同一运行循环中以避免在重用单元期间出现闪烁。
     */
    SDWebImageQueryDiskDataSync = 1 << 14,
    
    /**
     * By default, when the cache missed, the image is load from the loader. This flag can prevent this to load from cache only.
     * 默认情况下,当缓存未命中时,图像将从加载程序加载。此标志可阻止仅从缓存加载。
     */
    SDWebImageFromCacheOnly = 1 << 15,
    
    /**
     * By default, we query the cache before the image is load from the loader. This flag can prevent this to load from loader only.
     * 默认情况下,我们在图像从加载程序加载之前查询缓存。此标志可阻止仅从加载程序加载。
     */
    SDWebImageFromLoaderOnly = 1 << 16,
    
    /**
     * By default, when you use `SDWebImageTransition` to do some view transition after the image load finished, this transition is only applied for image when the callback from manager is asynchronous (from network, or disk cache query)
     * This mask can force to apply view transition for any cases, like memory cache query, or sync disk cache query.
     *  默认情况下,当您使用`SDWebImageTransition`在图像加载完成后进行某些视图过渡时,此过渡仅适用于来自网络或磁盘缓存查询的异步回调产生的图像。
     * 此掩码可以强制对任何情况(如内存缓存查询或同步磁盘缓存查询)应用视图过渡。
     */
    SDWebImageForceTransition = 1 << 17,
    
    /**
     * By default, we will decode the image in the background during cache query and download from the network. This can help to improve performance because when rendering image on the screen, it need to be firstly decoded. But this happen on the main queue by Core Animation.
     * However, this process may increase the memory usage as well. If you are experiencing an issue due to excessive memory consumption, This flag can prevent decode the image.
     * @note 5.14.0 introduce `SDImageCoderDecodeUseLazyDecoding`, use that for better control from codec, instead of post-processing. Which acts the similar like this option but works for SDAnimatedImage as well (this one does not)
     * 默认情况下,我们将在缓存查询和网络下载期间在后台解码图像。这可以帮助提高性能,因为在屏幕上渲染图像时,首先需要解码。但是,这发生在Core Animation的主队列上。
     * 然而,此过程也可能增加内存使用量。如果由于过度内存消耗而遇到问题,此标志可以防止解码图像。
     * @note 5.14.0引入了`SDImageCoderDecodeUseLazyDecoding`,使用该方法可以更好地从编解码器进行控制,而不是后处理。它的作用与此选项类似,但也适用于SDAnimatedImage(此选项不适用)。
     */
    SDWebImageAvoidDecodeImage = 1 << 18,
    
    /**
     * By default, we decode the animated image. This flag can force decode the first frame only and produce the static image.
     * 默认情况下,我们解码动画图像。此标志可以强制仅解码第一个帧并生成静态图像。
     */
    SDWebImageDecodeFirstFrameOnly = 1 << 19,
    
    /**
     * By default, for `SDAnimatedImage`, we decode the animated image frame during rendering to reduce memory usage. However, you can specify to preload all frames into memory to reduce CPU usage when the animated image is shared by lots of imageViews.
     * This will actually trigger `preloadAllAnimatedImageFrames` in the background queue(Disk Cache & Download only).
     * 默认情况下,对于`SDAnimatedImage`,我们在渲染期间解码动画图像帧以减少内存使用量。但是,您可以指定将所有帧预加载到内存中,以减少动画图像由许多imageViews共享时的CPU使用量。
     * 这实际上会触发后台队列(磁盘缓存和下载)中的`preloadAllAnimatedImageFrames`。
     */
    SDWebImagePreloadAllFrames = 1 << 20,
    
    /**
     * By default, when you use `SDWebImageContextAnimatedImageClass` context option (like using `SDAnimatedImageView` which designed to use `SDAnimatedImage`), we may still use `UIImage` when the memory cache hit, or image decoder is not available to produce one exactlly matching your custom class as a fallback solution.
     * Using this option, can ensure we always callback image with your provided class. If failed to produce one, a error with code `SDWebImageErrorBadImageData` will been used.
     * Note this options is not compatible with `SDWebImageDecodeFirstFrameOnly`, which always produce a UIImage/NSImage.
     * 默认情况下,当您使用`SDWebImageContextAnimatedImageClass`上下文选项(如使用`SDAnimatedImageView`,旨在使用`SDAnimatedImage`)时,我们可能仍然使用`UIImage`当内存缓存命中时,或图像解码器不可用来生成一个完全匹配您的自定义类作为后备解决方案.
     * 使用此选项,可以确保我们始终使用您提供的类回调图像。如果无法生成,将使用代码为`SDWebImageErrorBadImageData`的错误。
     * 请注意,此选项与`SDWebImageDecodeFirstFrameOnly`不兼容,后者始终生成UIImage/NSImage。
     */
    SDWebImageMatchAnimatedImageClass = 1 << 21,
    
    /**
     * By default, when we load the image from network, the image will be written to the cache (memory and disk, controlled by your `storeCacheType` context option)
     * This maybe an asynchronously operation and the final `SDInternalCompletionBlock` callback does not guarantee the disk cache written is finished and may cause logic error. (For example, you modify the disk data just in completion block, however, the disk cache is not ready)
     * If you need to process with the disk cache in the completion block, you should use this option to ensure the disk cache already been written when callback.
     * Note if you use this when using the custom cache serializer, or using the transformer, we will also wait until the output image data written is finished.
     * 默认情况下,当我们从网络加载图像时,图像将被写入缓存(内存和磁盘,由您的`storeCacheType`上下文选项控制)。
     * 这可能是一个异步操作,最终的`SDInternalCompletionBlock`回调不能保证磁盘缓存写入已完成,并可能导致逻辑错误。 (例如,您只在完成块中修改磁盘数据,但是磁盘缓存尚未准备好)
     * 如果您需要在完成块中处理磁盘缓存,应使用此选项以确保在回调时磁盘缓存已经写入。
     * 请注意,如果使用自定义缓存序列化程序或使用变换器,我们也会等待输出图像数据写入完成。
     */
    SDWebImageWaitStoreCache = 1 << 22,
    
    /**
     * We usually don't apply transform on vector images, because vector images supports dynamically changing to any size, rasterize to a fixed size will loss details. To modify vector images, you can process the vector data at runtime (such as modifying PDF tag / SVG element).
     * Use this flag to transform them anyway.
     * 我们通常不对矢量图像应用变换,因为矢量图像支持动态更改为任何大小,对固定大小进行光栅化会损失细节。要修改矢量图像,您可以在运行时处理矢量数据(如修改PDF标记/SVG元素)。
     * 使用此标志无论如何对它们进行变换。
     */
    SDWebImageTransformVectorImage = 1 << 23
};


#pragma mark - Manager Context Options

/**
 A String to be used as the operation key for view category to store the image load operation. This is used for view instance which supports different image loading process. If nil, will use the class name as operation key. (NSString *)
 */
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextSetImageOperationKey;

/**
 A SDWebImageManager instance to control the image download and cache process using in UIImageView+WebCache category and likes. If not provided, use the shared manager (SDWebImageManager *)
 @deprecated Deprecated in the future. This context options can be replaced by other context option control like `.imageCache`, `.imageLoader`, `.imageTransformer` (See below), which already matches all the properties in SDWebImageManager.
 */
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextCustomManager API_DEPRECATED("Use individual context option like .imageCache, .imageLoader and .imageTransformer instead", macos(10.10, API_TO_BE_DEPRECATED), ios(8.0, API_TO_BE_DEPRECATED), tvos(9.0, API_TO_BE_DEPRECATED), watchos(2.0, API_TO_BE_DEPRECATED));

/**
 A `SDCallbackQueue` instance which controls the `Cache`/`Manager`/`Loader`'s callback queue for their completionBlock.
 This is useful for user who call these 3 components in non-main queue and want to avoid callback in main queue.
 @note For UI callback (`sd_setImageWithURL`), we will still use main queue to dispatch, means if you specify a global queue, it will enqueue from the global queue to main queue.
 @note This does not effect the components' working queue (for example, `Cache` still query disk on internal ioQueue, `Loader` still do network on URLSessionConfiguration.delegateQueue), change those config if you need.
 Defaults to nil. Which means main queue.
 */
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextCallbackQueue;

/**
 A id<SDImageCache> instance which conforms to `SDImageCache` protocol. It's used to override the image manager's cache during the image loading pipeline.
 In other word, if you just want to specify a custom cache during image loading, you don't need to re-create a dummy SDWebImageManager instance with the cache. If not provided, use the image manager's cache (id<SDImageCache>)
 */
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextImageCache;

/**
 A id<SDImageLoader> instance which conforms to `SDImageLoader` protocol. It's used to override the image manager's loader during the image loading pipeline.
 In other word, if you just want to specify a custom loader during image loading, you don't need to re-create a dummy SDWebImageManager instance with the loader. If not provided, use the image manager's cache (id<SDImageLoader>)
*/
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextImageLoader;

/**
 A id<SDImageCoder> instance which conforms to `SDImageCoder` protocol. It's used to override the default image coder for image decoding(including progressive) and encoding during the image loading process.
 If you use this context option, we will not always use `SDImageCodersManager.shared` to loop through all registered coders and find the suitable one. Instead, we will arbitrarily use the exact provided coder without extra checking (We may not call `canDecodeFromData:`).
 @note This is only useful for cases which you can ensure the loading url matches your coder, or you find it's too hard to write a common coder which can used for generic usage. This will bind the loading url with the coder logic, which is not always a good design, but possible. (id<SDImageCache>)
*/
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextImageCoder;

/**
 A id<SDImageTransformer> instance which conforms `SDImageTransformer` protocol. It's used for image transform after the image load finished and store the transformed image to cache. If you provide one, it will ignore the `transformer` in manager and use provided one instead. If you pass NSNull, the transformer feature will be disabled. (id<SDImageTransformer>)
 @note When this value is used, we will trigger image transform after downloaded, and the callback's data **will be nil** (because this time the data saved to disk does not match the image return to you. If you need full size data, query the cache with full size url key)
 */
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextImageTransformer;

#pragma mark - Image Decoder Context Options

/**
 A Dictionary (SDImageCoderOptions) value, which pass the extra decoding options to the SDImageCoder. Introduced in SDWebImage 5.14.0
 You can pass additional decoding related options to the decoder, extensible and control by you. And pay attention this dictionary may be retained by decoded image via `UIImage.sd_decodeOptions` 
 This context option replace the deprecated `SDImageCoderWebImageContext`, which may cause retain cycle (cache -> image -> options -> context -> cache)
 @note There are already individual options below like `.imageScaleFactor`, `.imagePreserveAspectRatio`, each of individual options will override the same filed for this dictionary.
 */
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextImageDecodeOptions;

/**
 A CGFloat raw value which specify the image scale factor. The number should be greater than or equal to 1.0. If not provide or the number is invalid, we will use the cache key to specify the scale factor. (NSNumber)
 */
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextImageScaleFactor;

/**
 A Boolean value indicating whether to keep the original aspect ratio when generating thumbnail images (or bitmap images from vector format).
 Defaults to YES. (NSNumber)
 */
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextImagePreserveAspectRatio;

/**
 A CGSize raw value indicating whether or not to generate the thumbnail images (or bitmap images from vector format). When this value is provided, the decoder will generate a thumbnail image which pixel size is smaller than or equal to (depends the `.imagePreserveAspectRatio`) the value size.
 @note When you pass `.preserveAspectRatio == NO`, the thumbnail image is stretched to match each dimension. When `.preserveAspectRatio == YES`, the thumbnail image's width is limited to pixel size's width, the thumbnail image's height is limited to pixel size's height. For common cases, you can just pass a square size to limit both.
 Defaults to CGSizeZero, which means no thumbnail generation at all. (NSValue)
 @note When this value is used, we will trigger thumbnail decoding for url, and the callback's data **will be nil** (because this time the data saved to disk does not match the image return to you. If you need full size data, query the cache with full size url key)
 */
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextImageThumbnailPixelSize;

/**
 A NSString value (UTI) indicating the source image's file extension. Example: "public.jpeg-2000", "com.nikon.raw-image", "public.tiff"
 Some image file format share the same data structure but has different tag explanation, like TIFF and NEF/SRW, see https://en.wikipedia.org/wiki/TIFF
 Changing the file extension cause the different image result. The coder (like ImageIO) may use file extension to choose the correct parser
 @note If you don't provide this option, we will use the `URL.path` as file extension to calculate the UTI hint
 @note If you really don't want any hint which effect the image result, pass `NSNull.null` instead
 */
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextImageTypeIdentifierHint;

#pragma mark - Cache Context Options

/**
 A Dictionary (SDImageCoderOptions) value, which pass the extra encode options to the SDImageCoder. Introduced in SDWebImage 5.15.0
 You can pass encode options like `compressionQuality`, `maxFileSize`, `maxPixelSize` to control the encoding related thing, this is used inside `SDImageCache` during store logic.
 @note For developer who use custom cache protocol (not SDImageCache instance), they need to upgrade and use these options for encoding.
 */
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextImageEncodeOptions;

/**
 A SDImageCacheType raw value which specify the source of cache to query. Specify `SDImageCacheTypeDisk` to query from disk cache only; `SDImageCacheTypeMemory` to query from memory only. And `SDImageCacheTypeAll` to query from both memory cache and disk cache. Specify `SDImageCacheTypeNone` is invalid and totally ignore the cache query.
 If not provide or the value is invalid, we will use `SDImageCacheTypeAll`. (NSNumber)
 */
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextQueryCacheType;

/**
 A SDImageCacheType raw value which specify the store cache type when the image has just been downloaded and will be stored to the cache. Specify `SDImageCacheTypeNone` to disable cache storage; `SDImageCacheTypeDisk` to store in disk cache only; `SDImageCacheTypeMemory` to store in memory only. And `SDImageCacheTypeAll` to store in both memory cache and disk cache.
 If you use image transformer feature, this actually apply for the transformed image, but not the original image itself. Use `SDWebImageContextOriginalStoreCacheType` if you want to control the original image's store cache type at the same time.
 If not provide or the value is invalid, we will use `SDImageCacheTypeAll`. (NSNumber)
 */
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextStoreCacheType;

/**
 The same behavior like `SDWebImageContextQueryCacheType`, but control the query cache type for the original image when you use image transformer feature. This allows the detail control of cache query for these two images. For example, if you want to query the transformed image from both memory/disk cache, query the original image from disk cache only, use `[.queryCacheType : .all, .originalQueryCacheType : .disk]`
 If not provide or the value is invalid, we will use `SDImageCacheTypeDisk`, which query the original full image data from disk cache after transformed image cache miss. This is suitable for most common cases to avoid re-downloading the full data for different transform variants. (NSNumber)
 @note Which means, if you set this value to not be `.none`, we will query the original image from cache, then do transform with transformer, instead of actual downloading, which can save bandwidth usage.
 */
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextOriginalQueryCacheType;

/**
 The same behavior like `SDWebImageContextStoreCacheType`, but control the store cache type for the original image when you use image transformer feature. This allows the detail control of cache storage for these two images. For example, if you want to store the transformed image into both memory/disk cache, store the original image into disk cache only, use `[.storeCacheType : .all, .originalStoreCacheType : .disk]`
 If not provide or the value is invalid, we will use `SDImageCacheTypeDisk`, which store the original full image data into disk cache after storing the transformed image. This is suitable for most common cases to avoid re-downloading the full data for different transform variants. (NSNumber)
 @note This only store the original image, if you want to use the original image without downloading in next query, specify `SDWebImageContextOriginalQueryCacheType` as well.
 */
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextOriginalStoreCacheType;

/**
 A id<SDImageCache> instance which conforms to `SDImageCache` protocol. It's used to control the cache for original image when using the transformer. If you provide one, the original image (full size image) will query and write from that cache instance instead, the transformed image will query and write from the default `SDWebImageContextImageCache` instead. (id<SDImageCache>)
 */
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextOriginalImageCache;

/**
 A Class object which the instance is a `UIImage/NSImage` subclass and adopt `SDAnimatedImage` protocol. We will call `initWithData:scale:options:` to create the instance (or `initWithAnimatedCoder:scale:` when using progressive download) . If the instance create failed, fallback to normal `UIImage/NSImage`.
 This can be used to improve animated images rendering performance (especially memory usage on big animated images) with `SDAnimatedImageView` (Class).
 */
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextAnimatedImageClass;

#pragma mark - Download Context Options

/**
 A id<SDWebImageDownloaderRequestModifier> instance to modify the image download request. It's used for downloader to modify the original request from URL and options. If you provide one, it will ignore the `requestModifier` in downloader and use provided one instead. (id<SDWebImageDownloaderRequestModifier>)
 */
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextDownloadRequestModifier;

/**
 A id<SDWebImageDownloaderResponseModifier> instance to modify the image download response. It's used for downloader to modify the original response from URL and options.  If you provide one, it will ignore the `responseModifier` in downloader and use provided one instead. (id<SDWebImageDownloaderResponseModifier>)
 */
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextDownloadResponseModifier;

/**
 A id<SDWebImageContextDownloadDecryptor> instance to decrypt the image download data. This can be used for image data decryption, such as Base64 encoded image. If you provide one, it will ignore the `decryptor` in downloader and use provided one instead. (id<SDWebImageContextDownloadDecryptor>)
 */
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextDownloadDecryptor;

/**
 A id<SDWebImageCacheKeyFilter> instance to convert an URL into a cache key. It's used when manager need cache key to use image cache. If you provide one, it will ignore the `cacheKeyFilter` in manager and use provided one instead. (id<SDWebImageCacheKeyFilter>)
 */
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextCacheKeyFilter;

/**
 A id<SDWebImageCacheSerializer> instance to convert the decoded image, the source downloaded data, to the actual data. It's used for manager to store image to the disk cache. If you provide one, it will ignore the `cacheSerializer` in manager and use provided one instead. (id<SDWebImageCacheSerializer>)
 */
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextCacheSerializer;
