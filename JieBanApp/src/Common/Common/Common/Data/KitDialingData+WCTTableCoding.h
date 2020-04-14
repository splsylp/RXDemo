//
//  KitDialingData+WCTTableCoding.h
//  Common
//
//  Created by lxj on 2018/8/2.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "KitDialingData.h"
#import <WCDB/WCDB.h>

@interface KitDialingData (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(tid)
WCDB_PROPERTY(mobile)
WCDB_PROPERTY(account)
WCDB_PROPERTY(call_status)
WCDB_PROPERTY(nickname)
WCDB_PROPERTY(call_number)
WCDB_PROPERTY(call_date)
WCDB_PROPERTY(call_type)

@end
