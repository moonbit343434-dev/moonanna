// Audio manager — заглушка (можно подключить audioplayers позже)
class AudioManager {
  static final AudioManager _instance = AudioManager._();
  AudioManager._();
  factory AudioManager() => _instance;

  bool soundEnabled = true;
  bool musicEnabled = true;

  void playSwap() {}
  void playMatch() {}
  void playCombo() {}
  void playSpecial() {}
  void playLevelComplete() {}
  void playBoss() {}
  void playButton() {}
}
