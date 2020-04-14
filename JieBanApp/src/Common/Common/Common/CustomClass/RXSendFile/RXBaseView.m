//
//  RXBaseView.m
//  ECSDKDemo_OC
//
//  Created by ywj on 16/8/4.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "RXBaseView.h"

@implementation RXBaseView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end
