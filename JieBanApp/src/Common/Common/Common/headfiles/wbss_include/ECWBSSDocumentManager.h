//
//  ECWBSSDocumentManager.h
//  WBSSiPhoneSDK
//
//  Created by jiazy on 16/6/20.
//  Copyright © 2016年 yuntongxun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECWBSSDocument.h"
#import "ECWBSSProgressDelegate.h"

/**
 * 文档管理类
 */
@protocol ECWBSSDocumentManager <NSObject>

/**
 @brief 上传文档
 @param document 上传的文档信息
 @param progress 上传进度代理
 @param completion 执行结果回调block
 @return 进度id，用户上传进度，标识上传id，不用于文档id
 */
-(unsigned int)uploadDocument:(ECWBSSDocument*)document progress:(id<ECWBSSProgressDelegate>)progress completion:(void(^)(ECWBSSError *error ,ECWBSSDocument *document))completion;

/**
 @brief 共享文档
 @param document 共享的文档
 @param completion 执行结果回调block
 */
-(void)shareDocument:(ECWBSSDocument*)document completion:(void(^)(ECWBSSError *error ,ECWBSSDocument *document))completion;

/**
 @brief 清除当前页面
 @param document 清除的文档
 @param userId 清除的用户ID
 @param completion 执行结果回调block
 */
-(void)clearCurrentPageOfDocument:(ECWBSSDocument*)document andUserId:(NSString*)userId completion:(void(^)(ECWBSSError *error ,ECWBSSDocument *document))completion;

/**
 @brief 跳转页面
 @param pageIndex 跳转页码索引
 @param document 当前文档
 @param completion 执行结果回调block
 */
-(void)gotoPage:(int)pageIndex OfDocument:(ECWBSSDocument*)document completion:(void(^)(ECWBSSError *error ,ECWBSSDocument *document))completion;

/**
 @brief 下一页
 @param document 当前文档
 @param completion 执行结果回调block
 */
-(void)gotoNextPageOfDocument:(ECWBSSDocument*)document completion:(void(^)(ECWBSSError *error ,ECWBSSDocument *document))completion;

/**
 @brief 上一页
 @param document 当前文档
 @param completion 执行结果回调block
 */
-(void)gotoPrevPageOfDocument:(ECWBSSDocument*)document completion:(void(^)(ECWBSSError *error ,ECWBSSDocument *document))completion;

@end
