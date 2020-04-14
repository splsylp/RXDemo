//
//  YXPBannerView.h
//  Common
//
//  Created by yuxuanpeng on 2017/7/27.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KitBannerData.h"

@protocol YXPBannerViewDelegate <NSObject>

/**
 * webUrl 跳转网页地址
 * userData 扩展字段
 */
- (void)onActionEvent:(NSString *)webUrl userData:(NSString *)userData;

@end

@interface YXPBannerView : UIView

@property(nonatomic, assign) id<YXPBannerViewDelegate>delegate;

/**
 * frame 坐标
 * bannerImageUrl 网页地址
 * bannerDefaultImage 默认图片
 * bannerTitle banner内容
 * showArray 显示的banner图 规则 是@[@{@"bannerImageUrl":@"xxx",@"bannerDefaultImage":@"xxx",@"bannerTitle":@""},@{}]
 **/
- (instancetype)initWithFrame:(CGRect)frame withShowArray:(NSArray<KitBannerData *> *)showArray;

- (void)updaloadImage;//更新图片

- (void)updateShowBanner:(NSArray<KitBannerData *> *)bannerArray;//更新所以显示的banner



@end
