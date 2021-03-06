#import "RCFlutterRTCManager+LocalUser.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation RCFlutterRTCManager (LocalUser)

- (void)publishRTCDefaultAVStreams:(RongFlutterOperationCallback)completion {
    [[RCRTCEngine sharedInstance].room.localUser publishDefaultStreams:completion];
}

- (void)unpublishDefaultStreams:(RongFlutterOperationCallback)completion{
    [[RCRTCEngine sharedInstance].room.localUser unpublishDefaultStreams:completion];
}

- (void)publishStreams:(nullable NSArray<RCRTCOutputStream *> *)streams
            completion:(RongFlutterOperationCallback)completion {
    [[RCRTCEngine sharedInstance].room.localUser publishStreams:streams
                                                            completion:completion];
}

- (void)unpublishStreams:(nullable NSArray<RCRTCOutputStream *> *)streams
              completion:(RongFlutterOperationCallback)completion {
    [[RCRTCEngine sharedInstance].room.localUser unpublishStreams:streams
                                                              completion:completion];
}

- (void)subscribeStreams:(nullable NSArray<RCRTCInputStream *> *)avStreams
             tinyStreams:(nullable NSArray<RCRTCInputStream *> *)tinyStreams
              completion:(nullable RCRTCOperationCallback)completion {
    [[RCRTCEngine sharedInstance].room.localUser subscribeStream:avStreams
                                                            tinyStreams:tinyStreams
                                                             completion:completion];
}

- (void)unsubscribeStreams:(NSArray<RCRTCInputStream *> *)streams
               completion:(RCRTCOperationCallback)completion {
    [[RCRTCEngine sharedInstance].room.localUser unsubscribeStreams:streams
                                                               completion:completion];
}

- (void)setAttributeValue:(NSString *)attributeValue
                   forKey:(NSString *)key
                  message:(RCMessageContent *)message
               completion:(RCRTCOperationCallback)completion {
    
    [[RCRTCEngine sharedInstance].room.localUser setAttribute:attributeValue forKey:key message:message completion:completion];
}

- (void)deleteAttributes:(NSArray<NSString *> *)attributeKeys
                 message:(RCMessageContent *)message
              completion:(RCRTCOperationCallback)completion {
    [[RCRTCEngine sharedInstance].room.localUser deleteAttributes:attributeKeys
                                                                 message:message
                                                              completion:completion];
}

- (void)getAttributes:(NSArray<NSString *> *)attributeKeys
           completion:(RCRTCAttributeOperationCallback)completion {
    [[RCRTCEngine sharedInstance].room.localUser getAttributes:attributeKeys
                                                           completion:completion];
}

@end

#pragma clang diagnostic pop
