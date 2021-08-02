import 'package:flutter/material.dart';

import 'src/views/chat_list_view.dart';
import 'src/views/dashboard_view.dart';
import 'src/views/hash_videos_view.dart';
import 'src/views/my_profile_view.dart';
import 'src/views/password_login_view.dart';
import 'src/views/redirect_view.dart';
import 'src/views/sign_up_view.dart';
import 'src/views/splash_screen_view.dart';
import 'src/views/users_view.dart';
import 'src/views/verify_otp_screen.dart';
import 'src/views/verify_profile.dart';
import 'src/views/video_recorder.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/splash-screen':
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => DashboardWidget());
      case '/password-login':
        return MaterialPageRoute(builder: (_) => PasswordLoginView());
      case '/sign-up':
        return MaterialPageRoute(builder: (_) => SignUpView());
      case '/verify-otp-screen':
        return MaterialPageRoute(builder: (_) => VerifyOTPView());
      case '/users':
        return MaterialPageRoute(builder: (_) => UsersView());
      case '/my-profile':
        return MaterialPageRoute(builder: (_) => MyProfileView());
      case '/verification-page':
        return MaterialPageRoute(builder: (_) => VerifyProfileView());
      case '/video-recorder':
        return MaterialPageRoute(builder: (_) => VideoRecorder());
      case '/user-chats':
        return MaterialPageRoute(builder: (_) => ChatListView());
      case '/hash-videos':
        return MaterialPageRoute(builder: (_) => HashVideosView());
      case '/redirect-page':
        return MaterialPageRoute(builder: (_) => RedirectPage(currentTab: args));
      default:
        // return MaterialPageRoute(builder: (_) => SplashScreen());
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: SafeArea(
              child: Center(
                child: Text('Route Error'),
              ),
            ),
          ),
        );
    }
  }
}
