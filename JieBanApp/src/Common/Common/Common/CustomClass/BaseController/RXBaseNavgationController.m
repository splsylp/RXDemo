//
//  RXBaseNavgationController.m
//  BaseComponent
//
//  Created by keven on 2018/9/19.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "RXBaseNavgationController.h"
#import "RXThirdPart.h"
#import "UIBarButtonItem+RXAdd.h"

@interface RXBaseNavgationController ()<UINavigationControllerDelegate>

@property(nonatomic ,strong) id popDelegate;

@end

@implementation RXBaseNavgationController

- (void)viewDidLoad {
    [super viewDidLoad];
    //滑动返回
    _popDelegate = self.interactivePopGestureRecognizer.delegate;
    self.delegate = self;
}

//写这个方法目的：能够拦截所有push进来的控制器viewController
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.viewControllers.count > 0) {//这时push的是子控制器（不是根控制器）
        viewController.hidesBottomBarWhenPushed = YES;//隐藏tabbar
//        dispatch_queue_t addNewMsgQueue = dispatch_queue_create("RXbasenvc", NULL);
//        dispatch_async(addNewMsgQueue, ^{
//            UIImage *image = KKThemeImage(@"title_bar_back");
//            dispatch_async(dispatch_get_main_queue(), ^{
//                 viewController.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(back) image:image];
//            });
//        });
        viewController.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(back) image:ThemeColorImage(KKThemeImage(@"title_bar_back"), [UIColor blackColor])];
        
//        viewController.hidesBottomBarWhenPushed = YES;
//        CATransition *animation = [CATransition animation];
//        animation.duration = 0.3f;
//        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//        animation.type = kCATransitionPush;
//        animation.subtype = kCATransitionFromRight;
//        [self.navigationController.view.layer addAnimation:animation forKey:nil];
//        [super pushViewController:viewController animated:NO];
//        return;
    }
    [super pushViewController:viewController animated:animated];
}


- (void)back {
    // 因为self本来就是一个导航控制器，self.navigationController这里是nil的
    [self popViewControllerAnimated:YES];
}
//滑动返回
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (viewController == [self.viewControllers firstObject]) {
        self.interactivePopGestureRecognizer.delegate = _popDelegate;
    }else{
        self.interactivePopGestureRecognizer.delegate = nil;
    }
}
@end
