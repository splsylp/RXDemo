//
//  ECWBSSRoomDelegate.h
//  WBSSiPhoneSDK
//
//  Created by jiazy on 16/6/20.
//  Copyright © 2016年 yuntongxun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECWBSSRoom.h"
#import "ECWBSSRoomManager.h"
#import "ECWBSSError.h"

/**
 * 房间通知代理
 */
@protocol ECWBSSRoomDelegate <NSObject>

/*
 @param userId 用户ID
 @param auth 用户权限
 @param type 类型 0 代表收回权限 1 代表赋予权限
 */
- (void) onReceivemNotifyChangeMember:(NSString*)userId auth:(MemberAuth)auth andType:(int)type;

@end
