import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'bookmark_screen.dart';

class AppColors {
  static const Color background = Color(0xFFF5F6F8);
  static const Color textMain = Color(0xFF191F28);
  static const Color textSub = Color(0xFFB0B8C1);
  static const Color badgeBg = Color(0xFFF0F2F5);
  static const Color pointOrange = Color(0xFFFF512F);
  static const Color white = Colors.white;
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _expController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _strengthController = TextEditingController();

  bool _isLoading = true;
  String _userName = '취준생';
  String _userEmail = '';
  String _userTier = '브론즈'; // 💡 현재 등급 (기본 브론즈)

  @override
  void initState() {
    super.initState();
    _loadUserProfileAndCalculateTier(); // 👈 화면 켜질 때 정보+등급 계산!
  }

  @override
  void dispose() {
    _expController.dispose();
    _jobController.dispose();
    _strengthController.dispose();
    super.dispose();
  }

  // 🚀 핵심 마법: 프로필 가져오고 + 쓴 글/좋아요 세서 등급 올리기!
  Future<void> _loadUserProfileAndCalculateTier() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      setState(() {
        _userName = user.userMetadata?['full_name'] ?? '취준생';
        _userEmail = user.email ?? '';
      });

      // 1. 프로필 창고에서 내 정보 가져오기
      final data = await Supabase.instance.client
          .from('profiles').select().eq('id', user.id).maybeSingle(); 

      if (data != null) {
        _expController.text = data['experience_year'] ?? '';
        _jobController.text = data['job_type'] ?? '';
        _strengthController.text = data['strength'] ?? '';
        _userTier = data['tier'] ?? '브론즈';
      }

      // 2. 👑 운영자가 아니라면? -> 내가 쓴 글과 좋아요 개수 세서 등급 계산!
      if (_userTier != '운영자') {
        final posts = await Supabase.instance.client
            .from('posts').select('id, like_count').eq('author_name', _userName);

        int postCount = posts.length; // 내가 쓴 글 개수
        int totalLikes = 0;           // 내가 받은 좋아요 총합
        for (var post in posts) {
          totalLikes += (post['like_count'] as int? ?? 0);
        }

        // 💡 사장님이 정한 승급 기준!
        String calculatedTier = '브론즈';
        if (postCount >= 10 && totalLikes >= 10) {
          calculatedTier = '골드';
        } else if (postCount >= 5 && totalLikes >= 5) {
          calculatedTier = '실버';
        }

        // 등급이 올랐으면? 창고(DB) 업데이트하고 화면에도 반영!
        if (calculatedTier != _userTier) {
          await Supabase.instance.client
              .from('profiles').update({'tier': calculatedTier}).eq('id', user.id);
          _userTier = calculatedTier;
        }
      }
    } catch (e) {
      debugPrint('프로필 로드 에러: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('로그인 정보가 없습니다.');

      await Supabase.instance.client.from('profiles').upsert({
        'id': user.id,
        'full_name': _userName,
        'experience_year': _expController.text,
        'job_type': _jobController.text,
        'strength': _strengthController.text,
        'tier': _userTier, // 💡 등급 덮어씌워지지 않게 유지!
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✨ 프로필이 성공적으로 저장되었습니다!')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    // 등급별 라벨 색상 정하기
    Color tierColor = AppColors.textSub;
    if (_userTier == '실버') tierColor = Colors.blueGrey;
    if (_userTier == '골드') tierColor = Colors.amber;
    if (_userTier == '운영자') tierColor = Colors.black;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white, elevation: 0,
        title: const Text('내 프로필', style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.logout, color: AppColors.textSub), onPressed: _signOut)],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.pointOrange))
        : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 프로필 헤더
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30, backgroundColor: AppColors.pointOrange.withOpacity(0.2),
                      child: Text(_userName.substring(0, 1), style: const TextStyle(color: AppColors.pointOrange, fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('$_userName 님', style: const TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            // 🚀 뱃지 UI: 내 등급 띄워주기!
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: tierColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                              child: Text(_userTier, style: TextStyle(color: tierColor, fontSize: 11, fontWeight: FontWeight.w900)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(_userEmail, style: const TextStyle(color: AppColors.textSub, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                
                // 🚀 사장님(운영자) 전용 시크릿 버튼!!
                if (_userTier == '운영자') ...[
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      icon: const Icon(Icons.admin_panel_settings, color: AppColors.white),
                      label: const Text('관리자 페이지 이동', style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        // 나중에 관리자 화면 만들면 여기 연결!
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('👑 관리자님 환영합니다! (페이지 준비 중)')));
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.badgeBg, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.bookmark, color: AppColors.pointOrange, size: 24),
                    ),
                    title: const Text('내가 찜한 목록', style: TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textSub),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const BookmarkScreen()));
                    },
                  ),
                ),
                const SizedBox(height: 20),

                const Divider(color: AppColors.badgeBg),
                const SizedBox(height: 20),

                const Text('💡 이 정보들은 AI 자소서 생성 시 맞춤형 데이터로 활용됩니다.', style: TextStyle(color: AppColors.pointOrange, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                _buildInputField('경력 (예: 신입, 3년차)', _expController),
                const SizedBox(height: 16),
                _buildInputField('희망 직무 (예: 웹 프론트엔드, AI 엔지니어)', _jobController),
                const SizedBox(height: 16),
                _buildInputField('나의 핵심 강점 (예: UX에 대한 깊은 이해, 꼼꼼함)', _strengthController, maxLines: 2),
                
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.pointOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    onPressed: _saveProfile,
                    child: const Text('프로필 저장하기', style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller, maxLines: maxLines,
          decoration: InputDecoration(
            filled: true, fillColor: AppColors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.pointOrange)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}