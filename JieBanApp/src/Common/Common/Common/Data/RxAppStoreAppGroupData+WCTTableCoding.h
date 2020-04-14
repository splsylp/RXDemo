//
//  RxAppStoreAppGroupData+WCTTableCoding.h
//  Common
//
//  Created by lxj on 2018/8/6.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "RxAppStoreAppGroupData.h"
#import <WCDB/WCDB.h>

@interface RxAppStoreAppGroupData (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(groupId)
WCDB_PROPERTY(groupName)
WCDB_PROPERTY(groupCode)
WCDB_PROPERTY(account)
WCDB_PROPERTY(groupOrder)

@end
