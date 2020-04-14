//
//  RXCollectData+WCTTableCoding.h
//  Common
//
//  Created by lxj on 2018/8/6.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "RXCollectData.h"
#import <WCDB/WCDB.h>

@interface RXCollectData (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(collectId)
WCDB_PROPERTY(type)
WCDB_PROPERTY(txtContent)
WCDB_PROPERTY(url)
WCDB_PROPERTY(time)
WCDB_PROPERTY(sessionId)
WCDB_PROPERTY(messageId)
WCDB_PROPERTY(fromId)

@end
