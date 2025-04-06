import 'package:client_portal/utils/GradiantBackground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/cubit/video_cubit/video_cubit.dart';
import '../../widgets/custom_appbar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Settings",
        titleColor: Colors.white,
        onLeadingButtonPressed: () {
          Navigator.pop(context);
        },
        showBackButton: true,
      ),
      body: GradientBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: BlocBuilder<VideoCubit, VideoState>(
            builder: (context, state) {
              print("isPlaying: ${state.isPlaying}");
              print("isSoundOn: ${state.isSoundOn}");
              return Column(
                children: [
                  _buildSettingCard(
                    title: "Play Video",
                    icon: state.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    iconColor:
                    state.isPlaying ? Colors.greenAccent : Colors.redAccent,
                    switchValue: state.isPlaying,
                    onToggle: (value) {
                      context.read<VideoCubit>().toggleVideoPlaying(value);
                    },
                  ),
                  _buildSettingCard(
                    title: "Mute Video",
                    icon: state.isSoundOn ? Icons.volume_up : Icons.volume_off,
                    iconColor:
                    state.isSoundOn ? Colors.greenAccent : Colors.redAccent,
                    switchValue: state.isSoundOn,
                    onToggle: (value) {
                      context.read<VideoCubit>().toggleMute(value);
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool switchValue,
    required ValueChanged<bool> onToggle,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: Colors.black26,
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: Icon(icon, color: iconColor, size: 32),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        trailing: Transform.scale(
          scale: 1.2,
          child: Switch(
            value: switchValue,
            onChanged: onToggle,
            activeColor: Colors.greenAccent,
            inactiveTrackColor: Colors.grey.shade400,
            inactiveThumbColor: Colors.redAccent,
          ),
        ),
      ),
    );
  }
}
