//
//  GetEndBackTime.h
//  Chat
//
//  Created by 韩微 on 2017/9/20.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** 进入后台block typedef */
typedef void(^YTHandlerEnterBackgroundBlock)(NSNotification * _Nonnull note, NSTimeInterval stayBackgroundTime);

/** 处理进入后台并计算留在后台时间间隔类 */
@interface GetEndBackTime : NSObject


/** 添加观察者并处理后台 */
+ (void)addObserverUsingBlock:(nullable YTHandlerEnterBackgroundBlock)block;
/** 移除后台观察者 */
+ (void)removeNotificationObserver:(nullable id)observer;

@end
