//
//  ECWBSSDelegate.h
//
//  Created by jiazy on 14/11/13.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECWBSSRoomDelegate.h"
#import "ECWBSSDocumentDelegate.h"

/**
 * SDK消息接收代理
 * 设置代理用于SDK上报的消息；
 */
@protocol ECWBSSDelegate <ECWBSSRoomDelegate, ECWBSSDocumentDelegate>

@required
@end