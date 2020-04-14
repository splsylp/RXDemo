//
//  ShowDocumentImageView.h
//  ECSDKDemo_OC
//
//  Created by ywj on 16/8/2.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ShowDocumentImageView;

@protocol ShowDocumentImageViewDelegate <NSObject>

//- (void)ShowDocumentImageViewSingleTap:(ShowDocumentImageView*)itemView;

- (void)ShowDocumentImageViewLongPressed:(ShowDocumentImageView*)itemView;

@end

@interface ShowDocumentImageView : UIView<UIGestureRecognizerDelegate,UIScrollViewDelegate>

@property (nonatomic,strong)FLAnimatedImageView *myImageView;
@property (nonatomic,strong)UIScrollView *myScrollView;

@property (nonatomic,strong)ECMessage *message;

@property (nonatomic,assign)id<ShowDocumentImageViewDelegate>delegate;

/**
 * message 文档的信息
 */
- (instancetype)initWithFrame:(CGRect)frame
                  fileMessage:(ECMessage *)message;

@end

