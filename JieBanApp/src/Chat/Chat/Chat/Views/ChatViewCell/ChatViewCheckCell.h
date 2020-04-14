//
//  ChatViewCheckCell.h
//  ECSDKDemo_OC
//
//  Created by yuxuanpeng on 16/2/3.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ChatViewCell.h"
extern NSString *const KResponderCustomChatViewTextCheckCellBubbleViewEvent;

@interface ChatViewCheckCell : ChatViewCell
{
    UILabel * labelCheck;//审批
    UILabel * labelPrompt;//提示
    UILabel * labelAPRVTitle;//标题
    UILabel * labelAPRV_End;//截止时间提示
    UILabel * labelLine;//间隔线
    UILabel *_labelAPRV_Src;//标题事件
    UILabel *_label;
    UIView * shView;//总事件View
    UILabel *timeLable;//时间
    UIImageView * spimage;//审批图片1
    UIImageView * checkImage;//审批图片2
    UIImageView *arrowheadImg;//箭头
}
@property (nonatomic, strong)NSDataDetector *detector;
@property (nonatomic, strong) NSArray *urlMatches;
@end
