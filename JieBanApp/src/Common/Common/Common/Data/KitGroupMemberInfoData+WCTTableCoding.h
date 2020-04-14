//
//  KitGroupMemberInfoData+WCTTableCoding.h
//  Common
//
//  Created by lxj on 2018/8/3.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "KitGroupMemberInfoData.h"
#import <WCDB/WCDB.h>

@interface KitGroupMemberInfoData (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(tid)
WCDB_PROPERTY(memberId)
WCDB_PROPERTY(groupId)
WCDB_PROPERTY(memberName)
WCDB_PROPERTY(headUrl)
WCDB_PROPERTY(headMd5)
WCDB_PROPERTY(role)
WCDB_PROPERTY(sex)

@end
