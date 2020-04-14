//
//  SportMeetModel.h
//  ECSDKDemo_OC
//
//  Created by yuxuanpeng on 16/3/22.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SportMeetMessageModel : NSObject
@property(nonatomic,strong)NSString *msgId;
@property(nonatomic,strong)NSString *sender;//发送者
@property(nonatomic,strong)NSString *revicer;//接受者
@property(nonatomic,strong)NSString *subject;//主题
@property(nonatomic,strong)NSString *file_url;//头像地址
@property(nonatomic,strong)NSString *headUrl;//用户头像
@property(nonatomic,assign)NSInteger status;//消息状态
@property(nonatomic,strong)NSString *faildes;//审核失败的原因
@property(nonatomic,strong)NSString *ctime;//创建的时间
@property(nonatomic,strong)NSString *utime;//修改的时间
@property(nonatomic,strong)NSString *content;//文本消息内容
@property(nonatomic,assign)NSInteger msg_type;//消息分类 1你我看点，2场外之声，3精彩回放，4战绩快报
@property(nonatomic,strong)NSString *eam_id;//组织结构ID

@end

@interface SportMeetReceiveModel : NSObject
@property(nonatomic,strong)NSString *sender;//发送者
@property(nonatomic,strong)NSString *revicer;//接受者
@property(nonatomic,strong)NSString *file_url;//头像地址
@property(nonatomic,strong)NSString *headUrl;//用户头像
@property(nonatomic,assign)NSInteger status;//消息状态
@property(nonatomic,strong)NSString *time;//创建的时间
@property(nonatomic,strong)NSString *content;//文本消息内容
@property(nonatomic,strong)NSString *domain;//消息分类
@property(nonatomic,strong)NSString *version;//版本号
@property(nonatomic,strong)NSString *subject;//主题
@property(nonatomic,strong)NSString *teamName;//团队名称

@end

@interface SportMeetBrowseModel : NSObject
@property(nonatomic,strong)NSString *imgUrl;//图片地址
@property(nonatomic,strong)NSString *content;//内容显示
@property(nonatomic,strong)NSString *smallImgUrl;//小图地址

@end

