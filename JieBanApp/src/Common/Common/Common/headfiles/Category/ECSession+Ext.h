//
//  ECSession+Ext.h
//  Common
//
//  Created by 王文龙 on 2017/6/15.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "ECSession.h"

@class ECMessage;

@interface ECSession (Ext)

//当前是否新消息提醒
- (void)setMessageNotice:(BOOL)messageNotice;
- (BOOL)getMessageNotice;

///ECMessage转ECSession
+ (ECSession *)messageConvertToSession:(ECMessage *)message useNewTime:(BOOL)useNewTime;

@end
