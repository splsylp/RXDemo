//
//  YXPPlayerHandlerFactory.h
//  Common
//
//  Created by yuxuanpeng on 2017/10/11.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXPPlayer.h"

@interface YXPPlayerHandlerFactory : NSObject
/**
 注册对应协议的处理者
 
 @param handler 处理者
 @param protocol 协议名称
 */
+ (void)resisterHandler:(id)handler protocol:(Protocol *)protocol;


/**
 返回对应协议的处理者
 
 @param protocol 协议名称
 */
+ (id)hanlerForProtocol:(Protocol *)protocol;
@end
