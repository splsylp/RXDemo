//
//  HXMergeMessageModel.h
//  ECSDKDemo_OC
//
//  Created by 陈长军 on 2017/3/31.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HXMergeMessageModel : NSObject



@property (nonatomic,strong) NSString * merge_type;

@property (nonatomic,strong) NSString * merge_title;

@property (nonatomic,strong) NSString * merge_time;

@property (nonatomic,strong) NSString * merge_url;

@property (nonatomic,strong) NSString * merge_content;

@property (nonatomic,strong) NSString * merge_account;

@property (nonatomic,strong) NSString * merge_userData;

@property (nonatomic,strong) ECMessage * faterMessage;

@property (nonatomic,strong) NSString *merge_linkThumUrl;

@property (nonatomic,strong) NSString *merge_messageId;

@property (nonatomic,strong) NSString *merge_sessonId;

@property (nonatomic,strong) NSString *merge_duration;

/**
 @brief 发送状态
 */
@property (nonatomic,assign) ECMessageState merge_messageState;

/**
 @brief 本地路径
 */
@property (nonatomic,strong) NSString  *localPath;
/**
 *@brief 文件大小
 */
@property (nonatomic, strong) NSString *merge_fileSize;
/**
 *@brief 文字里包含该的url--------点击文字跳转时用
 */
@property (nonatomic,strong) NSString *textUrl;


/** bubbleW 为了做转发详情小弹窗用的 */
@property(nonatomic,assign)CGFloat bubbleW;

/** 图片的尺寸  防止重复计算 */
@property(nonatomic,assign)CGSize imageSize;

@end
