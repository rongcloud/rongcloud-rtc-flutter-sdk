class RCConnectionStatus {
  static const int Connected = 0;//连接成功
  static const int Connecting = 1;//连接中
  static const int KickedByOtherClient = 2;//该账号在其他设备登录，导致当前设备掉线，无法连接 IM
  static const int NetworkUnavailable = 3;//网络不可用
  static const int TokenIncorrect = 4;//token 非法，此时无法连接 IM，需重新获取 token
  static const int UserBlocked = 5;//用户被封禁，无法连接 IM
}