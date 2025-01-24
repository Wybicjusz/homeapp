import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homeapp/blocs/auth_bloc.dart';
import 'package:homeapp/blocs/weather_bloc.dart';
import 'package:homeapp/repositories/auth_repository.dart';
import 'package:homeapp/repositories/weather_repository.dart';
import 'package:homeapp/services/weather_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:homeapp/screens/login_screen.dart';
import 'package:homeapp/screens/dashboard_screen.dart';
import 'package:homeapp/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AuthRepository authRepository = AuthRepository();
  final WeatherRepository weatherRepository =
      WeatherRepository(weatherService: WeatherService());

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(authRepository),
        ),
        BlocProvider(
          create: (context) => WeatherBloc(weatherRepository),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter IoT App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/dashboard': (context) => DashboardScreen(),
        },
      ),
    );
  }
}
