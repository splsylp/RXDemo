//
//  KCUtils_EventBus.h
//  KX3
//
//  Created by peng zhi on 12-8-20.
//  Copyright (c) 2012年 kaixin001. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCUtils_EventBus : NSObject

+ (KCUtils_EventBus *)sharedBus;
+ (void)addEventListener:(NSString *)eventType target:(id)target callBack:(SEL)callBack;
+ (void)dispatchEvent:(NSString *)eventType params:(id)params;
+ (void)removeEventListener:(NSString *)eventType target:(id)target callBack:(SEL)callBack;
+ (void)removeEventListenerWithTarget:(id)target;
@end
