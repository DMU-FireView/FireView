import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppColors {
  static const Color background = Color(0xFFF5F6F8);
  static const Color textMain = Color(0xFF191F28);
  static const Color textSub = Color(0xFFB0B8C1);
  static const Color badgeBg = Color(0xFFF0F2F5);
  static const Color pointOrange = Color(0xFFFF512F);
  static const Color white = Colors.white;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _profileInfo = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData(); 
  }

  Future<void> _loadProfileData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final data = await Supabase.instance.client
          .from('profiles').select('full_name, experience_year, job_type, strength')
          .eq('id', user.id).single();

      setState(() {
        _profileInfo = '${data['full_name']}님, ${data['experience_year']}, ${data['job_type']} 희망';
      });
    } catch (e) {
      setState(() {
        _profileInfo = '김세나님, 신입, 웹 프론트엔드 희망'; // 임시 데이터
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0, leadingWidth: 130,
        leading: const Padding(
          padding: EdgeInsets.only(left: 20, top: 15),
          child: Text('FireView', style: TextStyle(color: AppColors.textMain, fontSize: 22, fontWeight: FontWeight.bold)),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(), 
            _buildDeadlineJobsSection(), 
            _buildLiveCommunitySection(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String nameToDisplay = '취린이님,'; 
    if (_profileInfo.isNotEmpty) nameToDisplay = '${_profileInfo.split('님')[0]}님,';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.badgeBg, borderRadius: BorderRadius.circular(4)),
            child: const Text('Lv.1 취린이', style: TextStyle(color: AppColors.textSub, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 10),
          Text('$nameToDisplay\n11월 합격까지 달려볼까요?', style: const TextStyle(color: AppColors.textMain, fontSize: 24, fontWeight: FontWeight.w900, height: 1.3)),
        ],
      ),
    );
  }

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
              Text('마감 임박 공채', style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Container(
          height: 140, padding: const EdgeInsets.only(left: 20),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: Supabase.instance.client.from('jobs').select(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.pointOrange));
              if (snapshot.hasError || (snapshot.data ?? []).isEmpty) return const Center(child: Text('공채가 없습니다.', style: TextStyle(color: AppColors.textSub)));
              final jobs = snapshot.data!;
              return ListView.separated(
                scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(), itemCount: jobs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final job = jobs[index];
                  return Container(
                    width: 140, padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))]),
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
                              child: Text(job['d_day'].toString(), style: const TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(job['company_name'].toString(), style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.bold, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
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

  Widget _buildLiveCommunitySection() {
    final posts = [{'title': '오늘 카카오 기출 모의고사 만점 받았습니다!', 'commentCount': 12, 'likeCount': 45}, {'title': '네트워크 OSI 7계층 쉽게 외우는 팁 공유', 'commentCount': 8, 'likeCount': 22}];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('실시간 커뮤니티', style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('더보기 >', style: TextStyle(color: AppColors.textSub, fontSize: 12))),
            ],
          ),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: posts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFF0F2F5))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(posts[index]['title']!.toString(), style: const TextStyle(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.bold, height: 1.3)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.chat_bubble_outline, color: AppColors.textSub, size: 16), const SizedBox(width: 5), Text('${posts[index]['commentCount']}', style: const TextStyle(color: AppColors.textSub, fontSize: 12)),
                        const SizedBox(width: 15),
                        Icon(Icons.favorite_border, color: AppColors.textSub, size: 16), const SizedBox(width: 5), Text('${posts[index]['likeCount']}', style: const TextStyle(color: AppColors.textSub, fontSize: 12)),
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
}