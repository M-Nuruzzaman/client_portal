import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../presentation/screens/settings/VideoSettings.dart';

part 'video_state.dart';

class VideoCubit extends Cubit<VideoState> {
  final VideoSettings _videoSettings;

  VideoCubit(this._videoSettings) : super(VideoState.initial()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _videoSettings.initPrefs();
    bool isPlaying = _videoSettings.isVideoPlaying();
    bool isSoundOn = _videoSettings.isSoundEnabled();
    emit(state.copyWith(isPlaying: isPlaying, isSoundOn: isSoundOn));
  }

  Future<void> toggleVideoPlaying(bool isPlaying) async {
    await _videoSettings.setVideoPlaying(isPlaying);
    emit(state.copyWith(isPlaying: isPlaying));
  }

  Future<void> toggleMute(bool isSoundOn) async {
    await _videoSettings.setSoundEnabled(isSoundOn);
    emit(state.copyWith(isSoundOn: isSoundOn));
  }
}
