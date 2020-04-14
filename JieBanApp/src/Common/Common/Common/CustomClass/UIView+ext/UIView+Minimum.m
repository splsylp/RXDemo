//
//  UIView+Minimum.m
//  NewVoiceMeeting
//
//  Created by 王明哲 on 2016/12/13.
//  Copyright © 2016年 maibou. All rights reserved.
//

#import "UIView+Minimum.h"

@implementation UIView (Minimum)

- (void)panTheView:(UIGestureRecognizer *)p width:(CGFloat)width height:(CGFloat)height {
    CGPoint panPoint = [p locationInView:[[UIApplication sharedApplication] keyWindow]];
    
    if(p.state == UIGestureRecognizerStateChanged) {
        self.center = CGPointMake(panPoint.x, panPoint.y);
        
    }else if(p.state == UIGestureRecognizerStateEnded) {
        if(panPoint.x <= kScreenWidth/2) {
            
            if(panPoint.y <= 40*fitScreenWidth+height/2 && panPoint.x >= 20*fitScreenWidth+width/2) {
                [UIView animateWithDuration:0.15f animations:^{
                    self.center = CGPointMake(panPoint.x, height/2+25*fitScreenWidth);
                }];
                
            }else if(panPoint.y >= kScreenHeight-height/2-40*fitScreenWidth && panPoint.x >= 20*fitScreenWidth+width/2) {
                [UIView animateWithDuration:0.15f animations:^{
                    self.center = CGPointMake(panPoint.x, kScreenHeight-height/2-25*fitScreenWidth);
                }];
                
            }else if (panPoint.x < width/2+15*fitScreenWidth && panPoint.y > kScreenHeight-height/2) {
                [UIView animateWithDuration:0.15f animations:^{
                    self.center = CGPointMake(width/2+25*fitScreenWidth, kScreenHeight-height/2-25*fitScreenWidth);
                }];
                
            }else {
                CGFloat pointy = panPoint.y < height/2 ? height/2 :panPoint.y;
                [UIView animateWithDuration:0.15f animations:^{
                    self.center = CGPointMake(width/2+25*fitScreenWidth, pointy);
                }];
            }
        }else if(panPoint.x > kScreenWidth/2) {
            if(panPoint.y <= 40*fitScreenWidth+height/2 && panPoint.x < kScreenWidth-width/2-20*fitScreenWidth ) {
                [UIView animateWithDuration:0.15f animations:^{
                    self.center = CGPointMake(panPoint.x, height/2 + 25*fitScreenWidth);
                }];
                
            }else if(panPoint.y >= kScreenHeight-40*fitScreenWidth-height/2 && panPoint.x < kScreenWidth-width/2-20*fitScreenWidth) {
                [UIView animateWithDuration:0.15f animations:^{
                    self.center = CGPointMake(panPoint.x, kScreenHeight-height/2 - 25*fitScreenWidth);
                }];
                
            }else if (panPoint.x > kScreenWidth-width/2 - 15*fitScreenWidth && panPoint.y < height/2) {
                [UIView animateWithDuration:0.15f animations:^{
                    self.center = CGPointMake(kScreenWidth-width/2 - 25*fitScreenWidth, height/2 + 25*fitScreenWidth);
                }];
                
            }else {
                CGFloat pointy = panPoint.y > kScreenHeight-height/2 ? kScreenHeight-height/2 :panPoint.y;
                [UIView animateWithDuration:0.15f animations:^{
                    self.center = CGPointMake(kScreenWidth-width/2 - 25*fitScreenWidth, pointy);
                }];
            }
        }
    }
}

@end
