//
//  DataBaseManager.h
//  WCDB_Demo
//
//  Created by lxj on 2018/7/25.
//  Copyright © 2018年 lxj. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"耗时: %f", -[startTime timeIntervalSinceNow])


#define TABLE_WCDB_NAME NSStringFromClass([self class])
#define TABLE_WCDB_CLASS(className) NSClassFromString(className)
//企业通讯录
#define DATA_COMPANYADDRESS_DBTABLE @"data_RXCompanyAddress_table"
#define DATA_COMPANYADDRESS_DBTABLE_FTS @"data_RXCompanyAddress_table_FTS"

//公司部门
#define DATA_COMPANYDEPT_DBTABLE @"data_RXCompanyDept_table"
///公司表 未用到
#define DATA_COMPANY_DBTABLE @"data_RXCompany_table"
//电话记录
#define DATA_DIALING_DBTABLE_NAME @"data_RXdialing_table"
//电话记录详情表
#define DATA_INFODIALING_DATABLE_NAME @"data_RXinfodialing_table"
//群组表 没有数据进入
#define DATA_GROUP_DBTABLE @"data_RXgroup_table"
//群信息表 主键:群组ID
#define DATA_GROUPINFO_DBTABLE @"data_RXGroupInfo_tabel"
//群成员表 主键成员账号
#define DATA_GROUPMEMBERINFO_DBTABLE @"data_RXGroupMemberInfo_table"

//=======公共号数据表======
//公共号消息列表
#define DATA_PUBLICE_MESSAGELIST_DATABLE @"public_"

///收藏
#define DATA_COLLECTION_DBTABLE @"data_collection_table"

//appStore app信息表
#define DATA_APPSTORE_AppInfo_DBTABLE @"data_appStore_appInfo"
//appStore app分组表
#define DATA_APPSTORE_Group_DBTABLE @"data_appStore_appGroup"
//appStore 用户侧app信息表
#define DATA_APPSTORE_MyApps_DBTABLE @"data_appStore_MyApps"
//应用商店未读数 2017yxp8.17
#define DATA_MYAPPUNREADCOUNT_DBTABLE @"data_appUnreadCount"
///应用商店卸载程序
#define DATA_MYAPPOPEARTE_DBTABLE @"data_myAppOperate_table"
//banner图的表
#define DATA_BANNER_DBTABLE @"data_banner_bannerData"
//自己接受的 或者添加的好友
#define DATA_MYFRIEND_LIST @"data_MYFriend_table"

//好友邀请关系列表
#define DATA_NEWFRIEND_LIST @"data_friend_table"
//好友邀请count 计算
#define DATA_NEWFRIENDINVITE_COUNT @"HX_inviteFrien_count"
//特别关注
#define DATA_SPECIAL_DBTABLE @"data_special_table"
//公众号表
#define DATA_PUBLIC_NUM  @"data_RXPublicInfo_table"
//公共号IM列表
#define DATA_PUBLIC_NUMBER @"public_numberlist"
//公共号消息列表
#define DATA_PUBLIC_MESSAGE_DBTABLE @"data_RXPublicMessage_table"
//同事圈点赞
#define DATA_FC_MESSAGE_FAVOUR_DBTABLE @"data_fc_message_favour_table"
//同事圈消息列表
#define DATA_SPORT_MESSAGE_DBTABLE @"data_sport_message_table"
//同事圈未读评论和点赞
#define DATA_FC_MESSAGE_UNREADMSG_DBTABLE @"data_fc_message_unreadmsg_table"
//同事圈评论
#define DATA_FC_MESSAGE_REPLY_DBTABLE @"data_fc_message_reply_table"
//某个人所有的同事圈
#define DATA_SELFFC_MESSAGE_DBTABLE @"data_selfFC_table"
///沟通表
#define DATA_SESSION_DBTABLE  @"session"
///聊天表
#define DATA_CHAT_DBTABLE @"chat"
///文件缓存表
#define DATA_CACHEFILE_DBTABLE @"cacheFile"

@interface DataBaseManager : NSObject

+ (DataBaseManager *)sharedInstance;
- (id)dataBase;
- (void)createDataBase;


/**
 增

 @param object 对象
 @param tableName 表名
 */
- (void)insertObject:(id)object into:(NSString *)tableName;

/**
 查

 @param className 类
 @param tableName 表名
 @return 数组
 */
- (NSArray *)getAllObjectsOfClass:(Class)className tableName:(NSString *)tableName;

/**
 删

 @param tableName 表名
 @return 结果
 */
- (BOOL)deleteAllObjectsFromTable:(NSString *)tableName;

- (void)clearAllSqliteData;
@end
