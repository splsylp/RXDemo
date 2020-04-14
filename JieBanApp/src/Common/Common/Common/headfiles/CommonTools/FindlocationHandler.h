//
//  FindlocationHandler.h
//  ECSDKDemo_OC
//
//  Created by zhouwh on 15/8/20.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface FindlocationHandler : NSObject

+ (instancetype)sharedFindlocation;

- (NSString *)findBelongingWithPhoneNum:(NSString *)moblie;

@end
