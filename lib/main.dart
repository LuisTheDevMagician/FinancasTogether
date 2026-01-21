import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import 'blocs/filter/filter_bloc.dart';
import 'blocs/user/user_bloc.dart';
import 'blocs/user/user_event.dart';
import 'blocs/category/category_bloc.dart';
import 'blocs/category/category_event.dart';
import 'blocs/transaction/transaction_bloc.dart';
import 'repositories/user_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/transaction_repository.dart';
import 'ui/screens/home_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Obter tema salvo
  final String? themeMode = prefs.getString(AppConstants.prefKeyThemeMode);
  final ThemeMode initialThemeMode = themeMode == 'dark'
      ? ThemeMode.dark
      : themeMode == 'light'
          ? ThemeMode.light
          : ThemeMode.system;

  runApp(MyApp(key: appKey, initialThemeMode: initialThemeMode));
}

// Global key para acessar o state do app
final GlobalKey<State<MyApp>> appKey = GlobalKey<State<MyApp>>();

class MyApp extends StatefulWidget {
  final ThemeMode initialThemeMode;

  const MyApp({super.key, required this.initialThemeMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  // Alternar tema
  Future<void> toggleTheme() async {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });

    // Salvar preferência
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.prefKeyThemeMode,
      _themeMode == ThemeMode.light ? 'light' : 'dark',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => FilterBloc()),
        BlocProvider(
          create: (context) =>
              UserBloc(repository: UserRepository())..add(const LoadUsers()),
        ),
        BlocProvider(
          create: (context) => CategoryBloc(repository: CategoryRepository())
            ..add(const LoadCategories()),
        ),
        BlocProvider(
          create: (context) =>
              TransactionBloc(repository: TransactionRepository()),
        ),
      ],
      child: MaterialApp(
        title: 'Finanças Together',
        debugShowCheckedModeBanner: false,

        // Tema
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,

        // Localização
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
        locale: const Locale('pt', 'BR'),

        // Tela inicial
        home: const HomeScreen(),
      ),
    );
  }
}
