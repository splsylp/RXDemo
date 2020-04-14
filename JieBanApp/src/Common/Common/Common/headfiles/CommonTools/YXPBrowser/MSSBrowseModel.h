//
//  MSSBrowseModel.h
//  MSSBrowse
//
//  Created by yuxuanpeng on 15/12/5.
//  Copyright © 2015年 yuxuanpeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MSSBrowseModel : NSObject

@property (nonatomic,copy)NSString *bigImageUrl;// 大图
@property (nonatomic,strong)UIImageView *smallImageView;// 小图
@property (nonatomic,strong)NSString * authId;//图片作者ID
@property (nonatomic,strong) NSString * locImgUrl;//本地图片路径
@property (nonatomic,assign) CGRect smallimageViewFrame;
@property (nonatomic,strong) NSString *messageId;
@property (nonatomic,assign) BOOL isBurnMessage;
@property (nonatomic,assign)BOOL  isHistoryMsg;
@end
