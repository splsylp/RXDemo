//
//  YHCConferenceHelper.h
//  ConferenceDemo
//
//  Created by 王文龙 on 2018/5/2.
//  Copyright © 2018年 wwl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHCManager.h"
#import "AppModel.h"
//#import "KitSelectContactsViewController.h"
@interface YHCConferenceHelper : NSObject<YHCPlugDelegate,YHCConferenceDelegate,YHCBoardDelegate,AppModelDelegate>
+(YHCConferenceHelper*)sharedInstance;
@end
