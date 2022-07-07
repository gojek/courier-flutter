// MQTTClient.framework
// 
// Copyright © 2013-2017, Christoph Krey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCDTimer: NSObject

+ (GCDTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                     repeats:(BOOL)repeats
                                       queue:(dispatch_queue_t)queue
                                       block:(void (^)(void))block;
- (void)invalidate;

@end
