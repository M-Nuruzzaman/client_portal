part of 'video_cubit.dart';

class VideoState extends Equatable {
  final bool isPlaying;
  final bool isSoundOn;

  const VideoState({required this.isPlaying, required this.isSoundOn});

  factory VideoState.initial() {
    return const VideoState(isPlaying: true, isSoundOn: false);
  }

  VideoState copyWith({bool? isPlaying, bool? isSoundOn}) {
    return VideoState(
      isPlaying: isPlaying ?? this.isPlaying,
      isSoundOn: isSoundOn ?? this.isSoundOn,
    );
  }

  @override
  List<Object> get props => [isPlaying, isSoundOn];
}
