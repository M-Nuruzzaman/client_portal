import 'package:client_portal/notifications/websocket/message_screen.dart';
import 'package:client_portal/presentation/screens/settings/VideoSettings.dart';
import 'package:client_portal/presentation/screens/withdraw/fund_withdraw_screen.dart';
import 'package:client_portal/presentation/screens/withdraw/withdraw_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../../logic/cubit/video_cubit/video_cubit.dart';
import '../../../utils/AppColors.dart';
import '../../../utils/custom_page_route.dart';
import '../../widgets/navigation_service.dart';
import '../../widgets/reusable_button.dart';
import '../auth/login_screen.dart';
import '../auth/registration_screen.dart';
import '../deposit/fund_deposit_screen.dart';
import '../registration/investor_code_screen.dart';
import 'advanced_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver, RouteAware {
  late VideoPlayerController _controller;
  final AdvancedDrawerController _drawerController = AdvancedDrawerController();
  bool _isPlaying = true;
  bool _isSoundOn = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = VideoPlayerController.asset('assets/video_night_mood.mp4')
      ..initialize().then((_) {
        setState(() {});
        _loadSettings();
      });

    _controller.setLooping(true);
    // Subscribe to RouteObserver
    WidgetsBinding.instance.addPostFrameCallback((_) {
      routeObserver.subscribe(this, ModalRoute.of(context)!);
    });
  }

  /// Load video settings from shared preferences
  Future<void> _loadSettings() async {
    // add here videoSettings
    await VideoSettings().initialize();
    setState(() {
      _isPlaying = VideoSettings().isVideoPlaying();
      _isSoundOn = VideoSettings().isSoundEnabled();
    });


    if (_isPlaying) {
      _controller.play();
    }
    _controller.setVolume(_isSoundOn ? 1 : 0);
    setState(() {});
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _drawerController.dispose();
    super.dispose();
  }

  @override
  void didPushNext() {
    // Navigated to another screen
    _controller.pause();
    _controller.setVolume(0); // Mute audio
  }

  @override
  void didPopNext() {
    // Came back to HomeScreen
    if (_isPlaying) {
      _controller.play();
      _controller.setVolume(_isSoundOn ? 1 : 0);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _controller.pause();
    } else if (state == AppLifecycleState.resumed && _isPlaying) {
      if (ModalRoute.of(context)?.isCurrent == true) {
        _controller.play();
        _controller.setVolume(_isSoundOn ? 1 : 0);
      }
    }
  }

  void _navigateToScreen(Widget page) {
    _controller.pause();
    Navigator.push(context, CustomPageRoute(page: page)).then((_) {
      if (_isPlaying) {
        _controller.play();
        _controller.setVolume(_isSoundOn ? 1 : 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VideoCubit, VideoState>(
      listener: (context, state) {
        setState(() {
          _isPlaying = state.isPlaying;
          _isSoundOn = state.isSoundOn;
        });

        if (_isPlaying) {
          _controller.play();
        } else {
          _controller.pause();
        }
        _controller.setVolume(_isSoundOn ? 1 : 0);
      },
      child: AdvancedDrawer(
        controller: _drawerController,
        backdropColor: AppColors.primaryColor,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
        animateChildDecoration: true,
        drawer: SafeArea(child: DrawerWidget(navigateToScreen: _navigateToScreen)),
        child: AnimatedBuilder(
          animation: _drawerController,
          builder: (context, child) {
            final isDrawerOpen = _drawerController.value.visible;
      
            if (isDrawerOpen) {
              _controller.pause();
            } else if (ModalRoute.of(context)?.isCurrent == true && _isPlaying) {
              _controller.play();
            }
      
            return ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              child: Scaffold(
                body: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_controller.value.isInitialized)
                      AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    Container(color: Colors.black.withOpacity(0.5)),
                    Positioned(
                      top: 30.0,
                      left: 10.0,
                      child: IconButton(
                        icon: const Icon(Icons.menu, size: 32, color: Colors.white),
                        onPressed: () => _drawerController.showDrawer(),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/LOGO.png', // Add your logo image in the assets folder
                              height: 70,
                              width: 280,
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              'Welcome to BRAC EPL',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            const SizedBox(height: 300),
                            CustomButton(
                              text: 'Open an Account',
                              onPressed: () => _navigateToScreen(const RegistrationScreen()),
                              backgroundColor: AppColors.accentColor,
                              textColor: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            CustomButton(
                              text: 'Login',
                              onPressed: () => _navigateToScreen(const LoginScreen()),
                              backgroundColor: AppColors.buttonColor,
                              textColor: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => _navigateToScreen(const InvestorCodeScreen()),
                              child: Text(
                                'Already have a BO account?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondaryBackgroundColor,
                                ),
                              ),
                            ),
                            // TextButton(
                            //   onPressed: () => _navigateToScreen(MessageScreen()),
                            //   child: Text(
                            //     'Websocket',
                            //     style: TextStyle(
                            //       fontSize: 16,
                            //       fontWeight: FontWeight.bold,
                            //       color: AppColors.secondaryBackgroundColor,
                            //     ),
                            //   ),
                            // ),
                            // TextButton(
                            //   onPressed: () => _navigateToScreen(PaymentPage()),
                            //   child: Text(
                            //     'Payment 1',
                            //     style: TextStyle(
                            //       fontSize: 16,
                            //       fontWeight: FontWeight.bold,
                            //       color: AppColors.secondaryBackgroundColor,
                            //     ),
                            //   ),
                            // ),
                            // TextButton(
                            //   onPressed: () => _navigateToScreen(FundDepositScreen()),
                            //   child: Text(
                            //     'Deposit',
                            //     style: TextStyle(
                            //       fontSize: 16,
                            //       fontWeight: FontWeight.bold,
                            //       color: AppColors.secondaryBackgroundColor,
                            //     ),
                            //   ),
                            // ),
                            // TextButton(
                            //   onPressed: () => _navigateToScreen(FundWithdrawScreen()),
                            //   child: Text(
                            //     'Withdraw',
                            //     style: TextStyle(
                            //       fontSize: 16,
                            //       fontWeight: FontWeight.bold,
                            //       color: AppColors.secondaryBackgroundColor,
                            //     ),
                            //   ),
                            // ),
                            // TextButton(
                            //   onPressed: () => _navigateToScreen(WithdrawHistoryScreen()),
                            //   child: Text(
                            //     'Withdraw History',
                            //     style: TextStyle(
                            //       fontSize: 16,
                            //       fontWeight: FontWeight.bold,
                            //       color: AppColors.secondaryBackgroundColor,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
