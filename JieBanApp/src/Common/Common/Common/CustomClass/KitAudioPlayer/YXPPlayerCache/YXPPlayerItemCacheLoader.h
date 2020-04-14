//
//  YXPPlayerItemCacheLoader.h
//  Common
//
//  Created by yuxuanpeng on 2017/9/30.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAssetResourceLoader.h>

@interface YXPPlayerItemCacheLoader : NSObject<AVAssetResourceLoaderDelegate>

@property (nonatomic,readonly) NSString *cacheFilePath;

+ (instancetype)cacheLoaderWithCacheFilePath:(NSString *)cacheFilePath;
- (instancetype)initWithCacheFilePath:(NSString *)cacheFilePath;


/**
 清空缓存

 @param cacheFilePath 文件路径
 */
+ (void)removeCacheWithCacheFilePath:(NSString *)cacheFilePath;


/**
 删除过期数据
 
 @param maxFileCount 设置保留缓存最大个数. 小于0，忽略文件上限
 @param seconds 删除多久之前数据. 小于0,忽略过期时间
 @return 错误信息
 */
+ (NSError *)removeExpireFiles:(NSInteger)maxFileCount beforeTime:(NSInteger)seconds;
/**
 *  清理所有音频缓存
 
 *  return 返回执行删除时错误
 */
+ (NSError *)removeAllAudioCache;

@end
