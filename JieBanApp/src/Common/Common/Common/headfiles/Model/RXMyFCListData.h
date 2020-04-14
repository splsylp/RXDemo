//
//  RXMyFCListData.h
//  ECSDKDemo_OC
//
//  Created by zhouwh on 16/7/13.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "KitBaseData.h"

@interface RXMyFCListData : KitBaseData

@property (nonatomic ,strong) NSString * msgId;
@property (nonatomic ,strong) NSString * sender;
@property (nonatomic ,strong) NSString * phoneNum;
@property (nonatomic ,strong) NSString * fileUrl;
@property (nonatomic ,strong) NSString * ctime;
@property (nonatomic ,strong) NSString * domain;
@property (nonatomic ,strong) NSString * content;
@property (nonatomic ,strong) NSString * subject;
@property (nonatomic ,strong) NSString * msgType;

//插入单条数据
+ (void)insertSingleMyFCListData:(RXMyFCListData *)resourse;
//插入数据
+ (void)insertMyFCListDataAttentsInfo:(NSArray*)resourse;
//获取一条数据
+ (RXMyFCListData *)getMyFCListDataWithMsgId:(NSString *)msgId;
//获取最近的数据
+(NSMutableArray *)getRecentlyMyFCListDataWithAccount:(NSString *)account Count:(int)count;
//获取历史数据
+ (NSMutableArray *)getMyFCListDataWithAccount:(NSString *)account Time:(NSString *)time Count:(int)count;
//删除数据
+ (bool)deleteMyFCListDataWithMsgId:(NSString *)msgId;
@end
