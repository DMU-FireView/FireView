import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppColors {
  static const Color background = Color(0xFFF5F6F8);
  static const Color textMain = Color(0xFF191F28);
  static const Color textSub = Color(0xFFB0B8C1);
  static const Color badgeBg = Color(0xFFF0F2F5);
  static const Color pointOrange = Color(0xFFFF512F);
  static const Color white = Colors.white;
}

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  // 💡 안드로이드 에뮬레이터면 'http://10.0.2.2:3000', 크롬(웹)이면 'http://localhost:3000'
  final String baseUrl = 'http://localhost:3000/api'; 

  @override
  Widget build(BuildContext context) {
    // 🚀 마법의 위젯: DefaultTabController가 스와이프 탭 기능을 알아서 다 해줍니다!
    return DefaultTabController(
      length: 2, // 💡 일단 완성된 2개(공채, 강소)만 세팅! 나중에 5개로 늘릴 수 있습니다.
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: const Text('채용/기업', style: TextStyle(color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.bold)),
          actions: [IconButton(icon: const Icon(Icons.search, color: AppColors.textMain), onPressed: () {})],
          // 탭바 메뉴 세팅
          bottom: const TabBar(
            labelColor: AppColors.pointOrange,
            unselectedLabelColor: AppColors.textSub,
            indicatorColor: AppColors.pointOrange,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            tabs: [
              Tab(text: '🔥 공채 기업'),
              Tab(text: '⭐ 강소 기업'),
            ],
          ),
        ),
        // 탭바를 눌렀을 때 보여줄 각각의 화면들 (순서대로 매칭됨)
        body: TabBarView(
          physics: const BouncingScrollPhysics(), // 스와이프할 때 쫀득한 효과
          children: [
            _buildPublicCompaniesTab(), // 1번 탭: 공채기업
            _buildSmallGiantsTab(),     // 2번 탭: 강소기업
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 1번 탭: 🔥 공채 기업 리스트
  // ==========================================
  Widget _buildPublicCompaniesTab() {
    return FutureBuilder<http.Response>(
      future: http.get(Uri.parse('$baseUrl/public-companies')),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.pointOrange));
        if (snapshot.hasError || !snapshot.hasData) return const Center(child: Text('데이터를 불러오지 못했습니다.'));
        
        final decodedData = json.decode(utf8.decode(snapshot.data!.bodyBytes));
        final List<dynamic> companies = decodedData['dhsOpenEmpHireInfoList']['dhsOpenEmpHireInfo'] ?? [];

        return ListView.separated(
          padding: const EdgeInsets.all(20), physics: const BouncingScrollPhysics(), itemCount: companies.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final company = companies[index];
            return _buildCardUI(
              logoUrl: company['regLogImgNm'],
              companyName: company['coNm'],
              badgeText: company['coClcdNm'], // 예: 공공기관
              description: company['coIntroSummaryCont'],
            );
          },
        );
      },
    );
  }

  // ==========================================
  // 2번 탭: ⭐ 강소 기업 리스트 (새로 만든 부분!)
  // ==========================================
  Widget _buildSmallGiantsTab() {
    return FutureBuilder<http.Response>(
      future: http.get(Uri.parse('$baseUrl/small-giants')),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.pointOrange));
        if (snapshot.hasError || !snapshot.hasData) return const Center(child: Text('데이터를 불러오지 못했습니다.'));
        
        final decodedData = json.decode(utf8.decode(snapshot.data!.bodyBytes));
        // 💡 강소기업은 JSON 구조가 살짝 다릅니다! 사장님이 주신 데이터에 맞춰서 쏙 빼옵니다.
        final List<dynamic> companies = decodedData['smallGiantsList']['smallGiant'] ?? [];

        return ListView.separated(
          padding: const EdgeInsets.all(20), physics: const BouncingScrollPhysics(), itemCount: companies.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final company = companies[index];
            return _buildCardUI(
              logoUrl: null, // 강소기업 API는 로고를 안 주니 null 처리
              companyName: company['coNm'],
              badgeText: company['sgBrandNm'], // 예: 노사문화우수기업
              description: '${company['superIndTpNm']} | ${company['regionNm']}\n직원수: ${company['alwaysWorkerCnt']}명', // 산업 + 지역 + 직원수 조합
            );
          },
        );
      },
    );
  }

  // ==========================================
  // 🎨 공통 카드 UI (디자인 통일)
  // ==========================================
  Widget _buildCardUI({required dynamic logoUrl, required dynamic companyName, required dynamic badgeText, required dynamic description}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🖼️ 로고 영역
              Container(
                width: 45, height: 45,
                decoration: BoxDecoration(color: AppColors.badgeBg, borderRadius: BorderRadius.circular(8)),
                child: logoUrl != null && logoUrl.toString().isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8), 
                        child: Image.network(logoUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.business, color: AppColors.textSub, size: 24))
                      )
                    : const Icon(Icons.business, color: AppColors.textSub, size: 24),
              ),
              const SizedBox(width: 12),
              // 텍스트 영역
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(companyName ?? '이름 없음', style: const TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    if (badgeText != null && badgeText.toString().isNotEmpty)
                      Text(badgeText.toString(), style: const TextStyle(color: AppColors.pointOrange, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Icon(Icons.bookmark_border, color: AppColors.textSub, size: 22),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description ?? '소개 내용이 없습니다.',
            style: const TextStyle(color: AppColors.textMain, fontSize: 14, height: 1.4),
            maxLines: 2, overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}