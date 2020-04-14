//
//  ECMessage_Son+WCTTableCoding.h
//  Common
//
//  Created by lxj on 2018/8/22.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "ECMessage_Son.h"
#import <WCDB/WCDB.h>

@interface ECMessage_Son (WCTTableCoding) <WCTTableCoding>
///主键自增
WCDB_PROPERTY(tid)
WCDB_PROPERTY(sessionId)
WCDB_PROPERTY(messageId)
WCDB_PROPERTY(from)
WCDB_PROPERTY(to)
WCDB_PROPERTY(timestamp)
WCDB_PROPERTY(userData)
WCDB_PROPERTY(messageState)
WCDB_PROPERTY(msgType)
WCDB_PROPERTY(text)
WCDB_PROPERTY(localPath)
WCDB_PROPERTY(remotePath)
WCDB_PROPERTY(serverTime)
WCDB_PROPERTY(dstate)
WCDB_PROPERTY(remark)
WCDB_PROPERTY(displayName)
WCDB_PROPERTY(isRead)
WCDB_PROPERTY(height)
WCDB_PROPERTY(imageHeight)
WCDB_PROPERTY(imageWight)
WCDB_PROPERTY(uuid)

@end
