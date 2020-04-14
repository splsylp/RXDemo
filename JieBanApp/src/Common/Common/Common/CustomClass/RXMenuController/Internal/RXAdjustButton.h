//
//  RXAdjustButton.h
//  RXMenuController
//
//  Created by GIKI on 2017/10/19.
//  Copyright © 2017年 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RXAdjustButtonIMGPosition) {
    RXAdjustButtonIMGPositionLeft = 0, //Default
    RXAdjustButtonIMGPositionRight,
    RXAdjustButtonIMGPositionTop,
    RXAdjustButtonIMGPositionBottom,
};

@interface RXAdjustButton : UIButton

@property (nonatomic, assign) RXAdjustButtonIMGPosition  imagePosition;

@end
