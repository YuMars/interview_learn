// AFURLSessionManager.h
// Copyright (c) 2011–2016 Alamofire Software Foundation ( http://alamofire.org/ )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import <Foundation/Foundation.h>

#import "AFURLResponseSerialization.h"
#import "AFURLRequestSerialization.h"
#import "AFSecurityPolicy.h"
#import "AFCompatibilityMacros.h"
#if !TARGET_OS_WATCH
#import "AFNetworkReachabilityManager.h"
#endif

/**
 AFURLSessionManager 根据指定的 NSURLSessionConfiguration 对象创建和管理 NSURLSession 对象,该对象遵守 <NSURLSessionTaskDelegate>、`<NSURLSessionDataDelegate>、<NSURLSessionDownloadDelegate> 和 <NSURLSessionDelegate>` 协议。
 ## 子类化注意事项
 这是 AFHTTPSessionManager 的基类,它添加了执行 HTTP 请求的特定功能。如果您要专门扩展 AFURLSessionManager 用于 HTTP,请考虑将 AFHTTPSessionManager 作为子类化对象。
 ## NSURLSession 和 NSURLSessionTask 代理方法
 AFURLSessionManager 实现了以下代理方法:
 ### NSURLSessionDelegate
 - URLSession:didBecomeInvalidWithError:
 - URLSession:didReceiveChallenge:completionHandler:
 - URLSessionDidFinishEventsForBackgroundURLSession:
 ### NSURLSessionTaskDelegate
 - URLSession:willPerformHTTPRedirection:newRequest:completionHandler:
 - URLSession:task:didReceiveChallenge:completionHandler:
 - URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:
 - URLSession:task:needNewBodyStream:
 - URLSession:task:didCompleteWithError:
 ### NSURLSessionDataDelegate
  - URLSession:dataTask:didReceiveResponse:completionHandler:
  - URLSession:dataTask:didBecomeDownloadTask:
  - URLSession:dataTask:didReceiveData:
  - URLSession:dataTask:willCacheResponse:completionHandler:
 ### NSURLSessionDownloadDelegate
  - URLSession:downloadTask:didFinishDownloadingToURL:
  - URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:
  - URLSession:downloadTask:didResumeAtOffset:expectedTotalBytes:
 如果在子类中重写了这些方法中的任何一个,则 __必须__ 首先调用 super 实现。
 ## 网络可达性监控
 可通过 reachabilityManager 属性监控网络可达性状态和变化情况。应用程序可选择监控网络可达性状况,以防止或暂停任何发出的请求。有关详细信息,请参阅 AFNetworkReachabilityManager。
 ## NSCoding 注意事项
 - 编码的管理器不包括任何块属性。使用 -initWithCoder: 或 NSKeyedUnarchiver 时,请务必设置委托回调块。
 ## NSCopying 注意事项
 - -copy 和 -copyWithZone: 返回具有从原始配置创建的新 NSURLSession 的新管理器。
 - 操作副本不包括任何委托回调块,因为它们通常强引用 self,这会产生令人意外的副作用,即当复制时,指向__原始__会话管理器。
 @warning 后台会话的管理器必须在使用期间一直持有。这可以通过创建应用程序级别或共享的单例实例来实现。
 */

NS_ASSUME_NONNULL_BEGIN

@interface AFURLSessionManager : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate, NSSecureCoding, NSCopying>

/**
 这个属性代表由AFURLSessionManager创建和管理的NSURLSession对象。
 AFURLSessionManager作为NSURLSession的代理,创建了一个NSURLSession对象,并负责对其进行配置和监听。这个session属性就是它所创建的NSURLSession对象。
 我们可以通过这个属性获取会话相关的信息,如:
 - 会话的配置NSURLSessionConfiguration
 - 会话的代理AFURLSessionManager自身
 - 会话中当前的任务列表[NSArray<NSURLSessionTask *> *tasks]
 - 等等
 并且,通过AFURLSessionManager对这个会话的管理,我们可以进行诸如:
 - 暂停/恢复会话
 - 取消会话或其中的某个任务
 - 监听会话的状态变化和通知等
 */
@property (readonly, nonatomic, strong) NSURLSession *session;

/**
 这个属性表示AFURLSessionManager在其上运行NSURLSession代理回调的NSOperationQueue对象。
 当NSURLSession发出代理通知回调时,这些回调会在此操作队列上运行。例如:
 - URLSession:task:didCompleteWithError:
 - URLSession:dataTask:didReceiveData:
 - URLSession:downloadTask:didFinishDownloadingToURL:
 - 等等
 设置这个属性的目的有二:
 1. 我们可以指定运行代理回调的优先级,从而控制回调被执行的时间点。例如设置为主队列,则回调会立即在主线程运行。
 2. 我们可以将代理回调与AFURLSessionManager自身的操作隔离开来,这样未来即使AFURLSessionManager的运行被阻塞,回调依然可以被执行,避免出现死锁的情况。
 默认情况下,AFURLSessionManager会创建一个专门的队列用于运行代理回调。我们也可以选择传入自定义的队列,例如:

 */
@property (readonly, nonatomic, strong) NSOperationQueue *operationQueue;

/**
 使用 dataTaskWithRequest:success:failure: 创建并使用 GET / POST 等便捷方法运行的数据任务中,从服务器发送的响应会自动由响应序列化程序验证和序列化。默认情况下,此属性设置为 AFJSONResponseSerializer 的实例。
 用于设置AFURLSessionManager在接收到NSURLSessionDataTask的响应时,用以验证和序列化响应的响应序列化器。
 默认情况下,AFURLSessionManager会使用AFJSONResponseSerializer来将JSON响应解析成Foundation对象。
 我们可以设置其他的响应序列化器,例如:
 - AFXMLParserResponseSerializer:解析XML响应
 - AFPropertyListResponseSerializer:解析 plist 格式响应
 - 自定义的响应序列化器等
 这样,AFURLSessionManager在接收响应后,会自动调用此属性指定的响应序列化器的序列化响应数据的方法,并在响应成功的回调中返回解析后的结果给我们。
 */
@property (nonatomic, strong) id <AFURLResponseSerialization> responseSerializer;

///-------------------------------
/// @name Managing Security Policy
///-------------------------------

/**
 为安全连接评估服务器信任度而创建会话使用的安全策略。除非另有说明,否则 AFURLSessionManager 使用 defaultPolicy。
 这个属性用于设置AFURLSessionManager创建的NSURLSession用于评估安全连接服务器信任度的安全策略。
 默认情况下,AFURLSessionManager会为NSURLSession设置默认的安全策略。我们可以自定义此属性为其他安全策略,例如:
 - AFSSLPinningSecurityPolicy:用于对证书锁定的策略
 - AFAllowAllSSLSecurityPolicy:接受所有的SSL证书
 - 等等
 设置这个属性的目的是为了满足我们自定义的SSL验证需求。例如对特定域名进行证书锁定,或者在开发环境下接受所有证书等。
 */
@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;

#if !TARGET_OS_WATCH
///--------------------------------------
/// @name Monitoring Network Reachability
///--------------------------------------

/**
 网络可达性管理器。默认情况下,AFURLSessionManager 使用 sharedManager。
 这个属性用于设置AFURLSessionManager使用的AFNetworkReachabilityManager对象。
 AFNetworkReachabilityManager用于监测设备的网络连接状况(WiFi、蜂窝网络等)及其变化。AFURLSessionManager将使用这个属性指定的AFNetworkReachabilityManager对象来监控网络状况。
 默认情况下,AFURLSessionManager会使用[AFNetworkReachabilityManager sharedManager]
 */
@property (readwrite, nonatomic, strong) AFNetworkReachabilityManager *reachabilityManager;
#endif

///----------------------------
/// @name Getting Session Tasks
///----------------------------

/**
 受管理会话当前运行的数据、上传和下载任务
 这个属性包含了AFURLSessionManager所管理的NSURLSession当前正在运行的所有NSURLSessionTask对象。
 这其中包括:
 - NSURLSessionDataTask:数据任务
 - NSURLSessionUploadTask:上传任务
 - NSURLSessionDownloadTask:下载任务
 通过这个属性,我们可以获取会话当前的所有运行任务,并对其进行操作,例如:
 - 取消某个任务:[task cancel]
 - 暂停/恢复某个任务:[task suspend] / [task resume]
 - 监听某个任务的进度、完成或失败
 - 根据当前运行的任务数量来确定会话的负载情况等
 */
@property (readonly, nonatomic, strong) NSArray <NSURLSessionTask *> *tasks;

/**
 受管理会话当前正在运行的数据任务。
 这个属性包含了AFURLSessionManager所管理的NSURLSession当前正在运行的所有NSURLSessionDataTask对象。
 NSURLSessionDataTask代表进行数据传输的任务,例如使用GET, POST等方法发起的网络请求。
 我们可以通过这个属性获取当前运行的所有数据任务,并对其进行操作,例如:
 - 取消某个数据任务:[dataTask cancel]
 - 监听某个数据任务的进度、完成或失败
 - 根据当前运行的数据任务数量来确定会话的数据传输负载情况等
 */
@property (readonly, nonatomic, strong) NSArray <NSURLSessionDataTask *> *dataTasks;

/**
 受管理会话当前正在运行的上传任务。
 这个属性包含了AFURLSessionManager所管理的NSURLSession当前正在运行的所有NSURLSessionUploadTask对象。
 NSURLSessionUploadTask代表进行数据上传的任务,例如使用POST请求上传文件或二进制数据等。
 我们可以通过这个属性获取当前运行的所有上传任务,并对其进行操作,例如:
 - 取消某个上传任务:[uploadTask cancel]
 - 监听某个上传任务的进度、完成或失败
 - 根据当前运行的上传任务数量来确定会话的数据上传负载情况等
 */
@property (readonly, nonatomic, strong) NSArray <NSURLSessionUploadTask *> *uploadTasks;

/**
 受管理会话当前正在运行的下载任务。
 翻译:
 这个属性包含了AFURLSessionManager所管理的NSURLSession当前正在运行的所有NSURLSessionDownloadTask对象。
 NSURLSessionDownloadTask代表进行数据下载的任务。
 我们可以通过这个属性获取当前运行的所有下载任务,并对其进行操作,例如:
 - 取消某个下载任务:[downloadTask cancel]
 - 监听某个下载任务的进度、完成或失败
 - 根据当前运行的下载任务数量来确定会话的数据下载负载情况等
 */
@property (readonly, nonatomic, strong) NSArray <NSURLSessionDownloadTask *> *downloadTasks;

///-------------------------------
/// @name Managing Callback Queues
///-------------------------------

/**
 The dispatch queue for `completionBlock`. If `NULL` (default), the main queue is used.
 */
@property (nonatomic, strong, nullable) dispatch_queue_t completionQueue;

/**
 completionBlock 的调度队列。如果为 NULL(默认),将使用主队列。
 这个属性用于设置AFURLSessionManager的请求完成回调 completionBlock 被执行的调度队列。
 当一个数据、上传或下载任务完成时,我们通常会设置一个completionBlock回调 block,在其中处理响应或pertain other work。
 默认情况下,AFURLSessionManager会将completionBlock放在主队列主线程执行。通过设置这个属性,我们可以自定义其执行队列,例如:
 - 后台队列:避免阻塞主线程
 - 高优先级队列:优先执行回调
 - 自定义串行/并发队列等
 */
@property (nonatomic, strong, nullable) dispatch_group_t completionGroup;

///---------------------
/// @name Initialization
///---------------------

/**
 使用指定的配置创建和返回一个管理器用于创建会话。这是指定的初始化程序。
 @param configuration 用于创建受管理会话的配置。
 @return 新创建会话的管理器。
 这个方法是AFURLSessionManager的指定初始化方法。
 它使用传入的NSURLSessionConfiguration对象创建一个NSURLSession,并返回一个AFURLSessionManager对象来对其进行管理。
 我们可以传入自定义的configuration对象,例如:
 - 后台配置:创建后台会话
 - 默认配置:创建标准会话
 - 自定义配置:设置会话的缓存策略、超时时间、允许使用蜂窝网络等特性
 AFURLSessionManager作为这个NSURLSession的代理,负责接收其代理回调并做相关处理。同时,AFURLSessionManager也提供了更高级的用于管理、控制这个NSURLSession的属性和方法。
 */
- (instancetype)initWithSessionConfiguration:(nullable NSURLSessionConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

/**
 使受管理会话无效,可选择取消挂起的任务和可选择重置给定的会话。
 @param cancelPendingTasks 是否取消挂起的任务。
 @param resetSession 是否重置管理器的会话。
 这个方法用于使AFURLSessionManager所管理的NSURLSession无效,并选择性地取消未完成的任务或重置会话。
 传入参数:
 - cancelPendingTasks:是否取消NSURLSession中正在运行的任务。设置为YES可取消所有运行中任务。
 - resetSession:是否重置AFURLSessionManager的session属性,并重新创建一个NSURLSession。设置为YES会重置管理器,并重新开始。
 默认情况下,调用此方法后,AFURLSessionManager仅会使其管理的NSURLSession无效,未完成的任务也会无法继续,但session属性并不会重置。
 我们可以根据具体需求选择是否取消未完成任务或重置管理器,例如:
 - 单纯使会话无效然后重新创建,调用`invalidateSessionManager`
 - 使会话无效并取消所有运行中任务,调用`invalidateSessionManager:YES NO`
 - 完全重置管理器,调用`invalidateSessionManager:YES YES`
 */
- (void)invalidateSessionCancelingTasks:(BOOL)cancelPendingTasks resetSession:(BOOL)resetSession;

///-------------------------
/// @name Running Data Tasks
///-------------------------

/**
 使用指定的请求创建一个 NSURLSessionDataTask。
 @param request 请求的HTTP请求。
 @param uploadProgressBlock 当上传进度更新时执行的块对象。请注意,这个块在会话队列上调用,而不是主队列。
 @param downloadProgressBlock 当下载进度更新时执行的块对象。请注意,这个块在会话队列上调用,而不是主队列。
 @param completionHandler 任务完成时执行的块对象。这个块没有返回值,有三个参数:服务器响应、由该反序列化器创建的响应对象和发生的错误(如果有)。
 这个方法用于创建一个NSURLSessionDataTask来进行数据请求。
 它使用传入的NSURLRequest对象创建一个NSURLSessionDataTask,并设置:
 - 上传进度回调block:uploadProgressBlock,在上传过程中更新上传进度。
 - 下载进度回调block:downloadProgressBlock,在下载响应数据过程中更新下载进度。
 - 完成回调block:completionHandler,在请求完成后,返回响应数据或错误信息。
 我们可以在这3个block回调中处理进度更新事件或请求完成后的相关逻辑。
 需要注意的是,uploadProgressBlock和downloadProgressBlock会在后台会话队列中执行。如果需要在主线程更新UI,需要手动dispatch到主队列。
  completionHandler回调会在AFURLSessionManager的completionQueue属性指定的队列(默认主队列)中执行。
 */
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                               uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock
                             downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                            completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler;

///---------------------------
/// @name Running Upload Tasks
///---------------------------

/**
 使用指定的请求为本地文件创建一个 NSURLSessionUploadTask。
 @param request 请求的HTTP请求。
 @param fileURL 要上传的本地文件的URL。
 @param uploadProgressBlock 当上传进度更新时执行的块对象。请注意,这个块在会话队列上调用,而不是主队列。
 @param completionHandler 任务完成时执行的块对象。这个块没有返回值,有三个参数:服务器响应、由该反序列化器创建的响应对象和发生的错误(如果有)。
 这个方法用于创建一个NSURLSessionUploadTask来上传本地文件。
 它使用传入的NSURLRequest对象和本地文件的NSURL创建一个NSURLSessionUploadTask,并设置:
 - 上传进度回调block:uploadProgressBlock,在上传过程中更新上传进度。
 - 完成回调block:completionHandler,在上传完成后,返回响应数据或错误信息。
 我们可以在uploadProgressBlock回调中处理上传进度更新事件,并在completionHandler回调中处理上传完成后的相关逻辑。
 需要注意的是,uploadProgressBlock会在后台会话队列中执行。如果需要在主线程更新UI,需要手动dispatch到主队列。
 completionHandler回调会在AFURLSessionManager的completionQueue属性指定的队列(默认主队列)中执行。
 与dataTaskWithRequest:方法相比,这个方法是更加针对上传文件的任务而设计的,直接传入本地文件的NSURL,更加简洁高效。

 */
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromFile:(NSURL *)fileURL
                                         progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock
                                completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject, NSError  * _Nullable error))completionHandler;

/**
 使用指定的请求为HTTP正文创建一个 NSURLSessionUploadTask。
 @param request 请求的HTTP请求。
 @param bodyData 包含要上传的HTTP主体的数据对象。
 @param uploadProgressBlock 当上传进度更新时执行的块对象。请注意,这个块在会话队列上调用,而不是主队列。
 @param completionHandler 任务完成时执行的块对象。这个块没有返回值,有三个参数:服务器响应、由该反序列化器创建的响应对象和发生的错误(如果有)。
 这个方法用于创建一个NSURLSessionUploadTask来上传HTTP请求体数据。
 它使用传入的NSURLRequest对象和包含HTTP请求体数据的NSData对象创建一个NSURLSessionUploadTask,并设置:
 - 上传进度回调block:uploadProgressBlock,在上传过程中更新上传进度。
 - 完成回调block:completionHandler,在上传完成后,返回响应数据或错误信息。
 我们可以在uploadProgressBlock回调中处理上传进度更新事件,并在completionHandler回调中处理上传完成后的相关逻辑。
 需要注意的是,uploadProgressBlock会在后台会话队列中执行。如果需要在主线程更新UI,需要手动dispatch到主队列。
 completionHandler回调会在AFURLSessionManager的completionQueue属性指定的队列(默认主队列)中执行。
 与uploadTaskWithRequest:fromFile:方法相比,这个方法用于上传HTTP请求体数据,传入NSData对象而非本地文件路径,更加灵活。
 */
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromData:(nullable NSData *)bodyData
                                         progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock
                                completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject, NSError * _Nullable error))completionHandler;

/**
 使用指定的流请求创建一个 NSURLSessionUploadTask。
 @param request 请求的HTTP请求。
 @param uploadProgressBlock 当上传进度更新时执行的块对象。请注意,这个块在会话队列上调用,而不是主队列。
 @param completionHandler 任务完成时执行的块对象。这个块没有返回值,有三个参数:服务器响应、由该反序列化器创建的响应对象和发生的错误(如果有)。
 这个方法用于创建一个NSURLSessionUploadTask来上传流数据(输入流或输出流)。
 它使用传入的NSURLRequest对象创建一个NSURLSessionUploadTask,传入一个NSInputStream或NSOutputStream对象进行流数据上传,并设置:
 - 上传进度回调block:uploadProgressBlock,在上传过程中更新上传进度。
 - 完成回调block:completionHandler,在上传完成后,返回响应数据或错误信息。
 我们可以在uploadProgressBlock回调中处理上传进度更新事件,并在completionHandler回调中处理上传完成后的相关逻辑。
 需要注意的是,uploadProgressBlock会在后台会话队列中执行。如果需要在主线程更新UI,需要手动dispatch到主队列。
 completionHandler回调会在AFURLSessionManager的completionQueue属性指定的队列(默认主队列)中执行。
 与uploadTaskWithRequest:fromFile:和uploadTaskWithRequest:fromData:方法相比,这个方法用于上传输入流或输出流形式的数据,更加灵活高效。
 */
- (NSURLSessionUploadTask *)uploadTaskWithStreamedRequest:(NSURLRequest *)request
                                                 progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock
                                        completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject, NSError * _Nullable error))completionHandler;

///-----------------------------
/// @name Running Download Tasks
///-----------------------------

/**
 使用指定的请求创建一个 NSURLSessionDownloadTask。
 @param request 请求的HTTP请求。
 @param downloadProgressBlock 当下载进度更新时执行的块对象。请注意,这个块在会话队列上调用,而不是主队列。
 @param destination 要在下载完成时确定所下载文件的目标位置的块对象。此块接受两个参数:目标路径和服务器响应,并返回所下载内容的所需文件URL。下载过程中使用的临时文件在移动到返回的URL后会自动删除。
 @param completionHandler 任务完成时执行的块。此块没有返回值,有三个参数:服务器响应、已下载文件的路径和描述网络或解析错误的错误(如果有)。
 @warning 如果在iOS上使用后台`NSURLSessionConfiguration`,则这些块将在应用终止时失效。后台会话可能更喜欢使用`-setDownloadTaskDidFinishDownloadingBlock:`来指定下载文件保存的URL,而不是此方法的目标块。
 这个方法用于创建一个NSURLSessionDownloadTask来下载文件。
 它使用传入的NSURLRequest对象创建一个NSURLSessionDownloadTask,并设置:
 - 下载进度回调block:downloadProgressBlock,在下载过程中更新下载进度。
 - 目标位置确定block:destination,在下载完成后确定下载文件的保存位置,并返回保存文件的NSURL。传入的临时文件会在移动到返回的NSURL后自动删除。
 - 完成回调block:completionHandler,在下载完成后,返回下载文件的NSURL和错误信息(如果有)。
 我们可以在downloadProgressBlock回调中处理下载进度更新事件,destination block中确定保存位置,并在completionHandler回调中获取下载文件的NSURL并进行后续处理。
 需要注意的是,downloadProgressBlock会在后台会话队列中执行。如果需要在主线程更新UI,需要手动dispatch到主队列。
 completionHandler回调会在AFURLSessionManager的completionQueue属性指定的队列(默认主队列)中执行。
 与dataTaskWithRequest:和uploadTaskWithRequest:方法相比,这个方法是更加针对文件下载任务而设计的,提供了文件名确定和打开文件等功能。
 */
- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                             progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                          destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                    completionHandler:(nullable void (^)(NSURLResponse *response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler;

/**
 使用指定的恢复数据创建一个 NSURLSessionDownloadTask。
 @param resumeData 用于恢复下载的数据。
 @param downloadProgressBlock 当下载进度更新时执行的块对象。请注意,这个块在会话队列上调用,而不是主队列。
 @param destination 要在下载完成时确定所下载文件的目标位置的块对象。此块接受两个参数:目标路径和服务器响应,并返回所下载内容的所需文件URL。下载过程中使用的临时文件在移动到返回的URL后会自动删除。
 @param completionHandler 任务完成时执行的块。此块没有返回值,有三个参数:服务器响应、已下载文件的路径和描述网络或解析错误的错误(如果有)。
 这个方法用于使用之前的恢复数据创建一个NSURLSessionDownloadTask来继续下载文件。
 它使用传入的resumeData(上一次下载生成的恢复数据)创建一个NSURLSessionDownloadTask,并设置:
 - 下载进度回调block:downloadProgressBlock,在下载过程中更新下载进度。
 - 目标位置确定block:destination,在下载完成后确定下载文件的保存位置,并返回保存文件的NSURL。传入的临时文件会在移动到返回的NSURL后自动删除。
 - 完成回调block:completionHandler,在下载完成后,返回下载文件的NSURL和错误信息(如果有)。
 我们可以在downloadProgressBlock回调中处理下载进度更新事件,destination block中确定保存位置,并在completionHandler回调中获取下载文件的NSURL并进行后续处理。
 需要注意的是,downloadProgressBlock会在后台会话队列中执行。如果需要在主线程更新UI,需要手动dispatch到主队列。
 completionHandler回调会在AFURLSessionManager的completionQueue属性指定的队列(默认主队列)中执行。
 与downloadTaskWithRequest:方法相比,这个方法使用上一次下载生成的恢复数据继续未完成的下载,这也增强了NSURLSession在断点下载方面的功能。
 */
- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData
                                                progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                             destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                       completionHandler:(nullable void (^)(NSURLResponse *response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler;

///---------------------------------
/// @name Getting Progress for Tasks
///---------------------------------

/**
 返回指定任务的上传进度。
 @param task 会话任务。不能为空。
 @return 一个报告任务上传进度的 NSProgress 对象,
 */
- (nullable NSProgress *)uploadProgressForTask:(NSURLSessionTask *)task;

/**
 返回指定任务的下载进度。
 @param task 会话任务。不能为'nil'。
 @return 报告任务下载进度的 NSProgress 对象,如果进度不可用则返回 nil
 */
- (nullable NSProgress *)downloadProgressForTask:(NSURLSessionTask *)task;

///-----------------------------------------
/// @name Setting Session Delegate Callbacks
///-----------------------------------------

/**
 设置一个block在受管理的会话变得无效时执行,由 NSURLSessionDelegate 方法 URLSession:didBecomeInvalidWithError: 处理。
 @param block 当托管会话变为无效时执行的块对象。该块没有返回值,有两个参数:会话和与无效原因相关的错误。
 这个方法用于设置当 managedSession (由AFURLSessionManager创建和管理的NSURLSession)变为无效时的回调block。
 它将在NSURLSessionDelegate方法URLSession:didBecomeInvalidWithError:中被调用,用于处理session失效相关逻辑。
 我们需要传入一个block,两个参数:
 - session:失效的NSURLSession
 - error:导致session失效的错误
 */
- (void)setSessionDidBecomeInvalidBlock:(nullable void (^)(NSURLSession *session, NSError *error))block;

/**
 当出现连接级身份验证 challenge 时,设置要执行的块,由 NSURLSessionDelegate 方法 URLSession:didReceiveChallenge:completionHandler: 处理。
 @param block 当出现连接级身份验证 challenge 时要执行的块对象。该块返回身份验证 challenge 的处理方式,并接受三个参数:会话、身份验证 challenge 和用于解决 challenge 的凭据指针。
 @warning 自己实现 session 身份验证 challenge 处理程序将完全绕过 AFNetworking 的安全策略(由 AFSecurityPolicy 定义)。在实现自定义 session 身份验证 challenge 处理程序之前,请确保完全理解其影响。如果不想绕过 AFNetworking 的安全策略,请使用 setTaskDidReceiveAuthenticationChallengeBlock:。
 @see -securityPolicy
 @see -setTaskDidReceiveAuthenticationChallengeBlock:
 这个方法用于设置当在连接层发生身份验证challenge时的回调block。
 它将在NSURLSessionDelegate方法URLSession:didReceiveChallenge:completionHandler:中被调用,用于处理整个session的身份验证challenge。
 我们需要传入一个block,三个参数:
 - session:发生challenge的NSURLSession
 - challenge: NSURLAuthenticationChallenge对象
 - credential:用于解决challenge的NSURLCredential对象的指针
 block需要返回一个NSURLSessionAuthChallengeDisposition来指示如何处理challenge。
 */
- (void)setSessionDidReceiveAuthenticationChallengeBlock:(nullable NSURLSessionAuthChallengeDisposition (^)(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential * _Nullable __autoreleasing * _Nullable credential))block;

///--------------------------------------
/// @name Setting Task Delegate Callbacks
///--------------------------------------

/**
 设置一个block在发生连接级别身份验证挑战时执行,由 NSURLSessionDelegate 方法 URLSession:didReceiveChallenge:completionHandler: 处理。
 @param block 当发生连接级别身份验证挑战时执行的块对象。该块返回身份验证挑战的处理方法,有三个参数:会话、身份验证挑战和用于解决挑战的凭据指针。
 @warning 自己完全实现会话身份验证挑战处理程序将完全绕过AFNetworking的`AFSecurityPolicy`中定义的安全政策。在实现自定义会话身份验证挑战处理程序之前,请确保您完全理解其含义。如果您不想绕过AFNetworking的安全政策,请改用`setTaskDidReceiveAuthenticationChallengeBlock:`。
 @see -securityPolicy
 @see -setTaskDidReceiveAuthenticationChallengeBlock:
 设置一个当任务需要向远程服务器发送新请求体数据流时执行的块,由 NSURLSessionTaskDelegate 方法 URLSession:task:needNewBodyStream: 处理。

 这两个方法分别用于设置:
 - 当NSURLSession发生连接级别的身份验证挑战时的回调block。
 - 当NSURLSessionTask需要新的请求体数据流时的回调block。
 第一个方法:
 - 它将在NSURLSessionDelegate方法URLSession:didReceiveChallenge:completionHandler:中被调用
 - 我们需要传入一个block,返回值表示身份验证挑战的处理方式
 - 3个参数:session、身份验证挑战、用于解决挑战的凭据
 第二个方法:
 - 它将在NSURLSessionTaskDelegate方法URLSession:task:needNewBodyStream:中被调用
 - 我们只需要传入一个block
 这两个方法为我们提供了对应场景下的回调机制,可以在block内处理相关逻辑。
 */
- (void)setTaskNeedNewBodyStreamBlock:(nullable NSInputStream * (^)(NSURLSession *session, NSURLSessionTask *task))block;

/**
 设置一个块在HTTP请求尝试执行到不同URL的重定向时执行,由 NSURLSessionTaskDelegate 方法 URLSession:willPerformHTTPRedirection:newRequest:completionHandler: 处理。
 @param block 当HTTP请求尝试执行到不同URL的重定向时执行的块对象。该块返回要为重定向发出的请求,有四个参数:会话、任务、重定向响应和对应于重定向响应的请求。
 这个方法用于设置当NSURLSessionTask执行HTTP重定向时的回调block。
 它将在NSURLSessionTaskDelegate方法URLSession:willPerformHTTPRedirection:newRequest:completionHandler:中被调用,用于重定向请求之前的逻辑处理。
 我们需要传入一个block,它应返回重定向的新NSURLRequest对象,4个参数:
 - session:NSURLSession对象
 - task:将重定向的NSURLSessionTask对象
 - redirectResponse:重定向响应
 - request:对应重定向响应的原始NSURLRequest对象
 在block中我们可以根据需求修改新请求,或者选择不重定向等。
 */
- (void)setTaskWillPerformHTTPRedirectionBlock:(nullable NSURLRequest * _Nullable (^)(NSURLSession *session, NSURLSessionTask *task, NSURLResponse *response, NSURLRequest *request))block;

/**
 设置一个块在会话任务收到特定于请求的身份验证挑战时执行,由 NSURLSessionTaskDelegate 方法 URLSession:task:didReceiveChallenge:completionHandler: 处理。
  @param authenticationChallengeHandler 在会话任务收到特定于请求的身份验证挑战时执行的块对象。
  在实现身份验证挑战处理程序时,您应首先检查身份验证方法(challenge.protectionSpace.authenticationMethod),以决定是否要自己处理身份验证挑战,或者是否要让AFNetworking处理它。如果您想让AFNetworking处理身份验证挑战,只需返回`@(NSURLSessionAuthChallengePerformDefaultHandling)`。例如,您肯定希望AFNetworking根据安全策略处理证书验证(即身份验证方法==NSURLAuthenticationMethodServerTrust)。如果您想自己处理挑战,您有四种选择:
  1. 从身份验证挑战处理程序返回`nil`。您**必须**自己调用完成处理程序并指定处理方法和凭据。在需要向用户呈现界面以输入其凭据的情况下使用此选项。
  2. 从身份验证挑战处理程序返回`NSError`对象。返回`NSError`时,**不要**调用完成处理程序。返回的错误将在任务的完成处理程序中报告。在需要使用特定错误中止身份验证挑战的情况下使用此选项。
  3. 从身份验证挑战处理程序返回`NSURLCredential`对象。返回`NSURLCredential`时,**不要**调用完成处理程序。返回的凭据将用于满足挑战。在可以在不向用户呈现界面的情况下获取凭据时使用此选项。
  4. 从身份验证挑战处理程序返回`NSNumber`对象,其中包装`NSURLSessionAuthChallengeDisposition`。支持的值是`@(NSURLSessionAuthChallengePerformDefaultHandling)`、`@(NSURLSessionAuthChallengeCancelAuthenticationChallenge)`和`@(NSURLSessionAuthChallengeRejectProtectionSpace)`。返回`NSNumber`时,**不要**调用完成处理程序。
  如果从身份验证挑战处理程序返回其他任何内容,则会引发异常。
  有关URL会话如何处理不同类型的身份验证挑战的更多信息,请参见[NSURLSession](https://developer.apple.com/reference/foundation/nsurlsession?language=objc)和[URL Session Programming Guide](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.html)。
 @see -securityPolicy
 */
- (void)setAuthenticationChallengeHandler:(id (^)(NSURLSession *session, NSURLSessionTask *task, NSURLAuthenticationChallenge *challenge, void (^completionHandler)(NSURLSessionAuthChallengeDisposition , NSURLCredential * _Nullable)))authenticationChallengeHandler;

/**
 设置一个块,定期跟踪上传进度,由 NSURLSessionTaskDelegate 方法 URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend: 处理。
  @param block 调用此块以报告已上传到服务器的未知字节数。此块没有返回值,有五个参数:会话、任务、上次调用上传进度块以来写入的字节数、总写入字节数和请求开始时确定的预期总写入字节数(由HTTP body的长度初步确定)。此块可能会被多次调用,并将在主线程上执行。
 */
- (void)setTaskDidSendBodyDataBlock:(nullable void (^)(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))block;

/**
 设置一个块,作为与特定任务相关的最后一条消息执行,由 NSURLSessionTaskDelegate 方法 URLSession:task:didCompleteWithError: 处理。
  @param block 一个块对象,在会话任务完成时执行。该块没有返回值,有三个参数:会话、任务和执行任务过程中发生的任何错误。
 */
- (void)setTaskDidCompleteBlock:(nullable void (^)(NSURLSession *session, NSURLSessionTask *task, NSError * _Nullable error))block;

/**
  设置一个块,在与特定任务相关的指标最终确定时执行,由 NSURLSessionTaskDelegate 方法 URLSession:task:didFinishCollectingMetrics: 处理。
  @param block 一个块对象,在会话任务完成时执行。该块没有返回值,有三个参数:会话、任务和执行任务过程中收集的任何指标。
 */
#if AF_CAN_INCLUDE_SESSION_TASK_METRICS
- (void)setTaskDidFinishCollectingMetricsBlock:(nullable void (^)(NSURLSession *session, NSURLSessionTask *task, NSURLSessionTaskMetrics * _Nullable metrics))block AF_API_AVAILABLE(ios(10), macosx(10.12), watchos(3), tvos(10));
#endif
///-------------------------------------------
/// @name Setting Data Task Delegate Callbacks
///-------------------------------------------

/**
 设置一个块在数据任务收到响应时执行,由`NSURLSessionDataDelegate`方法`URLSession:dataTask:didReceiveResponse:completionHandler:`处理。
 @param block 当数据任务收到响应时执行的块对象。该块返回会话响应的处理方式,有三个参数:会话、数据任务和收到的响应。
 这个方法用于设置当NSURLSessionDataTask收到响应时的回调block。
 它将在NSURLSessionDataDelegate方法URLSession:dataTask:didReceiveResponse:completionHandler:中被调用,用于处理收到的响应。
 我们需要传入一个block,它应返回会话响应的处理方式,三个参数:
 - session:NSURLSession对象
 - dataTask:接收到响应的NSURLSessionDataTask
 - response:收到的NSURLResponse对象
 在block中我们可以根据需求修改响应,或者选择不处理等。

 */
- (void)setDataTaskDidReceiveResponseBlock:(nullable NSURLSessionResponseDisposition (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response))block;

/**
 设置一个块在数据任务变为下载任务时执行,由`NSURLSessionDataDelegate`方法`URLSession:dataTask:didBecomeDownloadTask:`处理。
 @param block 当数据任务变为下载任务时执行的块对象。该块没有返回值,有三个参数:会话、数据任务和它变为的下载任务。
 
 这个方法用于设置当NSURLSessionDataTask变为NSURLSessionDownloadTask时的回调block。
 它将在NSURLSessionDataDelegate方法URLSession:dataTask:didBecomeDownloadTask:中被调用,用于在数据任务转变为下载任务之后进行处理。
 我们需要传入一个block,无返回值,三个参数:
 - session:NSURLSession对象
 - dataTask: 变为下载任务之前的NSURLSessionDataTask
 - downloadTask:变为的NSURLSessionDownloadTask对象
 在block中我们可以根据需求处理下载任务,因为数据任务已经转变为下载任务。
 这个方法为我们提供了对应场景的回调机制,在数据任务转变为下载任务这个关键时刻进行回调,这增强了对任务执行流程的控制和管理。
 */
- (void)setDataTaskDidBecomeDownloadTaskBlock:(nullable void (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLSessionDownloadTask *downloadTask))block;

/**
 设置一个块在数据任务收到数据时执行,由`NSURLSessionDataDelegate`方法`URLSession:dataTask:didReceiveData:`处理。
 @param block 调用此块以报告从服务器下载的未知字节数。此块没有返回值,有三个参数:会话、数据任务和收到的数据。此块可能会被多次调用,并且将在会话管理器操作队列上执行。
 这个方法用于设置当NSURLSessionDataTask收到数据时的回调block。
 它将在NSURLSessionDataDelegate方法URLSession:dataTask:didReceiveData:中被周期性调用,用于处理下载的数据。
 我们需要传入一个block,无返回值,三个参数:
 - session:NSURLSession对象
 - dataTask:接收到数据的NSURLSessionDataTask对象
 - data:收到的数据
 在block中我们可以根据需求处理下载的数据。此block可能会被多次调用,用于处理数据任务下载的全部数据。
 */
- (void)setDataTaskDidReceiveDataBlock:(nullable void (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data))block;

/**
 设置一个块在确定数据任务的缓存行为时执行,由`NSURLSessionDataDelegate`方法`URLSession:dataTask:willCacheResponse:completionHandler:`处理。
 @param block 确定数据任务缓存行为的块对象。该块返回要缓存的响应,有三个参数:会话、数据任务和提出的缓存URL响应。
 这个方法用于设置确定NSURLSessionDataTask缓存行为的回调block。
 它将在NSURLSessionDataDelegate方法URLSession:dataTask:willCacheResponse:completionHandler:中被调用,用于决定是否要缓存响应及如何缓存。
 我们需要传入一个block,它应返回要缓存的响应,三个参数:
 - session:NSURLSession对象
 - dataTask:执行缓存判断的NSURLSessionDataTask
 - proposedResponse:提出缓存的NSURLResponse对象
 在block中我们有三种选择:
 1. 返回proposedResponse对象:同意缓存该响应
 2. 返回nil:不同意缓存该响应
 3. 返回另一个NSURLResponse对象:同意缓存指定的响应
 */
- (void)setDataTaskWillCacheResponseBlock:(nullable NSCachedURLResponse * (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSCachedURLResponse *proposedResponse))block;

/**
 设置一个块,在为会话排队的所有消息都已传递后执行一次,由 NSURLSessionDataDelegate 方法 URLSessionDidFinishEventsForBackgroundURLSession: 处理。
  @param block  一个块对象,在为会话排队的所有消息都已传递后执行一次。该块没有返回值,只有一个参数:会话。
 这个方法用于设置在后台NSURLSession传递完所有消息(事件)后的回调block。
 它将在NSURLSessionDataDelegate方法URLSessionDidFinishEventsForBackgroundURLSession:中被调用一次,用于在所有消息传递完毕之后进行处理。
 我们需要传入一个block,无返回值,一个参数:
 - session:NSURLSession对象
 在block中我们可以根据需求执行一些清理工作,因为所有消息(事件)已经传递完毕。
 */
- (void)setDidFinishEventsForBackgroundURLSessionBlock:(nullable void (^)(NSURLSession *session))block AF_API_UNAVAILABLE(macos);

///-----------------------------------------------
/// @name Setting Download Task Delegate Callbacks
///-----------------------------------------------

/**
 设置一个块在下载任务完成下载时执行,由`NSURLSessionDownloadDelegate`方法`URLSession:downloadTask:didFinishDownloadingToURL:`处理。
 @param block 下载任务完成时执行的块对象。该块返回下载应移动到的URL,有三个参数:会话、下载任务和下载文件临时位置。如果文件管理器在试图将临时文件移动到目标位置时遇到错误,将发布`AFURLSessionDownloadTaskDidFailToMoveFileNotification`通知,下载任务作为其对象,并带有错误的user info。
 这个方法用于设置当NSURLSessionDownloadTask完成下载时的回调block。
 它将在NSURLSessionDownloadDelegate方法URLSession:downloadTask:didFinishDownloadingToURL:中被调用一次,用于在下载完成后进行处理。
 我们需要传入一个block,它应返回下载文件应移动到的NSURL,三个参数:
 - session:NSURLSession对象
 - downloadTask:完成下载的NSURLSessionDownloadTask对象
 - location:下载文件临时存放位置的NSURL
 在block中我们需要返回下载文件最终存放位置的NSURL。如果在移动文件过程中出现错误,AFNetworking会发布`AFURLSessionDownloadTaskDidFailToMoveFileNotification`通知,并在userInfo中包含错误信息。
 */
- (void)setDownloadTaskDidFinishDownloadingBlock:(nullable NSURL * _Nullable  (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, NSURL *location))block;

/**
 设置一个块,定期执行以跟踪下载进度,由 NSURLSessionDownloadDelegate 方法 URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite: 处理。
 @param block 调用此块以报告从服务器下载的未知字节数。此块没有返回值,有五个参数:会话、下载任务、上次调用下载进度块以来读取的字节数、总读取字节数和请求开始时确定的预期总读取字节数(最初由 NSHTTPURLResponse 对象的预期内容大小确定)。此块可能会被多次调用,并将在会话管理器操作队列上执行。
 这个方法用于设置定期跟踪NSURLSessionDownloadTask下载进度的回调block。
 它将在NSURLSessionDownloadDelegate方法URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:中周期性调用,用于报告下载进度。
 我们需要传入一个block,无返回值,五个参数:
 - session:NSURLSession对象
 - downloadTask:正在下载的NSURLSessionDownloadTask对象
 - bytesWritten:上次回调后的已下载字节数
 - totalBytesWritten:总共已下载字节数
 - totalBytesExpectedToWrite:预期总下载字节数
 在block中我们可以根据下载进度更新UI等。此block可能会被多次调用,用于报告下载任务的全部进度。
 */
- (void)setDownloadTaskDidWriteDataBlock:(nullable void (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite))block;

/**
 设置一个块在下载任务恢复时执行,由`NSURLSessionDownloadDelegate`方法`URLSession:downloadTask:didResumeAtOffset:expectedTotalBytes:`处理。
 @param block 下载任务恢复时执行的块对象。该块没有返回值,有四个参数:会话、下载任务、恢复下载的文件偏移量和预期下载总字节数。
 这个方法用于设置当NSURLSessionDownloadTask被恢复时的回调block。
 它将在NSURLSessionDownloadDelegate方法URLSession:downloadTask:didResumeAtOffset:expectedTotalBytes:中被调用一次,用于在下载任务恢复后进行处理。
 我们需要传入一个block,无返回值,四个参数:
 - session:NSURLSession对象
 - downloadTask:被恢复的NSURLSessionDownloadTask对象
 - fileOffset:恢复下载的文件偏移量
 - expectedTotalBytes:预期总下载字节数
 在block中我们可以根据需求在下载任务恢复后执行一些操作。

 */
- (void)setDownloadTaskDidResumeBlock:(nullable void (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t fileOffset, int64_t expectedTotalBytes))block;

@end

///--------------------
/// @name Notifications
///--------------------

/**
 Posted when a task resumes.
 */
FOUNDATION_EXPORT NSString * const AFNetworkingTaskDidResumeNotification;

/**
 Posted when a task finishes executing. Includes a userInfo dictionary with additional information about the task.
 */
FOUNDATION_EXPORT NSString * const AFNetworkingTaskDidCompleteNotification;

/**
 Posted when a task suspends its execution.
 */
FOUNDATION_EXPORT NSString * const AFNetworkingTaskDidSuspendNotification;

/**
 Posted when a session is invalidated.
 */
FOUNDATION_EXPORT NSString * const AFURLSessionDidInvalidateNotification;

/**
 Posted when a session download task finished moving the temporary download file to a specified destination successfully.
 */
FOUNDATION_EXPORT NSString * const AFURLSessionDownloadTaskDidMoveFileSuccessfullyNotification;

/**
 Posted when a session download task encountered an error when moving the temporary download file to a specified destination.
 */
FOUNDATION_EXPORT NSString * const AFURLSessionDownloadTaskDidFailToMoveFileNotification;

/**
 The raw response data of the task. Included in the userInfo dictionary of the `AFNetworkingTaskDidCompleteNotification` if response data exists for the task.
 */
FOUNDATION_EXPORT NSString * const AFNetworkingTaskDidCompleteResponseDataKey;

/**
 The serialized response object of the task. Included in the userInfo dictionary of the `AFNetworkingTaskDidCompleteNotification` if the response was serialized.
 */
FOUNDATION_EXPORT NSString * const AFNetworkingTaskDidCompleteSerializedResponseKey;

/**
 The response serializer used to serialize the response. Included in the userInfo dictionary of the `AFNetworkingTaskDidCompleteNotification` if the task has an associated response serializer.
 */
FOUNDATION_EXPORT NSString * const AFNetworkingTaskDidCompleteResponseSerializerKey;

/**
 The file path associated with the download task. Included in the userInfo dictionary of the `AFNetworkingTaskDidCompleteNotification` if an the response data has been stored directly to disk.
 */
FOUNDATION_EXPORT NSString * const AFNetworkingTaskDidCompleteAssetPathKey;

/**
 Any error associated with the task, or the serialization of the response. Included in the userInfo dictionary of the `AFNetworkingTaskDidCompleteNotification` if an error exists.
 */
FOUNDATION_EXPORT NSString * const AFNetworkingTaskDidCompleteErrorKey;

/**
 The session task metrics taken from the download task. Included in the userInfo dictionary of the `AFNetworkingTaskDidCompleteSessionTaskMetrics`
 */
FOUNDATION_EXPORT NSString * const AFNetworkingTaskDidCompleteSessionTaskMetrics;

NS_ASSUME_NONNULL_END
