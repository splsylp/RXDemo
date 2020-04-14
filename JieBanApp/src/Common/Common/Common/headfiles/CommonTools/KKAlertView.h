//
//  KKAlertView.h
//  CEDongLi
//
//  Created by beartech on 15/11/1.
//  Copyright (c) 2015年 KeKeStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KKAlertViewDelegate;

@interface KKAlertView : UIWindow

@property (nonatomic,retain)NSDictionary *information;

- (instancetype)initWithTitle:(NSString *)title subTitle:(NSString*)subTitle message:(NSString *)message delegate:(id /*<KKAlertViewDelegate>*/)delegate buttonTitles:(NSString *)buttonTitles, ... ;

- (void)show;


/**
 重载会重新布局titleLabel , subTitleLabel ,messageTextView,同时所有的button将会被移除，并重新添置新的。
 所以，如果要设置button的样式，请在reload之后设置button样式
 */
- (void)reload;

- (UIButton*)buttonAtIndex:(NSInteger)aIndex;

- (UILabel*)titleLabel;

- (UILabel*)subTitleLabel;

- (UITextView*)messageTextView;

@end



@protocol KKAlertViewDelegate <NSObject>
@optional

- (void)KKAlertView_backgroundClicked:(KKAlertView*)aAlertView;

- (void)KKAlertView:(KKAlertView*)aAlertView didDismissWithButtonIndex:(NSInteger)buttonIndex;

@end
