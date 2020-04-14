//
//  GroupAddCollectionViewCell.h
//  ECSDKDemo_OC
//
//  Created by ywj on 16/4/16.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GroupAddCollectionViewCellDelegate <NSObject>

-(void)onChickAddMember;


@end

@interface GroupAddCollectionViewCell : UICollectionViewCell
@property (strong,nonatomic)UILabel *memberInfoLabel;
@property(nonatomic,assign)id<GroupAddCollectionViewCellDelegate>delegate;
@property (strong,nonatomic) UIButton *addMemberBtn;
@end
