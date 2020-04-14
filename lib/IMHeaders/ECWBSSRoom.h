//
//  ECWBSSRoom.h
//  WBSSiPhoneSDK
//
//  Created by jiazy on 16/6/20.
//  Copyright © 2016年 yuntongxun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * 房间类
 */
@interface ECWBSSRoom : NSObject

/**
 @brief 房间ID
 */
@property (nonatomic, assign) int roomId;

/**
 @brief 房间类型 1.临时房间，　2.永久房间
 */
@property (nonatomic, assign) int roomType;

/**
 @brief 人员限制
 */
@property (nonatomic, assign) int memberLimit;

/**
 @brief 角色ID
 */
@property (nonatomic, assign) int roleId;

/**
 @brief 房间密码
 */
@property (nonatomic, copy) NSString* password;

/**
 @brief 线颜色
 */
@property (nonatomic, copy) UIColor *lineColor;

/**
 @brief 线宽度
 */
@property (nonatomic, assign) int lineSize;

/**
 @brief 线形状 自由划线:1，直线:2 , 四边形:3
 */
@property (nonatomic, assign) int lineShape;

/**
 @brief 当前文档ID
 */
@property (nonatomic, assign) int curDocId;

/**
 @brief 房间所有文档列表
 */
@property (nonatomic, strong) NSMutableArray *docmentArray;
@end
