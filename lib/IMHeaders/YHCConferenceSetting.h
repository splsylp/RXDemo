//
//  YHCConferenceSetting.h
//  CCPiPhoneSDK
//
//  Created by 王文龙 on 2017/7/11.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHCConferenceSetting : NSObject
/**
 @brief 会议呼入电话号码，列表。
 */
@property (nonatomic, copy) NSArray *telNum;

/**
 @brief 会议最大成员数。最大不能超过应用中设置的最大数值。
 */
@property (nonatomic, assign) NSInteger maxMember;

/**
 @brief 会议最小成员数。最小不能低于应用中设置的最小数值。
 */
@property (nonatomic, assign) NSInteger minMember;


/**
 @brief 应用ID
 */
@property (nonatomic, copy) NSString * appId;



@end
