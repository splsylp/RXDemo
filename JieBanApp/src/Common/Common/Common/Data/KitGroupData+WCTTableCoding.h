//
//  KitGroupData+WCTTableCoding.h
//  Common
//
//  Created by lxj on 2018/8/2.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "KitGroupData.h"
#import <WCDB/WCDB.h>

@interface KitGroupData (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(groupId)
WCDB_PROPERTY(groupName)
WCDB_PROPERTY(groupAD)
WCDB_PROPERTY(isOpenIMMsg)
WCDB_PROPERTY(isMsgTopDisplay)
WCDB_PROPERTY(isGroupNickname)

@end
