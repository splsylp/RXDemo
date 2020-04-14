//
//  HYTCommonDialog.h
//  HIYUNTON
//
//  Created by yuxuanpeng on 14-10-22.
//  Copyright (c) 2014年 hiyunton.com. All rights reserved.
//

#import "KitBaseDialog.h"

typedef void(^SelectedBlock)(NSInteger index);

@interface RXCommonDialog : KitBaseDialog

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@property (nonatomic, copy) void (^selectButtonAtIndex)(NSInteger index); //点击事件

///如果不传subTile 就不显示   不传cancleStr cancle按钮就不显示
- (void)showTitle:(NSString *)title subTitle:(NSString *)subTitle ensureStr:(NSString *)ensureStr cancalStr:(NSString *)cancleStr selected:(SelectedBlock)selected;
@end
