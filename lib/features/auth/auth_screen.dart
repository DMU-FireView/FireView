import 'package:flutter/foundation.dart'; // kIsWeb 사용을 위해 추가
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// 🚨 주의: AI가 넣었던 google_sign_in 패키지 임포트는 삭제했습니다!

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      // 🔥 이것이 최신 Supabase 공식 구글 로그인 방식입니다! (단 한 줄)
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        // 웹 브라우저일 때는 null, 모바일 앱일 때는 돌아올 딥링크 주소 지정
        redirectTo: kIsWeb ? null : 'fireview://login-callback',
      );
      
      // 웹(크롬)에서는 이 함수가 호출되면 아예 구글 로그인 웹페이지로 넘어갑니다.
      // 로그인 성공 시 알아서 앱으로 다시 돌아오며, 인증 상태가 갱신됩니다!
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF421010),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            const Icon(
              Icons.local_fire_department_rounded,
              size: 100,
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 20),
            const Text(
              'FireView',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const Text(
              '당신의 취업 열정에 불을 지피세요',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const Spacer(flex: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signInWithGoogle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                            height: 24,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.login),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Google로 시작하기',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '계속 진행하면 이용약관에 동의하는 것으로 간주됩니다.',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}