//
//  HXSelectCacheDocumentBar.h
//  ECSDKDemo_OC
//
//  Created by ywj on 16/8/4.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "RXBaseView.h"


#define SelectCacheDocumentBar_Height 40


@class HXSelectCacheDocumentBar;
@protocol HXSelectCacheDocumentBarDelegate <NSObject>
@optional

- (void)SelectCacheDocumentBar:(HXSelectCacheDocumentBar*)aSegmentedBarView selectedIndex:(NSInteger)aIndex;

@end

@interface HXSelectCacheDocumentBar : RXBaseView
@property(nonatomic,strong)UIButton *fileBtn;//文件按钮
@property(nonatomic,strong)UIButton *imgFileBtn;//图片按钮
@property(nonatomic,strong)UIButton *otherBtn;//其他按钮

@property (nonatomic,assign)NSInteger selectIndex;
@property (nonatomic,assign)NSInteger selectwidth;

@property (nonatomic,retain)UIView *lineView;

@property(nonatomic,assign)id<HXSelectCacheDocumentBarDelegate>delegate;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)selectIndex:(NSInteger)aIndex needDelegate:(BOOL)aNeedDelegate;
@end
