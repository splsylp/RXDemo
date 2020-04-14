//
//  CoreModel+Conference.m
//  CoreModel
//
//  Created by zhouwh on 2017/12/18.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "CoreModel+Conference.h"
#import "CocoaLumberjack.h"
//#import "YHCUserInfo.h"
@implementation CoreModel (Conference)
/**
 @brief 获取应用下的总的会议设置信息
 @param completion 执行结果回调block
 */
- (void)getConferenceAppSetting:(void(^)(ECError* error, ECConferenceAppSettingInfo *appSettingfo))completion {
    [[ECDevice sharedInstance].conferenceManager getConferenceAppSetting:^(ECError *error, ECConferenceAppSettingInfo *appSettingfo) {
        DDLogInfo(@"errorCode=%d,des=%@",(int)error.errorCode,error.errorDescription);
        if (completion) {
            completion(error,appSettingfo);
        }
    }];
}

/**
 @brief 获取用户会议室ID
 @param completion 执行结果回调block
 */
- (void)getConfroomIdListWithAccount:(ECAccountInfo *)member confId:(NSString *)confId completion:(void(^)(ECError* error, NSArray *arr))completion {
    DDLogInfo(@"getConfroomIdListWithAccount account=%@,phoneNum=%@,username=%@,confId=%@",member.accountId,member.phoneNumber,member.userName,confId);
    [[ECDevice sharedInstance].conferenceManager getConfroomIdListWithAccount:member confId:confId completion:^(ECError *error, NSArray *arr) {
        DDLogInfo(@"getConfroomIdListWithAccount errorCode=%d,des=%@,arr=%@",(int)error.errorCode,error.errorDescription,arr);
        if (completion) {
            completion(error,arr);
        }
    }];
}


/**
 @brief 创建会议
 @param conferenceInfo 会议类
 @param completion 执行结果回调block
 */
- (void)createConference:(ECConferenceInfo*)conferenceInfo completion:(void(^)(ECError* error, ECConferenceInfo*conferenceInfo))completion {
DDLogInfo(@"createConference confName=%@,confId=%@,confType=%d,creator=%@,phoneNum=%@,creatorName=%@",conferenceInfo.confName,conferenceInfo.conferenceId,(int)conferenceInfo.confType,conferenceInfo.creator.accountId,conferenceInfo.creator.phoneNumber,conferenceInfo.creator.userName);
    [[ECDevice sharedInstance].conferenceManager createConference:conferenceInfo completion:^(ECError *error, ECConferenceInfo *conferenceInfo) {
        DDLogInfo(@"createConference errorCode=%d,des=%@,confId=%@",(int)error.errorCode,error.errorDescription,conferenceInfo.conferenceId);
        if (completion) {
            completion(error,conferenceInfo);
        }
    }];
}

/**
 @brief 删除会议
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)deleteConference:(NSString*)confId completion:(void(^)(ECError* error))completion {
    DDLogInfo(@"confId=%@",confId);
    [[ECDevice sharedInstance].conferenceManager deleteConference:confId completion:^(ECError *error) {
        DDLogInfo(@"errorCode=%d,des=%@",(int)error.errorCode,error.errorDescription);
        if (completion) {
            completion(error);
        }
    }];
}

/**
 @brief 更新会议信息
 @param conferenceInfo 会议类
 @param completion 执行结果回调block
 */
- (void)updateConference:(ECConferenceInfo*)conferenceInfo completion:(void(^)(ECError* error))completion {
    DDLogInfo(@"confId=%@,account=%@",conferenceInfo.conferenceId,conferenceInfo.creator.accountId);
    [[ECDevice sharedInstance].conferenceManager updateConference:conferenceInfo completion:^(ECError *error) {
        DDLogInfo(@"errorCode=%d,des=%@",(int)error.errorCode,error.errorDescription);
        if (completion) {
            completion(error);
        }
    }];
}

/**
 @brief 获取会议信息
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)getConference:(NSString*)confId completion:(void(^)(ECError* error, ECConferenceInfo*conferenceInfo))completion {
    DDLogInfo(@"getConferenceconfId=%@",confId);
    [[ECDevice sharedInstance].conferenceManager getConference:confId completion:^(ECError *error, ECConferenceInfo *conferenceInfo) {
        DDLogInfo(@"getConference errorCode=%d,des=%@",(int)error.errorCode,error.errorDescription);
        if (completion) {
            completion(error,conferenceInfo);
        }
    }];
}

/**
 @brief 获取会议列表
 @param condition 筛选条件
 @param page 分页信息
 @param completion 执行结果回调block
 */
- (void)getConferenceListWithCondition:(ECConferenceCondition*)condition page:(CGPage)page ofMember:(ECAccountInfo*)member completion:(void(^)(ECError* error, NSArray* conferenceList))completion {
DDLogInfo(@"getConferenceListWithCondition confId=%@,confType=%d,createTimeBegin=%@,createTimeEnd=%@,pageSize=%d,pageNumber=%d,account=%@,username=%@",condition.confId,(int)condition.confType,condition.createTimeBegin,condition.createTimeEnd,(int)page.size,(int)page.number,member.accountId,member.userName);
    [[ECDevice sharedInstance].conferenceManager getConferenceListWithCondition:condition page:page ofMember:member completion:^(ECError *error, NSArray *conferenceList) {
        DDLogInfo(@"getConferenceListWithCondition errorCode=%d,des=%@,conferenceList=%@",(int)error.errorCode,error.errorDescription,conferenceList);
        if (completion) {
            completion(error,conferenceList);
        }
    }];
}

/**
 @brief 获取历史会议列表
 @param condition 筛选条件
 @param page 分页信息
 @param completion 执行结果回调block
 */
- (void)getHistoryConferenceListWithCondition:(ECConferenceCondition*)condition page:(CGPage)page completion:(void(^)(ECError* error, NSArray* conferenceList))completion {
DDLogInfo(@"confId=%@,confType=%d,createTimeBegin=%@,createTimeEnd=%@,pageSize=%d,pageNumber=%d",condition.confId,(int)condition.confType,condition.createTimeBegin,condition.createTimeEnd,(int)page.size,(int)page.number);
    [[ECDevice sharedInstance].conferenceManager getHistoryConferenceListWithCondition:condition page:page completion:^(ECError *error, NSArray *conferenceList) {
        DDLogInfo(@"errorCode=%d,des=%@,conferenceList=%@",(int)error.errorCode,error.errorDescription,conferenceList);
        if (completion) {
            completion(error,conferenceList);
        }
    }];
}

/**
 @brief 锁定会议
 @param confId 会议ID
 @param lockType 0 锁定，1 解锁，2 锁定白板发起，3 解锁，4 锁定白板标注，5 解锁
 @param completion 执行结果回调block
 */
- (void)lockConference:(NSString*)confId lockType:(int)lockType completion:(void(^)(ECError* error))completion {
    DDLogInfo(@"confId=%@,isLock=%d",confId,lockType);
    [[ECDevice sharedInstance].conferenceManager lockConference:confId lockType:lockType completion:^(ECError *error) {
        DDLogInfo(@"errorCode=%d,des=%@",(int)error.errorCode,error.errorDescription);
        if (completion) {
            completion(error);
        }
    }];
}

/**
 @brief 加入会议
 @param joinInfo 加入条件
 @param completion 执行结果回调block
 */
- (void)joinConferenceWith:(ECConferenceJoinInfo*)joinInfo completion:(void(^)(ECError* error, ECConferenceInfo*conferenceInfo))completion {
    DDLogInfo(@"joinConferenceWith confId=%@,username=%@,mediaType=%d,inviter=%@,terminalUA=%@",joinInfo.conferenceId,joinInfo.userName,(int)joinInfo.mediaType,joinInfo.inviter,joinInfo.terminalUA);
    [[ECDevice sharedInstance].conferenceManager joinConferenceWith:joinInfo completion:^(ECError *error, ECConferenceInfo *conferenceInfo) {
        
        DDLogInfo(@"joinConferenceWith errorCode=%d,des=%@",(int)error.errorCode,error.errorDescription);
        if (completion) {
            completion(error,conferenceInfo);
        }
    }];
}

/**
 @brief 退出会议
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)quitConference:(NSString*)confId completion:(void(^)(ECError* error))completion {
    DDLogInfo(@"confId=%@",confId);
    [[ECDevice sharedInstance].conferenceManager quitConference:confId completion:^(ECError *error) {
        DDLogInfo(@"errorCode=%d,des=%@",(int)error.errorCode,error.errorDescription);
        if (completion) {
            completion(error);
        }
    }];
}

/**
 @brief 更换成员信息
 @param memberInfo 成员信息
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)updateMember:(ECConferenceMemberInfo*)memberInfo ofConference:(NSString*)confId completion:(void(^)(ECError* error))completion {
    DDLogInfo(@"updateMemberaccount=%@,username=%@,appdata=%@,confId=%@",memberInfo.account.accountId,memberInfo.account.userName,memberInfo.appData,confId);
    [[ECDevice sharedInstance].conferenceManager updateMember:memberInfo ofConference:confId completion:^(ECError *error) {
        DDLogInfo(@"updateMember errorCode=%d,des=%@",(int)error.errorCode,error.errorDescription);
        if (completion) {
            completion(error);
        }
    }];
}

/**
 @brief 获取成员信息
 @param member 账号信息
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)getMember:(ECAccountInfo*)member ofConference:(NSString*)confId completion:(void(^)(ECError* error, ECConferenceMemberInfo* memberInfo))completion {
    DDLogInfo(@"getMember account=%@,confId=%@",member.accountId,confId);
    [[ECDevice sharedInstance].conferenceManager getMember:member ofConference:confId completion:^(ECError *error, ECConferenceMemberInfo *memberInfo) {
        DDLogInfo(@"getMember errorCode=%d,des=%@,account=%@,username=%@,appData=%@",(int)error.errorCode,error.errorDescription,memberInfo.account.accountId,memberInfo.account.userName,memberInfo.appData);
        if (completion) {
            completion(error,memberInfo);
        }
    }];
}

/**
 @brief 获取成员列表
 @param confId 会议ID
 @param page 分页信息
 @param completion 执行结果回调block
 */
- (void)getMemberListOfConference:(NSString*)confId page:(CGPage)page completion:(void(^)(ECError* error, NSArray* members))completion {
    DDLogInfo(@"getMemberListOfConferenceconfId=%@,pageNumber=%d,pageSize=%d",confId,(int)page.number,(int)page.size);
    [[ECDevice sharedInstance].conferenceManager getMemberListOfConference:confId page:page completion:^(ECError *error, NSArray *members) {
        DDLogInfo(@"getMemberListOfConference errorCode=%d,des=%@,members=%@",(int)error.errorCode,error.errorDescription,members);
        if (completion) {
            completion(error,members);
        }
    }];
}

/**
 @brief 获取会议中的成员与会记录
 @param accountInfo 相关成员记录 如果为nil，获取所有成员与会记录
 @param confId 会议ID
 @param page 分页信息
 @param completion 执行结果回调block
 */
- (void)getMemberRecord:(ECAccountInfo*)accountInfo ofConference:(NSString*)confId page:(CGPage)page completion:(void(^)(ECError* error, NSArray* membersRecord))completion {
    DDLogInfo(@"getMemberRecordaccount=%@,username=%@,confId=%@,pageNumber=%d,pageSize=%d",accountInfo.accountId,accountInfo.userName,confId,(int)page.number,(int)page.size);
    [[ECDevice sharedInstance].conferenceManager getMemberRecord:accountInfo ofConference:confId page:page completion:^(ECError *error, NSArray *membersRecord) {
        DDLogInfo(@"getMemberRecord errorCode=%d,des=%@,membersRecord=%@",(int)error.errorCode,error.errorDescription,membersRecord);
        if (completion) {
            completion(error,membersRecord);
        }
    }];
}

/**
 @brief 邀请加入会议
 @param inviteMembers ECAccountInfo数组 邀请的成员
 @param confId 会议ID
 @param callImmediately 是否立即发起呼叫 对于自定义账号，1表示给用户显示呼叫页面，并设置超时时间1分钟 对于电话号码（或关联电话）账号，1表示立即给cm发呼叫命令 0表示仅在会议中增加成员（一般用户预约会议开始前增加成员）
 @param appData 预留
 @param completion 执行结果回调block
 */
- (void)inviteMembers:(NSArray*)inviteMembers inConference:(NSString*)confId callImmediately:(int)callImmediately appData:(NSString*)appData completion:(void(^)(ECError* error))completion {
    DDLogInfo(@"inviteMembers=%@,confId=%@,appData=%@,callImmediately=%d",inviteMembers,confId,appData,callImmediately);
    [[ECDevice sharedInstance].conferenceManager inviteMembers:inviteMembers inConference:confId callImmediately:callImmediately appData:appData completion:^(ECError *error) {
        DDLogInfo(@"errorCode=%d,des=%@",(int)error.errorCode,error.errorDescription);
        if (completion) {
            completion(error);
        }
    }];
}


/**
 @brief 拒绝会议邀请
 @param invitationId 邀请的id
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)rejectInvitation:(NSString*)invitationId cause:(NSString*)cause ofConference:(NSString*)confId completion:(void(^)(ECError* error))completion {
    DDLogInfo(@"invitationId=%@,cause=%@,confId=%@",invitationId,cause,confId);
    [[ECDevice sharedInstance].conferenceManager rejectInvitation:invitationId cause:cause ofConference:confId completion:^(ECError *error) {
        DDLogInfo(@"errorCode=%d,des=%@",(int)error.errorCode,error.errorDescription);
        if (completion) {
            completion(error);
        }
    }];
}
/**
 @brief 踢出成员
 @param kickMembers ECAccountInfo数组 踢出的成员
 @param confId 会议ID
 @param appData 预留
 @param completion 执行结果回调block
 */
- (void)kickMembers:(NSArray*)kickMembers outConference:(NSString*)confId appData:(NSString*)appData completion:(void(^)(ECError* error))completion {
    DDLogInfo(@"kickMembers=%@,confId=%@,appData=%@",kickMembers,confId,appData);
    [[ECDevice sharedInstance].conferenceManager kickMembers:kickMembers outConference:confId appData:appData completion:^(ECError *error) {
        DDLogInfo(@"errorCode=%d,des=%@",(int)error.errorCode,error.errorDescription);
        if (completion) {
            completion(error);
        }
    }];
}

/**
 @brief 设置成员角色
 @param member 相关设置信息
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)setMemberRole:(ECAccountInfo*)member ofConference:(NSString*)confId completion:(void(^)(ECError* error))completion {
    DDLogInfo(@"account=%@,username=%@,roleId=%d,confId=%@",member.accountId,member.userName,(int)member.roleId,confId);
    [[ECDevice sharedInstance].conferenceManager setMemberRole:member ofConference:confId completion:^(ECError *error) {
        DDLogInfo(@"errorCode=%d,des=%@",(int)error.errorCode,error.errorDescription);
        if (completion) {
            completion(error);
        }
    }];
}

/**
 @brief 媒体控制
 @param action 控制动作
 @param members ECAccountInfo数组 控制成员列表
 @param isAllMember 是否全部成员
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)controlMedia:(ECControlMediaAction)action toMembers:(NSArray*)members isAll:(int)isAllMember ofConference:(NSString*)confId completion:(void(^)(ECError* error))completion {
    DDLogInfo(@"action=%lu,members=%@,isAllMember=%d,confId=%@",action,members,isAllMember,confId);
    [[ECDevice sharedInstance].conferenceManager controlMedia:action toMembers:members isAll:isAllMember ofConference:confId completion:^(ECError *error) {
        DDLogInfo(@"errorCode=%d,des=%@",(int)error.errorCode,error.errorDescription);
        if (completion) {
            completion(error);
        }
    }];
}

/**
 @brief 会议媒体是否sdk自动控制   1 sdk收到会控通知会自动控制媒体 0 sdk不会控制媒体相关
 
 @param isAuto 是否自动控制
 */
- (NSInteger)setConferenceAutoMediaControl:(BOOL)isAuto{
    return [[ECDevice sharedInstance].conferenceManager setConferenceAutoMediaControl:isAuto];
}

/**
 @brief 会议录制
 @param action 录制控制
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)record:(ECRecordAction)action conference:(NSString*)confId completion:(void(^)(ECError* error))completion {
    DDLogInfo(@"action=%lu,confId=%@",action,confId);
    [[ECDevice sharedInstance].conferenceManager record:action conference:confId completion:^(ECError *error) {
        DDLogInfo(@"errorCode=%d,des=%@",(int)error.errorCode,error.errorDescription);
        if (completion) {
            completion(error);
        }
    }];
}

/**
 @brief 发布音频
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)publishVoiceInConference:(NSString*)confId exclusively:(int)exclusively completion:(void(^)(ECError* error))completion {
    DDLogInfo(@"confId=%@",confId);
    [[ECDevice sharedInstance].conferenceManager publishVoiceInConference:confId exclusively:exclusively completion:^(ECError *error) {
        DDLogInfo(@"errorCode=%d,des=%@",(int)error.errorCode,error.errorDescription);
        if (completion) {
            completion(error);
        }
    }];
}

/**
 @brief 取消发布
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)stopVoiceInConference:(NSString*)confId exclusively:(int)exclusively completion:(void(^)(ECError* error))completion {
    DDLogInfo(@"confId=%@",confId);
    [[ECDevice sharedInstance].conferenceManager stopVoiceInConference:confId exclusively:exclusively completion:^(ECError *error) {
        DDLogInfo(@"errorCode=%d,des=%@",(int)error.errorCode,error.errorDescription);
        if (completion) {
            completion(error);
        }
    }];
}

/**
 @brief 发布视频
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)publishVideoInConference:(NSString*)confId completion:(void(^)(ECError* error))completion {
    DDLogInfo(@"confId=%@",confId);
    [[ECDevice sharedInstance].conferenceManager publishVideoInConference:confId completion:^(ECError *error) {
        DDLogInfo(@"errorCode=%d,des=%@",(int)error.errorCode,error.errorDescription);
        if (completion) {
            completion(error);
        }
    }];
}

/**
 @brief 取消发布
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)cancelVideoInConference:(NSString*)confId completion:(void(^)(ECError* error))completion {
    DDLogInfo(@"confId=%@",confId);
    [[ECDevice sharedInstance].conferenceManager cancelVideoInConference:confId completion:^(ECError *error) {
        DDLogInfo(@"errorCode=%d,des=%@",(int)error.errorCode,error.errorDescription);
        if (completion) {
            completion(error);
        }
    }];
}

/**
 @brief 共享屏幕
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)shareScreenInConference:(NSString*)confId completion:(void(^)(ECError* error))completion {
    DDLogInfo(@"confId=%@",confId);
    [[ECDevice sharedInstance].conferenceManager shareScreenInConference:confId completion:^(ECError *error) {
        DDLogInfo(@"errorCode=%d,des=%@",(int)error.errorCode,error.errorDescription);
        if (completion) {
            completion(error);
        }
    }];
}

/**
 @brief 停止共享屏幕
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)stopScreenInConference:(NSString*)confId completion:(void(^)(ECError* error))completion {
    DDLogInfo(@"confId=%@",confId);
    [[ECDevice sharedInstance].conferenceManager stopScreenInConference:confId completion:^(ECError *error) {
        DDLogInfo(@"errorCode=%d,des=%@",(int)error.errorCode,error.errorDescription);
        if (completion) {
            completion(error);
        }
    }];
}

/**
 @brief 请求成员视频
 @param videoInfo 视频信息
 @param completion 执行结果回调block
 */
- (void)requestMemberVideoWith:(ECConferenceVideoInfo*)videoInfo completion:(void(^)(ECError* error))completion {
DDLogInfo(@"requestMemberVideoWith confId=%@,account=%@,userName=%@,sourceType=%d",videoInfo.conferenceId,videoInfo.member.accountId,videoInfo.member.userName,(int)videoInfo.sourceType);
    [[ECDevice sharedInstance].conferenceManager requestMemberVideoWith:videoInfo completion:^(ECError *error) {
        DDLogInfo(@"requestMemberVideoWith errorCode=%d,des=%@",(int)error.errorCode,error.errorDescription);
        if (completion) {
            completion(error);
        }
    }];
}

/**
 @brief 停止成员视频
 @param videoInfo 视频信息
 @param completion 执行结果回调block
 */
- (void)stopMemberVideoWith:(ECConferenceVideoInfo*)videoInfo completion:(void(^)(ECError* error))completion {
DDLogInfo(@"stopMemberVideoWith confId=%@,account=%@,userName=%@,sourceType=%d",videoInfo.conferenceId,videoInfo.member.accountId,videoInfo.member.userName,(int)videoInfo.sourceType);
    [[ECDevice sharedInstance].conferenceManager stopMemberVideoWith:videoInfo completion:^(ECError *error) {
        DDLogInfo(@"errorCode=%d,des=%@",(int)error.errorCode,error.errorDescription);
        if (completion) {
            completion(error);
        }
    }];
}

/**
 @brief 重置显示View
 @param videoInfo 视频信息
 */
- (int)resetMemberVideoWith:(ECConferenceVideoInfo*)videoInfo {
DDLogInfo(@"resetMemberVideoWith confId=%@,account=%@,userName=%@,sourceType=%d",videoInfo.conferenceId,videoInfo.member.accountId,videoInfo.member.userName,(int)videoInfo.sourceType);
    int result = [[ECDevice sharedInstance].conferenceManager resetMemberVideoWith:videoInfo];
    DDLogInfo(@"result=%d",result);
    return result;
}

/**
 @brief 重置本地预览显示View
 */
- (int)resetLocalVideoWithConfId:(NSString *)confId remoteView:(UIView *)remoteView localView:(UIView *)localView {
    DDLogInfo(@" resetLocalVideoWithConfId confId=%@,remoteView=%@,localView=%@",confId,remoteView,localView);
    int result = [[ECDevice sharedInstance].conferenceManager resetLocalVideoWithConfId:confId remoteView:remoteView localView:localView];
    DDLogInfo(@"result=%d",result);
    return result;
}









@end
