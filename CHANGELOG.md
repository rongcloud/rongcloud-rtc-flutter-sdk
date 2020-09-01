## 4.0.2 -- 2020.09.01
* 与官网移动端 SDK 版本同步，Android & iOS 内部使用同版本号的 SDK
* 所有接口均与移动端 SDK 保持同步，名称参数保持一致，调用方式保持一致。
* 第一期暂时只支持音视频会议模式，开放 Flutter 层调用 Native SDK 之间的适配层源代码。
* 正式将 Flutter 作为主力平台开发，提升迭代速度，争取在个把月内追齐移动端 SDK 所有功能。
* 欢迎提意见及 Pull Request，加入一起开发。

## 2.0.1
* SDK:
* 1.指明依赖 RTCLib 3.2.2

## 2.0.0+1

* 适配 RTC 3.2.2 版本
* 与依赖的 `rongcloud_im_plugin` 版本保持一致

## 2.0.0

* 与依赖的 `rongcloud_im_plugin` 版本保持一致

## 1.1.1

* 与依赖的 `rongcloud_im_plugin` 版本保持一致

## 1.1.0+1

* 更新 `RTCLib`依赖版本

## 1.1.0
`从 1.1.0 开始为方便排查 Android 问题将 RTC Flutter SDK Android 的包名改为 io.rong.flutter.rtclib`
* 与依赖的 `rongcloud_im_plugin` 版本保持一致

## 1.0.7

* 与依赖的 `rongcloud_im_plugin` 版本保持一致

## 1.0.6

* 与依赖的 `rongcloud_im_plugin` 版本保持一致

## 1.0.5

* 与依赖的 `rongcloud_im_plugin` 版本保持一致
## 1.0.4

* 与依赖的 `rongcloud_im_plugin` 版本保持一致
 
## 1.0.3

* 与依赖的 `rongcloud_im_plugin` 版本保持一致

## 1.0.2

* 与依赖的 `rongcloud_im_plugin` 版本保持一致

## 1.0.1

* 与依赖的 `rongcloud_im_plugin` 版本保持一致

## 1.0.0

* 与依赖的 `rongcloud_im_plugin` 版本保持一致

## 0.9.9

* 与依赖的 `rongcloud_im_plugin` 版本保持一致

## 0.9.8

* 与依赖的 `rongcloud_im_plugin` 版本保持一致

## 0.9.7

* 与依赖的 `rongcloud_im_plugin` 版本保持一致


## 0.9.6+1

* 增加纯音频功能
* 增加[纯音频文档](https://github.com/rongcloud/rongcloud-rtc-flutter-sdk/blob/master/doc/AUDIO_ONLY.md)

## 0.9.6

* 与依赖的 `rongcloud_im_plugin` 版本保持一致

## 0.9.5

* 与依赖的 `rongcloud_im_plugin` 版本保持一致
* 更新文档

## 0.9.4

* 与依赖的 `rongcloud_im_plugin` 版本保持一致

## 0.9.3

* 与依赖的 `rongcloud_im_plugin` 版本保持一致

## 0.9.2

* 与依赖的 `rongcloud_im_plugin` 版本保持一致
* 实现的接口和回调如下

接口

```
初始化（im_plugin 接口）
连接（im_plugin 接口）
断开连接（im_plugin 接口）

加入 RTC 房间
退出 RTC 房间

设置录制参数
开启关闭采集

发布默认音视频流
取消发布默认音视频流

订阅音视频流
取消订阅音视频流

获取远端用户 id 列表

渲染本地视频 view
渲染远端视频 view

本地用户静音
本地用户切换摄像头
切换听筒、外放
移除视频 view
```

回调

```
本地加入房间结果回调
远端用户加入房间结果回调
远端用户离开房间回调
远端用户取消发布流
远端用户打开或关闭视频流
远端用户发布语音或者静音
远端用户第一帧到达
远端用户发布流成功回调
```