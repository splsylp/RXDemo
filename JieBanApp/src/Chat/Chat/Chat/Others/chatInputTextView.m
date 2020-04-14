//
//  chatInputTextView.m
//  ECSDKDemo_OC
//
//  Created by zhangmingfei on 2016/10/20.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "chatInputTextView.h"

@implementation chatInputTextView
static id _instanceType;

+ (instancetype)sharedTextView {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instanceType = [[self alloc]init];
    });
    
    return _instanceType;
}

@end
