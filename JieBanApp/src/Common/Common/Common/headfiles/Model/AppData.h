//
//  AppData.h
//  AppModel
//
//  Created by wangming on 16/7/16.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KitDialingInfoData.h"
#import "KitMsgData.h"


@interface AppData : NSObject

@property(nonatomic,strong) NSDictionary* userInfo;
@property (nonatomic, strong) KitDialingInfoData *  curVoipCall;//外呼voip呼叫数据
@property (nonatomic, strong) KitMsgData         *  curSendMsgData;
@property (nonatomic, strong) NSMutableDictionary *  curSessionsDict;
@property (nonatomic, strong) NSMutableArray     *  allCompanyAddress;

@property (nonatomic, assign) BOOL bLoginState;//0未登录，1登录
@end
