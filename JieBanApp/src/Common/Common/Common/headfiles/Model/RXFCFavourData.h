//
//  RXFCFavourData.h
//  ECSDKDemo_OC
//
//  Created by zhouwh on 16/5/18.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "KitBaseData.h"

@interface RXFCFavourData : KitBaseData
@property(nonatomic,strong)NSString * fid;//点赞ID
@property(nonatomic,strong)NSString * msgId;//同事圈ID
@property(nonatomic,strong)NSString * phoneNum;//手机号
@property(nonatomic,strong)NSString * account;//帐号
@property(nonatomic,strong)NSString * ctime;//时间
@property(nonatomic,strong)NSString * unRead;//是否未读

//单条插入
+ (void)insertSingleFavourMsgData:(RXFCFavourData *)data;
+ (void)insertSingleFavourMsgFavourData:(NSDictionary *)favourJson;
//批量插入
+ (void)insertFavoursMsgData:(NSArray *)json;
//获取某条同事圈的点赞
+ (NSMutableArray *)getFavoursOfFCMessageWithMsgId:(NSString *)msgId;
//获取最新的点赞
+ (NSMutableArray *)getCurrentTimeFavourDataWithCount:(int)count;
//获取未读的点赞
+ (NSMutableArray *)getAllUnreadFavourData;
//删除同事圈下的所有点赞
+ (void)deleteFavourWithMsgId:(NSString *)msgId;
//删除
+ (bool)deleteFavourWithfid:(NSString *)fid;
//全部删除
+ (bool)deleteAllFavourMessage;


@end
