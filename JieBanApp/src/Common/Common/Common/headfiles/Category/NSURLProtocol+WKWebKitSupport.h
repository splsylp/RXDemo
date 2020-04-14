//
//  NSURLProtocol+WKWebKitSupport.h
//  Common
//
//  Created by tianao on 2017/6/30.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLProtocol (WKWebKitSupport)

+ (void)wk_registerScheme:(NSString*)scheme;

+ (void)wk_unregisterScheme:(NSString*)scheme;

@end
