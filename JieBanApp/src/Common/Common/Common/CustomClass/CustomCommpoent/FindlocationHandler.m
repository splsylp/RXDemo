//
//  FindlocationHandler.m
//  ECSDKDemo_OC
//
//  Created by zhouwh on 15/8/20.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "FindlocationHandler.h"
#import <sqlite3.h>

@interface FindlocationHandler (){

    NSString * mylabelphonenumber;//手机号码
    NSString * mylabellocation;//归属地
    NSString * mylabelmobile;//运营商
    NSString * mylabelzonecode;//城市区号
    sqlite3 *db;
}

@end

@implementation FindlocationHandler

+ (instancetype)sharedFindlocation {
    static id _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

//查询手机号码所属的运营商
-(NSString *)getTelCarrieroperator:(NSString *)phoneNum{
    NSString *loacation = @"";

    NSString *path = [[NSBundle mainBundle] pathForResource:@"number_location" ofType:@"db"];
    if (sqlite3_open([path UTF8String], &db)!= SQLITE_OK) {
        sqlite3_close(db);
        NSLog(@"打开数据库失败");
    }
    sqlite3_stmt *stmt = nil;

    NSString *str = phoneNum;
    if(phoneNum.length > 3){
        str = [phoneNum substringToIndex:3];
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT mobilenumber.mobile FROM mobilenumber LEFT JOIN numbermobile ON numbermobile.mobile = mobilenumber.uid where numbermobile.uid=%@",str];

    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL);
    if (result == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            //根据SQL语句将搜索到的符合条件的值取出来
            loacation = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 0)];
        }
    }
    sqlite3_finalize(stmt);
    return loacation;
}

//查询手机号码所在的归属地
- (NSString *)getTelLocation:(NSString *)prefix center:(NSString *)center{
    NSString *location = @"";

    NSString *path = [[NSBundle mainBundle] pathForResource:@"number_location" ofType:@"db"];
    if (sqlite3_open([path UTF8String], &db)!= SQLITE_OK) {
        sqlite3_close(db);
        return nil;
    }
    if (center == nil){
        return nil;
    }

    sqlite3_stmt *stmt = nil;
    //构造sql语句
    int num = [center intValue] - 1;
    NSString *sql1 = [NSString stringWithFormat:@"SELECT city_id FROM number_%@ limit %d,1",prefix,num];
    NSString *sql2 = [NSString stringWithFormat:@"SELECT province_id FROM city where _id = (%@)",sql1];
    NSString *sql = [NSString stringWithFormat:@"SELECT province,city FROM province,city where _id=(%@)and id=(%@)",sql1,sql2];
    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL);


    NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
    if (result == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            int col_count = sqlite3_column_count(stmt);
            for (int i = 0; i < col_count; i++) {
                NSString *columnName = [NSString stringWithUTF8String:(const char *)sqlite3_column_name(stmt, i)];
                NSString *columnValue = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, i)];
                if (columnValue == nil) {
                    columnValue = @"";
                }
                [map setValue:columnValue forKey:columnName];
            }
        }
    }
    NSString *province = [map objectForKey:@"province"];
    NSString *city = [map objectForKey:@"city"];
    if (province != nil && city != nil) {
        if ([province isEqualToString:city]) {
            location = province;
        }else{
            location = [NSString stringWithFormat:@"%@%@",province,city];
        }
    }
    sqlite3_finalize(stmt);
    return location;
}

- (NSString *)findBelongingWithPhoneNum:(NSString *)moblie{
    if (moblie.length > 6) {
        NSString * mobileStr = [self getTelCarrieroperator:moblie];
        NSRange range = {3,4};
        
        NSString * locationStr = [self getTelLocation:[moblie substringToIndex:3] center:[moblie substringWithRange:range]];
        return [NSString stringWithFormat:@"%@%@",locationStr,mobileStr];
    }
    return @"";
}

@end
