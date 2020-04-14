//
//  ChatMoreActionBar.m
//  ECSDKDemo_OC
//
//  Created by zhouwh on 2016/12/26.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ChatMoreActionBar.h"
@interface ChatMoreActionBar()<UIActionSheetDelegate>

@end
@implementation ChatMoreActionBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createMoreActionBar];
    }
    return self;
}

- (void)createMoreActionBar {

    self.backgroundColor = [UIColor whiteColor];
    
    CGFloat BtnWidth = 25.0f;
    CGFloat BtnHeight = 25.0f;
    NSInteger BtnNum = 0;//按钮个数
    if (IsHengFengTarget) {
        BtnNum = 1;
    }else{
        BtnNum = 3;
    }
    CGFloat spaceWidth = (kScreenWidth - BtnWidth*BtnNum)/(BtnNum+1);
    CGFloat spaceHeight = (self.height - BtnHeight)/2;
    
//    self.forWardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.forWardBtn.frame = CGRectMake(spaceWidth, spaceHeight, BtnWidth, BtnHeight);
//    self.forWardBtn.tag = ChatMoreActionBarType_forword;
//    [self.forWardBtn setImage:ThemeImage(@"chatting_bottom_forward_icon") forState:UIControlStateNormal];
//    [self.forWardBtn setImage:ThemeImage(@"chatting_bottom_forward_icon_disable") forState:UIControlStateDisabled];
//    [self.forWardBtn addTarget:self action:@selector(actionBarClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:self.forWardBtn];
    
    self.forWardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.forWardBtn.frame = CGRectMake(spaceWidth, spaceHeight, BtnWidth, BtnHeight);
    self.forWardBtn.tag = ChatMoreActionBarType_forword_Multiple_Merge;//多条合并
//    self.forWardBtn.tag =ChatMoreActionBarType_forword;
    // chatting_bottom_forward_icon
    [self.forWardBtn setImage:ThemeImage(@"btn_forward_normal") forState:UIControlStateNormal];
    [self.forWardBtn setImage:ThemeImage(@"btn_forward_disable") forState:UIControlStateDisabled];
    [self.forWardBtn addTarget:self action:@selector(actionBarClick:) forControlEvents:UIControlEventTouchUpInside];
//     [self.forWardBtn addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.forWardBtn];
    
    //收藏
    self.collectionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.collectionBtn.frame = CGRectMake(self.forWardBtn.right + spaceWidth, spaceHeight, BtnWidth, BtnHeight);
    self.collectionBtn.tag = ChatMoreActionBarType_collection;
    //chatting_bottom_favorite_icon
    [self.collectionBtn setImage:ThemeImage(@"btn_collect_normal") forState:UIControlStateNormal];
    [self.collectionBtn setImage:ThemeImage(@"btn_collect_disable") forState:UIControlStateDisabled];
    [self.collectionBtn addTarget:self action:@selector(actionBarClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.collectionBtn];
    
    //删除
    self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.deleteBtn.frame = CGRectMake(self.collectionBtn.right + spaceWidth, spaceHeight, BtnWidth, BtnHeight);
    self.deleteBtn.tag = ChatMoreActionBarType_delete;
    //chatting_bottom_delete_icon
    [self.deleteBtn setImage:ThemeImage(@"btn_delete_normal") forState:UIControlStateNormal];
    [self.deleteBtn setImage:ThemeImage(@"btn_delete_disable") forState:UIControlStateDisabled];
    [self.deleteBtn addTarget:self action:@selector(actionBarClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.deleteBtn];
    
}

- (void)setDisabled:(BOOL)disabled {

    self.forWardBtn.enabled = disabled;
    self.collectionBtn.enabled = disabled;
    self.deleteBtn.enabled = disabled;
}

- (void)actionBarClick:(UIButton *)sender {

    if (self.delegate && [self.delegate respondsToSelector:@selector(ChatMoreActionBarClickWithType:)]) {
        [self.delegate ChatMoreActionBarClickWithType:sender.tag];
    }
}




@end
