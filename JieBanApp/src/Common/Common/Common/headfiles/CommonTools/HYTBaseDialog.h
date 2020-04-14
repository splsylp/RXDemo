//
//  HYTBaseDialog.h
//  HIYUNTON
//
//  Created by chaizhiyong on 14-10-16.
//  Copyright (c) 2014年 hiyunton.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HYTBaseDialogDelegate;

static NSInteger const KKMaskViewTagValue=9999;
static NSInteger const kKDialogObjTagValue = 99990;
typedef enum : NSUInteger {
    EContentPosTOPWithNaviK,
    EContentPosTOPk,
    EContentPosMIDk,
    EContentPosButtomk,
    EContentPosunconditionalK,
    
} TContentPosk;
@interface HYTBaseDialog : UIView

@property (weak, nonatomic) id<HYTBaseDialogDelegate> delegate;

+ (id)presentModalDialogFromNibWidthDelegate:(id<HYTBaseDialogDelegate>)delegate withPos:(TContentPosk)pos withTapAtBackground:(BOOL)tapStatus;
+ (id)presentModalDialogWithRect:(CGRect)rect  WidthDelegate:(id<HYTBaseDialogDelegate>)delegate withPos:(TContentPosk)pos withTapAtBackground:(BOOL)tapStatus;
+ (id)presentModalDialogWithRect:(CGRect)rect  WidthDelegate:(id<HYTBaseDialogDelegate>)delegate withPos:(TContentPosk)pos withTapAtBackground:(BOOL)tapStatus maskColor:(UIColor *)maskColor;
- (void)showModalDialogWithAnimation:(BOOL)animation withPos:(TContentPosk)pos withTapAtBackground:(BOOL)tapStatus;
- (void)dismissModalDialogWithAnimation:(BOOL)animation;

- (void)cancelTapGesture;
- (void)addTapGesture;
+ (void)removeSubviews;
@end

@protocol HYTBaseDialogDelegate <NSObject>

@end
