//
//  ECWBSSDocument.h
//  WBSSiPhoneSDK
//
//  Created by jiazy on 16/6/20.
//  Copyright © 2016年 yuntongxun. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 文档类
 */
@interface ECWBSSDocument : NSObject

/**
 @brief 所属房间ID
 */
@property (nonatomic, assign) int roomId;

/**
 @brief 文档ID
 */
@property (nonatomic, assign) int documentId;

/**
 @brief 当前显示页
 */
@property (nonatomic, assign) int currentPage;

/**
 @brief 文档的页数
 */
@property (nonatomic, assign) int pageCount;

/**
 @brief 文档名称
 */
@property (nonatomic, copy) NSString* fileName;

/**
 @brief 文档路径(上传文档使用)
 */
@property (nonatomic, copy) NSString* filePath;

@end
