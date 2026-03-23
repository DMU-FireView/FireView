import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/router.dart';

Future<void> main() async {
  // 1. Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 2. 환경변수(.env) 로드
  await dotenv.load(fileName: ".env");

  // 3. Supabase 초기화 (dotenv 사용)
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // 4. ProviderScope로 감싸서 실행
  runApp(
    const ProviderScope(
      child: FireViewApp(),
    ),
  );
}

class FireViewApp extends StatelessWidget {
  const FireViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FireView',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      // Step 2에서 정의한 GoRouter 연결
      routerConfig: router,
    );
  }
}
