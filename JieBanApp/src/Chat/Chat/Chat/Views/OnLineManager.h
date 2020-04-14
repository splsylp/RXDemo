//
//  OnLineManager.h
//  Chat
//
//  Created by 李晓杰 on 2019/9/21.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OnLineManager : NSObject

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(OnLineManager)

- (void)showTipInView:(UIView *)view name:(NSString *)name isOnline:(BOOL)isOnline duration:(NSInteger)duration;

@end

NS_ASSUME_NONNULL_END
