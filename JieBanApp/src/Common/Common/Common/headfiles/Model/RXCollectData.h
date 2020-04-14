//
//  RXCollectData.h
//  ECSDKDemo_OC
//
//  Created by zhouwh on 16/7/11.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "BaseModel.h"

@interface RXCollectData : BaseModel

@property (nonatomic ,strong) NSString * collectId;
@property (nonatomic ,strong) NSString * type;  //1,文本 ；2，图片；3，网页；4，语音；5，视频；6，图文 7.file 8.位置
@property (nonatomic ,strong) NSString * time;
@property (nonatomic ,strong) NSString * txtContent;
@property (nonatomic ,strong) NSString * url;
@property (nonatomic ,strong) NSString * sessionId;
@property (nonatomic, strong) NSString * messageId;
@property (nonatomic, strong) NSString * fromId;
@property (nonatomic, strong) NSString * favoriteMsgId; //增加收藏新增字段  用于防重复判断  暂时不入库
@property (nonatomic,copy) NSString *collect_content;//增加收藏新增字段  合并收藏用的
@property (nonatomic,copy) NSString *mergeId;//新增字段，合并收藏用来记录会话对象

#pragma mark - 增
//插入单条或更新收藏数据
+ (BOOL)insertCollectionInfoData:(RXCollectData*)infoData;
//批量插入数据
+ (void)insertCollectionAttentsInfo:(NSArray *)resourse;
//使用事务来入库
+ (void)insertData:(NSArray<RXCollectData *> *)resourse useTransaction:(BOOL)useTransaction;
#pragma mark - 删
//根据collectId 删除
+ (BOOL)deleteCollectionData:(NSString *)collectId;
#pragma mark - 查
///根据collectId查询
+ (RXCollectData *)getCollectDataWithCollectId:(NSString *)collectId;
///查最近的n条数据
+ (NSArray<RXCollectData *> *)getRecentlyCollectionDataWithCount:(int)count;
///查询时间前的n条数据
+ (NSArray<RXCollectData *> *)getCollectionDataWithTime:(NSString *)time Count:(int)count;
///查所有数据
+ (NSArray<RXCollectData *> *)getAllCollectionData;

///查所有文件类型数据
+ (NSArray<RXCollectData *> *)getAllFileCollectionData;

///查所有图片视频类型数据
+ (NSArray<RXCollectData *> *)getAllMeidaCollectionData;

///查所有链接类型数据
+ (NSArray<RXCollectData *> *)getAllLinkCollectionData;

@end


@interface RXCollectModel : NSObject

/** RXCollectData */
@property(nonatomic,strong)RXCollectData *data;

/** domain */
@property(nonatomic,strong)NSDictionary *domain;

/** domain */
@property(nonatomic,strong)NSDictionary *userData;

@end
