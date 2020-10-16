//
//  RCRTCStatisticalForm.h
//  RongRTCLib
//
//  Created by RongCloud on 2019/5/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCRTCGlobals.h"

typedef NSString *RongRTCMediaType;

NS_ASSUME_NONNULL_BEGIN

RONGRTCLIB_EXTERN RongRTCMediaType const RongRTCMediaTypeVideo;
RONGRTCLIB_EXTERN RongRTCMediaType const RongRTCMediaTypeAudio;

typedef NS_ENUM(NSInteger, RongRTCStreamState) {
    Equivocal = -1,
    Disabled = 0,
    Enabled = 1
};

/*!
 媒体流状态统计
 */
@interface RCRTCStreamStat : NSObject

/*!
 trackid
 */
@property (nonatomic, readonly) NSString *trackId;

/*!
 媒体类型
 */
@property (nonatomic, readonly) RongRTCMediaType mediaType;

/*!
 音量大小, 0 - 9表示音量高低
 */
@property (nonatomic, readonly) NSInteger audioLevel;

/*!
 码率
 */
@property (nonatomic, readonly) float bitRate;

/*!
 丢包率
 */
@property (nonatomic, readonly) float packetLoss;

/*!
 视频帧宽度
 */
@property (nonatomic, readonly) NSInteger frameWidth;

/*!
 视频帧高度
 */
@property (nonatomic, readonly) NSInteger frameHeight;

/*!
 往返时间
 */
@property (nonatomic, readonly) NSInteger rtt;

/*!
 帧率
 */
@property (nonatomic, readonly) NSInteger frameRate;

/*!
 抖动
 */
@property (nonatomic, readonly) NSInteger jitterReceived;

/*!
 编码名称
 */
@property (nonatomic, readonly) NSString *codecName;

/*!
 渲染延时
 */
@property (nonatomic, readonly) NSInteger renderDelayMs;

/*!
 编解码器名称
 */
@property (nonatomic, readonly) NSString* codecImplementationName;

/*!
 nacks 数量
 */
@property (nonatomic, readonly) NSInteger googNacksReceived;

/*!
 统计格式化字符串
 */
@property (nonatomic, readonly) NSString* formString;

@end


/*!
 sdk 状态统计表
 */
@interface RCRTCStatisticalForm : NSObject

/*!
 cpu 使用率
 */
@property (nonatomic, readonly) float cpuUsage;

/*!
 上行码率
 */
@property (nonatomic, readonly) float totalSendBitRate;

/*!
 下行码率
 */
@property (nonatomic, readonly) float totalRecvBitRate;

/*!
 系统 cpu 使用率
 */
@property (nonatomic, readonly) float cpuUsageOfOS;

/*!
 网络类型，wlan 4g
 */
@property (nonatomic, readonly) NSString* networkType;

/*!
 往返时间
 */
@property (nonatomic, readonly) NSInteger rtt;

/*!
 ip 地址
 */
@property (nonatomic, readonly) NSString *ipAddress;

/*!
 可接收带宽
 */
@property (nonatomic, readonly) NSInteger availableReceiveBandwidth;

/*!
 可发送带宽
 */
@property (nonatomic, readonly) NSInteger availableSendBandwidth;

/*!
 发送端丢包数
 */
@property (nonatomic, readonly) NSInteger packetsDiscardedOnSend;

/*!
 上行 媒体流状态统计 数组
 */
@property (nonatomic, readonly) NSArray<RCRTCStreamStat*>* sendStats;

/*!
 下行 媒体流状态统计 数组
 */
@property (nonatomic, readonly) NSArray<RCRTCStreamStat*>* recvStats;

/*!
 通过 trackId 查找到此 Track 所属的 UserId
 */
+ (NSString *)fetchUserIdFromTrackId:(NSString *)trackId;

@end


@interface RCRTCStatisticalForm (stat)

- (NSString*)rc_R5FormString;

- (NSString*)rc_NEWRC5FormString;

@end

NS_ASSUME_NONNULL_END
