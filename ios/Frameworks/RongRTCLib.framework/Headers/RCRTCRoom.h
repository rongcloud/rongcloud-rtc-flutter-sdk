//
//  RCRTCRoom.h
//  RongRTCLib
//
//  Created by RongCloud on 2019/1/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RCRTCRoomEventDelegate.h"
#import "RCRTCLocalUser.h"
#import "RCRTCRemoteUser.h"
#import "RCRTCActivityMonitorDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 音视频通话的房间
 */
@interface RCRTCRoom : NSObject

/*!
 房间 Delegate
 */
@property (nonatomic, weak) id <RCRTCRoomEventDelegate> delegate;

/*!
 房间ID
 */
@property (nonatomic, copy, readonly) NSString *roomId;

/*!
 当前用户
 */
@property (nonatomic, strong, readonly) RCRTCLocalUser *localUser;

/*!
 参与用户
 */
@property (nonatomic, strong, readonly) NSArray<RCRTCRemoteUser *> *remoteUsers;

/*!
 会话 id, 用于 server API，会话唯一标识
 */
@property (nonatomic, copy, readonly) NSString *sessionId;

/*!
 根据 userId 获取房间内用户，不存在则返回 nil
 
 @param userId user ID
 */
- (RCRTCRemoteUser *)getRemoteUser:(NSString *)userId;

/*!
 将所有远端用户静音
 
 @param mute 是否静音所有远端用户, YES 禁止  NO 允许
 @discussion
 将所有远端用户静音, 注: 该功能只是不播放接收到的音频数据
 
 @remarks 音频流处理
 */
- (void)muteAllRemoteAudio:(BOOL)mute;

/*!
 发送消息
 
 @param content             消息的内容
 @param successBlock        消息发送成功的回调 [messageId:消息的ID]
 @param errorBlock          消息发送失败的回调 [nErrorCode:发送失败的错误码,messageId:消息的ID]
 @discussion
 该接口只能发送 persistentFlag 为 MessagePersistent_STATUS 的状态消息, 远端用户如果不在线则消息丢失, 自定义消息时下面标识一定要给出, 否则会导致消息发送失败
 + (RCMessagePersistent)persistentFlag {
    return MessagePersistent_STATUS;
 }
 
 @remarks 房间管理
 @return 发送的消息实体
 */
- (RCMessage *)sendMessage:(RCMessageContent *)content
                   success:(void (^)(long messageId))successBlock
                     error:(void (^)(RCErrorCode nErrorCode, long messageId))errorBlock;

/*!
 设置房间属性
 
 @param attributeValue 属性值
 @param key 属性名称
 @param message 是否在设置属性的时候携带消息内容, 传空则不往房间中发送消息
 @param completion 设置完成回调
 @discussion
 设置房间属性
 
 @remarks 房间管理
 */
- (void)setRoomAttributeValue:(NSString *)attributeValue
                       forKey:(NSString *)key
                      message:(RCMessageContent *)message
                   completion:(RCRTCOperationCallback)completion;

/*!
 删除房间属性
 
 @param attributeKeys 属性名称数组
 @param message 是否在设置属性的时候携带消息内容, 传空则不往房间中发送消息
 @param completion 删除完成回调
 @discussion
 删除房间属性
 
 @remarks 房间管理
 */
- (void)deleteRoomAttributes:(NSArray <NSString *> *)attributeKeys
                     message:(RCMessageContent *)message
                  completion:(RCRTCOperationCallback)completion;

/*!
 获取房间属性
 
 @param attributeKeys 属性名称
 @param completion 获取结果回调
 @discussion
 获取房间属性
 
 @remarks 房间管理
 */
- (void)getRoomAttributes:(NSArray <NSString *> *)attributeKeys
               completion:(RCRTCAttributeOperationCallback)completion;

@end

NS_ASSUME_NONNULL_END
