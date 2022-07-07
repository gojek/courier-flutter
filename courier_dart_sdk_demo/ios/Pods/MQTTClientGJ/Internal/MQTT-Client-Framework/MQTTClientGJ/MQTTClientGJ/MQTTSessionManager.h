// MQTTClient.framework
// 
// Copyright © 2013-2017, Christoph Krey. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE == 1
#import <UIKit/UIKit.h>
#endif
/**
 Enumeration of MQTTSessionManagerState values
 */
typedef NS_ENUM(int, MQTTSessionManagerState) {
    MQTTSessionManagerStateStarting,
    MQTTSessionManagerStateConnecting,
    MQTTSessionManagerStateError,
    MQTTSessionManagerStateConnected,
    MQTTSessionManagerStateClosing,
    MQTTSessionManagerStateClosed
};
