//
//  ECProgressDelegate.h
//  CCPiPhoneSDK
//
//  Created by jiazy on 14/11/7.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECWBSSDocument.h"

/**
 * 文档上传进度代理
 */
@protocol ECWBSSProgressDelegate <NSObject>

/**
 @brief 设置进度
 @discussion 用户需实现此接口用以支持进度显示
 @param progress 值域为0到1.0的浮点数
 @param progressID  某一条消息的progressID
 */
- (void)setProgress:(float)progress forProgressID:(unsigned int)progressID;

@required

@end
