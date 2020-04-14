//
//  KitAddressBook.h
//  HIYUNTON
//
//  Created by 王 甲 on 14-10-16.
//  Copyright (c) 2014年 hiyunton.com. All rights reserved.
//

#import <BaseModel.h>


@interface KitAddressBook : BaseModel

#pragma mark- 通讯录信息
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) UIImage *head;
@property (nonatomic, strong) NSMutableDictionary *phones;
@property (nonatomic, strong) NSMutableDictionary *others;
///名字头字母
@property (nonatomic, copy) NSString *firstLetter;
@property (nonatomic, copy) NSString *pyname;
#pragma mark - 注册账号信息，如果已经注册的话
@property (nonatomic, copy) NSString *mobilenum;
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *voipaccount;
@property (nonatomic, copy) NSString *signature;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *photourl;
@property (nonatomic, copy) NSString *urlmd5;
@property (nonatomic, copy) NSString *curStateIndex;//表示会议成员的状态 0:未加入 1:加入 2:退出 3:拒绝加入 4:被移出 5:其他
@property (nonatomic, copy) NSString *notSpeakIndex;//表示会议成员禁言状态
@property (nonatomic, copy) NSString *departmentShow;
@property (nonatomic, copy) NSString *recordTele;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, copy) NSString *deptName;
@property (nonatomic, copy) NSString *place;
@property (nonatomic, assign) BOOL isVoIP;
@property (nonatomic, copy) NSNumber *localID;
@property (nonatomic, assign) long long sort;
//@property (nonatomic, assign) int isOne;//判断是否是同一个联系人
@property (nonatomic, assign) NSInteger level;//用户级别
@property (nonatomic, copy) NSString * mail;//邮箱
@property (nonatomic,copy) NSString *userStatus;//用户状态


//用户单项设置，客户端存储
//@property (nonatomic,readonly)SINUserSettingInfoData *userSettingInfoData;
//@property (nonatomic,readonly)HYTSINUserSettingInfoData *userSettingInfoData;

+ (KitAddressBook *)getAddressBook:(NSString *)mobiel;

@end
