//
//  HSDownloadManager.m
//  HSDownloadManagerExample
//
//  Created by hans on 15/8/4. Modified by vitasuper on 16/12/1
//  Copyright © 2015年 hans. All rights reserved.
//

// 缓存主目录
#define HSCachesDirectory [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"HSCache"]

// 保存文件名
#define HSFileName(url) [url lastPathComponent]

// 文件的存放路径（caches）
//#define HSFileFullpath(url) [HSCachesDirectory stringByAppendingPathComponent:HSFileName(url)]
#define HSFileFullpath(url) [HSCachesDirectory stringByAppendingPathComponent:HSFileName(url)]

// 文件的已下载长度
#define HSDownloadLength(url) [[[NSFileManager defaultManager] attributesOfItemAtPath:HSFileFullpath(url) error:nil][NSFileSize] integerValue]

// 存储文件总长度的文件路径（caches）
#define HSTotalLengthFullpath [HSCachesDirectory stringByAppendingPathComponent:@"totalLength.plist"]

#import "HSDownloadManager.h"
#import "NSString+Hash.h"

@interface HSDownloadManager()<NSCopying, NSURLSessionDelegate>

@property (nonatomic, strong) NSMutableArray *tasksUrls;
@property (nonatomic, strong) NSMutableArray *taskCoverImgUrls;

/** 保存所有下载中的任务(注：用下载地址md5后作为key)
 (NSString *)url(MD5) <-> (NSURLSessionDataTask *)task
 */
@property (nonatomic, strong) NSMutableDictionary *tasks;

/** 保存下载好的任务
 (NSString *)url(MD5) <-> (NSURLSessionDataTask *)task
 */
@property (nonatomic, strong) NSMutableDictionary *completedTasks;

/** 字典，存下载任务及对应的缩略图url
 (NSString *)url(MD5) <-> (NSString *)coverImgUrl
 */
@property (nonatomic, strong) NSMutableDictionary *coverImgDict;

/** 字典，存下载任务下载完成情况 
 (NSString *)url(MD5) <-> (BOOL)isCompleted
 */
@property (nonatomic, strong) NSMutableDictionary *isCompletedDict;

/** 保存所有下载相关信息 */
@property (nonatomic, strong) NSMutableDictionary *sessionModels;
@end

@implementation HSDownloadManager


- (NSMutableArray *)tasksUrls {
    if (!_tasksUrls) {
        _tasksUrls = [[NSMutableArray alloc] init];
    }
    return _tasksUrls;
}

- (NSMutableArray *)taskCoverImgUrls {
    if (!_taskCoverImgUrls) {
        _taskCoverImgUrls = [[NSMutableArray alloc] init];
    }
    return _taskCoverImgUrls;
}

- (NSMutableDictionary *)tasks {
    if (!_tasks) {
        _tasks = [NSMutableDictionary dictionary];
    }
    return _tasks;
}

- (NSMutableDictionary *)completedTasks {
    if (!_completedTasks) {
        _completedTasks = [NSMutableDictionary dictionary];
    }
    return _completedTasks;
}

- (NSMutableDictionary *)coverImgDict {
    if (!_coverImgDict) {
        _coverImgDict = [NSMutableDictionary dictionary];
    }
    return _coverImgDict;
}

- (NSMutableDictionary *)isCompletedDict {
    if (!_isCompletedDict) {
        _isCompletedDict = [NSMutableDictionary dictionary];
    }
    return _isCompletedDict;
}

- (NSMutableDictionary *)sessionModels {
    if (!_sessionModels) {
        _sessionModels = [NSMutableDictionary dictionary];
    }
    return _sessionModels;
}


static HSDownloadManager *_downloadManager;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _downloadManager = [super allocWithZone:zone];
    });
    
    return _downloadManager;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return _downloadManager;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _downloadManager = [[self alloc] init];
    });
    
    return _downloadManager;
}

/**
 *  创建缓存目录文件
 */
- (void)createCacheDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:HSCachesDirectory]) {
        [fileManager createDirectoryAtPath:HSCachesDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

/**
 *  开启任务下载资源
 */
- (void)download:(NSString *)url coverImgUrl:(NSString *)taskCoverImgUrl progress:(void (^)(NSInteger, NSInteger, CGFloat))progressBlock state:(void (^)(DownloadState))stateBlock {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!url) return;
        if ([self isCompletion:url]) {
            stateBlock(DownloadStateCompleted);
            NSLog(@"----该资源已下载完成");
            return;
        }
        
        // 暂停
        if ([self.tasks valueForKey:HSFileName(url)]) {
            [self handle:url];
            
            return;
        }
        
        // 新任务
        // 创建缓存目录文件
        [self createCacheDirectory];
        
        [self.tasksUrls addObject:url];
        [self.taskCoverImgUrls addObject:taskCoverImgUrl];
        //    NSLog(@"DEBUG2.0: %lu", (unsigned long)[self.taskCoverImgUrls count]);
        //    NSLog(@"DEBUG2.1: %@", taskCoverImgUrl);
        
        // 新资源才存缩略图，并设置为未完成状态
        [self.coverImgDict setObject:taskCoverImgUrl forKey:HSFileName(url)];
        [self.isCompletedDict setObject:[NSNumber numberWithBool:FALSE] forKey:HSFileName(url)];
        
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
        
        // 创建流
        NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:HSFileFullpath(url) append:YES];
        
        // 创建请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        
        // 设置请求头
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-", HSDownloadLength(url)];
        [request setValue:range forHTTPHeaderField:@"Range"];
        
        // 创建一个Data任务
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
        NSUInteger taskIdentifier = arc4random() % ((arc4random() % 10000 + arc4random() % 10000));
        [task setValue:@(taskIdentifier) forKeyPath:@"taskIdentifier"];
        
        // 保存任务
        [self.tasks setValue:task forKey:HSFileName(url)];
        
        HSSessionModel *sessionModel = [[HSSessionModel alloc] init];
        sessionModel.url = url;
        sessionModel.progressBlock = progressBlock;
        sessionModel.stateBlock = stateBlock;
        sessionModel.stream = stream;
        sessionModel.coverImgUrl = taskCoverImgUrl;
        [self.sessionModels setValue:sessionModel forKey:@(task.taskIdentifier).stringValue];
        
        [self start:url];
    });
}

- (void)handle:(NSString *)url {
    NSURLSessionDataTask *task = [self getTask:url];
    if (task.state == NSURLSessionTaskStateRunning) {
        [self pause:url];
    } else {
        [self start:url];
    }
}

- (BOOL)isRunning:(NSString *)url {
    NSURLSessionDataTask *task = [self getTask:url];
    if (task.state == NSURLSessionTaskStateRunning) {
        return YES;
    } else {
        return NO;
    }
}

/**
 *  开始下载
 */
- (void)start:(NSString *)url {
    NSURLSessionDataTask *task = [self getTask:url];
    [task resume];

    [self getSessionModel:task.taskIdentifier].stateBlock(DownloadStateStart);
}

/**
 *  暂停下载
 */
- (void)pause:(NSString *)url {
    NSLog(@"DEBUG4: 要暂停的url: %@", url);
    
    NSURLSessionDataTask *task = [self getTask:url];
    [task suspend];

    
    [self getSessionModel:task.taskIdentifier].stateBlock(DownloadStateSuspended);
}

/**
 *  根据url获得对应的下载任务
 */
- (NSURLSessionDataTask *)getTask:(NSString *)url {
    return (NSURLSessionDataTask *)[self.tasks valueForKey:HSFileName(url)];
}

/**
 *  根据url获取对应的下载信息模型
 */
- (HSSessionModel *)getSessionModel:(NSUInteger)taskIdentifier {
    return (HSSessionModel *)[self.sessionModels valueForKey:@(taskIdentifier).stringValue];
}

/**
 *  判断该文件是否下载完成
 */
- (BOOL)isCompletion:(NSString *)url {
    if ([self fileTotalLength:url] && HSDownloadLength(url) == [self fileTotalLength:url]) {
        return YES;
    }
    return NO;
}

/**
 *  查询该资源的下载进度值
 */
- (CGFloat)progress:(NSString *)url {
    return [self fileTotalLength:url] == 0 ? 0.0 : 1.0 * HSDownloadLength(url) /  [self fileTotalLength:url];
}

/**
 *  获取该资源总大小
 */
- (NSInteger)fileTotalLength:(NSString *)url {
    return [[NSDictionary dictionaryWithContentsOfFile:HSTotalLengthFullpath][HSFileName(url)] integerValue];
}

/**
 *  获取本地资源总大小
 */
- (NSInteger)fileLocalTotalLength:(NSString *)localUrl {
    return [[NSDictionary dictionaryWithContentsOfFile:HSTotalLengthFullpath][localUrl] integerValue];
}

#pragma mark - 删除
/**
 *  删除该资源
 */
- (void)deleteFile:(NSString *)url {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:HSFileFullpath(url)]) {
        [self handle:url];
        // 删除沙盒中的资源
        [fileManager removeItemAtPath:HSFileFullpath(url) error:nil];
        
        [self.tasksUrls removeObject:url];
//        [self.taskCoverImgUrlDict removeObject:]
        
        // 删除缩略图
        [self.coverImgDict removeObjectForKey:HSFileName(url)];
        
        // 删除任务
        [self.tasks removeObjectForKey:HSFileName(url)];
        [self.completedTasks removeObjectForKey:HSFileName(url)];
        [self.isCompletedDict removeObjectForKey:HSFileName(url)];
        [self.sessionModels removeObjectForKey:@([self getTask:url].taskIdentifier).stringValue];
        // 删除资源总长度
        if ([fileManager fileExistsAtPath:HSTotalLengthFullpath]) {
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:HSTotalLengthFullpath];
            [dict removeObjectForKey:HSFileName(url)];
            [dict writeToFile:HSTotalLengthFullpath atomically:YES];
        
        }
    }
}

/**
 *  删除本地资源
 */
- (void)deleteLocalFile:(NSString *)localUrl {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[HSCachesDirectory stringByAppendingPathComponent:localUrl]]) {
        
        // 删除沙盒中的资源
        [fileManager removeItemAtPath:[HSCachesDirectory stringByAppendingPathComponent:localUrl] error:nil];
        
        // 删除缩略图
//        [self.coverImgDict removeObjectForKey:HSFileName(url)];
        
        // 删除任务
        // 删除资源总长度
        if ([fileManager fileExistsAtPath:HSTotalLengthFullpath]) {
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:HSTotalLengthFullpath];
            [dict removeObjectForKey:localUrl];
            [dict writeToFile:HSTotalLengthFullpath atomically:YES];
            
        }
    }
}

/**
 *  清空所有下载资源 - 未完成
 */
- (void)deleteAllFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:HSCachesDirectory]) {
        // 删除沙盒中所有资源
        
        [fileManager removeItemAtPath:HSCachesDirectory error:nil];
        // 删除任务
        [[self.tasks allValues] makeObjectsPerformSelector:@selector(cancel)];
        [self.tasks removeAllObjects];
        
        for (HSSessionModel *sessionModel in [self.sessionModels allValues]) {
            [sessionModel.stream close];
        }
        [self.sessionModels removeAllObjects];
        
        // 删除资源总长度
        if ([fileManager fileExistsAtPath:HSTotalLengthFullpath]) {
            [fileManager removeItemAtPath:HSTotalLengthFullpath error:nil];
        }
    }
}

#pragma mark - 用于“我的下载”页面的方法

/**
 检测该资源是否正在下载
 */
- (BOOL)isDownloading:(NSString *)url {
    if ([self.tasks objectForKey:HSFileName(url)] != nil) {
        return TRUE;
    } else {
        return FALSE;
    }
}

/**
 检测该资源是否已经下载完成
 */
- (BOOL)isDownloaded:(NSString *)url {
    if ([self.completedTasks objectForKey:HSFileName(url)] != nil) {
        return TRUE;
    } else {
        return FALSE;
    }
}

/**
 检测缓存中是否存在对应文件
 */
- (BOOL)isInCache:(NSString *)url {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:HSFileFullpath(url)]) {
        return TRUE;
    } else {
        return FALSE;
    }
}

#pragma mark - 属性getter

- (NSMutableDictionary *)getTasks {
    return self.tasks;
}

- (NSMutableArray *)getTaskCoverImgUrls {
    return self.taskCoverImgUrls;
}


- (NSMutableDictionary *)getCompletedTasks {
    return self.completedTasks;
}

- (NSMutableDictionary *)setCoverImgDict {
    return self.setCoverImgDict;
}

- (NSMutableDictionary *)getIsCompletedDict {
    return self.getIsCompletedDict;
}

- (NSMutableDictionary *)getSessionModels {
    return self.sessionModels;
}

- (NSMutableArray *)getTasksUrls {
    return self.tasksUrls;
}
#pragma mark - 代理
#pragma mark NSURLSessionDataDelegate
/**
 * 接收到响应
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    HSSessionModel *sessionModel = [self getSessionModel:dataTask.taskIdentifier];
    
    // 打开流
    [sessionModel.stream open];
    
    // 获得服务器这次请求 返回数据的总长度
    NSInteger totalLength = [response.allHeaderFields[@"Content-Length"] integerValue] + HSDownloadLength(sessionModel.url);
    sessionModel.totalLength = totalLength;
    
    // 存储总长度
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:HSTotalLengthFullpath];
    if (dict == nil) dict = [NSMutableDictionary dictionary];
    dict[HSFileName(sessionModel.url)] = @(totalLength);
    [dict writeToFile:HSTotalLengthFullpath atomically:YES];
    
    // 接收这个请求，允许接收服务器的数据
    completionHandler(NSURLSessionResponseAllow);
}

/**
 * 接收到服务器返回的数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    HSSessionModel *sessionModel = [self getSessionModel:dataTask.taskIdentifier];
    
    // 写入数据
    [sessionModel.stream write:data.bytes maxLength:data.length];
    
    // 下载进度
    NSUInteger receivedSize = HSDownloadLength(sessionModel.url);
    NSUInteger expectedSize = sessionModel.totalLength;
    CGFloat progress = 1.0 * receivedSize / expectedSize;

    sessionModel.progressBlock(receivedSize, expectedSize, progress);
    
    NSLog(@"我还在下载……是你想要的吗？！");
}

/**
 * 请求完毕（成功|失败）
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    HSSessionModel *sessionModel = [self getSessionModel:task.taskIdentifier];
    if (!sessionModel) return;
    
    if ([self isCompletion:sessionModel.url]) {
        // 下载完成
        sessionModel.stateBlock(DownloadStateCompleted);
        
        // 将下载项完成度置为已完成(TRUE)
        [self.isCompletedDict setObject:[NSNumber numberWithBool:TRUE] forKey:HSFileName(sessionModel.url)];
        // 移入completedTasks字典
        [self.completedTasks setObject:[self.tasks objectForKey:HSFileName(sessionModel.url)] forKey:HSFileName(sessionModel.url)];
        
    } else if (error) {
        // 下载失败
        sessionModel.stateBlock(DownloadStateFailed);
        
        // 下载失败的话删除缩略图
        [self.coverImgDict removeObjectForKey:HSFileName(sessionModel.url)];
    }
    
    // 关闭流
    [sessionModel.stream close];
    sessionModel.stream = nil;
    
    // 完成后在tasks字典清除任务
    [self.tasksUrls removeObject:sessionModel.url];
    [self.tasks removeObjectForKey:HSFileName(sessionModel.url)];
    [self.sessionModels removeObjectForKey:@(task.taskIdentifier).stringValue];

    NSLog(@"%@ 下载好啦！", [sessionModel.url lastPathComponent]);
}

@end
