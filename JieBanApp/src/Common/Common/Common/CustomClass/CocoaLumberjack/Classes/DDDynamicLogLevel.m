//
//  DDLogLevel s_ddLogLevel.m
//  Common
//
//  Created by wangming on 2017/8/4.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "DDDynamicLogLevel.h"

#ifdef DEBUG
static DDLogLevel s_ddLogLevel = DDLogLevelVerbose;
#else
static DDLogLevel s_ddLogLevel = DDLogLevelError;//wangming release版本默认改为 DDLogLevelError 减少日志输出，如果需要详细日志，请改为DDLogLevelVerbose;
#endif

@implementation DDDynamicLogLevel;

+ (DDLogLevel)ddLogLevel
{
    return s_ddLogLevel;
}

+ (void)ddSetLogLevel:(DDLogLevel)level
{
    s_ddLogLevel = level;
}



@end
