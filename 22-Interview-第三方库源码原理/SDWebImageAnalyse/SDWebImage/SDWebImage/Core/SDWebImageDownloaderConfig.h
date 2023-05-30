/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "SDWebImageCompat.h"

/// Operation execution order
typedef NS_ENUM(NSInteger, SDWebImageDownloaderExecutionOrder) {
    /**
     * Default value. All download operations will execute in queue style (first-in-first-out).
     * 所有下载操作将以队列方式执行(先进先出)。
     */
    SDWebImageDownloaderFIFOExecutionOrder,
    
    /**
     * All download operations will execute in stack style (last-in-first-out).
     * 所有下载操作将以堆栈方式执行(后进先出)。
     */
    SDWebImageDownloaderLIFOExecutionOrder
};

/**
 The class contains all the config for image downloader
 @note This class conform to NSCopying, make sure to add the property in `copyWithZone:` as well.
 */
@interface SDWebImageDownloaderConfig : NSObject <NSCopying>

/**
 Gets the default downloader config used for shared instance or initialization when it does not provide any downloader config. Such as `SDWebImageDownloader.sharedDownloader`.
 @note You can modify the property on default downloader config, which can be used for later created downloader instance. The already created downloader instance does not get affected.
 */
@property (nonatomic, class, readonly, nonnull) SDWebImageDownloaderConfig *defaultDownloaderConfig;

/**
 * The maximum number of concurrent downloads.
 * Defaults to 6.
 * 最大并发下载数。
 * 默认值为6。
 */
@property (nonatomic, assign) NSInteger maxConcurrentDownloads;

/**
 * The timeout value (in seconds) for each download operation.
 * Defaults to 15.0.
 * 每个下载操作的超时值(以秒为单位)。
 * 默认值为15.0。
 */
@property (nonatomic, assign) NSTimeInterval downloadTimeout;

/**
 * The minimum interval about progress percent during network downloading. Which means the next progress callback and current progress callback's progress percent difference should be larger or equal to this value. However, the final finish download progress callback does not get effected.
 * The value should be 0.0-1.0.
 * @note If you're using progressive decoding feature, this will also effect the image refresh rate.
 * @note This value may enhance the performance if you don't want progress callback too frequently.
 * Defaults to 0, which means each time we receive the new data from URLSession, we callback the progressBlock immediately.
 * 网络下载期间进度百分比的最小间隔。这意味着下一个进度回调和当前进度回调的进度百分比差应大于或等于此值。但是,最终完成下载进度回调不受影响。
 * 值应为0.0-1.0。
 * @note 如果使用渐进式解码功能,这也会影响图像刷新率。
 * @note 如果不希望进度回调太频繁,此值可以提高性能。
 * 默认值为0,这意味着每次我们从URLSession接收新数据时,我们将立即调用progressBlock。
 */
@property (nonatomic, assign) double minimumProgressInterval;

/**
 * The custom session configuration in use by NSURLSession. If you don't provide one, we will use `defaultSessionConfiguration` instead.
 * Defatuls to nil.
 * @note This property does not support dynamic changes, means it's immutable after the downloader instance initialized.
 * 由NSURLSession使用的自定义会话配置。如果您未提供,我们将使用`defaultSessionConfiguration`。
 * 默认为nil。
 * @note 此属性不支持动态更改,意味着在下载器实例初始化后,它是不可变的。
 */
@property (nonatomic, strong, nullable) NSURLSessionConfiguration *sessionConfiguration;

/**
 * Gets/Sets a subclass of `SDWebImageDownloaderOperation` as the default
 * `NSOperation` to be used each time SDWebImage constructs a request
 * operation to download an image.
 * Defaults to nil.
 * @note Passing `NSOperation<SDWebImageDownloaderOperation>` to set as default. Passing `nil` will revert to `SDWebImageDownloaderOperation`.
 * 获取/设置`SDWebImageDownloaderOperation`的子类作为默认
 * 每次SDWebImage构建请求
 * 下载图像的操作使用的`NSOperation`。
 * 默认值为nil。
 * @note 传递`NSOperation<SDWebImageDownloaderOperation>以设置默认值。传递nil`将恢复为`SDWebImageDownloaderOperation`。
 */
@property (nonatomic, assign, nullable) Class operationClass;

/**
 * Changes download operations execution order.
 * Defaults to `SDWebImageDownloaderFIFOExecutionOrder`.
 * 更改下载操作的执行顺序。
 * 默认为`SDWebImageDownloaderFIFOExecutionOrder`。
 */
@property (nonatomic, assign) SDWebImageDownloaderExecutionOrder executionOrder;

/**
 * Set the default URL credential to be set for request operations.
 * Defaults to nil.
 * 设置请求操作的默认URL凭据。
 * 默认值为nil。
 */
@property (nonatomic, copy, nullable) NSURLCredential *urlCredential;

/**
 * Set username using for HTTP Basic authentication.
 * Defaults to nil.
 * 设置用于HTTP基本身份验证的用户名。
 * 默认值为nil。
 */
@property (nonatomic, copy, nullable) NSString *username;

/**
 * Set password using for HTTP Basic authentication.
 * Defaults to nil.
 *  * 设置用于HTTP基本身份验证的密码。
 * 默认值为nil。
 */
@property (nonatomic, copy, nullable) NSString *password;

/**
 * Set the acceptable HTTP Response status code. The status code which beyond the range will mark the download operation failed.
 * For example, if we config [200, 400) but server response is 503, the download will fail with error code `SDWebImageErrorInvalidDownloadStatusCode`.
 * Defaults to [200,400). Nil means no validation at all.
 *  * 设置可接受的HTTP响应状态代码。超出范围的状态代码将标记下载操作失败。
 * 例如,如果我们配置[200,400),但服务器响应是503,下载将以错误代码`SDWebImageErrorInvalidDownloadStatusCode`失败。
 * 默认值为[200,400)。Nil意味着根本没有验证。
 */
@property (nonatomic, copy, nullable) NSIndexSet *acceptableStatusCodes;

/**
 * Set the acceptable HTTP Response content type. The content type beyond the set will mark the download operation failed.
 * For example, if we config ["image/png"] but server response is "application/json", the download will fail with error code `SDWebImageErrorInvalidDownloadContentType`.
 * Normally you don't need this for image format detection because we use image's data file signature magic bytes: https://en.wikipedia.org/wiki/List_of_file_signatures
 * Defaults to nil. Nil means no validation at all.
 * 设置可接受的HTTP响应内容类型。超出集合的内容类型将标记下载操作失败。
 * 例如,如果我们配置["image/png"],但服务器响应是"application/json",下载将以错误码`SDWebImageErrorInvalidDownloadContentType`失败。
 * 通常您不需要此图像格式检测,因为我们使用图像的数据文件签名魔术字节:https://en.wikipedia.org/wiki/List_of_file_signatures
 * 默认值为nil。Nil意味着根本没有验证
 */
@property (nonatomic, copy, nullable) NSSet<NSString *> *acceptableContentTypes;

@end
