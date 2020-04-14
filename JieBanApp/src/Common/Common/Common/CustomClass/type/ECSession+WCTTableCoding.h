//
//  ECSession+WCTTableCoding.h
//  Common
//
//  Created by lxj on 2018/8/21.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "ECSession.h"
#import <WCDB/WCDB.h>

@interface ECSession (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(sessionId)
WCDB_PROPERTY(fromId)
WCDB_PROPERTY(dateTime)
WCDB_PROPERTY(type)
WCDB_PROPERTY(text)
WCDB_PROPERTY(unreadCount)
WCDB_PROPERTY(sumCount)
WCDB_PROPERTY(isAt)
WCDB_PROPERTY(draft)
WCDB_PROPERTY(isNotice)

@end
