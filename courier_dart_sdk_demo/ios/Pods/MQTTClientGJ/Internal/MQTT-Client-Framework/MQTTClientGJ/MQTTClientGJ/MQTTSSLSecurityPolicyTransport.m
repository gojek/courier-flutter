// MQTTClient.framework
// 
// Copyright © 2013-2017, Christoph Krey. All rights reserved.
//

#import "MQTTSSLSecurityPolicyTransport.h"
#import "MQTTSSLSecurityPolicyEncoder.h"
#import "MQTTSSLSecurityPolicyDecoder.h"

#import "MQTTLog.h"

@interface MQTTSSLSecurityPolicyTransport()
@property (strong, nonatomic) MQTTSSLSecurityPolicyEncoder *encoder;
@property (strong, nonatomic) MQTTSSLSecurityPolicyDecoder *decoder;

@end

@implementation MQTTSSLSecurityPolicyTransport
@synthesize state;
@synthesize delegate;

- (instancetype)init {
    self = [super init];
    self.securityPolicy = nil;
    return self;
}

- (void)open {
    DDLogVerbose(@"[MQTTSSLSecurityPolicyTransport] open");
    self.state = MQTTTransportOpening;

    NSError* connectError;

    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;

    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)self.host, self.port, &readStream, &writeStream);
    
    CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);

    if (self.tls) {
        NSMutableDictionary *sslOptions = [[NSMutableDictionary alloc] init];
   
        sslOptions[(NSString *)kCFStreamSSLValidatesCertificateChain] = @NO;
        sslOptions[(NSString *)kCFStreamSSLLevel] = self.streamSSLLevel;

        if (self.certificates) {
            sslOptions[(NSString *)kCFStreamSSLCertificates] = self.certificates;
        }
        
        if (!CFReadStreamSetProperty(readStream, kCFStreamPropertySSLSettings, (__bridge CFDictionaryRef)(sslOptions))){
            connectError = [NSError errorWithDomain:@"MQTT"
                                               code:errSSLInternal
                                           userInfo:@{NSLocalizedDescriptionKey : @"Fail to init ssl input stream!"}];
        }
        if (!CFWriteStreamSetProperty(writeStream, kCFStreamPropertySSLSettings, (__bridge CFDictionaryRef)(sslOptions))){
            connectError = [NSError errorWithDomain:@"MQTT"
                                               code:errSSLInternal
                                           userInfo:@{NSLocalizedDescriptionKey : @"Fail to init ssl output stream!"}];
        }
        
        if (@available(iOS 11, *)) {
            if (self.alpn != nil && [self.alpn count] > 0) {
                OSStatus err;
                SSLContextRef sslContext = CFReadStreamCopyProperty(readStream, kCFStreamPropertySSLContext);
                if ((err = SSLSetALPNProtocols(sslContext, (__bridge CFArrayRef) self.alpn))) {
                    connectError = [NSError errorWithDomain:@"MQTT" code:err userInfo:@{
                        NSLocalizedDescriptionKey : @"ALPN error"}];
                }
                
                sslContext = CFWriteStreamCopyProperty(writeStream, kCFStreamPropertySSLContext);
                if ((err = SSLSetALPNProtocols(sslContext, (__bridge CFArrayRef) self.alpn))) {
                    connectError = [NSError errorWithDomain:@"MQTT" code:err userInfo:@{
                        NSLocalizedDescriptionKey : @"ALPN error"}];
                }
            }
        }
    }
    
    if (!connectError) {
        self.encoder = [[MQTTSSLSecurityPolicyEncoder alloc] init];
        CFWriteStreamSetDispatchQueue(writeStream, self.queue);
        self.encoder.stream = CFBridgingRelease(writeStream);
        self.encoder.securityPolicy = self.tls ? self.securityPolicy : nil;
        self.encoder.securityDomain = self.tls ? self.host : nil;
        self.encoder.delegate = self;
        if (self.voip) {
            [self.encoder.stream setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType];
        }
        [self.encoder open];
        
        self.decoder = [[MQTTSSLSecurityPolicyDecoder alloc] init];
        CFReadStreamSetDispatchQueue(readStream, self.queue);
        self.decoder.stream =  CFBridgingRelease(readStream);
        self.decoder.securityPolicy = self.tls ? self.securityPolicy : nil;
        self.decoder.securityDomain = self.tls ? self.host : nil;
        self.decoder.delegate = self;
        if (self.voip) {
            [self.decoder.stream setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType];
        }
        [self.decoder open];
        
    } else {
        [self close];
    }
}

@end
