//
//  KitBannerData+WCTTableCoding.h
//  Common
//
//  Created by lxj on 2018/8/6.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "KitBannerData.h"
#import <WCDB/WCDB.h>

@interface KitBannerData (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(bannerId)
WCDB_PROPERTY(bannerStatus)
WCDB_PROPERTY(bannerImageUrl)
WCDB_PROPERTY(bannerTitle)
WCDB_PROPERTY(bannerUrl)
WCDB_PROPERTY(bannerUpdateTime)
WCDB_PROPERTY(orders)

@end

