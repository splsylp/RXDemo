//
//  Common.h
//  Common
//
//  Created by wangming on 16/7/26.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KitBaseHeader.h"

@interface Common : NSObject
@property(nonatomic,weak) id<ComponentDelegate> componentDelegate;//代理

+ (Common *)sharedInstance;
@end
