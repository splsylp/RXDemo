//
//  HXSpecialData+WCTTableCoding.h
//  Common
//
//  Created by lxj on 2018/8/8.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "HXSpecialData.h"
#import <WCDB/WCDB.h>

@interface HXSpecialData (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(account)

@end
