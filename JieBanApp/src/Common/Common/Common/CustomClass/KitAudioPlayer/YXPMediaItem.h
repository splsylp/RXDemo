//
//  YXPMediaItem.h
//  Common
//
//  Created by yuxuanpeng on 2017/9/29.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YXPMediaItem : NSObject
@property (nonatomic, strong) NSArray <NSURL*> * assetUrls;// 媒体资源地址
@property(nonatomic,strong)NSURL *currentUrl;//下载的url
@property(nonatomic,copy)NSString *currentId;//当前语音消息id
@property(nonatomic,copy)NSString *currentMsgId;//当前消息的msgId;
@end
