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
