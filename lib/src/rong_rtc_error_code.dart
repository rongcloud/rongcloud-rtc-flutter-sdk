/**
 * 音视频错误码定义
 *
 * 服务器返回错误以 4 开头，后两位是业务代码，最后两位是错误码 4XXXX，如 400XX 基础连接部分
 * 本地返回错误以 5 开头，后两位是业务代码，最后两位是错误码 5XXXX，如 500XX 初始化基础连接部分
 */

class RongRTCCode {

  static const int Success  = 0;

  static const int JoinRoomError = 40000;
  
  /// 加入房间失败，不再房间中
  static const int NotInRoom = 40001;

  /// server 内部错误
  static const int InternalError = 40002;

  /// 没有匹配的 RTC room
  static const int NoMatchedRoom = 40003;

  /// 非法的用户 id
  static const int InvalidUserId = 40004;

  /// 重复加入已经存在的 RTC room，表示在服务端重复加入
  static const int JoinRepeatedRoom = 40005;

  /// 初始化失败, 信令服务（IM Server）未连接
  static const int SignalServerNotConnect = 50000;

  /// 参数错误
  static const int ParameterError = 50001;

  /// 加入相同房间错误，表示用户在客户端重复加入相同的房间
  static const int JoinToSameRoom = 50002;

  /// HTTP 请求超时
  static const int HttpTimeoutError = 50010;

  /// HTTP 响应错误（含 500，404，405 等错误）
  static const int HttpResponseError = 50011;

  /// HTTP 请求错误（含网络不可达，请求未能为能正常发出）
  static const int HttpRequestError = 50012;

  /// 发布重复资源
  static const int PublishDuplicateResources = 50020;

  /// 初步会话协商错误，没有消息的音视频参数
  static const int SessionDegotiateOfferError = 50021;

  /// 会话协商错误，协商数据不匹配或者其他问题
  static const int SessionDegotiateSetRemoteError = 50022;

  /// 发布的流的个数已经到达上限
  static const int PublishStreamsHasReachedMaxCount = 50023;

  /// 取消发布不存在的资源
  static const int UnpublishUnexistStream = 50024;

  /// 订阅不存在的音视频资源
  static const int SubscribeNotExistResources = 50030;

  /// 资源重复订阅
  static const int SubscribeDuplicateResources = 50031;

  /// 取消订阅不存在的音视频资源
  static const int UnsubscribeNotExistResouce = 50032;

  /// SDK 内部业务逻辑错误码
  static const int SDKInternalError = 50071;

}