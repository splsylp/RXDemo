//
//  ViewController.h
//  LocationDemo
//
//  Created by zhangmingfei on 2017/6/8.
//  Copyright © 2017年 com.ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECLocationPoint.h"
#import "BaseViewController.h"

@protocol NewLocationViewControllerDelegate <NSObject>

-(void)onSendUserLocation:(ECLocationPoint*)point;

@end

@interface NewLocationViewController : BaseViewController

@property (nonatomic, weak) id<NewLocationViewControllerDelegate> NewLocationDelegate;

@end

