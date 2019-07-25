# 融云 RTC Flutter Plugin 项目的 APP 层代码

该目录是基于 `rongcloud_rtc_plugin` 开发 iOS/Android 的项目源码

如何运行改项目？

终端进入项目路径执行下面命令获取相关的依赖

`$ flutter packages get`

# iOS 项目

使用 iOS 设备连接电脑，最好用真机，记得修改项目的 bundle 为自己的，方便真机运行

## 使用 Flutter 命令运行 iOS 项目

进入 `example/` 目录执行 `flutter run` 命令，第一次可能会花费较长的时间（因为 Flutter 会自动从 pod 仓库下载融云 IMLib 和 RTCLib 的 iOS SDK，如果时间较长不想等待，可以自行进入 `example/ios/` 目录，执行 `pod update` 命令，手动下载 iOS SDK）

当启动了之后就可以正常使用了

## 使用 Xcode 运行 iOS 项目

按照上一步骤执行完 `flutter run` 命令之后， `example/ios/` 目录会生成 Runner.xcworkspace 文件，Xcode 直接打开即可

# Android 项目

使用 Android 设备连接电脑，最好用真机

## 使用 Flutter 命令运行 Android 项目

进入 `example/` 目录执行 `flutter run` 命令，第一次可能会花费较长的时间（因为 Flutter 会自动从 maven 仓库下载融云 IMLib 和 RTCLib 的 Android SDK）

当命令执行完之后就可以正常使用了

## 使用 Android Studio 运行 Android 项目

使用 Android Studio 打开 `example/android/` 目录即可


常见问题

1.执行 `flutter run` 命令报错

必须确保在 `example` 目录执行 `flutter run` 命令

2.执行 `flutter run` 弹出下面的内容

```
➜  example git:(dev) ✗ flutter run
More than one device connected; please specify a device with the '-d <deviceId>' flag, or use '-d all' to act on all devices.

SM G6200      • 9789da1aa5                               • android-arm64 • Android 8.1.0 (API 27)
“Sin”的 iPhone • 40106a0c0583066c9f22bdaae546d55e25449c85 • ios           • iOS 12.1.4
```

这是因为 `flutter run` 只有一个连接设备的时候使用，如果有多个设备就会有这样的问题，此时需要加 `-d` 参数加设备 id 来指定设备，内容的第二列就是设备 id，如执行

```
$ flutter run -d 9789da1aa5
```

3.iOS 执行报错 `[VERBOSE-2:platform_view_layer.cc(28)] Trying to embed a platform view but the PaintContext does not support embedding`

打开需要使用 Platform View 的 iOS 工程，在`Info.plist`中添加字段`io.flutter.embedded_views_preview`，其值为`YES`。

4.Android 无法 IM ，报错 `dlopen failed: library "libsqlite.so" not found`

参照 https://support.rongcloud.cn/ks/NTQw