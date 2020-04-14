//
//  YXPPlayerItemCacheFile.h
//  Common
//
//  Created by yuxuanpeng on 2017/9/30.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface YXPPlayerItemCacheFile : NSObject
@property (nonatomic,copy,readonly) NSString *cacheFilePath;//缓存路径
@property (nonatomic,assign,readonly) NSUInteger fileLength;//文件大小
@property (nonatomic,readonly) BOOL isCompeleted;//是否完成
@property (nonatomic,copy,readonly) NSString *indexFilePath;
@property (nonatomic,assign,readonly) NSUInteger readOffset;//阅读的进度
@property (nonatomic,copy,readonly) NSDictionary *responseHeaders;//响应头
@property (nonatomic,readonly) NSUInteger cachedDataBound;//缓存总大小
@property (nonatomic,copy,readonly)NSString *tmpFilePath;//临时缓存路径

/**
 缓存

 @param filePath 缓存路径
 @return 缓存对象
 */
+ (instancetype)cacheFileWithFilePath:(NSString *)filePath;


/**
 快进

 @param pos 具体的位置
 */
- (void)seekToPosition:(NSUInteger)pos;
- (void)seekToEnd;

/**
 移除缓存
 */
- (void)removeCache;


/**
 文件后缀

 @return 文件路径
 */
+ (NSString *)indexFileExtension;


/**
 文件缓存位置

 @param pos 位置
 @return 对应的缓存位置
 */
- (NSRange)firstNotCachedRangeFromPosition:(NSUInteger)pos;

- (BOOL)synchronize;


/**
 设置回应

 @param response 回应
 @return 状态
 */
- (BOOL)setResponse:(NSHTTPURLResponse *)response;


/**
 保存文件数据

 @param data 文件数据
 @param offset 位置 即开始的起始位置
 @param synchronize 是否同步
 @return 保存状态
 */
- (BOOL)saveData:(NSData *)data atOffset:(NSUInteger)offset synchronize:(BOOL)synchronize;


/**
 临时缓存路径

 @return 缓存路径
 */
-(NSString *)tempFilePath;

@end
