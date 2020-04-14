//
//  RXSelectContactSectionView.m
//  ECSDKDemo_OC
//
//  Created by zhouwh on 15/8/7.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "RXSelectContactSectionView.h"

@implementation RXSelectContactSectionView

- (instancetype)initWithFrame:(CGRect)frame Tag:(NSInteger)tag Layer:(NSString *)layer
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _sectionTag = tag;
        _layerTag = layer;
        self.layerTitleArr = [NSMutableArray arrayWithCapacity:0];
        
        CGFloat width = self.frame.size.width;
        CGFloat height = self.frame.size.height;
        
        self.backgroundColor = [UIColor whiteColor];
        self.titleLab = [[UILabel alloc] initWithFrame:CGRectMake(10, (height - 30*FitThemeFont)/2, 150*FitThemeFont, 30*FitThemeFont)];
        self.titleLab.backgroundColor = [UIColor clearColor];
        [self addSubview:self.titleLab];
        
        self.numLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.titleLab.frame), (height - 20*FitThemeFont)/2, 80*FitThemeFont, 20*FitThemeFont)];
        self.numLab.textColor = [UIColor lightGrayColor];
//        self.numLab.textColor = LineViewColor;
        self.numLab.font =ThemeFontSmall;
        [self addSubview:self.numLab];
        
        self.img = [[UIImageView alloc] initWithFrame:CGRectMake(width - 30*FitThemeFont, (height - 14*FitThemeFont)/2, 14*FitThemeFont, 14*FitThemeFont)];
        self.img.image = ThemeImage(@"enter_icon_02.png");
        [self addSubview:self.img];
        
        
        self.line = [[UIView alloc] initWithFrame:CGRectMake(10, height - 1, width - 20, 1)];
        self.line.backgroundColor = LineViewColor;//[UIColor colorWithRed:0.90f green:0.90f blue:0.90f alpha:1.00f];
        [self addSubview:self.line];
        
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
        [self addGestureRecognizer:tap];

    }
    return self;
}

- (void)tapClick{
    [self.delegate selectSectionView:_sectionTag Layer:_layerTag];
}

@end
