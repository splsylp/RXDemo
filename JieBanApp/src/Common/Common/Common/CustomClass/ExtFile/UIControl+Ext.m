//
//  UIControl+Ext.m
//  objectAssociation
//
//  Created by yuxuanpeng on 14-7-18.
//  Copyright (c) 2014年 yuxuanpeng. All rights reserved.
//

#import "UIControl+Ext.h"

@implementation UIControl (Ext)

+ (NSString*)controlEventName:(UIControlEvents)controlEvent
{
    switch (controlEvent) {
            
        case UIControlEventTouchDown:          return @"UIControlEventTouchDown";
        case UIControlEventTouchDownRepeat:    return @"UIControlEventTouchDownRepeat";
        case UIControlEventTouchDragInside:    return @"UIControlEventTouchDragInside";
        case UIControlEventTouchDragOutside:   return @"UIControlEventTouchDragOutside";
        case UIControlEventTouchDragEnter:     return @"UIControlEventTouchDragEnter";
        case UIControlEventTouchDragExit:      return @"UIControlEventTouchDragExit";
        case UIControlEventTouchUpInside:      return @"UIControlEventTouchUpInside";
        case UIControlEventTouchUpOutside:     return @"UIControlEventTouchUpOutside";
        case UIControlEventTouchCancel:        return @"UIControlEventTouchCancel";
        case UIControlEventValueChanged:       return @"UIControlEventValueChanged";
        case UIControlEventEditingDidBegin:    return @"UIControlEventEditingDidBegin";
        case UIControlEventEditingChanged:     return @"UIControlEventEditingChanged";
        case UIControlEventEditingDidEnd:      return @"UIControlEventEditingDidEnd";
        case UIControlEventEditingDidEndOnExit:return @"UIControlEventEditingDidEndOnExit";
        case UIControlEventAllTouchEvents:     return @"UIControlEventAllTouchEvents";
        case UIControlEventAllEditingEvents:   return @"UIControlEventAllEditingEvents";
        case UIControlEventApplicationReserved:return @"UIControlEventApplicationReserved";
        case UIControlEventSystemReserved:     return @"UIControlEventSystemReserved";
        case UIControlEventAllEvents:          return @"UIControlEventAllEvents";
        default:
            return @"description";
    }
    return @"description";
}

- (void)removeAllTargets {
    for (id target in [self allTargets]) {
        [self removeTarget:target action:NULL forControlEvents:UIControlEventAllEvents];
    }
}

@end
