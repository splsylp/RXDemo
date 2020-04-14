//
//  ECWBSSRoomManager.h
//  WBSSiPhoneSDK
//
//  Created by jiazy on 16/6/20.
//  Copyright © 2016年 yuntongxun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECWBSSRoom.h"
#import "ECWBSSError.h"

/**
 * @brief 画图形状
 */
typedef NS_ENUM(int,LineShapeType) {
    LineShapeType_NONE = 0,
    LineShapeType_FREE = 1,
    LineShapeType_LINE = 2,
    LineShapeType_ANGLE = 3,
    LineShapeType_TRIANGLE = 4
};

/**
 * @brief 赋予权限的类型
 */
typedef NS_ENUM(int, MemberAuth) {
    MemberAuth_CreateTmpRoom      = 0x00000001, //创建临时房间
    MemberAuth_CreatePermRoom     = 0x00000003, //能创建永久房间，也能创建临时房间
    MemberAuth_DeleteTmpRoom      = 0x00000004, //删除临时房间
    MemberAuth_DeletePermentRoom  = 0x00000008, //删除永久房间
    MemberAuth_Upload             = 0x00000010, //上传文件
    MemberAuth_DownloadOrigFile   = 0x00000020, //下载原始文件
    MemberAuth_ShareDoc           = 0x00000040, //共享文件
    MemberAuth_Draw               = 0x00000080, //划线
    MemberAuth_DeleteDraw         = 0x00000100, //删除划线
    MemberAuth_Kick               = 0x00000200, //踢人
    MemberAuth_AbandonDraw        = 0x00000400, //禁止某人划线
    MemberAuth_AbandonShare       = 0x00000800, //禁止某人共享文件
    MemberAuth_AbandonDelteDraw   = 0x00001000  //禁止某人删除划线
};

/**
 * @brief 画笔类型
 */
typedef NS_ENUM(int,PenType) {
    PenType_NORMAL = 0,
} ;

/**
 * @brief 画线撤销类型
 */
typedef NS_ENUM(int,UndoType) {
    UndoType_SELF = 0,
    UndoType_ALL = 1,
} ;
/**
 * 房间管理类
 */
@protocol ECWBSSRoomManager <NSObject>

/**
 @brief 创建房间
 @param room 房间信息
 @param completion 执行结果回调block
 */
-(void)createRoom:(ECWBSSRoom*)room completion:(void(^)(ECWBSSError *error ,ECWBSSRoom *room))completion;

/**
 @brief 删除房间
 @param room 房间信息
 @param completion 执行结果回调block
 */
-(void)deleteRoom:(ECWBSSRoom*)room completion:(void(^)(ECWBSSError *error ,ECWBSSRoom *room))completion;

/**
 @brief 离开房间
 @param room 房间信息
 @param completion 执行结果回调block
 */
-(void)leaveRoom:(ECWBSSRoom*)room completion:(void(^)(ECWBSSError *error ,ECWBSSRoom *room))completion;

/**
 @brief 加入房间
 @param room 房间信息
 @param completion 执行结果回调block
 */
-(void)joinRoom:(ECWBSSRoom*)room completion:(void(^)(ECWBSSError *error ,ECWBSSRoom *room))completion;

/**
 @brief 设置线的形状
 @param shape 自由划线:1，直线:2 , 四边形:3
 @param roomId 房间ID
 */
-(int) setLineShape:(LineShapeType)shape ofRoom:(int)roomId;

/**
 @brief 设置线的颜色
 @param lineColor 线颜色
 @param roomId 房间ID
 */
-(int) setLineColor:(UIColor*)lineColor ofRoom:(int)roomId;

/**
 @brief 设置线大小
 @param lineSize 线大小
 @param roomId 房间ID
 */
-(int) setLineSize:(int)lineSize ofRoom:(int)roomId;

/**
 @brief 获取橡皮擦
 @param roomId 房间ID
 */
-(int) getEraserOfRoom:(int)roomId;

/**
 @brief 获取画笔
 @param type 画笔类型
 @param roomId 房间ID
 */
-(int) getPenType:(PenType)type ofRoom:(int)roomId;

/**
 @brief 撤销划线
 @param type 划线类型
 @param completion 执行结果回调block
 */
-(void) drawUndoOfType:(UndoType)type completion:(void(^)(ECWBSSError* error))completion;

/**
 @brief 恢复划线
 @param completion 执行结果回调block
 */
-(void) drawRedoCompletion:(void(^)(ECWBSSError* error))completion;

/**
 @brief 获取房间成员
 @param roomId 房间ID
 @param completion 执行结果回调block
 */
-(void) getMembersOfRoom:(int)roomId completion:(void(^)(ECWBSSError* error, NSArray* members)) completion;

/**
 @brief 修改成员权限
 @param userId 用户ID
 @param auth 用户权限
 @param type 类型 0 代表收回权限 1 代表赋予权限
 @param roomId 房间ID
 @param completion 执行结果回调block
 */
-(void) changeMember:(NSString*)userId withAuth:(MemberAuth)auth andType:(int)type OfRoom:(int)roomId completion:(void(^)(ECWBSSError* error, NSString* userId)) completion;
@end
