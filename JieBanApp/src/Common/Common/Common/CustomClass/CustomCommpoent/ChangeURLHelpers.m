//
//  ChangeURLHelpers.m
//  Common
//
//  Created by tianao on 2017/6/30.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "ChangeURLHelpers.h"
#import "NSString+Ext.h"
#import "KCConstants_API.h"

@implementation ChangeURLHelpers

+ (NSString *)buildUrl:(NSString *)url infoDic:(NSMutableDictionary *)infoDic{
    NSURL *splitUrl = [NSURL URLWithString:url];
    NSString *hostStr;
    if (!splitUrl.port) {
        hostStr = [NSString stringWithFormat:@"%@://%@",splitUrl.scheme,splitUrl.host];
    }else{
        hostStr = [NSString stringWithFormat:@"%@://%@:%@",splitUrl.scheme,splitUrl.host,splitUrl.port];
    }
   
    NSString *strUrl;
    if ([url rangeOfString:hostStr].location != NSNotFound) {
        strUrl = [url stringByReplacingOccurrencesOfString:hostStr withString:kProxyServer];
    }

    return strUrl;
}
@end
