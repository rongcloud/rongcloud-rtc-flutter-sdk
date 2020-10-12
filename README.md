# 融云 Flutter SDK

## 版本说明

* 基于融云 RTCLib+IMLib 4.0.1 开发，可支持会议模式及直播模式。

## Git 提交规范

* 提交代码前设置自己的 user.name 和 user.email

  ```
  $ git config --global user.name <英文名>
  $ git config --global user.email <邮箱地址>
  ```

* 提交规范遵循：https://www.conventionalcommits.org/en/v1.0.0/
* 单次提交只做一件事儿，并用英文描述清楚。
* 提交代码要保证可编译通过，无已知 bug。
* 提交代码需要遵循编码规范，不要全局格式化非本次提交的代码，以免他人合并时带来不必要的麻烦。
* 如需批量格式化代码，需作为一次单独的提交，使用 `style: xxx` 来描述，同时不要有逻辑修改。

## 编码规范：

* 遵循官方代码编写规范：https://dart.dev/guides/language/effective-dart/style
* 上述文档中未说明部分，遵循 flutter 源码所使用规范。
* IDE 格式化自动换行距离设置为 120，默认的 80 过于严苛，对主流显示器不友好。

## 注释规范：

* 未完成部分用 `// TODO(git 用户名): 描述` 来说明。
* 已知问题用 `// FIXME(git 用户名): 描述` 来说明。

