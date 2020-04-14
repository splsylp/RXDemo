//
//  MessageTypeManager.h
//  Common
//
//  Created by 王文龙 on 2017/6/9.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageTypeManager : NSObject
//userData解析为内容字典
+ (NSMutableDictionary *)getCusDicWithUserData:(NSString *)userData;
@end
