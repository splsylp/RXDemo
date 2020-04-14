//
//  YXPPlayerHandlerFactory.m
//  Common
//
//  Created by yuxuanpeng on 2017/10/11.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "YXPPlayerHandlerFactory.h"
@interface YXPPlayerHandlerFactory()
@property (nonatomic, strong) NSMapTable *handlesTable; //注册的handle

@end

@implementation YXPPlayerHandlerFactory

+ (instancetype)share {
    static YXPPlayerHandlerFactory * _sharInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharInstance = [[self alloc] init];
        _sharInstance.handlesTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
    });
    
    return _sharInstance;
}

+ (void)resisterHandler:(id)handler protocol:(Protocol *)protocol {
    NSLog(@"register handler %@",NSStringFromProtocol(protocol));
    NSAssert(handler && protocol, @"handle or protocol cannot be nil");
    
    [[YXPPlayerHandlerFactory share].handlesTable setObject:handler forKey:NSStringFromProtocol(protocol)];
}

+ (id)hanlerForProtocol:(Protocol *)protocol {
    NSAssert(protocol, @"cannot find  handler for nil protocol");
    
    id handler = [[YXPPlayerHandlerFactory share].handlesTable objectForKey:NSStringFromProtocol(protocol)];
    return handler;
}

@end
