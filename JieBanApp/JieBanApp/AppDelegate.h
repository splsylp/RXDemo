//
//  AppDelegate.h
//  JieBanApp
//
//  Created by Tony on 2020/4/8.
//  Copyright © 2020 Tony. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (UIViewController *)getRootViewController;

@end

