//
//  UIImageView+Md5.m
//  Common
//
//  Created by yuxuanpeng on 2017/6/22.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "UIImageView+Md5.h"
@implementation UIImageView (Md5)

- (void)setImageWithURLString:(NSString *)urlStr urlmd5:(NSString*)urlmd5 options:(SDWebImageOptions)options placeholderImage:(UIImage *)placeholder withRefreshCached:(BOOL)isRefreshCached;
{
    
   if(KCNSSTRING_ISEMPTY(urlStr))
   {
       self.image =  placeholder;
       return;
   }
    
   if(isRefreshCached)
   {
       [self sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:placeholder options:options completed:nil];
       return;
   }
    __weak __typeof(self)wself = self;
    SDWebImageOptions cacheOptions = options;
    if([self hasCurrentRequestCache:urlStr withMd5:urlmd5])
    {
        cacheOptions = 0;
    }
    [self sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:placeholder options:cacheOptions completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        dispatch_main_async_safe(^{
            __strong __typeof (wself) sself = wself;
            if (!sself) {
                return;
            }
            if(error)
            {
            }else if (cacheType ==SDImageCacheTypeNone)
            {
                if(image)
                {
                    [sself setMd5:urlmd5 withKey:urlStr];
                }
            }
        });
    }];  
}

- (BOOL)hasCurrentRequestCache:(NSString *)headUrl withMd5:(NSString *)md5Str
{
    if(KCNSSTRING_ISEMPTY(headUrl))
    {
        return NO;
    }
    
    NSString *cacheMd5 = [self getMd5Key:headUrl];
    
    if([cacheMd5 isEqualToString:md5Str])
    {
        return YES;
    }
    
    return NO;
}

- (NSString *)getMd5Key:(NSString *)headUrl
{
    if(KCNSSTRING_ISEMPTY(headUrl))
    {
        return nil;
    }
    NSString *cacheMd5 = [[NSUserDefaults standardUserDefaults]objectForKey:headUrl];

    return cacheMd5;
}

- (void)setMd5:(NSString *)md5 withKey:(NSString *)headUrl
{
    if(md5 && headUrl)
    {
        [[NSUserDefaults standardUserDefaults] setObject:md5 forKey:headUrl];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
