//
//  YXPPlayerItemCacheTask.h
//  Common
//
//  Created by yuxuanpeng on 2017/10/11.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "YXPPlayerItemCacheFile.h"
#import "YXPPlayerError.h"
@class YXPPlayerItemCacheTask;

typedef void (^YXPPlayerItemCacheTaskFinishedBlock)(YXPPlayerItemCacheTask *task,NSError *error);


@interface YXPPlayerItemCacheTask : NSOperation
{
//   __weak AVAssetResourceLoadingRequest *_loadingRequest;
    NSRange _range;
    YXPPlayerItemCacheFile *_itemCacheFile;
}
@property (nonatomic,copy) YXPPlayerItemCacheTaskFinishedBlock finishBlock;
@property (nonatomic,strong) AVAssetResourceLoadingRequest *loadingRequest;
- (instancetype)initWithCacheFile:(YXPPlayerItemCacheFile *)cacheFile loadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest range:(NSRange)range;
@end


