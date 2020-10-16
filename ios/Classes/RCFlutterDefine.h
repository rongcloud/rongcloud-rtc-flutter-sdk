/*!
 资源类型
 */
typedef NS_ENUM(NSUInteger, RongFlutterMediaType) {
    /*!
     只有声音
     */
    RongFlutterMediaTypeAudio,
    /*!
     声音视频
     */
    RongFlutterMediaTypeVideo,

};

/*!
 当前流状态
 */
typedef NS_ENUM(NSUInteger, RongFlutterStreamState) {
    /*!
     流处于禁用状态, 不应该订阅, 即使订阅该流也不会收到音视频数据
     */
    RongFlutterStreamStateForbidden = 0,
    /*!
     流处于正常状态, 可以正常订阅
     */
    RongFlutterStreamStateNormal
};
