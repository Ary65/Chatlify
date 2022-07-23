import 'package:chatlify/features/auth/controller/auth_controller.dart';
import 'package:chatlify/features/auth/screens/user_information_screen.dart';
import 'package:chatlify/features/common/widgets/error.dart';
import 'package:chatlify/features/landing/screens/landing_screen.dart';
import 'package:chatlify/firebase_options.dart';
import 'package:chatlify/router.dart';
import 'package:chatlify/screens/mobile_layout_screen.dart';
import 'package:chatlify/utils/colors.dart';
import 'package:chatlify/utils/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Chatlify',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          color: appBarColor,
        ),
      ),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) => generateRoute(settings),
      home: ref.watch(userDataAuthProvider).when(
            data: (user) {  
              if (user == null) {
                return const LandingScreen();
              }
              return const MobileLayoutScreen();
            },
            error: (err, trace) {
              return ErrorScreen(
                error: err.toString(),
              );
            },
            loading: () => const Loader(),
          ),
      // home: const LandingScreen(),
    );
  }
}
