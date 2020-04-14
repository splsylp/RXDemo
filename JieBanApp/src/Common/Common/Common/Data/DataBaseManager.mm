//
//  DataBaseManager.m
//  WCDB_Demo
//
//  Created by lxj on 2018/7/25.
//  Copyright © 2018年 lxj. All rights reserved.
//

#import "DataBaseManager.h"
#import <WCDB/WCDB.h>

@interface DataBaseManager()

@property(nonatomic ,strong) WCTDatabase *database;

@end

@implementation DataBaseManager

+ (DataBaseManager *)sharedInstance {
    static DataBaseManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)dataBase{
    if (self.database == nil) {
        [self createDataBase];
    }
    return self.database;
}

///创建数据库
- (void)createDataBase{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *path = [NSString stringWithFormat:@"%@.db", [docDir stringByAppendingPathComponent:[[Common sharedInstance] getAccount]]];
    DDLogInfo(@"本地数据库路径:%@",path);
    self.database = [[WCTDatabase alloc] initWithPath:path];
    if (ISOPENCipher){
        NSData *password = [@"rxpassword" dataUsingEncoding:NSASCIIStringEncoding];
        [self.database setCipherKey:password];
    }
    self.database.tag = 1;
    if ([self.database canOpen]) {
        [self createTable];
        if (ISFTSMODE) {
            [self createFTSTable];
        }
    } else {
        NSLog(@"DATABASE OPEN FAILD");
    }
}
///创建表
- (void)createTable{
    [self.database createTableAndIndexesOfName:DATA_COMPANYADDRESS_DBTABLE withClass:TABLE_WCDB_CLASS(@"KitCompanyAddress")];
    [self.database createTableAndIndexesOfName:DATA_COMPANYDEPT_DBTABLE withClass:TABLE_WCDB_CLASS(@"KitCompanyDeptNameData")];
    [self.database createTableAndIndexesOfName:DATA_COMPANY_DBTABLE withClass:TABLE_WCDB_CLASS(@"KitCompanyData")];
    [self.database createTableAndIndexesOfName:DATA_DIALING_DBTABLE_NAME withClass:TABLE_WCDB_CLASS(@"KitDialingData")];
    [self.database createTableAndIndexesOfName:DATA_INFODIALING_DATABLE_NAME withClass:TABLE_WCDB_CLASS(@"KitDialingInfoData")];
    [self.database createTableAndIndexesOfName:DATA_GROUP_DBTABLE withClass:TABLE_WCDB_CLASS(@"KitGroupData")];
    [self.database createTableAndIndexesOfName:DATA_GROUPINFO_DBTABLE withClass:TABLE_WCDB_CLASS(@"KitGroupInfoData")];
    [self.database createTableAndIndexesOfName:DATA_GROUPMEMBERINFO_DBTABLE withClass:TABLE_WCDB_CLASS(@"KitGroupMemberInfoData")];
    [self.database createTableAndIndexesOfName:DATA_COLLECTION_DBTABLE withClass:TABLE_WCDB_CLASS(@"RXCollectData")];
    [self.database createTableAndIndexesOfName:DATA_APPSTORE_Group_DBTABLE withClass:TABLE_WCDB_CLASS(@"RxAppStoreAppGroupData")];
    [self.database createTableAndIndexesOfName:DATA_APPSTORE_AppInfo_DBTABLE withClass:TABLE_WCDB_CLASS(@"RxAppStoreData")];
    [self.database createTableAndIndexesOfName:DATA_APPSTORE_MyApps_DBTABLE withClass:TABLE_WCDB_CLASS(@"RxAppStoreMyAppData")];
    [self.database createTableAndIndexesOfName:DATA_MYAPPOPEARTE_DBTABLE withClass:TABLE_WCDB_CLASS(@"KitMyAppStoreOperate")];
    [self.database createTableAndIndexesOfName:DATA_BANNER_DBTABLE  withClass:TABLE_WCDB_CLASS(@"KitBannerData")];
    ///这张表没要了？
//    [self.database createTableAndIndexesOfName:DATA_MYAPPUNREADCOUNT_DBTABLE withClass:TABLE_WCDB_CLASS(@"KitAppStoreUnreadData")];
    [self.database createTableAndIndexesOfName:DATA_MYFRIEND_LIST withClass:TABLE_WCDB_CLASS(@"HXMyFriendList")];
    [self.database createTableAndIndexesOfName:DATA_MYFRIEND_LIST withClass:TABLE_WCDB_CLASS(@"RXMyFriendList")];
    [self.database createTableAndIndexesOfName:DATA_NEWFRIEND_LIST withClass:TABLE_WCDB_CLASS(@"HXAddnewFriendList")];
    [self.database createTableAndIndexesOfName:DATA_NEWFRIENDINVITE_COUNT withClass:TABLE_WCDB_CLASS(@"HXInviteCountData")];
    [self.database createTableAndIndexesOfName:DATA_SPECIAL_DBTABLE withClass:TABLE_WCDB_CLASS(@"HXSpecialData")];
    [self.database createTableAndIndexesOfName:DATA_PUBLIC_NUM withClass:TABLE_WCDB_CLASS(@"HXAttPublicNum")];
    [self.database createTableAndIndexesOfName:DATA_PUBLIC_NUMBER withClass:TABLE_WCDB_CLASS(@"HXPNMessageNumber")];
    [self.database createTableAndIndexesOfName:DATA_FC_MESSAGE_FAVOUR_DBTABLE withClass:TABLE_WCDB_CLASS(@"RXFCFavourData")];
    [self.database createTableAndIndexesOfName:DATA_SPORT_MESSAGE_DBTABLE withClass:TABLE_WCDB_CLASS(@"RXSportMeetData")];
    [self.database createTableAndIndexesOfName:DATA_FC_MESSAGE_UNREADMSG_DBTABLE withClass:TABLE_WCDB_CLASS(@"RXUnReadPCData")];
    [self.database createTableAndIndexesOfName:DATA_FC_MESSAGE_REPLY_DBTABLE withClass:TABLE_WCDB_CLASS(@"RXFCReplyData")];
    [self.database createTableAndIndexesOfName:DATA_SELFFC_MESSAGE_DBTABLE withClass:TABLE_WCDB_CLASS(@"RXMyFCListData")];
    [self.database createTableAndIndexesOfName:DATA_SESSION_DBTABLE withClass:TABLE_WCDB_CLASS(@"ECSession")];
    [self.database createTableAndIndexesOfName:DATA_CHAT_DBTABLE withClass:TABLE_WCDB_CLASS(@"ECMessage_Son")];
    [self.database createTableAndIndexesOfName:DATA_PUBLIC_MESSAGE_DBTABLE withClass:TABLE_WCDB_CLASS(@"RXPublicMessage")];
    BOOL result;
    result = [self.database createTableAndIndexesOfName:DATA_CACHEFILE_DBTABLE withClass:TABLE_WCDB_CLASS(@"SendFileData")];
}
- (void)createFTSTable{
    ///注册分词器
    [self.database setTokenizer:WCTTokenizerNameWCDB];
    //接口创建FTS表
    BOOL result = [self.database createVirtualTableOfName:DATA_COMPANYADDRESS_DBTABLE_FTS withClass:TABLE_WCDB_CLASS(@"KitCompanyAddress")];
    NSLog(@"%d",result);
}
- (void)insertObject:(WCTObject *)object into:(NSString *)tableName{
    object.isAutoIncrement = YES;
    [self.database insertObject:object into:tableName];
}
- (NSArray *)getAllObjectsOfClass:(Class)className tableName:(NSString *)tableName{
    return [self.database getAllObjectsOfClass:className fromTable:tableName];
}
- (BOOL)deleteAllObjectsFromTable:(NSString *)tableName{
    return [self.database deleteAllObjectsFromTable:tableName];
}
- (void)clearAllSqliteData{
    self.database = nil;
}
@end
