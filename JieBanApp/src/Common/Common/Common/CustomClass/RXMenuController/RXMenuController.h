//
//  RXMenuController.h
//  RXMenuController
//
//  Created by GIKI on 2017/9/27.
//  Copyright © 2017年 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RXMenuControllerHeader.h"
@class RXMenuViewContainer;

NS_ASSUME_NONNULL_BEGIN


@class RXMenuItem, RXMenuViewContainer;

@interface RXMenuController : NSObject

+ (RXMenuController *)sharedMenuController;

@property(nonatomic,getter = isMenuVisible) BOOL menuVisible;        // default is NO

@property(nonatomic) RXMenuControllerArrowDirection arrowDirection ; // default is GMenuControllerArrowDefault

@property(nullable, nonatomic,copy) NSArray<RXMenuItem *> *menuItems; // default is nil. these are in addition to the standard items

- (void)setMenuVisible:(BOOL)menuVisible animated:(BOOL)animated;

- (void)setTargetRect:(CGRect)targetRect inView:(UIView *)targetView;

- (void)update;

- (void)reset; /// reset menuViewContrainer configs 

@property(nonatomic,readonly) CGRect menuFrame;

@property(nonatomic,readonly) RXMenuViewContainer * menuViewContainer;

@end

NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN

@interface RXMenuItem : NSObject

- (instancetype)initWithTitle:(NSString *)title target:(id)target action:(SEL)action;
- (instancetype)initWithTitle:(NSString *)title image:(UIImage*)image target:(id)target action:(SEL)action;
@property (nonatomic, copy)     NSString *title;
@property (nonatomic, strong)   UIImage * image;
@property (nonatomic, strong)   id target;
@property (nonatomic) SEL       action;

@end
NS_ASSUME_NONNULL_END
