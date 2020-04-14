//
//  HXMPMovieController.m
//  ECSDKDemo_OC
//
//  Created by ywj on 16/9/3.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "HXMPMovieController.h"

@implementation HXMPMovieController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}
- (void)orientChange:(NSNotification *)noti {
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        switch (orientation)
        {
            case UIDeviceOrientationPortrait: {
                [UIView animateWithDuration:0.25 animations:^{
                    self.view.transform = CGAffineTransformMakeRotation(0);
                    self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
                }];
            }
                break;
            case UIDeviceOrientationLandscapeLeft: {
                [UIView animateWithDuration:0.25 animations:^{
                    self.view.transform = CGAffineTransformMakeRotation(M_PI*0.5);
                    self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
                }];
            }
                break;
            case UIDeviceOrientationLandscapeRight: {
                [UIView animateWithDuration:0.25 animations:^{
                    self.view.transform = CGAffineTransformMakeRotation(-M_PI*0.5);
                    self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
                }];
            }
                break;
            default:
                break;
        }
    }

-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

@end
