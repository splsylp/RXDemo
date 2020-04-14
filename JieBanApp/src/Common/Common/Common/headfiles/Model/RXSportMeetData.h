//
//  RXSportMeetData.h
//  ECSDKDemo_OC
//
//  Created by ywj on 16/3/29.
//  Copyright © 2016年 ronglian. All rights reserved.
//

//#import "SportMeetModel.h"
#import "KitBaseData.h"
#import "WFMessageBody.h"

@interface RXSportMeetData : KitBaseData
@property(nonatomic,strong)NSString *msgId;//兼容以前的version字段 数据库字符串为version
@property(nonatomic,strong)NSString *sender;
@property(nonatomic,strong)NSString *revicer;
@property(nonatomic,strong)NSString *content;
@property(nonatomic,strong)NSString *fileUrl;
@property(nonatomic,assign)NSInteger status;
@property(nonatomic,strong)NSString *ctime;
@property(nonatomic,strong)NSString *domain;
@property(nonatomic,strong)NSString *subject;
@property(nonatomic,assign)NSInteger item;
@property(nonatomic,strong)NSString *sportType;
@property(nonatomic,strong)NSString *teamName;

//发送成功后入库
+(void)insertSendSportMessageData:(RXSportMeetData *)spData;


//插入运动会和同学圈数据
+(void)insertSportMessageData:(NSDictionary *)json;

//获取运动会列表
+(NSMutableArray *)getAllSportMessageType:(NSString *)type;

+(void)insertjsonString:(id)model;
+ (BOOL)deleteAllCompanyAddressInfoDataDB;
+ (BOOL)deleteFCMessageDataWithVersion:(NSString*)version;
//获取当前最新消息
+(NSMutableArray *)getCurrentTimeDataSportType:(NSString *)sportType withCount:(int)count;
+(NSMutableArray *)addlocationmoredata:(NSString *)sportType withCount:(int)count withTimeStr:(NSString *)time
;//加载更多本地数据

+(void)insertSportNotificationData:(NSDictionary *)jsonDic;//消息推送入库
//获取最新的消息
+(NSMutableArray *)addlocationLaterdata:(NSString *)sportType withCount:(int)count withTimeStr:(NSString *)time
;
//根据版本号获取
+(RXSportMeetData *)getSportDataWithVersion:(NSString *)version;
//单批入库
+(void)insertSportBrowsejson:(NSDictionary *)browseJson;
//同事圈单批入库
+(void)insertFCMessageBoby:(WFMessageBody *)messageBody;

@end
