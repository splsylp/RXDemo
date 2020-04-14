//
//  KitBaseDialog.h
//  guodiantong
//
//  Created by yuxuanpeng on 14-10-16.
//  Copyright (c) 2014年 guodiantong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYTBaseDialog.h"
@protocol KitBaseDialogDelegate;

static NSInteger const kMaskViewTagValue = 99999;
static NSInteger const kDialogObjTagValue = 99990;

@interface KitBaseDialog : UIView

@property (assign, nonatomic) id<KitBaseDialogDelegate> delegate;

+ (id)presentModalDialogFromNibWidthDelegate:(id<KitBaseDialogDelegate>)delegate withPos:(TContentPosk)pos withTapAtBackground:(BOOL)tapStatus;
+ (id)presentModalDialogWithRect:(CGRect)rect  WidthDelegate:(id<KitBaseDialogDelegate>)delegate withPos:(TContentPosk)pos withTapAtBackground:(BOOL)tapStatus;

- (void)showModalDialogWithAnimation:(BOOL)animation withPos:(TContentPosk)pos withTapAtBackground:(BOOL)tapStatus;
- (void)dismissModalDialogWithAnimation:(BOOL)animation;

- (void)cancelTapGesture;
- (void)addTapGesture;
+ (void)removeSubviews;
@end

@protocol KitBaseDialogDelegate <NSObject>

@end
