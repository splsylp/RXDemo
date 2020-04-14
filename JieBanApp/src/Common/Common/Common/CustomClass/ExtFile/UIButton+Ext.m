//
//  UIButton+Ext.m
//  objectAssociation
//
//  Created by yuxuanpeng on 14-7-18.
//  Copyright (c) 2014年 yuxuanpeng. All rights reserved.
//

#import "UIButton+Ext.h"
#import "UIControl+Ext.h"
#import <objc/runtime.h>
static char topNameKey;
static char rightNameKey;
static char bottomNameKey;
static char leftNameKey;
@implementation UIButton (Ext)
static char OperationKey;

- (void)removeHandleControlEvent:(UIControlEvents)controlEvent
{
    NSString *methodName = [UIControl controlEventName:controlEvent];
    NSMutableDictionary *opreations = (NSMutableDictionary*)objc_getAssociatedObject(self, &OperationKey);
    
    if(opreations == nil)
    {
        opreations = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, &OperationKey, opreations, OBJC_ASSOCIATION_RETAIN);
    }
    [opreations removeObjectForKey:methodName];
    [self removeTarget:self action:NSSelectorFromString(methodName) forControlEvents:controlEvent];
}

- (void)handleControlEvent:(UIControlEvents)event withBlock:(buttonControlEventBlock)block{
    
    NSString *buttonTapMethodName = [UIControl controlEventName:event];
    NSMutableDictionary *opreations = (NSMutableDictionary*)objc_getAssociatedObject(self, &OperationKey);
    if (!opreations) {
        opreations = [[NSMutableDictionary alloc]init];
        objc_setAssociatedObject(self, &OperationKey, opreations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [opreations setObject:block forKey:buttonTapMethodName];
    [self addTarget:self action:NSSelectorFromString(buttonTapMethodName) forControlEvents:event];
}

- (void)callActionBlock:(UIControlEvents)controlEvent{
    NSMutableDictionary *opreations = (NSMutableDictionary*)objc_getAssociatedObject(self, &OperationKey);
    if (!opreations) {
        return;
    }
    NSString *buttonTapMethodName = [UIControl controlEventName:controlEvent];
    buttonControlEventBlock block = [opreations objectForKey:buttonTapMethodName];
    if (block) {
        block(self);
    }
}

-(void) UIControlEventTouchDown{[self callActionBlock:UIControlEventTouchDown];}
-(void) UIControlEventTouchDownRepeat{[self callActionBlock:UIControlEventTouchDownRepeat];}
-(void) UIControlEventTouchDragInside{[self callActionBlock:UIControlEventTouchDragInside];}
-(void) UIControlEventTouchDragOutside{[self callActionBlock:UIControlEventTouchDragOutside];}
-(void) UIControlEventTouchDragEnter{[self callActionBlock:UIControlEventTouchDragEnter];}
-(void) UIControlEventTouchDragExit{[self callActionBlock:UIControlEventTouchDragExit];}
-(void) UIControlEventTouchUpInside{[self callActionBlock:UIControlEventTouchUpInside];}
-(void) UIControlEventTouchUpOutside{[self callActionBlock:UIControlEventTouchUpOutside];}
-(void) UIControlEventTouchCancel{[self callActionBlock:UIControlEventTouchCancel];}
-(void) UIControlEventValueChanged{[self callActionBlock:UIControlEventValueChanged];}
-(void) UIControlEventEditingDidBegin{[self callActionBlock:UIControlEventEditingDidBegin];}
-(void) UIControlEventEditingChanged{[self callActionBlock:UIControlEventEditingChanged];}
-(void) UIControlEventEditingDidEnd{[self callActionBlock:UIControlEventEditingDidEnd];}
-(void) UIControlEventEditingDidEndOnExit{[self callActionBlock:UIControlEventEditingDidEndOnExit];}
-(void) UIControlEventAllTouchEvents{[self callActionBlock:UIControlEventAllTouchEvents];}
-(void) UIControlEventAllEditingEvents{[self callActionBlock:UIControlEventAllEditingEvents];}
-(void) UIControlEventApplicationReserved{[self callActionBlock:UIControlEventApplicationReserved];}
-(void) UIControlEventSystemReserved{[self callActionBlock:UIControlEventSystemReserved];}
-(void) UIControlEventAllEvents{[self callActionBlock:UIControlEventAllEvents];}
- (void)setEnlargeEdge:(CGFloat) size
{
    objc_setAssociatedObject(self, &topNameKey, [NSNumber numberWithFloat:size], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &rightNameKey, [NSNumber numberWithFloat:size], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &bottomNameKey, [NSNumber numberWithFloat:size], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &leftNameKey, [NSNumber numberWithFloat:size], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void) setEnlargeEdgeWithTop:(CGFloat) top right:(CGFloat) right bottom:(CGFloat) bottom left:(CGFloat) left
{
    objc_setAssociatedObject(self, &topNameKey, [NSNumber numberWithFloat:top], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &rightNameKey, [NSNumber numberWithFloat:right], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &bottomNameKey, [NSNumber numberWithFloat:bottom], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &leftNameKey, [NSNumber numberWithFloat:left], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGRect) enlargedRect
{
    NSNumber* topEdge = objc_getAssociatedObject(self, &topNameKey);
    NSNumber* rightEdge = objc_getAssociatedObject(self, &rightNameKey);
    NSNumber* bottomEdge = objc_getAssociatedObject(self, &bottomNameKey);
    NSNumber* leftEdge = objc_getAssociatedObject(self, &leftNameKey);
    if (topEdge && rightEdge && bottomEdge && leftEdge)
    {
        return CGRectMake(self.bounds.origin.x - leftEdge.floatValue,
                          self.bounds.origin.y - topEdge.floatValue,
                          self.bounds.size.width + leftEdge.floatValue + rightEdge.floatValue,
                          self.bounds.size.height + topEdge.floatValue + bottomEdge.floatValue);
    }
    else
    {
        return self.bounds;
    }
}

- (UIView*) hitTest:(CGPoint) point withEvent:(UIEvent*) event
{
    CGRect rect = [self enlargedRect];
    if (CGRectEqualToRect(rect, self.bounds))
    {
        return [super hitTest:point withEvent:event];
    }
    return CGRectContainsPoint(rect, point) ? self : nil;
}
@end
