//
//  KitSetConfiData.h
//  Rongxin
//
//  Created by yuxuanpeng on 14-12-8.
//  Copyright (c) 2014年 Rongxin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, EMsgSetStyle) {
    ENewNotifiVailable = 100,
    ESoundVailable,
    EVibrateVailable,
    ENewNotifiSound,
    EBackgroundNotifiTime,
    ECompanyNoDisturbing
};

@interface KitSetConfiData : NSObject
@property (assign,nonatomic) EMsgSetStyle style;
@property (copy,nonatomic) NSString *isVailable; //1可用 0 不可用
@property (copy,nonatomic) NSString *sid;   //保持

@end
