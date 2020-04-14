//
//  HXInviteCountData+WCTTableCoding.h
//  Common
//
//  Created by lxj on 2018/8/8.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "HXInviteCountData.h"
#import <WCDB/WCDB.h>

@interface HXInviteCountData (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(userAccount)
WCDB_PROPERTY(inviteCount)

@end
