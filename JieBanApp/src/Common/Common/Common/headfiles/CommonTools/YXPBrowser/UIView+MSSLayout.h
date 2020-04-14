//
//  UIView+MSSLayout.h
//  MSSBrowse
//
//  Created by YXP on 15/12/5.
//  Copyright © 2015年 YXP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MSSLayout)

- (CGFloat)mssLeft;
- (CGFloat)mssRight;
- (CGFloat)mssBottom;
- (CGFloat)mssTop;
- (CGFloat)mssHeight;
- (CGFloat)mssWidth;

- (void)setMssX:(CGFloat)mssX;
- (void)setMssY:(CGFloat)mssY;
- (void)setMssWidth:(CGFloat)mssWidth;
- (void)setMssHeight:(CGFloat)mssHeight;

- (void)mss_setFrameInSuperViewCenterWithSize:(CGSize)size;

@end
