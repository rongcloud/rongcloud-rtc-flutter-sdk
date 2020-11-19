//
//  ThisClassShouldNotBelongHere.m
//  rongcloud_rtc_plugin
//
//  Created by 潘铭达 on 2020/10/28.
//

#import "ThisClassShouldNotBelongHere.h"
#import "RLogUtil.h"

@implementation ThisClassShouldNotBelongHere

+ (RCMessageContent *)string2MessageContent:(NSString *)object content:(NSString *)content {
    RCMessageContent *message = nil;
    if ([@"RC:chrmKVNotiMsg" isEqualToString:object]) {
        message = [[RCChatroomKVNotificationMessage alloc] init];
    }
//    else if ([@"RC:CombineMsg" isEqualToString:object]) {
//        message = [[RCCombineMessage alloc] init];
//    }
    else if ([@"RC:FileMsg" isEqualToString:object]) {
        message = [[RCFileMessage alloc] init];
    } else if ([@"RC:GIFMsg" isEqualToString:object]) {
        message = [[RCGIFMessage alloc] init];
    } else if ([@"RC:ImgMsg" isEqualToString:object]) {
        message = [[RCImageMessage alloc] init];
    } else if ([@"RC:LBSMsg" isEqualToString:object]) {
        message = [[RCLocationMessage alloc] init];
    } else if ([@"RC:RcNtf" isEqualToString:object]) {
        message = [[RCRecallNotificationMessage alloc] init];
    } else if ([@"RC:ReferenceMsg" isEqualToString:object]) {
        message = [[RCReferenceMessage alloc] init];
    } else if ([@"RC:ImgTextMsg" isEqualToString:object]) {
        message = [[RCRichContentMessage alloc] init];
    } else if ([@"RC:SightMsg" isEqualToString:object]) {
        message = [[RCSightMessage alloc] init];
    } else if ([@"RC:TxtMsg" isEqualToString:object]) {
        message = [[RCTextMessage alloc] init];
    } else if ([@"RC:HQVCMsg" isEqualToString:object]) {
        message = [[RCHQVoiceMessage alloc] init];
    } else {
        RLogE(@"MessageContent NOT SUPPORT %@ TYPE MESSAGE!!!!", object);
    }
    
    if (message)
        [message decodeWithData:[content dataUsingEncoding:NSUTF8StringEncoding]];
    
    return message;
}

@end
