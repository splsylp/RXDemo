//
//  YXPEmptyNoticeView.h
//  ECSDKDemo_OC
//
//  Created by ywj on 16/8/4.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "RXBaseView.h"
typedef NS_ENUM(NSInteger, KKEmptyNoticeViewAlignment){
    
    KKEmptyNoticeViewAlignment_Top = 1,//顶部对齐
    
    KKEmptyNoticeViewAlignment_Center = 2,//居中对齐
};

@interface YXPEmptyNoticeView : RXBaseView


+ (void)showInView:(UIView*)aView
         withImage:(UIImage*)aImage
              text:(NSString*)text
         alignment:(KKEmptyNoticeViewAlignment)alignment;

+ (void)hideForView:(UIView*)aView;
@end
@interface UITableView (UITableView_KKEmptyNoticeView)

- (void)showEmptyViewDefault;

- (void)showEmptyViewWithImage:(UIImage*)aImage
                          text:(NSString*)text
                     alignment:(KKEmptyNoticeViewAlignment)alignment
                       offsetY:(CGFloat)offsetY;

- (void)showEmptyViewWithImage:(UIImage*)aImage
                          text:(NSString*)text
                     alignment:(KKEmptyNoticeViewAlignment)alignment;

- (void)hideEmptyViewWithBackgroundColor:(UIColor*)aColor;

@end