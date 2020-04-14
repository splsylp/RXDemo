//
//  YHCBoard.h
//  ECSDKDemo_OC
//
//  Created by 王明哲 on 16/8/30.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECWBSSError.h"
#import "ECWBSSRoom.h"

@interface YHCBoard : NSObject
//单例
+ (instancetype)sharedInstance;
//获取当前的白板
- (UIViewController *)getCurrentBoardCoopVC;
//设置预览模式
- (void)setPreviewMode:(BOOL)isPreviewMode;

//清空当前房间和文档
- (void)setCurrentRoomNil;
- (void)setSubmitDocNil;

//关闭白板
- (void)closeBoardVC;

/**
 ·@brief 保存应用信息
 @discussion 根据传入的参数修改应用id，服务器地址，登录账号等
 @param     userID 登录账号
 @param     AppId 应用id
 @param     wbssAddress 服务器地址
 */
- (void)saveAppInfomationWithUserID:(NSString *)userID AppId:(NSString *)AppId wbssAddress:(NSArray *)wbssAddress;


//普通模式创建白板
//必传参数 -> USERID PASSWORD ROOMTYPE BOARDTYPE
//可选参数 -> USERS SENDIM
- (ECWBSSRoom *)createBoardWithParams:(NSDictionary *)dic andPresentVC:(UIViewController *)vc completion:(void(^)(ECWBSSError *error ,ECWBSSRoom *room))completion;

//加入白板
//必传参数 -> USERID PASSWORD BOARDTYPE SENDIM ROOMID
//可选参数 -> USERS SUBMITDOC 通知方式加入需要传 NOTIFLAG 为 1
- (ECWBSSRoom *)joinRoomWithParams:(NSDictionary *)dic andPresentVC:(UIViewController *)vc completion:(void(^)(ECWBSSError *error ,ECWBSSRoom *room))completion;

//共享本地图片
- (void)shareDocWithImage:(UIImage *)image completion:(void(^)(ECWBSSError *error ,ECWBSSRoom *room))completion;
//共享本地文档
- (void)shareLocalDocWithFilePath:(NSString *)filePath completion:(void(^)(ECWBSSError *error ,ECWBSSRoom *room))completion;
//共享云盘文档
- (void)shareNetDocWithUrl:(NSString *)url completion:(void(^)(ECWBSSError *error ,ECWBSSRoom *room))completion;

@end
