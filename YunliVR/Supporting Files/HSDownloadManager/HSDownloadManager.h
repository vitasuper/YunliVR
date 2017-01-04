//
//  HSDownloadManager.h
//  HSDownloadManagerExample
//
//  Created by hans on 15/8/4. Modified by vitasuper on 16/12/1
//  Copyright © 2015年 hans. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSSessionModel.h"

@interface HSDownloadManager : NSObject

/**
 *  单例
 *
 *  @return 返回单例对象
 */
+ (instancetype)sharedInstance;

/**
 *  开启任务下载资源
 *
 *  @param url           下载地址
 *  @param progressBlock 回调下载进度
 *  @param stateBlock    下载状态
 */
- (void)download:(NSString *)url coverImgUrl:(NSString *)coverImgUrl progress:(void(^)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress))progressBlock state:(void(^)(DownloadState state))stateBlock;

/**
 *  查询该资源的下载进度值
 *
 *  @param url 下载地址
 *
 *  @return 返回下载进度值
 */
- (CGFloat)progress:(NSString *)url;

/**
 *  获取该资源总大小
 *
 *  @param url 下载地址
 *
 *  @return 资源总大小
 */
- (NSInteger)fileTotalLength:(NSString *)url;

/**
 *  获取本地资源总大小
 */
- (NSInteger)fileLocalTotalLength:(NSString *)localUrl;

/**
 *  判断该资源是否下载完成
 *
 *  @param url 下载地址
 *
 *  @return YES: 完成
 */
- (BOOL)isCompletion:(NSString *)url;

/**
 *  删除该资源
 *
 *  @param url 下载地址
 */
- (void)deleteFile:(NSString *)url;

/**
 *  删除本地资源
 */
- (void)deleteLocalFile:(NSString *)localUrl;

/**
 *  清空所有下载资源
 */
- (void)deleteAllFile;


/**
 检测该资源是否正在下载

 @param url 下载地址
 @return 正在下载，返回TRUE；反之返回FALSE
 */
- (BOOL)isDownloading:(NSString *)url;

/**
 检测该资源是否已经下载完成
 
 @param url 下载地址
 @return 下载完成，返回TRUE；反之返回FALSE
 */
- (BOOL)isDownloaded:(NSString *)url;

/**
 检测缓存中是否存在对应文件
 
 @param url 下载地址
 @return 缓存中有，返回TRUE；反之返回FALSE
 */
- (BOOL)isInCache:(NSString *)url;

- (BOOL)isRunning:(NSString *)url;

/**
 *  根据url获取对应的下载信息模型
 */
- (HSSessionModel *)getSessionModel:(NSUInteger)taskIdentifier;

/**
 *  属性的getter
 */

- (NSMutableArray *)getTasksUrls;

- (NSMutableArray *)getTaskCoverImgUrls;

- (NSMutableDictionary *)getTasks;

- (NSMutableDictionary *)getCompletedTasks;

- (NSMutableDictionary *)setCoverImgDict;

- (NSMutableDictionary *)getIsCompletedDict;

- (NSMutableDictionary *)getSessionModels;

@end
