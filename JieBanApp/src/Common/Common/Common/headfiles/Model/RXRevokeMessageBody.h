//
//  RXRevokeMessageBody.h
//  Common
//
//  Created by yongzhen on 2018/10/18.
//  Copyright © 2018 ronglian. All rights reserved.
//

#import "RXThirdPart.h"

//NS_ASSUME_NONNULL_BEGIN

@interface RXRevokeMessageBody : ECMessageBody

@property (nonatomic, copy) NSString *text;

-(instancetype)initWithText:(NSString*)text;
@end

//NS_ASSUME_NONNULL_END
