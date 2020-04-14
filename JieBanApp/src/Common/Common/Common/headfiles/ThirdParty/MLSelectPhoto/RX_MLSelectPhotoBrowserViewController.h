//  github: https://github.com/MakeZL/MLSelectPhoto
//  author: @email <120886865@qq.com>
//
//  RX_MLSelectPhotoBrowserViewController.h
//  MLSelectPhoto
//
//  Created by 张磊 on 15/4/23.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^selectBlock)(NSArray *selectArr);

@interface RX_MLSelectPhotoBrowserViewController : UIViewController
// 展示的图片 MLSelectAssets
@property (strong,nonatomic) NSArray *photos;
// 长按图片弹出的UIActionSheet
@property (strong,nonatomic) UIActionSheet *sheet;
// 当前提供的分页数
@property (nonatomic , assign) NSInteger currentPage;

//wwl 新图片提醒发送添加
@property (nonatomic , copy) selectBlock callBack;

///修改后的数据源是否回调
@property(nonatomic ,assign) BOOL shouldChange;
@end
