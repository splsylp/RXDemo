//
//  CanNotOpenDocumentView.h
//  ECSDKDemo_OC
//
//  Created by ywj on 16/8/2.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CanNotOpenDocumentView : UIView<UIDocumentInteractionControllerDelegate>
//@property (nonatomic,strong)ECMessage *message;
- (instancetype)initWithFrame:(CGRect)frame fileMessage:(ECMessage *)message;
@end
