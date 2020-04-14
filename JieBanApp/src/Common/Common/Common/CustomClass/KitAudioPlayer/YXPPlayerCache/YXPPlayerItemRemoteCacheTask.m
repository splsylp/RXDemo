//
//  YXPPlayerItemRemoteCacheTask.m
//  Common
//
//  Created by yuxuanpeng on 2017/10/11.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "YXPPlayerItemRemoteCacheTask.h"
#import "AVPlayerItem+YXPPlayerCache.h"
#import "YXPPlayerHandlerFactory.h"
#import "YXPPlayerError.h"

@implementation YXPPlayerItemRemoteCacheTask
{
    NSUInteger _offset;
    NSUInteger _requestLength;
    
    NSError *_error;
    
    NSURLConnection *_connection;
    BOOL _dataSaved;
    
    CFRunLoopRef _runloop;
    BOOL _executing;
    BOOL _finished;
}



- (void)main
{
    @autoreleasepool
    {
        if ([self isCancelled])
        {
            [self handleFinished];
            return;
        }
        
        [self setFinished:NO];
        [self setExecuting:YES];
        if ([self allowAccessNetwork]) {
            [self startURLRequestWithRequest:self.loadingRequest range:_range];
        }
        [self handleFinished];
    }
}

- (void)handleFinished
{
    if (self.loadingRequest) {
        NSLog(@"remote loadingRequest = nil",nil);
    }
    if (self.finishBlock && self.loadingRequest)
    {
        NSLog(@"remote task finish ",nil);
        self.finishBlock(self,_error);
    }
    
    [self setExecuting:NO];
    [self setFinished:YES];
}

- (void)cancel
{
    [super cancel];
    [_connection cancel];
}

- (void)startURLRequestWithRequest:(AVAssetResourceLoadingRequest *)loadingRequest range:(NSRange)range
{
    NSMutableURLRequest *urlRequest = [loadingRequest.request mutableCopy];
    urlRequest.URL = [loadingRequest.request.URL mc_avplayerOriginalURL];
    urlRequest.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    urlRequest.timeoutInterval = 20;
    
    _offset = 0;
    _requestLength = 0;
    if (!(_response && ![_response mc_supportRange]))
    {
        NSString *rangeValue = YXPRangeToHTTPRangeHeader(range);
        if (rangeValue)
        {
            [urlRequest setValue:rangeValue forHTTPHeaderField:@"Range"];
            _offset = range.location;
            _requestLength = range.length;
        }
    }
    
    _connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:NO];
    _dataSaved = NO;
    [_connection start];
    [self startRunLoop];
}

- (void)synchronizeCacheFileIfNeeded
{
    if (_dataSaved)
    {
        [_itemCacheFile synchronize];
    }
}
//保存完整的数据
- (void)saveAllReceiveData
{
    long long fileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:_itemCacheFile.tmpFilePath error:nil].fileSize;
    if(fileSize>0 && _requestLength>=fileSize)
    {
        NSError *error;
        NSFileManager * manager = [NSFileManager defaultManager];
        NSString * cacheFolderPath = _itemCacheFile.cacheFilePath;
        if ([manager fileExistsAtPath:cacheFolderPath]) {
            [manager removeItemAtPath:cacheFolderPath error:nil];
        }

        BOOL success = [[NSFileManager defaultManager] copyItemAtPath:_itemCacheFile.tmpFilePath toPath:cacheFolderPath error:&error];
        NSLog(@"cache file : %@", success ? @"success" : @"fail");
    }
    
}

- (void)startRunLoop
{
    _runloop = CFRunLoopGetCurrent();
    CFRunLoopRun();
}

- (void)stopRunLoop
{
    if (_runloop)
    {
        CFRunLoopStop(_runloop);
    }
}
#pragma mark - network state

-(BOOL)allowAccessNetwork {
    id<YXPPlayerNetworkChangedProtocol>handler = [YXPPlayerHandlerFactory hanlerForProtocol:@protocol(YXPPlayerNetworkChangedProtocol)];
    if ([handler respondsToSelector:@selector(mediaPlayerCanUseNetwork:)]) {
        BOOL allowd = [handler mediaPlayerCanUseNetwork:[self.loadingRequest.request.URL mc_avplayerOriginalURL]];
        if (!allowd) {
            _error = sqr_errorWithCode(KMediaPlayerErrorCodeNotAllowNetwork, @"not allowd access network!");
            return NO;
        }
    }
    return YES;
}


#pragma mark - handle connection
- (nullable NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(nullable NSURLResponse *)response
{
    if (response)
    {
        self.loadingRequest.redirect = request;
    }
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (_response || !response)
    {
        return;
    }
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        _response = (NSHTTPURLResponse *)response;
        [_itemCacheFile setResponse:_response];
        [self.loadingRequest mc_fillContentInformation:_response];
    }
    if (![_response mc_supportRange])
    {
        _offset = 0;
    }
    if (_offset == NSUIntegerMax)
    {
        _offset = (NSUInteger)_response.mc_fileLength - _requestLength;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (data.bytes && data.length<=2) {
        _dataSaved = YES;
    }
    else if (data.bytes && [_itemCacheFile saveData:data atOffset:_offset synchronize:NO])
    {
        _dataSaved = YES;
        _offset += [data length];
        [self.loadingRequest.dataRequest respondWithData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self synchronizeCacheFileIfNeeded];
    [self saveAllReceiveData];
    [self stopRunLoop];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self synchronizeCacheFileIfNeeded];
    _error = error;
    [self stopRunLoop];
}

- (void)setFinished:(BOOL)finished
{
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing
{
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}


@end
