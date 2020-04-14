//
//  DDDynamicLogLevel.h
//  Common
//
//  Created by wangming on 2017/8/4.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "DDLog.h"

@interface DDDynamicLogLevel : NSObject <DDRegisteredDynamicLogging>
+ (void)ddSetLogLevel:(DDLogLevel)level;
@end
