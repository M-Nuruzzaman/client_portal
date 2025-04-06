import 'package:client_portal/presentation/screens/deposit/deposit_history_screen.dart';
import 'package:client_portal/presentation/screens/deposit/deposit_review_screen.dart';
import 'package:client_portal/presentation/screens/deposit/fund_deposit_screen.dart';
import 'package:client_portal/presentation/screens/home/home_screen.dart';
import 'package:client_portal/presentation/screens/settings/VideoSettings.dart';
import 'package:client_portal/presentation/widgets/navigation_service.dart';
import 'package:client_portal/utils/AppColors.dart';
import 'package:client_portal/utils/fcm_token_manager.dart';
import 'package:client_portal/utils/session_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'logic/cubit/video_cubit/video_cubit.dart';
import 'logic/cubit/websocket/websocket_cubit.dart';
import 'notifications/firebase/background_message_handler.dart';
import 'notifications/firebase/on_message_handler.dart';

// Add a GlobalKey for the navigator to use in showDialog
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SessionManager.init();
  await FcmTokenManager.init();
  final videoSettings = VideoSettings();
  await videoSettings.initPrefs();

  await Firebase.initializeApp();

  // 🔹 Set the background message handler
  // 🔹 Set up the background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // 🔹 Listen to foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Received a foreground message: ${message.notification?.title}");
    handleForegroundNotification(message, navigatorKey.currentContext!);
  });


  // 🔹 Get the FCM token
  String? fcmToken = await FirebaseMessaging.instance.getToken();
  print("FCM Token: $fcmToken");
  if (fcmToken != null) {
    // Save it using your session manager or FcmTokenManager
    await FcmTokenManager.saveFcmToken(fcmToken);
  }

  runApp(MyApp(videoSettings: videoSettings));
}

class MyApp extends StatelessWidget {
  final VideoSettings videoSettings;

  const MyApp({super.key, required this.videoSettings});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => VideoCubit(videoSettings)),
        BlocProvider<WebSocketCubit>(create: (context) => WebSocketCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Client Portal',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: AppColors.backgroundColor,
        ),
        // home: HomeScreen(),
        // home: MessageScreen(),
        // home: PaymentPage(),
        // home: PaymentDemo(),
        // home: FundDepositScreen(),
        home: DepositsScreen(),



        // home: DepositReviewScreen(),
        navigatorKey: navigatorKey, // Add the navigatorKey to MaterialApp
        navigatorObservers: [routeObserver],
      ),
    );
  }
}

