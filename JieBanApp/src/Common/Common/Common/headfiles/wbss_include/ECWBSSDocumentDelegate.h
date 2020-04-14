//
//  ECWBSSDocumentDelegate.h
//  WBSSiPhoneSDK
//
//  Created by jiazy on 16/6/20.
//  Copyright © 2016年 yuntongxun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECWBSSDocument.h"

/**
 * 文档通知代理
 */
@protocol ECWBSSDocumentDelegate <NSObject>

/**
 @brief 共享文档通知
 @param document 文档信息
 */
-(void)onShareDocNotify:(ECWBSSDocument*)document;

/**
 @brief 文档翻页通知
 @param document 文档信息
 @param userid  用户ID
 */
-(void)onGotoPageNotify:(ECWBSSDocument*)document OfUserId:(NSString*)userid;

/**
 @brief 文档准备通知
 @param document 文档信息
 */
-(void)onReadyOfDocument:(ECWBSSDocument*)document;

/**
 @brief 文档中页面准备通知
 @param page 页码索引
 @param document 文档信息
 */
-(void)onReadyPage:(int)page OfDocument:(ECWBSSDocument *)document;

/**
 @brief 文档转换结果通知
 @param error 结果提示
 @param document 文档信息
 */
-(void)onConvertResult:(ECWBSSError*)error ofDocument:(ECWBSSDocument*)document;

@end
