//
//  RXMyFriendList+WCTTableCoding.h
//  Common
//
//  Created by lxj on 2018/8/7.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "RXMyFriendList.h"
#import <WCDB/WCDB.h>

@interface RXMyFriendList (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(account)

@end
