//
//  RXMenuDefaultView.h
//  RXMenuController
//
//  Created by GIKI on 2017/9/29.
//  Copyright © 2017年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RXMenuControllerHeader.h"
@class RXMenuItem, RXMenuViewContainer;
@interface RXMenuDefaultView : UIView
@property (nonatomic, strong) NSArray<RXMenuItem*>* menuItems;
@property (nonatomic, assign) CGSize  maxSize;
@property (nonatomic, assign) CGSize  arrowSize;
@property (nonatomic, assign) CGPoint anchorPoint;
@property (nonatomic, strong) UIColor  *menuTintColor;
@property (nonatomic, assign) RXMenuControllerArrowDirection  CorrectDirection;
+ (instancetype)defaultView:(RXMenuViewContainer*)container WithMenuItems:(NSArray<RXMenuItem*>*)menuItems MaxSize:(CGSize)maxSize arrowSize:(CGSize)arrowSize AnchorPoint:(CGPoint)anchorPoint;
- (void)processLineWithMidX:(CGFloat)midX direction:(RXMenuControllerArrowDirection)direction;
@end
