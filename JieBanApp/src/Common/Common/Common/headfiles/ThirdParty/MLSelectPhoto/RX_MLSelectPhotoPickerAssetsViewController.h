//  github: https://github.com/MakeZL/MLSelectPhoto
//  author: @email <120886865@qq.com>
//
//  ZLPhotoPickerAssetsViewController.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-12.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RX_MLSelectPhotoCommon.h"
#import "RX_MLSelectPhotoPickerGroupViewController.h"

@class RX_MLSelectPhotoPickerGroup;

@interface RX_MLSelectPhotoPickerAssetsViewController : UIViewController

@property (strong,nonatomic) RX_MLSelectPhotoPickerGroupViewController *groupVc;
@property (nonatomic , assign) PickerViewShowStatus status;
@property (nonatomic , strong) RX_MLSelectPhotoPickerGroup *assetsGroup;
@property (nonatomic , assign) NSInteger minCount;
// 需要记录选中的值的数据
@property (strong,nonatomic) NSArray *selectPickerAssets;
// 置顶展示图片
@property (assign,nonatomic) BOOL topShowPhotoPicker;

@property (nonatomic, copy)NSString *doneString;
@end
