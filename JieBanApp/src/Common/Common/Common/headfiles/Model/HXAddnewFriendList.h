//
//  HXAddnewFriendList.h
//  ECSDKDemo_OC
//
//  Created by ywj on 16/7/12.
//  Copyright © 2016年 ronglian. All rights reserved.
//

//-------------收到邀请消息列表----------------

#import "BaseModel.h"

//好友邀请验证状态
typedef NS_ENUM(NSInteger,InviteFriendStatus) {
    kHadBeenRefuseFriends,        //拒绝
    kAddAsNewFriends,             //已添加
    kNeedToPassVerification,      //待验证（等待接收方(自己)进行好友确认）
    kInviteFriendsDelete,         //删除
    kIMmessageSynchronize,         //同步消息
    kWaitToVerification,           //等待验证（发送方等待接收方进行验证）
    kExpiredVerification           //过期(人员离职处理 add yuxp)
};
//新的朋友类型
typedef NS_ENUM(NSInteger,NewFriendType) {
    kStrangePerson,                //陌生人
    kContactsFriends,              //通讯录好友
    kGroupFriends,                 //从群添加好友
};
//好友关系状态类型
typedef NS_ENUM(NSInteger,newFriendRelationType) {
    kBlackListNone = 1,          //好友
    kBlackListByMe ,         //被我加入黑名单
    kBlackListByOther,      //被对方加入黑名单
};

/**
 * 好友邀请状态枚举
 * 添加好友，接受状态；0，拒绝；1，接受 ；2，邀请
 **/
typedef NS_ENUM(NSInteger,AddFrienAgreeStatus) {
    AddFrien_refuse = 0,
    AddFrien_Agree,
    AddFrie_invite
};



@interface HXAddnewFriendList : BaseModel
///表里字段
@property(nonatomic, strong) NSString *userAccount;//用户账号 可存手机号/账号
@property(nonatomic, strong) NSString *userId;//好友id
@property(nonatomic, strong) NSString *describeMessage;//邀请描述信息
@property(nonatomic, assign) InviteFriendStatus inviteStatus;
@property(nonatomic, assign) NewFriendType friendType;

///非表里字段
@property(nonatomic, strong) NSString *userName;//好友名称
@property(nonatomic, strong) NSString *userSex;//好友性别
@property(nonatomic, strong) NSString *userPlace;//好友职位
@property(nonatomic, strong) NSString *userSign;//个性签名
@property(nonatomic, strong) NSString *userHeadUrl;//好友头像
@property(nonatomic, strong) NSString *md5Url;//头像md5值
@property(nonatomic, strong) NSString *nameFirstLetter;//姓和名首字母
@property(nonatomic, strong) NSString *nameLetter;//姓名拼音

#pragma mark - 增
+ (BOOL)insertImMessage:(HXAddnewFriendList *)friendList;
+ (void)insertFriendData:(NSArray *)friendJson;
+ (void)insertFriendData:(NSArray<HXAddnewFriendList *> *)friendarray useTransaction:(BOOL)useTransaction;
#pragma mark - 删
///根据userAccount删除
+(BOOL)deleteOneFriendData:(NSString *)userAccount;
///删除全部
+ (BOOL)deleteFriendAllData;
+ (void)deleteArrayFriendMessage:(NSArray *)friendArray;
#pragma mark - 改
///修改状态
+ (BOOL)updateFrienInviteStatus:(NSString *)userAccount inviteFriendType:(InviteFriendStatus)inviteType;
#pragma mark - 查
///根据userAccount和inviteStaus查询
+ (BOOL)isExistLocationNewInvite:(NSString *)userAccount InviteFriendStatus:(InviteFriendStatus)inviteStaus;
+ (NSArray<HXAddnewFriendList *> *)getAllInviteFriendListWithout:(NSString *)account;

@end
