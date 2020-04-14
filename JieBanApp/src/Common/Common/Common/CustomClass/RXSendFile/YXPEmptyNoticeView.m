//
//  YXPEmptyNoticeView.m
//  ECSDKDemo_OC
//
//  Created by ywj on 16/8/4.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "YXPEmptyNoticeView.h"

@implementation YXPEmptyNoticeView

+ (void)showInView:(UIView*)aView
         withImage:(UIImage*)aImage
              text:(NSString*)text
         alignment:(KKEmptyNoticeViewAlignment)alignment{
    
    [YXPEmptyNoticeView hideForView:aView];
    
    YXPEmptyNoticeView *subView = [[YXPEmptyNoticeView alloc] initWithSuperView:aView withImage:aImage text:text alignment:alignment];
    subView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [aView addSubview:subView];
    [aView bringSubviewToFront:subView];
    
}

+ (void)hideForView:(UIView*)aView{
    for (UIView *subView in [aView subviews]) {
        if ([subView isKindOfClass:[YXPEmptyNoticeView class]]) {
            [subView removeFromSuperview];
        }
    }
}

- (instancetype)initWithSuperView:(UIView*)aView
                        withImage:(UIImage*)aImage
                             text:(NSString*)text
                        alignment:(KKEmptyNoticeViewAlignment)alignment{
    self = [super init];
    if (self) {
        self.frame = aView.bounds;
        
        CGSize imageSize = aImage.size;
        
        CGSize textSize = [[Common sharedInstance] widthForContent:text withSize:CGSizeMake(self.width - 30, CGFLOAT_MAX) withLableFont:12];
        
        if (alignment == KKEmptyNoticeViewAlignment_Top) {
            CGFloat Y = 0;
            Y = Y + 15;
            if (aImage) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width-imageSize.width)/2.0, 15, imageSize.width, imageSize.height)];
                imageView.image = aImage;
                imageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
                [self addSubview:imageView];
                Y = Y + imageSize.height;
                
                Y = Y + 10;
            }
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, Y, self.bounds.size.width-30, textSize.height)];
            label.text = text;
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 0;
            label.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
            label.textColor = [UIColor colorWithRed:0.76f green:0.76f blue:0.76f alpha:1.00f];
            label.font =ThemeFontSmall;
            [self addSubview:label];
        }else if (alignment == KKEmptyNoticeViewAlignment_Center) {
            CGFloat Y = (self.bounds.size.height -imageSize.height - 10 - textSize.height)/2.0;
            if (aImage) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width-imageSize.width)/2.0, Y, imageSize.width, imageSize.height)];
                imageView.image = aImage;
                imageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
                [self addSubview:imageView];
                Y = Y + imageSize.height;
            }
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, Y+10, self.bounds.size.width-30, textSize.height)];
            label.text = text;
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 0;
            label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            label.textColor = [UIColor colorWithRed:0.76f green:0.76f blue:0.76f alpha:1.00f];
            label.font =ThemeFontSmall;
            [self addSubview:label];
        }else{
        }
    }
    return self;
}

@end


#pragma ==================================================
#pragma == UITableView_KKEmptyNoticeView
#pragma ==================================================
@implementation UITableView (UITableView_KKEmptyNoticeView)

- (void)showEmptyViewDefault{
    [self showEmptyViewWithImage:KKThemeImage(@"ico_EmptyData") text:languageStringWithKey(@"暂无数据") alignment:KKEmptyNoticeViewAlignment_Center offsetY:0];
}

- (void)showEmptyViewWithImage:(UIImage*)aImage
                          text:(NSString*)text
                     alignment:(KKEmptyNoticeViewAlignment)alignment
                       offsetY:(CGFloat)offsetY{
    
    UIView *fullView = [[UIView alloc] initWithFrame:self.bounds];
    fullView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    fullView.backgroundColor=[UIColor clearColor];
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, fullView.frame.size.width, fullView.frame.size.height-offsetY)];
    backgroundView.backgroundColor=[UIColor clearColor];
    [fullView addSubview:backgroundView];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [YXPEmptyNoticeView showInView:backgroundView withImage:aImage text:text alignment:alignment];
    
    self.backgroundView = fullView;
    
    self.hidden = NO;
    [self reloadData];
}

- (void)showEmptyViewWithImage:(UIImage*)aImage
                          text:(NSString*)text
                     alignment:(KKEmptyNoticeViewAlignment)alignment{
    [self showEmptyViewWithImage:aImage text:text alignment:alignment offsetY:0];
}

- (void)hideEmptyViewWithBackgroundColor:(UIColor*)aColor{
    if (aColor) {
        UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        backgroundView.backgroundColor = aColor;
        self.backgroundView = backgroundView;
    }
    else{
        self.backgroundView = nil;
    }
}

@end

