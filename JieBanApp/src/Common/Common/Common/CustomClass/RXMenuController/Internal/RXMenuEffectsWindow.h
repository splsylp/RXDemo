//
//  RXMenuEffectsWindow.h
//  RXMenuController
//
//  Created by GIKI on 2017/9/27.
//  Copyright © 2017年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RXMenuViewContainer;
@interface RXMenuEffectsWindow : UIWindow

@property(nonatomic,getter = isMenuVisible) BOOL menuVisible;        // default is NO

+ (instancetype)sharedWindow;

- (void)showMenu:(RXMenuViewContainer *)menu animation:(BOOL)animation;

- (void)hideMenu:(RXMenuViewContainer *)menu;

@end
    
