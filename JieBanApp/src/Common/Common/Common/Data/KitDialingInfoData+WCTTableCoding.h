//
//  KitDialingInfoData+WCTTableCoding.h
//  Common
//
//  Created by lxj on 2018/8/2.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "KitDialingInfoData.h"
#import <WCDB/WCDB.h>

@interface KitDialingInfoData (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(dialMobile)
WCDB_PROPERTY(dialNickName)
WCDB_PROPERTY(dialType)
WCDB_PROPERTY(dialState)
WCDB_PROPERTY(dialTime)
WCDB_PROPERTY(dialBeginTime)
WCDB_PROPERTY(dialAccount)

@end
