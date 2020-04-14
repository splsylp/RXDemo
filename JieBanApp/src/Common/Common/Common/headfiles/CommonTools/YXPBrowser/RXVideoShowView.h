//
//  RXVideoShowView.h
//  FriendsCircle
//
//  Created by 魏继源 on 17/4/13.
//  Copyright © 2017年 maibou. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^FinshEvaluateBlock)();

@interface RXVideoShowView : UIView

@property (nonatomic,strong)NSURL *url;
@property(nonatomic,assign)BOOL isExitVideo;
@property(nonatomic,assign)CGRect rect;

@property (copy, nonatomic) FinshEvaluateBlock finisBlock;

-(instancetype)initWithFrame:(CGRect)frame withUrl:(NSURL *)url;

@end
