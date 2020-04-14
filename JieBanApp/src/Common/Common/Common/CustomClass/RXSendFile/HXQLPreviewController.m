//
//  HXQLPreviewController.m
//  ECSDKDemo_OC
//
//  Created by yuxuanpeng on 2017/4/23.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "HXQLPreviewController.h"
@interface HXQLPreviewController ()<UIGestureRecognizerDelegate>
@end

@implementation HXQLPreviewController


- (void)viewDidLoad {
    [super viewDidLoad];
   
    // Do any additional setup after loading the view.
}


- (BOOL)canShowToolbar {
    return NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
