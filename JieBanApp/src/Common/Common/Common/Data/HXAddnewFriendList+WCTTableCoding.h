//
//  HXAddnewFriendList+WCTTableCoding.h
//  Common
//
//  Created by lxj on 2018/8/7.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "HXAddnewFriendList.h"
#import <WCDB/WCDB.h>

@interface HXAddnewFriendList (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(userAccount)
WCDB_PROPERTY(userId)
WCDB_PROPERTY(describeMessage)
WCDB_PROPERTY(inviteStatus)
WCDB_PROPERTY(friendType)

@end
