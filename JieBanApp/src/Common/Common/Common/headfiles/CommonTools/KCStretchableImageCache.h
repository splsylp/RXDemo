//
//  KCStretchableImageCache.h
//  KX3
//
//  Created by Song xiaofeng on 12-10-22.
//  Copyright (c) 2012年 kaixin001. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import <UIKit/UIKit.h>
@interface KCStretchableImageCache : NSObject
{
    NSMutableDictionary* _stretchableImages;
}

- (UIImage *)originImageNamed:(NSString *)imgName;

-(UIImage *)imageNamed:(NSString*)imgName
          leftCapwidth:(NSInteger)leftCapWidth
          topCapHeight:(NSInteger)topCapHeight ;

-(void)unloadAllCachedImages;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(KCStretchableImageCache)
@end
