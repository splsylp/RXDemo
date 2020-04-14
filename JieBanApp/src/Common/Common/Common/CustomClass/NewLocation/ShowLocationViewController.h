//
//  ShowLocationViewController.h
//  Chat
//
//  Created by zhangmingfei on 2017/6/23.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECLocationPoint.h"
#import "BaseViewController.h"
@interface ShowLocationViewController : BaseViewController
- (instancetype)initWithLocationPoint:(ECLocationPoint*)locationPoint;
@end
