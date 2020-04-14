//
//  ECWBSSMember.h
//  WBSSiPhoneSDK
//
//  Created by jiazy on 16/8/1.
//  Copyright © 2016年 yuntongxun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECWBSSMember : NSObject

/**
 @brief 用户ID
 */
@property (nonatomic, copy) NSString* userId;

/**
 @brief 房间ID
 */
@property (nonatomic, assign) int roomId;

/**
 @brief 角色ID
 */
@property (nonatomic, assign) int roleId;

/**
 @brief 是否在线
 */
@property (nonatomic, assign) BOOL isOnline;
@end
