import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/theme.dart';
import 'routes/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCcB9lfr5kkG2OsJzsDm2hZtt-eppSUUmA",
      authDomain: "siraj-e4a11.firebaseapp.com",
      projectId: "siraj-e4a11",
      storageBucket: "siraj-e4a11.appspot.com",
      messagingSenderId: "331059270060",
      appId:
          "1:331059270060:web:ed36e163c1fd0e4e12ea09", // ← Correct web app ID
    ),
  );

  runApp(const ProviderScope(child: SirajApp()));
}

class SirajApp extends ConsumerWidget {
  const SirajApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Siraj',
      theme: SirajTheme.lightTheme,
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}
