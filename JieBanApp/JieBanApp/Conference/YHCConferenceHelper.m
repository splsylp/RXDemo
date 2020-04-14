//
//  YHCConferenceHelper.m
//  ConferenceDemo
//
//  Created by 王文龙 on 2018/5/2.
//  Copyright © 2018年 wwl. All rights reserved.
//

#import "YHCConferenceHelper.h"
#import "RXBaseNavgationController.h"

@implementation YHCConferenceHelper
static YHCConferenceHelper *_sharedInstance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[super allocWithZone:NULL] init];
    });
    return _sharedInstance;
}

/**
 获取选择联系人页面
 */
-(UIViewController *)getChooseMembersVCWithExceptData:(YHCExceptData *)exceptData withType:(YHCSelectObjectType)type completion:(void(^)(NSArray *membersArr))completion{
    
    NSDictionary *dict =[NSDictionary dictionaryWithObjectsAndKeys:exceptData.confId,@"kitConferenceId",exceptData.exitMembers,@"members", nil];
    UIViewController *chooseMembersVC = [[AppModel sharedInstance] runModuleFunc:@"RXAddressBook" :@"getChooseMembersVCWithExceptData:WithType:" :@[dict,[NSNumber numberWithInteger:type]]];
    [AppModel sharedInstance].YHCcompletion = completion;
    RXBaseNavgationController *nav = [[RXBaseNavgationController alloc]initWithRootViewController:chooseMembersVC];
    if (chooseMembersVC) {
        return nav;
    }
    return nil;
}


@end
