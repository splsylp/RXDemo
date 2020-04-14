//
//  SendFileData.h
//  Common
//
//  Created by 王明哲 on 2016/10/24.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "BaseModel.h"

@interface SendFileData : BaseModel

@property(nonatomic ,strong) NSString *fileUrl;
@property(nonatomic ,strong) NSString *locatPath;//cacheFileLocatPath
@property(nonatomic ,strong) NSString *sessionId;
@property(nonatomic ,strong) NSString *fileDirectory;
@property(nonatomic ,strong) NSString *identifer;
@property(nonatomic ,strong) NSString *disPathName;
@property(nonatomic ,strong) NSString *extension;
@property(nonatomic ,strong) NSString *fileUuid;
@property(nonatomic ,strong) NSString *fileKey;
@property(nonatomic ,assign) NSInteger fileSize;



+ (instancetype)sharedInstance;

#pragma mark - 增
- (BOOL)insertFileinfoData:(NSDictionary *)fileDic;
#pragma mark - 删
///根据fileUrl删除
- (BOOL)deleteAllFileUrl:(NSString *)fileUrl;
///根据sessionId删除
- (BOOL)deleteAllFileSessionId:(NSString *)sessionId;
#pragma mark - 改
- (BOOL)updateFileKey:(NSString *)filekey withFileUUid:(NSString *)fileUuid;
#pragma mark - 查
///根据directory查数据
- (NSArray *)getAppointDirectoryCacheFile:(NSString *)directory;
///根据fileUrl查数据
- (NSDictionary *)getCacheFileData:(NSString *)fileUrl;
@end
