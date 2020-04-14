//
//  YXPPlayerItemRemoteCacheTask.h
//  Common
//
//  Created by yuxuanpeng on 2017/10/11.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "YXPPlayerItemCacheTask.h"

@interface YXPPlayerItemRemoteCacheTask : YXPPlayerItemCacheTask<NSURLConnectionDataDelegate>
@property (nonatomic,strong) NSHTTPURLResponse *response;

@end
