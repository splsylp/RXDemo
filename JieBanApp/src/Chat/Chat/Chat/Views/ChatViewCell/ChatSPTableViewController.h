//
//  ChatSPTableViewController.h
//  ECSDKDemo_OC
//
//  Created by lrn on 15/11/2.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "ChatViewCell.h"
#import "ChatViewCheckCell.h"

@interface ChatSPTableViewController : ChatViewCell
//获取特别的消息类型 需要自定义方法
+(CGFloat)getSpecialHightOfCellViewWith:(ECMessage *)message;

@end
