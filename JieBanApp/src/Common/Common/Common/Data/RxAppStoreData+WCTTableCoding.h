//
//  RxAppStoreData+WCTTableCoding.h
//  Common
//
//  Created by lxj on 2018/8/6.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "RxAppStoreData.h"
#import <WCDB/WCDB.h>

@interface RxAppStoreData (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(appId)
WCDB_PROPERTY(appName)
WCDB_PROPERTY(appType)
WCDB_PROPERTY(appLogo)
WCDB_PROPERTY(appUrl)
WCDB_PROPERTY(appDes)
WCDB_PROPERTY(groupId)
WCDB_PROPERTY(publicStatus)
WCDB_PROPERTY(installStatus)
WCDB_PROPERTY(account)
WCDB_PROPERTY(appCode)
WCDB_PROPERTY(isForcedInstall)
WCDB_PROPERTY(isHidden)
WCDB_PROPERTY(isNaviBar)

@end
