//
//  KitGroupInfoData+WCTTableCoding.h
//  Common
//
//  Created by lxj on 2018/8/2.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "KitGroupInfoData.h"
#import <WCDB/WCDB.h>

@interface KitGroupInfoData (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(groupId)
WCDB_PROPERTY(groupName)
WCDB_PROPERTY(declared)
WCDB_PROPERTY(createTime)
WCDB_PROPERTY(owner)
WCDB_PROPERTY(memberCount)
WCDB_PROPERTY(type)
WCDB_PROPERTY(isAnonymity)
WCDB_PROPERTY(isDiscuss)
WCDB_PROPERTY(isNotice)
WCDB_PROPERTY(isGroupMember)
@end
