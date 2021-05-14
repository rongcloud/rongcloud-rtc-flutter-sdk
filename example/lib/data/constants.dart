typedef void Callback(info);

typedef void StateCallback(code, info);

enum Mode {
  Meeting,
  Host,
  Audience,
}

const List<String> FPSStrings = [
  '10',
  '15',
  '25',
  '30',
];

const List<String> ResolutionStrings = [
  '144x176',
  '144x256',

  '180x180',
  '180x240',
  '180x320',

  '240x240',
  '240x320',

  '360x360',
  '360x480',
  '360x640',

  '480x480',
  '480x640',
  '480x720',

  '720x1280',

  '1080x1920',
];

const List<int> MinVideoKbps = [
  50,
  100,
  200,
  300,
];

const List<int> MaxVideoKbps = [
  300,
  500,
  800,
  1000,
  1200,
];

enum Role {
  Local,
  Remote,
  Audience,
}
