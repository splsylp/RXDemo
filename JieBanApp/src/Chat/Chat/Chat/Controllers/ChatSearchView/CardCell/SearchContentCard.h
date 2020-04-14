//
//  SearchContentCard.h
//  Chat
//
//  Created by mac on 2017/4/19.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RXGroupHeadImageView.h"

@interface SearchContentCard : UITableViewCell

@property (nonatomic, strong) RXGroupHeadImageView * groupHeadView;
@property (nonatomic, strong, readonly) UIImageView *portraitImg;
@property (nonatomic, strong, readonly) UILabel *nameLabel;
@property (nonatomic, strong, readonly) UILabel *contentLabel;
@property (nonatomic, strong, readonly) UILabel *unReadLabel;
@property (nonatomic, strong, readonly) UILabel *dateLabel;
@property (nonatomic, strong, readonly) UILabel *atLabel;
@property(nonatomic,retain)ECSession* session;

@end
