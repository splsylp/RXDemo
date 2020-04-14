//
//  ECWBSS.h
//  ECWBSS
//
//  Created by jiazy on 16/6/20.
//  Copyright © 2016年 yuntongxun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECWBSSManager.h"
#import "ECWBSSDelegate.h"

/**
 * 白板和文档共享类 使用该类的单例操作
 */
@interface ECWBSS : NSObject

/**
 @brief 单例
 @discussion 获取该类单例进行操作
 @return 返回类实例
 */
+(ECWBSS*)sharedInstance;

/**
 @brief 设置应用信息
 @discussion 调用WBSSManger操作前，需要先设置应用信息和账号
 @param appId 应用ID
 @param auth 应用auth
 @param userId 用户ID
 */
-(void)setWBSSAppId:(NSString*)appId andAuth:(NSString*)auth andUserId:(NSString*)userId;

/**
 @brief 设置应用地址
 @param server 服务器地址
 */
-(void)setServerJson:(NSString*)server;

/**
 @brief ECWBSS代理
 @discussion 用于监听通知事件
 */
@property (nonatomic, weak) id<ECWBSSDelegate> delegate;

/**
 @brief 操作类
 @discussion 用于房间管理和文档管理
 */
@property (nonatomic, readonly, strong) id<ECWBSSManager> WBSSManger;
@end
