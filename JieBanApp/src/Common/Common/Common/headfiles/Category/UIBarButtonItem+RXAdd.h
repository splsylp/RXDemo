//
//  UINavigationItem+RXAdd.h
//  Common
//
//  Created by y g on 2019/9/23.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIBarButtonItem (RXAdd)

+ (UIBarButtonItem *)itemWithTarget:(id)target action:(SEL)action image:(UIImage *)image;

+ (UIBarButtonItem *)itemWithTarget:(id)target
                            action:(SEL)action
                        nomalImage:(UIImage *)nomalImage
                  higeLightedImage:(UIImage *)higeLightedImage
                    imageEdgeInsets:(UIEdgeInsets)imageEdgeInsets;
@end

NS_ASSUME_NONNULL_END
