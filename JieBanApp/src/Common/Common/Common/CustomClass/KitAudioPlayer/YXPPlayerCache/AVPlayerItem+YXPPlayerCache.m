//
//  AVPlayerItem+YXPPlayerCache.m
//  Common
//
//  Created by yuxuanpeng on 2017/9/30.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "AVPlayerItem+YXPPlayerCache.h"
#import "YXPPlayerItemCacheLoader.h"
#import "YXPPlayerItemCacheFile.h"
#import <MobileCoreServices/MobileCoreServices.h>


static const void * const kAVPlayerItemMCCacheSupportCacheLoaderKey = &kAVPlayerItemMCCacheSupportCacheLoaderKey;


@implementation AVPlayerItem (YXPPlayerCache)

#pragma mark - init
+ (NSError *)mc_errorWithCode:(AVPlayerMCCacheError)errorCode reason:(NSString *)reason
{
    return [NSError errorWithDomain:@"AVPlayerYXPCacheErrorDomain" code:errorCode userInfo:@{
                                                                                         NSLocalizedDescriptionKey : @"The operation couldn’t be completed.",
                                                                                         NSLocalizedFailureReasonErrorKey : reason,
                                                                                         }];
}




+ (instancetype)mc_playerItemWithRemoteURL:(NSURL *)URL error:(NSError *__autoreleasing *)error
{
    return [self mc_playerItemWithRemoteURL:URL options:nil cacheFilePath:nil error:error];
}

+ (instancetype)mc_playerItemWithRemoteURL:(NSURL *)URL options:(NSDictionary<NSString *,id> *)options cacheFilePath:(NSString *)cacheFilePath error:(NSError *__autoreleasing *)error
{
    NSError *err = [self mc_checkURL:URL];
    if (err)
    {
        if (error != NULL)
        {
            *error = err;
        }
        return [self playerItemWithURL:URL];
    }
    
    NSString *path = cacheFilePath;
    if (!path)
    {
        path = [[YXPCacheTemporaryDirectory() stringByAppendingPathComponent:[[URL absoluteString] mc_md5]] stringByAppendingPathExtension:[URL pathExtension]];
    }
    
    long long fileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil].fileSize;
    // NSNumber *durationNum = [[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"publicVoice%@",[URL.absoluteString mc_md5]]];
    
    if(fileSize>0)
    {
        
        NSURL *sourceUrl = [NSURL fileURLWithPath:path];
        //        AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:sourceUrl options:nil];
        //        CMTime audioDuration = movieAsset.duration;
        ////
        //        NSInteger audioDurationSeconds =CMTimeGetSeconds(audioDuration);
        //        if(([durationNum integerValue]==audioDurationSeconds) || (!durationNum))
        //        {
        //        }
        
        return [AVPlayerItem playerItemWithURL:sourceUrl];
        
    }
    
    YXPPlayerItemCacheLoader *cacheLoader = [YXPPlayerItemCacheLoader cacheLoaderWithCacheFilePath:path];
//    if (!cacheLoader)
//    {
//        if (*error)
//        {
//            *error = [self mc_errorWithCode:AVPlayerMCCacheErrorCreateCacheFileFailed reason:@"create cache file failed."];
//        }
//        return [self playerItemWithURL:URL];
//        
//    }
    
   
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[URL mc_avplayerCacheSupportURL] options:options];
    [asset.resourceLoader setDelegate:cacheLoader queue:dispatch_get_main_queue()];
    AVPlayerItem *item = [self playerItemWithAsset:asset];
    if ([item respondsToSelector:@selector(setCanUseNetworkResourcesForLiveStreamingWhilePaused:)]) {
        item.canUseNetworkResourcesForLiveStreamingWhilePaused =  YES;
    }
    objc_setAssociatedObject(item, kAVPlayerItemMCCacheSupportCacheLoaderKey, cacheLoader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return item;
}

+ (NSError *)mc_checkURL:(NSURL *)URL
{
    AVPlayerMCCacheError errorCode = 0;
    NSString *reason = nil;
    if ([URL isFileURL])
    {
        errorCode = AVPlayerMCCacheErrorFileURL;
        reason = @"can not cache file URL.";
    }
    else if (![[[URL scheme] lowercaseString] hasPrefix:@"http"])
    {
        errorCode = AVPlayerMCCacheErrorSchemeNotHTTP;
        reason = @"only support URL with http scheme.";
    }
    else if ([URL mc_isM3U])
    {
        errorCode = AVPlayerMCCacheErrorUnsupportFormat;
        reason = @"do not support playlist format.";
    }
    
    if (errorCode == 0)
    {
        return nil;
    }
    else
    {
        return [self mc_errorWithCode:errorCode reason:reason];
    }
}

+ (void)mc_removeCacheWithCacheFilePath:(NSString *)cacheFilePath
{
    [YXPPlayerItemCacheLoader removeCacheWithCacheFilePath:cacheFilePath];
}


#pragma mark - property

- (YXPPlayerItemCacheLoader *)mc_cacheLoader
{
    return objc_getAssociatedObject(self, kAVPlayerItemMCCacheSupportCacheLoaderKey);
}


- (NSString *)mc_cacheFilePath
{
    return [self mc_cacheLoader].cacheFilePath;
}

@end

@implementation NSString (MCCacheSupport)
- (NSString *)mc_md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (int)strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (BOOL)mc_isM3U
{
    return [[[self pathExtension] lowercaseString] hasPrefix:@"m3u"];
}
@end

@implementation NSURL (MCCacheSupport)
- (NSURL *)mc_URLByReplacingSchemeWithString:(NSString *)scheme
{
    NSURLComponents *components = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:YES];
    components.scheme = scheme;
    return components.URL;
}

- (NSURL *)mc_avplayerCacheSupportURL
{
    if (![self mc_isAvPlayerCacheSupportURL])
    {
        NSString *scheme = [[self scheme] stringByAppendingString:kAVPlayerItemMCCacheSupportUrlSchemeSuffix];
        return [self mc_URLByReplacingSchemeWithString:scheme];
    }
    return self;
}

- (NSURL *)mc_avplayerOriginalURL
{
    if ([self mc_isAvPlayerCacheSupportURL])
    {
        NSString *scheme = [[self scheme] stringByReplacingOccurrencesOfString:kAVPlayerItemMCCacheSupportUrlSchemeSuffix withString:@""];
        return [self mc_URLByReplacingSchemeWithString:scheme];
    }
    return self;
}

- (BOOL)mc_isAvPlayerCacheSupportURL
{
    return [[self scheme] hasSuffix:kAVPlayerItemMCCacheSupportUrlSchemeSuffix];
}

- (NSString *)mc_pathComponentRelativeToURL:(NSURL *)baseURL
{
    NSString *absoluteString = [self absoluteString];
    NSString *baseURLString = [baseURL absoluteString];
    NSRange range = [absoluteString rangeOfString:baseURLString];
    if (range.location == 0)
    {
        NSString *subString = [absoluteString substringFromIndex:range.location + range.length];
        return subString;
    }
    return nil;
}

- (BOOL)mc_isM3U
{
    return [[[self pathExtension] lowercaseString] hasPrefix:@"m3u"];
}

+ (void)mc_removeCacheWithCacheFilePath:(NSString *)cacheFilePath
{
    [YXPPlayerItemCacheLoader removeCacheWithCacheFilePath:cacheFilePath];
}

+ (void)removeCacheWithCacheFilePath:(NSString *)cacheFilePath
{
    [[NSFileManager defaultManager] removeItemAtPath:cacheFilePath error:NULL];
    [[NSFileManager defaultManager] removeItemAtPath:[cacheFilePath stringByAppendingString:[YXPPlayerItemCacheFile indexFileExtension]] error:NULL];
}

@end

@implementation NSURLRequest (MCCacheSupport)
- (NSRange)mc_range
{
    NSRange range = {NSNotFound,0};
    NSString *rangeString = [self allHTTPHeaderFields][@"Range"];
    if ([rangeString hasPrefix:@"bytes="])
    {
        NSArray* components = [[rangeString substringFromIndex:6] componentsSeparatedByString:@","];
        if (components.count == 1)
        {
            components = [[components firstObject] componentsSeparatedByString:@"-"];
            if (components.count == 2)
            {
                NSString* startString = [components objectAtIndex:0];
                NSInteger startValue = [startString integerValue];
                NSString* endString = [components objectAtIndex:1];
                NSInteger endValue = [endString integerValue];
                if (startString.length && (startValue >= 0) && endString.length && (endValue >= startValue))
                {  // The second 500 bytes: "500-999"
                    range.location = startValue;
                    range.length = endValue - startValue + 1;
                }
                else if (startString.length && (startValue >= 0))
                {  // The bytes after 9500 bytes: "9500-"
                    range.location = startValue;
                    range.length = NSUIntegerMax;
                }
                else if (endString.length && (endValue > 0))
                {  // The final 500 bytes: "-500"
                    range.location = NSNotFound;
                    range.length = endValue;
                }
            }
        }
    }
    return range;
}
@end

@implementation NSHTTPURLResponse (MCCacheSupport)
- (long long)mc_fileLength
{
    NSString *range = [self allHeaderFields][@"Content-Range"];
    if (range)
    {
        NSArray *ranges = [range componentsSeparatedByString:@"/"];
        if (ranges.count > 0)
        {
            NSString *lengthString = [[ranges lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            return [lengthString longLongValue];
        }
    }
    else
    {
        return [self expectedContentLength];
    }
    return 0;
}

- (BOOL)mc_supportRange
{
    return [self allHeaderFields][@"Content-Range"] != nil;
}
@end

@implementation AVAssetResourceLoadingRequest (MCCacheSupport)
- (void)mc_fillContentInformation:(NSHTTPURLResponse *)response
{
    if (!response)
    {
        return;
    }
    
    self.response = response;
    
    if (!self.contentInformationRequest)
    {
        return;
    }
    
    NSString *mimeType = [response MIMEType];
    if (!mimeType) {
        mimeType = @"audio/x-m4a";
    }
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);
    self.contentInformationRequest.byteRangeAccessSupported = [response mc_supportRange];
    self.contentInformationRequest.contentType = CFBridgingRelease(contentType);
    self.contentInformationRequest.contentLength = [response mc_fileLength];
}
@end

@implementation NSFileHandle (MCCacheSupport)
- (BOOL)mc_safeWriteData:(NSData *)data
{
    NSInteger retry = 3;
    size_t bytesLeft = data.length;
    const void *bytes = [data bytes];
    int fileDescriptor = [self fileDescriptor];
    while (bytesLeft > 0 && retry > 0)
    {
        ssize_t amountSent = write(fileDescriptor, bytes + data.length - bytesLeft, bytesLeft);
        if (amountSent < 0)
        {
            //write failed
            break;
        }
        else
        {
            bytesLeft = bytesLeft - amountSent;
            if (bytesLeft > 0)
            {
                //not finished continue write after sleep 1 second
                sleep(1);  //probably too long, but this is quite rare
                retry--;
            }
        }
    }
    return bytesLeft == 0;
}

@end
