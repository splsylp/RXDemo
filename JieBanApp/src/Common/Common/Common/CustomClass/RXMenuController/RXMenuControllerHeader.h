//
//  GMenuControllerHeader.h
//  GMenuController
//
//  Created by GIKI on 2017/10/19.
//  Copyright © 2017年 GIKI. All rights reserved.
//

#ifndef RXMenuControllerHeader_h
#define RXMenuControllerHeader_h

typedef NS_ENUM(NSUInteger, RXMenuControllerArrowDirection) {
    RXMenuControllerArrowDefault, // up or down based on screen location
    RXMenuControllerArrowUp ,       // Forced upward. If the screen is not displayed,  Will do anchor displacement
    RXMenuControllerArrowDown ,     // Forced down
};

UIKIT_EXTERN NSNotificationName const RXMenuControllerWillShowMenuNotification;
UIKIT_EXTERN NSNotificationName const RXMenuControllerDidShowMenuNotification;
UIKIT_EXTERN NSNotificationName const RXMenuControllerWillHideMenuNotification;
UIKIT_EXTERN NSNotificationName const RXMenuControllerDidHideMenuNotification;
UIKIT_EXTERN NSNotificationName const RXMenuControllerMenuFrameDidChangeNotification;

#endif /* GMenuControllerHeader_h */
