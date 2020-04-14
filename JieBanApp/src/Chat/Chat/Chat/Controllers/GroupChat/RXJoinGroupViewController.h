//
//  RXJoinGroupViewController.h
//  Chat
//
//  Created by 胡伟 on 2019/8/29.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^finishBlock)(BOOL isfinish);

@interface RXJoinGroupViewController : BaseViewController

@property (nonatomic, strong) NSDictionary *dataSource;

- (void)joinGroup:(finishBlock)block;

@end

NS_ASSUME_NONNULL_END
