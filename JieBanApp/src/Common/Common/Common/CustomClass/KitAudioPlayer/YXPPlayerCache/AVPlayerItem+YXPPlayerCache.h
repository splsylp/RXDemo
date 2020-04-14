//
//  AVPlayerItem+YXPPlayerCache.h
//  Common
//
//  Created by yuxuanpeng on 2017/9/30.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>


//NSString *const AVPlayerYXPCacheErrorDomain = @"AVPlayerYXPCacheErrorDomain";
static NSString *const YXPCacheSubDirectoryName = @"AVPlayerMCCache";
static NSString *const kAVPlayerItemMCCacheSupportUrlSchemeSuffix = @"-stream";
//const NSRange YXPInvalidRange = {NSNotFound,0};


NS_INLINE BOOL YXPRangeCanMerge(NSRange range1,NSRange range2)
{
    return (NSMaxRange(range1) == range2.location) || (NSMaxRange(range2) == range1.location) || NSIntersectionRange(range1, range2).length > 0;
}


NS_INLINE BOOL YXPValidFileRange(NSRange range)
{
    return ((range.location != NSNotFound) && range.length > 0 && range.length != NSUIntegerMax);
}

NS_INLINE NSString *YXPCacheTemporaryDirectory()
{
    return [NSTemporaryDirectory() stringByAppendingPathComponent:YXPCacheSubDirectoryName];
}

NS_INLINE BOOL YXPValidByteRange(NSRange range)
{
    return ((range.location != NSNotFound) || (range.length > 0));
}

typedef NS_ENUM(NSUInteger, AVPlayerMCCacheError)
{
    AVPlayerMCCacheErrorFileURL = -1111900,
    AVPlayerMCCacheErrorSchemeNotHTTP = -1111901,
    AVPlayerMCCacheErrorUnsupportFormat = -1111902,
    AVPlayerMCCacheErrorCreateCacheFileFailed = -1111903,
};

NS_INLINE NSString* YXPRangeToHTTPRangeHeader(NSRange range)
{
    if (YXPValidByteRange(range))
    {
        if (range.location == NSNotFound)
        {
            return [NSString stringWithFormat:@"bytes=-%tu",range.length];
        }
        else if (range.length == NSUIntegerMax)
        {
            return [NSString stringWithFormat:@"bytes=%tu-",range.location];
        }
        else
        {
            return [NSString stringWithFormat:@"bytes=%tu-%tu",range.location, NSMaxRange(range) - 1];
        }
    }
    else
    {
        return nil;
    }
}

NS_INLINE NSString* YXPRangeToHTTPRangeReponseHeader(NSRange range,NSUInteger length)
{
    if (YXPValidByteRange(range))
    {
        NSUInteger start = range.location;
        NSUInteger end = NSMaxRange(range) - 1;
        if (range.location == NSNotFound)
        {
            start = range.location;
        }
        else if (range.length == NSUIntegerMax)
        {
            start = length - range.length;
            end = start + range.length - 1;
        }
        return [NSString stringWithFormat:@"bytes %tu-%tu/%tu",start,end,length];
    }
    else
    {
        return nil;
    }
}

@interface AVPlayerItem (YXPPlayerCache)


/**
 *  cache path
 */
@property (nonatomic,copy,readonly) NSString *mc_cacheFilePath;

/**
 远程地址下载

 @param URL URL 远程地址
 @param error 错误详情
 @return 本地 AVPlayerItem
 */
+ (instancetype)mc_playerItemWithRemoteURL:(NSURL *)URL error:(NSError **)error;


/**
 移除本地缓存

 @param cacheFilePath 缓存路径
 */
+ (void)mc_removeCacheWithCacheFilePath:(NSString *)cacheFilePath;


/**
 删除过期数据
 
 @param maxFileCount 设置保留缓存最大个数
 @param seconds 删除多久之前数据
 @return 错误信息
 */
+ (NSError *)removeExpireFiles:(NSInteger)maxFileCount beforeTime:(NSInteger)seconds;
+ (NSError *)removeAllAudioCache;

@end

@interface NSString (MCCacheSupport)
- (NSString *)mc_md5;
- (BOOL)mc_isM3U;
@end

@interface NSURL (MCCacheSupport)
- (NSURL *)mc_URLByReplacingSchemeWithString:(NSString *)scheme;
- (NSURL *)mc_avplayerCacheSupportURL;
- (NSURL *)mc_avplayerOriginalURL;
- (BOOL)mc_isAvPlayerCacheSupportURL;
- (NSString *)mc_pathComponentRelativeToURL:(NSURL *)baseURL;
- (BOOL)mc_isM3U;
@end

@interface NSURLRequest (MCCacheSupport)
@property (nonatomic,readonly) NSRange mc_range;
@end

@interface NSHTTPURLResponse (MCCacheSupport)
- (long long)mc_fileLength;
- (BOOL)mc_supportRange;
@end

@interface AVAssetResourceLoadingRequest (MCCacheSupport)
- (void)mc_fillContentInformation:(NSHTTPURLResponse *)response;
@end

@interface NSFileHandle (MCCacheSupport)
- (BOOL)mc_safeWriteData:(NSData *)data;
@end

