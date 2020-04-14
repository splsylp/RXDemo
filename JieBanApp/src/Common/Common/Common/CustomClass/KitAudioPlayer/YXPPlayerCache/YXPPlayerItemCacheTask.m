//
//  YXPPlayerItemCacheTask.m
//  Common
//
//  Created by yuxuanpeng on 2017/10/11.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "YXPPlayerItemCacheTask.h"

@implementation YXPPlayerItemCacheTask
{
    BOOL _executing;
    BOOL _finished;
}
- (instancetype)initWithCacheFile:(YXPPlayerItemCacheFile *)cacheFile loadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest range:(NSRange)range
{
    self = [super init];
    if (self)
    {
        _loadingRequest = loadingRequest;
        _range = range;
        _itemCacheFile = cacheFile;
    }
    return self;
}

- (void)main
{
    @autoreleasepool
    {
        [self setFinished:NO];
        [self setExecuting:YES];
        if (_finishBlock)
        {
            _finishBlock(self,nil);
        }
        
        [self setExecuting:NO];
        [self setFinished:YES];
    }
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
