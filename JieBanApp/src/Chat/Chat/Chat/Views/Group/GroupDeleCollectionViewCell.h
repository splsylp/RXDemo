//
//  GroupDeleCollectionViewCell.h
//  ECSDKDemo_OC
//
//  Created by ywj on 16/4/16.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol GroupDeleCollectionViewCellDelegate <NSObject>

-(void)onChickDeleteMember;


@end
@interface GroupDeleCollectionViewCell : UICollectionViewCell
@property (strong,nonatomic)  UIButton *deleteMemberBtn;
@property (strong,nonatomic) UILabel *deleteLabel;
@property(nonatomic,assign)id<GroupDeleCollectionViewCellDelegate>delegate;
@end
