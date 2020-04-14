//
//  ECWBSSManager.h
//  WBSSiPhoneSDK
//
//  Created by jiazy on 16/6/20.
//  Copyright © 2016年 yuntongxun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECWBSSRoomManager.h"
#import "ECWBSSDocumentManager.h"

/**
 * 管理类
 * 操作房间管理、文档管理等
 */
@protocol ECWBSSManager <ECWBSSRoomManager, ECWBSSDocumentManager>
@end