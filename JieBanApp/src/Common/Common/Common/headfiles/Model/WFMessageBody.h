//
//  WFMessageBody.h
//  WFCoretext
//
//  Created by 阿虎 on 15/4/29.
//  Copyright (c) 2015年 tigerwf. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  消息（栏目）分类
 */
typedef NS_ENUM(NSInteger, HXCustomMessageType) {
    
    HXCustomMessageType_FC = 0,  //同事圈
    HXCustomMessageType_Look,   //你我看点
    HXCustomMessageType_Outside,  //场外之声
    HXCustomMessageType_Playback,  //精彩回放
    HXCustomMessageType_Letters    //战绩快报
};


@interface WFMessageBody : NSObject

/**
 *  消息id 跟版本号Version 一样
 */
@property (nonatomic,copy) NSString * msgId;
/**
 *  用户头像url 此处直接用图片名代替
 */
@property (nonatomic,copy) NSString *posterImgstr;//

/**
 *  用户名称
 */
@property (nonatomic,copy) NSString *posterName;
/**
 *  消息版本
 */
@property (nonatomic,copy) NSString *version;
/**
 *  发送者
 */
@property (nonatomic,copy) NSString *sender;
/**
 *  接受者
 */
@property (nonatomic,copy) NSString *revicer;
/**
 *  消息类型
 */
@property (nonatomic,assign) HXCustomMessageType msg_type;
/**
 *  项目分类 (运动会)
 */
@property (nonatomic,assign) NSInteger item;
/**
 *  消息状态（审核）
 *  0一审待审核 1一审失败；9一审通过待发送
 *  10二审待审核；11二审核失败；19二审通过待发送
 *  20三审待审核；21三审失败；
 *  30三审核成功
 */
@property (nonatomic,assign) NSInteger status;

/**
 *  用户简介
 */
@property (nonatomic,copy) NSString *posterIntro;//

/**
 *  时间
 */
@property (nonatomic,copy) NSString *posterTime;

/**
 *  用户说说内容
 */
@property (nonatomic,copy) NSString *posterContent;//

/**
 *  用户发送的图片数组
 */
@property (nonatomic,strong) NSArray *posterPostImage;//

/**
 *  用户收到的赞 (该数组存点赞的人的昵称)
 */
@property (nonatomic,strong) NSMutableArray *posterFavour;

/**
 *  用户说说的评论数组 (该数组存解析后自定义对象)
 */
@property (nonatomic,strong) NSMutableArray *posterReplies;//

/**
 *  admin是否赞过
 */
@property (nonatomic,assign) BOOL isFavour;
/**
 *  admin是否评论过
 */
@property (nonatomic,assign) BOOL isReply;

@end
