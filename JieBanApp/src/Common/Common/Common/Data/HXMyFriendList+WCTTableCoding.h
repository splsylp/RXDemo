//
//  HXMyFriendList+WCTTableCoding.h
//  Common
//
//  Created by lxj on 2018/8/7.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "HXMyFriendList.h"
#import <WCDB/WCDB.h>

@interface HXMyFriendList (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(account)

@end
