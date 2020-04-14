//  github: https://github.com/MakeZL/MLSelectPhoto
//  author: @email <120886865@qq.com>
//
//  ZLPhotoPickerBrowserPhotoScrollView.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-14.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RX_MLSelectPhotoPickerBrowserPhotoImageView.h"
#import "RX_MLSelectPhotoPickerBrowserPhotoView.h"
#import "RX_MLSelectPhotoPickerBrowserPhoto.h"
#import "RX_MLSelectPhoto.h"

typedef void(^callBackBlock)(id obj);
@class RX_MLSelectPhotoPickerBrowserPhotoScrollView;

@protocol ZLPhotoPickerPhotoScrollViewDelegate <NSObject>
@optional
// 单击调用
- (void) pickerPhotoScrollViewDidSingleClick:(RX_MLSelectPhotoPickerBrowserPhotoScrollView *)photoScrollView;
@end

@interface RX_MLSelectPhotoPickerBrowserPhotoScrollView : UIScrollView <UIScrollViewDelegate, ZLPhotoPickerBrowserPhotoImageViewDelegate,ZLPhotoPickerBrowserPhotoViewDelegate>

@property (nonatomic,strong) RX_MLSelectPhotoAssets *photo;
@property (nonatomic, weak) id <ZLPhotoPickerPhotoScrollViewDelegate> photoScrollViewDelegate;
// 长按图片的操作，可以外面传入
@property (strong,nonatomic) UIActionSheet *sheet;
// 单击销毁的block
@property (copy,nonatomic) callBackBlock callback;

@end
