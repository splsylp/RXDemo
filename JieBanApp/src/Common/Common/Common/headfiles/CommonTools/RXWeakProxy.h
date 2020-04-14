//
//  RXWeakProxy.h
//  Common
//
//  Created by keven on 2019/2/15.
//  Copyright © 2019年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RXWeakProxy : NSProxy


@property (nullable, nonatomic, weak, readonly) id target;


- (instancetype)initWithTarget:(id)target;


+ (instancetype)proxyWithTarget:(id)target;

@end
