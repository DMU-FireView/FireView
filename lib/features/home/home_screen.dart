import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ 디자인 공통 색상
class AppColors {
  static const Color background = Color(0xFFF5F6F8);
  static const Color textMain = Color(0xFF191F28);
  static const Color textSub = Color(0xFFB0B8C1);
  static const Color badgeBg = Color(0xFFF0F2F5);
  static const Color pointOrange = Color(0xFFFF512F);
  static const Color white = Colors.white;
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 실제 로그인된 유저 이름 가져오기
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.userMetadata?['full_name'] != null 
        ? '${user!.userMetadata!['full_name']}님,' 
        : '취준생님,'; 

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 130,
        leading: const Padding(
          padding: EdgeInsets.only(left: 20, top: 15),
          child: Text(
            'FireView',
            style: TextStyle(color: AppColors.textMain, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15, top: 10),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textMain, size: 28),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(userName),
            _buildDeadlineJobsSection(), // 🔥 여기가 진짜 DB랑 연결된 부분입니다!
            _buildLiveCommunitySection(),
            _buildQuickActionButtons(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // 1. 상단 헤더 영역
  Widget _buildHeader(String userName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.badgeBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Lv.1 취린이',
              style: TextStyle(color: AppColors.textSub, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$userName\n11월 합격까지 달려볼까요?',
            style: const TextStyle(
              color: AppColors.textMain,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // 2. 🔥 마감 임박 공채 섹션 (Supabase DB 실시간 연동!)
  Widget _buildDeadlineJobsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: [
              Icon(Icons.local_fire_department_rounded, color: AppColors.pointOrange, size: 20),
              SizedBox(width: 8),
              Text(
                '마감 임박 공채',
                style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Container(
          height: 140,
          padding: const EdgeInsets.only(left: 20),
          // 🚀 FutureBuilder: Supabase에서 데이터를 가져올 때까지 기다려주는 마법의 위젯
          child: FutureBuilder<List<Map<String, dynamic>>>(
            // jobs 테이블에서 모든 데이터(*)를 가져옵니다!
            future: Supabase.instance.client.from('jobs').select(),
            builder: (context, snapshot) {
              // 1. 데이터를 열심히 가져오는 중일 때 (로딩 빙글빙글)
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.pointOrange));
              }
              
              // 2. 에러가 났을 때
              if (snapshot.hasError) {
                return const Center(child: Text('데이터를 불러오지 못했습니다. 😢', style: TextStyle(color: AppColors.textSub)));
              }

              // 3. 데이터가 비어있을 때
              final jobAnnouncements = snapshot.data ?? [];
              if (jobAnnouncements.isEmpty) {
                return const Center(child: Text('진행 중인 공채가 없습니다.', style: TextStyle(color: AppColors.textSub)));
              }

              // 4. 데이터를 무사히 가져왔을 때! (화면에 뿌려주기)
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: jobAnnouncements.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final job = jobAnnouncements[index];
                  return Container(
                    width: 140,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Placeholder(fallbackHeight: 40, fallbackWidth: 40, color: AppColors.badgeBg),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(color: AppColors.textMain, borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                job['d_day'].toString(), // DB에서 가져온 d_day
                                style: const TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          job['company_name'].toString(), // DB에서 가져온 company_name
                          style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.bold, height: 1.2),
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // 3. 실시간 커뮤니티 섹션 (이건 아직 가짜 데이터)
  Widget _buildLiveCommunitySection() {
    final communityPosts = [
      {'title': '오늘 카카오 기출 모의고사 만점 받았습니다!', 'commentCount': 12, 'likeCount': 45},
      {'title': '네트워크 OSI 7계층 쉽게 외우는 팁 공유', 'commentCount': 8, 'likeCount': 22},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '실시간 커뮤니티',
                style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('더보기 >', style: TextStyle(color: AppColors.textSub, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: communityPosts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final post = communityPosts[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFF0F2F5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['title']!.toString(),
                      style: const TextStyle(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.bold, height: 1.3),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildPostStatIcon(Icons.chat_bubble_outline, post['commentCount']!),
                        const SizedBox(width: 15),
                        _buildPostStatIcon(Icons.favorite_border, post['likeCount']!),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPostStatIcon(IconData icon, Object count) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSub, size: 16),
        const SizedBox(width: 5),
        Text(count.toString(), style: const TextStyle(color: AppColors.textSub, fontSize: 12)),
      ],
    );
  }

  // 4. 단축키 버튼 섹션 (AI 퀴즈, AI 자소서)
  Widget _buildQuickActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildActionButton(Icons.psychology_outlined, 'AI 맞춤 퀴즈')),
          const SizedBox(width: 15),
          Expanded(child: _buildActionButton(Icons.history_edu_outlined, 'AI 자소서 초안')),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.badgeBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E2E5)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textSub, size: 30),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}