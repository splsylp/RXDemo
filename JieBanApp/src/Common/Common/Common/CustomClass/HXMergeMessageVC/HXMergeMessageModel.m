//
//  HXMergeMessageModel.m
//  ECSDKDemo_OC
//
//  Created by 陈长军 on 2017/3/31.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "HXMergeMessageModel.h"
#import "HXFileCacheManager.h"

@implementation HXMergeMessageModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (void)setMerge_url:(NSString *)merge_url {
    _merge_url = merge_url;
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:merge_url];
    if(image){
        self.imageSize = image.size;
    }else {
//        self.imageSize = nil;
    }
}


@end
