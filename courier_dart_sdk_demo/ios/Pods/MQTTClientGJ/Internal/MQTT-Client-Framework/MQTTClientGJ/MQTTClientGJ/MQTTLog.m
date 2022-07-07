// MQTTClient.framework
// 
// Copyright © 2013-2017, Christoph Krey. All rights reserved.
//

#import "MQTTLog.h"

@implementation MQTTLog

#ifdef DEBUG

DDLogLevel ddLogLevel = DDLogLevelVerbose;

#else

DDLogLevel ddLogLevel = DDLogLevelWarning;

#endif

+ (void)setLogLevel:(DDLogLevel)logLevel {
    ddLogLevel = logLevel;
}

@end
