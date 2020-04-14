//
//  RXRevokeMessageBody.m
//  Common
//
//  Created by yongzhen on 2018/10/18.
//  Copyright © 2018 ronglian. All rights reserved.
//

#import "RXRevokeMessageBody.h"

@implementation RXRevokeMessageBody
- (instancetype)initWithText:(NSString *)text {
    self = [super init];
    if (self) {
        _text = text;
    }
    return self;
}
@end
