// MQTTClient.framework
// 
// Copyright © 2013-2017, Christoph Krey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MQTTClientGJ/MQTTPersistence.h>

@interface MQTTCoreDataPersistence : NSObject <MQTTPersistence>
- (void)initializeManagedObjectContext;
- (void)deleteAllFlows;
@end

@interface MQTTFlow : NSManagedObject <MQTTFlow>
@end

@interface MQTTCoreDataFlow : NSObject <MQTTFlow>
@end
