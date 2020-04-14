//
//  KitMyAppStoreOperate+WCTTableCoding.h
//  Common
//
//  Created by lxj on 2018/8/6.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "KitMyAppStoreOperate.h"
#import <WCDB/WCDB.h>

@interface KitMyAppStoreOperate (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(appId)
WCDB_PROPERTY(appType)
WCDB_PROPERTY(curStatus)

@end
