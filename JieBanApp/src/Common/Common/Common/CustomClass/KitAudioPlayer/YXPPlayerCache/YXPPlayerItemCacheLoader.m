//
//  YXPPlayerItemCacheLoader.m
//  Common
//
//  Created by yuxuanpeng on 2017/9/30.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "YXPPlayerItemCacheLoader.h"
#import "YXPPlayerItemCacheFile.h"
#import "AVPlayerItem+YXPPlayerCache.h"
#import "YXPPlayerItemRemoteCacheTask.h"
@interface YXPPlayerItemCacheLoader ()<NSURLConnectionDataDelegate>
{
@private
    NSMutableArray<AVAssetResourceLoadingRequest *> *_pendingRequests;
    AVAssetResourceLoadingRequest *_currentRequest;
    NSRange _currentDataRange;
    NSHTTPURLResponse *_response;
}
@property (nonatomic,strong) NSMutableDictionary * queues;
@property (atomic   ,strong) YXPPlayerItemCacheFile *cacheFile;

@end

@implementation YXPPlayerItemCacheLoader


#pragma mark - init & dealloc
+ (instancetype)cacheLoaderWithCacheFilePath:(NSString *)cacheFilePath
{
    return [[self alloc] initWithCacheFilePath:cacheFilePath];
}

- (instancetype)initWithCacheFilePath:(NSString *)cacheFilePath
{
    self = [super init];
    if (self)
    {
        _cacheFile = [YXPPlayerItemCacheFile cacheFileWithFilePath:cacheFilePath];
        if (!_cacheFile)
        {
            return nil;
        }
        _queues          = [NSMutableDictionary dictionary];
        _pendingRequests = [[NSMutableArray alloc] init];
        NSRange range = {NSNotFound,0};
        _currentDataRange = range;
    }
    return self;
}

- (NSString *)cacheFilePath
{
    return _cacheFile.cacheFilePath;
}

+ (void)removeCacheWithCacheFilePath:(NSString *)cacheFilePath
{
    [[NSFileManager defaultManager] removeItemAtPath:cacheFilePath error:NULL];
    [[NSFileManager defaultManager] removeItemAtPath:[cacheFilePath stringByAppendingString:[YXPPlayerItemCacheFile indexFileExtension]] error:NULL];
}

+ (NSError *)removeExpireFiles:(NSInteger)maxFileCount beforeTime:(NSInteger)seconds {
    NSString * dirPath = YXPCacheTemporaryDirectory();
    NSDirectoryEnumerator * fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:dirPath];
    
    NSMutableDictionary * validFiles = [NSMutableDictionary dictionary];
    NSError * lastError = nil;
    for (NSString * fileName in fileEnumerator) {
        NSString * filePath = [dirPath stringByAppendingPathComponent:fileName];
        
        NSError * error = nil;
        NSDictionary * attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
        if (error) {
            lastError = error;
            break;
        }
        
        NSDate * lastModifyDate = [attrs objectForKey:NSFileModificationDate];
        NSDate * oneDayAge      = [NSDate dateWithTimeIntervalSinceNow:-seconds];
        
        error = nil;
        if (seconds>0 &&[lastModifyDate compare:oneDayAge] == NSOrderedAscending) {
            // 移除  文件 & idx （成对删除）
            if ([fileName.pathExtension isEqualToString:[YXPPlayerItemCacheFile indexFileExtension]] == false) {
                [[self class] removeCacheWithCacheFilePath:filePath];
            }else {
                // 移除 idx 文件
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                if (error) {
                    lastError = error;
                }
            }
        }else {
            [validFiles setObject:filePath forKey:lastModifyDate];
        }
        
        error = nil;
    }
    
    if (maxFileCount>0 && validFiles.count > maxFileCount) {
        NSError * error = nil;
        
        NSArray * filterKeys = [validFiles.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSDate *  _Nonnull obj1, NSDate *  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        
        NSMutableArray * removeKeys = [NSMutableArray arrayWithArray:filterKeys];
        int i = (int)filterKeys.count - (int)maxFileCount;
        while (i > 0) {
            NSString * earlyPath = [validFiles objectForKey:removeKeys.firstObject];
            [[NSFileManager defaultManager] removeItemAtPath:earlyPath error:&error];
            if (error) {
                lastError = error;
            }
            
            [removeKeys removeObject:removeKeys.firstObject];
            i--;
        }
        error = nil;
    }
    
    return lastError;
}

+ (NSError *)removeAllAudioCache {
    NSString * dirPath = YXPCacheTemporaryDirectory();
    
    NSError * error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:dirPath error:&error];
    if (error) {
    }
    return error;
}


- (void)dealloc
{
    [self cancelAllQueue];
}

#pragma mark - loading request
- (void)startNextRequest
{
    if (_pendingRequests.count == 0)
    {
        return;
    }
    
    _currentRequest = [_pendingRequests lastObject];
    
    /*
     //data range
     if ([_currentRequest.dataRequest respondsToSelector:@selector(requestsAllDataToEndOfResource)] && _currentRequest.dataRequest.requestsAllDataToEndOfResource)
     {
     _currentDataRange = NSMakeRange((NSUInteger)_currentRequest.dataRequest.requestedOffset, NSUIntegerMax);
     }
     else
     {
     _currentDataRange = NSMakeRange((NSUInteger)_currentRequest.dataRequest.requestedOffset, _currentRequest.dataRequest.requestedLength);
     }
     */
    
    // 去除设置最大值，从网络获取的逻辑
    _currentDataRange = NSMakeRange((NSUInteger)_currentRequest.dataRequest.requestedOffset, _currentRequest.dataRequest.requestedLength);
    
    //response
    if (!_response && _cacheFile.responseHeaders.count > 0)
    {
        if (_currentDataRange.length == NSUIntegerMax)
        {
            _currentDataRange.length = [_cacheFile fileLength] - _currentDataRange.location;
        }
        
        NSMutableDictionary *responseHeaders = [_cacheFile.responseHeaders mutableCopy];
        NSString *contentRangeKey = @"Content-Range";
        BOOL supportRange = responseHeaders[contentRangeKey] != nil;
        if (supportRange && YXPValidByteRange(_currentDataRange))
        {
            responseHeaders[contentRangeKey] = YXPRangeToHTTPRangeReponseHeader(_currentDataRange, [_cacheFile fileLength]);
        }
        else
        {
            [responseHeaders removeObjectForKey:contentRangeKey];
        }
        responseHeaders[@"Content-Length"] = [NSString stringWithFormat:@"%tu",_currentDataRange.length];
        
        NSInteger statusCode = supportRange ? 206 : 200;
        _response = [[NSHTTPURLResponse alloc] initWithURL:_currentRequest.request.URL statusCode:statusCode HTTPVersion:@"HTTP/1.1" headerFields:responseHeaders];
        [_currentRequest mc_fillContentInformation:_response];
        
    }
    [self startCurrentRequest];
}

- (void)startCurrentRequest
{
    NSOperationQueue * queue = self.queues[_currentRequest.request.URL.absoluteString];
    queue.suspended = YES;
    if (_currentDataRange.length == NSUIntegerMax)
    {
        [self addTaskWithRange:NSMakeRange(_currentDataRange.location, NSUIntegerMax) cached:NO];
    }
    else
    {
        
        NSUInteger start = _currentDataRange.location;
        NSUInteger end = NSMaxRange(_currentDataRange);
        while (start < end)
        {
            NSRange firstNotCachedRange = [_cacheFile firstNotCachedRangeFromPosition:start];
            if (!YXPValidFileRange(firstNotCachedRange))
            {
                [self addTaskWithRange:NSMakeRange(start, end - start) cached:_cacheFile.cachedDataBound > 0];
                start = end;
            }
            else if (firstNotCachedRange.location >= end)
            {
                [self addTaskWithRange:NSMakeRange(start, end - start) cached:YES];
                start = end;
            }
            else if (firstNotCachedRange.location >= start)
            {
                if (firstNotCachedRange.location > start)
                {
                    [self addTaskWithRange:NSMakeRange(start, firstNotCachedRange.location - start) cached:YES];
                }
                NSUInteger notCachedEnd = MIN(NSMaxRange(firstNotCachedRange), end);
                [self addTaskWithRange:NSMakeRange(firstNotCachedRange.location, notCachedEnd - firstNotCachedRange.location) cached:NO];
                start = notCachedEnd;
            }
            else
            {
                [self addTaskWithRange:NSMakeRange(start, end - start) cached:YES];
                start = end;
            }
        }
    }
    queue.suspended = NO;
}

- (void)completeRequest:(AVAssetResourceLoadingRequest *)loadingRequest task:(NSError *)error {
    if (error) {
        if (![loadingRequest isFinished]) {
            [loadingRequest finishLoadingWithError:error];
        }
    }else {
        if (![loadingRequest isFinished]) {
            [loadingRequest finishLoading];
        }
    }
}

- (void)cleanUpCurrentRequest
{
    [_pendingRequests removeObject:_currentRequest];
    _currentRequest = nil;
    _response = nil;
    NSRange range = {NSNotFound,0};
    _currentDataRange = range;
}

- (void)addTaskWithRange:(NSRange)range cached:(BOOL)cached
{
    NSOperationQueue * queue = self.queues[[self keyForLoadingRequest:_currentRequest]];
    
    YXPPlayerItemCacheTask *task = nil;
    if (cached)
    {
        task = [[YXPPlayerItemRemoteCacheTask alloc] initWithCacheFile:_cacheFile loadingRequest:_currentRequest range:range];
    }
    else
    {
        task = [[YXPPlayerItemRemoteCacheTask alloc] initWithCacheFile:_cacheFile loadingRequest:_currentRequest range:range];
        //YXPPlayerItemRemoteCacheTask *cacheTask = (YXPPlayerItemRemoteCacheTask *)task ;
        [(YXPPlayerItemRemoteCacheTask *)task setResponse:_response];
    }
    __weak typeof(self)weakSelf = self;
    task.finishBlock = ^(YXPPlayerItemCacheTask *task, NSError *error)
    {
        if (task.cancelled || error.code == NSURLErrorCancelled)
        {
            return;
        }
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (error)
        {
            [strongSelf completeRequest:task.loadingRequest task:error];
        }
        else
        {
            if (queue.operationCount<=1) {
                [strongSelf completeRequest:task.loadingRequest task:nil];
            }
        }
    };
    [queue addOperation:task];
    
}

#pragma mark - tasks

- (NSString *)keyForLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSString * url      = loadingRequest.request.URL.absoluteString;
    NSString * range    = [NSString stringWithFormat:@"?range=%lli-%lu",loadingRequest.dataRequest.requestedOffset,(long int)loadingRequest.dataRequest.requestedLength];
    
#ifdef SingleQueue
    return @"custom queue";
#endif
    return [url stringByAppendingString:range];
}

- (void)addTaskQueue:(AVAssetResourceLoadingRequest *)loadingRequest {
#ifdef SingleQueue
    if (_queues[[self keyForLoadingRequest:loadingRequest]]) {
        return;
    }
#endif
    NSOperationQueue * queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    queue.name = [self keyForLoadingRequest:loadingRequest];
    
    _queues[[self keyForLoadingRequest:loadingRequest]] = queue;
    
}

- (void)removeTaskQueue:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSOperationQueue * queue = _queues[[self keyForLoadingRequest:loadingRequest]];
    if (queue) {
        [queue cancelAllOperations];
        [queue.operations makeObjectsPerformSelector:@selector(cancel)];
    }
    
    [_queues removeObjectForKey:[self keyForLoadingRequest:loadingRequest]];
    
}

- (void)cancelAllQueue {
    for (NSOperationQueue * queue in _queues.allValues) {
        [queue cancelAllOperations];
        [queue.operations makeObjectsPerformSelector:@selector(cancel)];
    }
    [_queues removeAllObjects];
}

#pragma mark - resource loader delegate
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest
{
    [_pendingRequests addObject:loadingRequest];
    [self addTaskQueue:loadingRequest];
    [self startNextRequest];
    
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
        
    [_pendingRequests removeObject:loadingRequest];
    [self removeTaskQueue:loadingRequest];
    
    return;
}
@end
