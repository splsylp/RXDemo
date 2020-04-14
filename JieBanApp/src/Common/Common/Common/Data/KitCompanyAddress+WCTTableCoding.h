//
//  KitCompanyAddress+WCTTableCoding.h
//  AddressBook
//
//  Created by lxj on 2018/7/27.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "KitCompanyAddress.h"
#import <WCDB/WCDB.h>

@interface KitCompanyAddress (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(name)
WCDB_PROPERTY(nameId)
WCDB_PROPERTY(pyname)
WCDB_PROPERTY(fnmname)
WCDB_PROPERTY(mobilenum)
WCDB_PROPERTY(voipaccount)
WCDB_PROPERTY(photourl)
WCDB_PROPERTY(signature)
WCDB_PROPERTY(place)
WCDB_PROPERTY(qq)
WCDB_PROPERTY(urlmd5)
WCDB_PROPERTY(department_id)
WCDB_PROPERTY(mail)
WCDB_PROPERTY(isLeader)
WCDB_PROPERTY(sex)
WCDB_PROPERTY(order)
WCDB_PROPERTY(account)
WCDB_PROPERTY(state)
WCDB_PROPERTY(userStatus)
WCDB_PROPERTY(level)
WCDB_PROPERTY(depart_name)


@end
