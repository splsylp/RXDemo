//
//  RXCopyLabel.m
//  UserCenter
//
//  Created by 胡伟 on 2019/7/18.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import "RXCopyLabel.h"

@implementation RXCopyLabel

- (void)awakeFromNib {
    [super awakeFromNib];
    [self addLongPressGesture];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addLongPressGesture];
    }
    return self;
}

- (void)addLongPressGesture {
    self.userInteractionEnabled = YES;
    UILongPressGestureRecognizer * longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longAction:)];
    [self addGestureRecognizer:longGesture];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIMenuControllerWillHideMenuNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        self.backgroundColor = [UIColor clearColor];
    }];
}

- (void)longAction:(UILongPressGestureRecognizer *)sender{
    if (sender.state == UIGestureRecognizerStateBegan) {
    //一定要调用这个方法
    [self becomeFirstResponder];
    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    //创建菜单控制器
    UIMenuController * menuvc = [UIMenuController sharedMenuController];
    UIMenuItem * menuItem1 = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(firstItemAction:)];
        menuvc.menuItems = @[menuItem1];
        [menuvc setTargetRect:self.frame inView:self.superview];
        [menuvc setMenuVisible:YES animated:YES];
    }
}

- (void)firstItemAction:(UIMenuItem *)item {
    //通过系统的粘贴板，记录下需要传递的数据
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = self.text;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(firstItemAction:)) {
        return YES;
    }
    return [super canPerformAction:action withSender:sender];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
