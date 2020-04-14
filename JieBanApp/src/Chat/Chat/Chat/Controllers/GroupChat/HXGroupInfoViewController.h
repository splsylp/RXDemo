//
//  HXGroupInfoViewController.h
//  ECSDKDemo_OC
//
//  Created by ywj on 16/4/16.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "BaseViewController.h"

@protocol GroupInfoViewDelegate <NSObject>

- (void)groupInfoView:(UIViewController *)groupInfoView didSelectedIndexPath:(NSIndexPath *)indexpath;

@end

@interface HXGroupInfoViewController : BaseViewController
@property (nonatomic, strong) NSMutableArray *groupMembers;

@property (weak, nonatomic) id <GroupInfoViewDelegate> groupInfodelegate;
@property (strong, nonatomic) IBOutlet UITableViewCell *groupMemberCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *groupNameCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *groupSizeCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *groupADCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *groupNewMessNotiCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *groupClearMessCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *groupTopCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *groupExitCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *groupDeleteCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *groupRecordCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *groupNickNameCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *groupNickNameSwitchCell;
@property (weak, nonatomic) IBOutlet UIView *ADCellLineView;


@property (strong, nonatomic) IBOutlet UITableViewCell *GroupQRCodeCell;

- (IBAction)onChickExitGroup:(id)sender;

@end


