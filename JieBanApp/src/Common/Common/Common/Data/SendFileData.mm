//
//  SendFileData.mm
//  Common
//
//  Created by lxj on 2018/8/24.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "SendFileData+WCTTableCoding.h"
#import "SendFileData.h"
#import <WCDB/WCDB.h>

#import "DataBaseManager.h"

static SendFileData *_sharedInstance = nil;

@implementation SendFileData

WCDB_IMPLEMENTATION(SendFileData)
WCDB_SYNTHESIZE(SendFileData, fileUrl)
WCDB_SYNTHESIZE_COLUMN(SendFileData, locatPath, "cacheFileLocatPath")
WCDB_SYNTHESIZE(SendFileData, sessionId)
WCDB_SYNTHESIZE(SendFileData, fileDirectory)
WCDB_SYNTHESIZE(SendFileData, identifer)
WCDB_SYNTHESIZE(SendFileData, disPathName)
WCDB_SYNTHESIZE(SendFileData, extension)
WCDB_SYNTHESIZE(SendFileData, fileUuid)
WCDB_SYNTHESIZE(SendFileData, fileKey)
WCDB_SYNTHESIZE(SendFileData, fileSize)


+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[super allocWithZone:NULL] init];
    });
    return _sharedInstance;
}

#pragma mark - 增
- (BOOL)insertFileinfoData:(NSDictionary *)fileDic{
    NSString *fileUrl = fileDic[cachefileUrl];
    SendFileData *data = [SendFileData getSendFileDataByCondition:SendFileData.fileUrl == fileUrl];
    fileUrl = data.fileUrl;

    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    if (KCNSSTRING_ISEMPTY(fileUrl)) {//为空 新增
        data = [SendFileData dataWithDic:fileDic];
        return [dataBase insertOrReplaceObject:data into:DATA_CACHEFILE_DBTABLE];
    }else{//修改
        data.fileKey = [fileDic objectForKey:cachefileKey];
        data.fileUuid = [fileDic objectForKey:cachefileUuid];
       return [dataBase updateRowsInTable:DATA_CACHEFILE_DBTABLE onProperties:SendFileData.fileKey withObject:data where:SendFileData.fileUuid == data.fileUuid];
    }
}
#pragma mark - 删
///删除方法
+ (BOOL)deleteSendFileDataByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteObjectsFromTable:DATA_CACHEFILE_DBTABLE where:condition];
}
///根据fileUrl删除
- (BOOL)deleteAllFileUrl:(NSString *)fileUrl{
    return [SendFileData deleteSendFileDataByCondition:SendFileData.fileUrl == fileUrl];
}
///根据sessionId删除
- (BOOL)deleteAllFileSessionId:(NSString *)sessionId{
    return [SendFileData deleteSendFileDataByCondition:SendFileData.sessionId == sessionId];
}
#pragma mark - 改
- (BOOL)updateFileKey:(NSString *)filekey withFileUUid:(NSString *)fileUuid {
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;

    SendFileData *data = [[SendFileData alloc] init];
    data.fileKey = filekey;
    return [dataBase updateRowsInTable:DATA_CACHEFILE_DBTABLE onProperties:SendFileData.fileKey withObject:data where:SendFileData.fileUuid == fileUuid];
}

#pragma mark - 查
///根据directory查数据
- (NSArray *)getAppointDirectoryCacheFile:(NSString *)directory{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    NSArray<SendFileData *> *array = [dataBase getObjectsOfClass:SendFileData.class fromTable:DATA_CACHEFILE_DBTABLE where:SendFileData.fileDirectory == directory];

    NSMutableArray *fileMsgArr = [[NSMutableArray alloc] init];
    for (SendFileData *data in array) {
        NSDictionary *dict = [SendFileData dicWithSendFileData:data];
        [fileMsgArr addObject:dict];
    }
    return fileMsgArr;
}

///单条查询
+ (SendFileData *)getSendFileDataByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getOneObjectOfClass:SendFileData.class fromTable:DATA_CACHEFILE_DBTABLE where:condition];
}
///根据fileUrl查数据
- (NSDictionary *)getCacheFileData:(NSString *)fileUrl{
    SendFileData *data = [SendFileData getSendFileDataByCondition:SendFileData.fileUrl == fileUrl];

    return [SendFileData dicWithSendFileData:data];
}


///SendFileData转字典
+ (NSDictionary *)dicWithSendFileData:(SendFileData *)data{
    if (data == nil) {
        return nil;
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[cachefileUrl] = data.fileUrl;
    dict[cacheimSissionId] = data.sessionId;
    dict[cachefileDirectory] = data.fileDirectory;
    dict[cachefileIdentifer] = data.identifer;
    dict[cachefileDisparhName] = data.disPathName;
    dict[cachefileExtension] = data.extension;
    dict[cachefileSize] = [NSString stringWithFormat:@"%ld",(long)data.fileSize];
    dict[cachefileUuid] = data.fileUuid ? : @"";
    dict[cachefileKey] = data.fileKey ? : @"";

    return dict;
}
+ (SendFileData *)dataWithDic:(NSDictionary *)dict{
    SendFileData *data = [[SendFileData alloc] init];
    data.fileUrl = dict[cachefileUrl];
    data.sessionId = dict[cacheimSissionId];
    data.fileDirectory = dict[cachefileDirectory];
    data.identifer = dict[cachefileIdentifer];
    data.disPathName = dict[cachefileDisparhName];
    data.extension = dict[cachefileExtension];
    data.fileSize = [dict[cachefileSize] integerValue];
    data.fileUuid = dict[cachefileUuid];
    data.fileKey = dict[cachefileKey];
    return data;
}
@end
