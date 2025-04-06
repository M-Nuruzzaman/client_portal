import 'BaseSettings.dart';

class VideoSettings extends BaseSettings {
  static final VideoSettings _instance = VideoSettings._internal();
  factory VideoSettings() => _instance;
  VideoSettings._internal();

  static const String _videoPlayingKey = "video_playing";
  static const String _soundEnabledKey = "sound_enabled";

  Future<void> initialize() async => await initPrefs(); // Ensure prefs is ready

  Future<void> setVideoPlaying(bool isPlaying) async {
    await saveSetting(_videoPlayingKey, isPlaying);
  }

  bool isVideoPlaying() {
    return getSetting(_videoPlayingKey, defaultValue: true);
  }

  Future<void> setSoundEnabled(bool isEnabled) async {
    await saveSetting(_soundEnabledKey, isEnabled);
  }

  bool isSoundEnabled() {
    return getSetting(_soundEnabledKey, defaultValue: true);
  }
}
