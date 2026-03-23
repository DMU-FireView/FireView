import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 마법의 한 줄: 현재 로그인된 구글 유저의 정보를 가져옵니다!
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('마이 프로필', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 프로필 아바타 이미지
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.orangeAccent.withOpacity(0.2),
              backgroundImage: user?.userMetadata?['avatar_url'] != null 
                  ? NetworkImage(user!.userMetadata!['avatar_url']) 
                  : null,
              child: user?.userMetadata?['avatar_url'] == null 
                  ? const Icon(Icons.person, size: 50, color: Colors.orangeAccent)
                  : null,
            ),
            const SizedBox(height: 20),
            
            // 구글에서 받아온 유저 이름
            Text(
              user?.userMetadata?['full_name'] ?? '이름 없음',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            // 구글에서 받아온 이메일
            Text(
              user?.email ?? '이메일 정보 없음',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            
            const SizedBox(height: 40),
            
            // 🔥 대망의 로그아웃 버튼
            ElevatedButton.icon(
              onPressed: () async {
                // 1. Supabase 로그아웃 실행
                await Supabase.instance.client.auth.signOut();
                
                // 2. 로그인 화면으로 쫓아내기 (라우터 주소에 맞게 '/auth' 또는 '/' 로 이동)
                if (context.mounted) {
                  context.go('/auth'); 
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('로그아웃'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}