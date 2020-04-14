//
//  HXSelectCacheDocumentBar.m
//  ECSDKDemo_OC
//
//  Created by ywj on 16/8/4.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "HXSelectCacheDocumentBar.h"

#define showCount  3


@implementation HXSelectCacheDocumentBar

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        [self initUI];
    }
    return self;
}
/**
 初始化 界面元素
 */

-(void)initUI
{
    _selectwidth =kScreenWidth/showCount;
    
    _fileBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _selectwidth, self.frame.size.height)];
    _fileBtn.tag = 1101;
    _fileBtn.backgroundColor =[UIColor clearColor];
    [_fileBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchDown];
    [_fileBtn setTitle:languageStringWithKey(@"文档") forState:UIControlStateNormal];
    [_fileBtn setTitleColor:MainTheme_GreenColor forState:UIControlStateSelected];
    [_fileBtn setTitleColor:MainTheme_TextGrayColor forState:UIControlStateNormal];
    _fileBtn.titleLabel.font = ThemeFontMiddle;
    [self addSubview:_fileBtn];
    _fileBtn.exclusiveTouch = YES; // 关闭多点
    
    _imgFileBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_fileBtn.frame), 0, _selectwidth, self.frame.size.height)];
    _imgFileBtn.backgroundColor=[UIColor clearColor];
    _imgFileBtn.tag = 1102;
    [_imgFileBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchDown];
    [_imgFileBtn setTitle:languageStringWithKey(@"图片") forState:UIControlStateNormal];
    [_imgFileBtn setTitleColor:MainTheme_GreenColor forState:UIControlStateSelected];
    [_imgFileBtn setTitleColor:MainTheme_TextGrayColor forState:UIControlStateNormal];
    _imgFileBtn.titleLabel.font = ThemeFontMiddle;
    [self addSubview:_imgFileBtn];
    _imgFileBtn.exclusiveTouch = YES; // 关闭多点
    
    _otherBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_imgFileBtn.frame), 0, _selectwidth, self.frame.size.height)];
    _otherBtn.backgroundColor=[UIColor clearColor];
    _otherBtn.tag = 1103;
    [_otherBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchDown];
    [_otherBtn setTitle:languageStringWithKey(@"其他") forState:UIControlStateNormal];
    [_otherBtn setTitleColor:MainTheme_GreenColor forState:UIControlStateSelected];
    [_otherBtn setTitleColor:MainTheme_TextGrayColor forState:UIControlStateNormal];
    _otherBtn.titleLabel.font = ThemeFontMiddle;
    [self addSubview:_otherBtn];
    _otherBtn.exclusiveTouch = YES; // 关闭多点
    
    
    
    UIView *footlineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1)];
    footlineView.backgroundColor = MainTheme_CellLineColor;
    [self addSubview:footlineView];
    
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-1, _selectwidth, 1)];
    _lineView.backgroundColor = MainTheme_GreenColor;
    [self addSubview:_lineView];
    
    _fileBtn.selected = YES;
    _imgFileBtn.selected = NO;
    _otherBtn.selected = NO;
}

- (void)buttonClicked:(UIButton*)aButton{
    [self selectIndex:aButton.tag-1101 needDelegate:YES];
}

- (void)selectIndex:(NSInteger)aIndex needDelegate:(BOOL)aNeedDelegate{
    
    _fileBtn.selected = NO;
    _imgFileBtn.selected = NO;
    _otherBtn.selected = NO;
    
    [UIView animateWithDuration:0.25 animations:^{
        _lineView.frame = CGRectMake(_selectwidth*aIndex, self.frame.size.height-1, _selectwidth, 1);
    }];
    
    _selectIndex = aIndex;
    
    UIButton *button = (UIButton*)[self viewWithTag:1101+aIndex];
    button.selected = YES;
    
    
    if (aNeedDelegate && self.delegate && [self.delegate respondsToSelector:@selector(SelectCacheDocumentBar:selectedIndex:)]) {
        [self.delegate SelectCacheDocumentBar:self selectedIndex:aIndex];
    }
}

@end
