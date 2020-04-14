//
//  RXMenuController.m
//  RXMenuController
//
//  Created by GIKI on 2017/9/27.
//  Copyright © 2017年 GIKI. All rights reserved.
//

#import "RXMenuController.h"
#import "RXMenuEffectsWindow.h"
#import "RXMenuViewContainer.h"
NSNotificationName  const RXMenuControllerWillShowMenuNotification = @"RXMenuControllerWillShowMenuNotification_private";
NSNotificationName  const RXMenuControllerDidShowMenuNotification= @"RXMenuControllerDidShowMenuNotification_private";
NSNotificationName  const RXMenuControllerWillHideMenuNotification= @"RXMenuControllerWillHideMenuNotification_private";
NSNotificationName  const RXMenuControllerDidHideMenuNotification= @"RXMenuControllerDidHideMenuNotification_private";
NSNotificationName  const RXMenuControllerMenuFrameDidChangeNotification= @"RXMenuControllerMenuFrameDidChangeNotification_private";

@interface RXMenuController()

@property (nonatomic, strong,readwrite) RXMenuViewContainer * menuViewContainer;
@property (nonatomic, weak) UIView * targetView;

@end

@implementation RXMenuController

#pragma mark - init

- (instancetype)init {
    self = [super init];
    if (self) {

    }
    return self;
}

#pragma mark - public Method

+ (RXMenuController *)sharedMenuController {
    static RXMenuController *inst = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inst = [RXMenuController new];
    });
    return inst;
}

- (BOOL)isMenuVisible {
    return [RXMenuEffectsWindow sharedWindow].isMenuVisible;
}

- (void)setMenuVisible:(BOOL)menuVisible {
    [self setMenuVisible:menuVisible animated:YES];
}

- (void)setMenuVisible:(BOOL)menuVisible animated:(BOOL)animated {
    if (menuVisible) {
        [[NSNotificationCenter defaultCenter] postNotificationName:RXMenuControllerWillShowMenuNotification object:nil];
        [self showMenuWithAnimated:animated];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:RXMenuControllerWillHideMenuNotification object:nil];
        [[RXMenuEffectsWindow sharedWindow] hideMenu:self.menuViewContainer];
    }
}

- (void)showMenuWithAnimated:(BOOL)animated {
   [[RXMenuEffectsWindow sharedWindow] showMenu:self.menuViewContainer animation:YES];
}

- (void)setTargetRect:(CGRect)targetRect inView:(UIView *)targetView {
    if (!self.menuViewContainer) return;
    self.targetView = targetView;
    [self.menuViewContainer setTargetRect:targetRect inView:targetView];
}

- (void)setMenuItems:(NSArray<RXMenuItem *> *)menuItems {
    _menuItems = menuItems;
    self.menuViewContainer.menuItems = menuItems;
}

- (void)update {
    [self.menuViewContainer processMenuFrame];
}

- (void)reset {
    [self.menuViewContainer initConfigs];
}

- (CGRect)menuFrame {
    return self.menuViewContainer ? self.menuViewContainer.frame :CGRectZero;
}

- (void)setArrowDirection:(RXMenuControllerArrowDirection)arrowDirection {
    _arrowDirection = arrowDirection;
    self.menuViewContainer.arrowDirection = arrowDirection;
}

- (RXMenuViewContainer *)menuViewContainer {
    if (!_menuViewContainer) {
        _menuViewContainer = [RXMenuViewContainer new];
    }
    return _menuViewContainer;
}
@end

@implementation RXMenuItem

- (instancetype)initWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    self = [super init];
    if (self) {
        self.title = title;
        self.target = target;
        self.action = action;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title image:(UIImage*)image target:(id)target action:(SEL)action {
    self = [super init];
    if (self) {
        self.title = title;
        self.target = target;
        self.action = action;
        self.image = image;
    }
    return self;
}

@end
