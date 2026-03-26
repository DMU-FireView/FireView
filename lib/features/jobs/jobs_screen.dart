import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'company_detail_screen.dart'; // 방금 만든 파일 이름!

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
  final String baseUrl = 'http://localhost:3000/api'; 

  // 💡 데이터가 1개일 때 Map으로 오는 현상 방지용 마법의 함수!
  List<dynamic> _ensureList(dynamic data) {
    if (data == null) return [];
    if (data is List) return data;
    return [data]; 
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: const Text('채용/기업', style: TextStyle(color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: AppColors.pointOrange,
            unselectedLabelColor: AppColors.textSub,
            indicatorColor: AppColors.pointOrange,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            tabs: [
              Tab(text: '🔥 공채'),
              Tab(text: '⭐ 강소'),
              Tab(text: '💡 프로그램'),
              Tab(text: '🛠️ 직무'),
              Tab(text: '💼 직업'),
            ],
          ),
        ),
        body: TabBarView(
          physics: const BouncingScrollPhysics(),
          children: [
            _buildPublicCompaniesTab(), // 1. 공채
            _buildSmallGiantsTab(),     // 2. 강소
            _buildProgramsTab(),        // 3. 프로그램 (완성)
            _buildDutiesTab(),          // 4. 직무 (완성)
            _buildOccupationsTab(),     // 5. 직업 (완성)
          ],
        ),
      ),
    );
  }

  // 1. 🔥 공채 기업 리스트
  Widget _buildPublicCompaniesTab() {
    return FutureBuilder<http.Response>(
      future: http.get(Uri.parse('$baseUrl/public-companies')),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.pointOrange));
        if (snapshot.hasError || !snapshot.hasData) return const Center(child: Text('데이터를 불러오지 못했습니다.'));
        try {
          final decodedData = json.decode(utf8.decode(snapshot.data!.bodyBytes));
          final items = _ensureList(decodedData['dhsOpenEmpHireInfoList']?['dhsOpenEmpHireInfo']);
          if (items.isEmpty) return const Center(child: Text('공채 기업이 없습니다.'));
          // 기존 코드 덮어쓰기!
          return _buildListView(items, (item) => _buildCardUI(
            logoUrl: item['regLogImgNm'], 
            title: item['coNm'], 
            badgeText: item['coClcdNm'], 
            description: item['coIntroSummaryCont'],
            // 🚀 카드를 눌렀을 때의 마법!
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CompanyDetailScreen(company: item), // 아이템 전체를 상세화면으로 토스!
                ),
              );
            }
          ));
        } catch (e) { return const Center(child: Text('에러가 발생했습니다.')); }
      },
    );
  }

  // 2. ⭐ 강소 기업 리스트
  Widget _buildSmallGiantsTab() {
    return FutureBuilder<http.Response>(
      future: http.get(Uri.parse('$baseUrl/small-giants')),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.pointOrange));
        if (snapshot.hasError || !snapshot.hasData) return const Center(child: Text('데이터를 불러오지 못했습니다.'));
        try {
          final decodedData = json.decode(utf8.decode(snapshot.data!.bodyBytes));
          final items = _ensureList(decodedData['smallGiantsList']?['smallGiant']);
          if (items.isEmpty) return const Center(child: Text('강소 기업이 없습니다.'));
          // 2번 탭: 강소기업 리스트 렌더링 부분 덮어쓰기!
          return _buildListView(items, (item) => _buildCardUI(
            logoUrl: null, 
            title: item['coNm'], 
            badgeText: item['sgBrandNm'], 
            description: '${item['superIndTpNm']} | ${item['regionNm']}\n직원수: ${item['alwaysWorkerCnt']}명',
            
            // 🚀 강소기업 전용 클릭 이벤트 장착!
            onTap: () {
              // 💡 마법의 포장지 교체: 강소기업 데이터를 상세페이지 규격에 맞게 변환!
              final mappedCompanyData = {
                'regLogImgNm': null, // 로고 없음
                'coNm': item['coNm'], // 회사명
                'coClcdNm': item['sgBrandNm'], // 뱃지 (예: 노사문화우수기업)
                'coIntroSummaryCont': '주요 사업: ${item['coMainProd'] ?? '정보 없음'}', // 한줄 요약에 주요 생산품 넣기!
                // 상세 소개칸에 주소, 직원수, 산업군 예쁘게 조합해서 넣기!
                'coIntroCont': '🏢 산업군: ${item['superIndTpNm']} > ${item['indTpNm']}\n\n'
                               '📍 주소: ${item['coAddr']}\n\n'
                               '👥 직원수: ${item['alwaysWorkerCnt']}명\n\n'
                               '💡 고용노동부가 공식 인증한 우수 강소기업입니다.',
                'homepg': null, // 강소기업 API는 홈페이지 주소를 안 주니 버튼은 자동으로 숨겨집니다!
              };

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CompanyDetailScreen(company: mappedCompanyData), // 포장한 데이터 토스!
                ),
              );
            }
          ));
        } catch (e) { return const Center(child: Text('에러가 발생했습니다.')); }
      },
    );
  }

  // 3. 💡 구직자취업역량 강화프로그램 (매뉴얼 적용 완벽 연동!)
  Widget _buildProgramsTab() {
    return FutureBuilder<http.Response>(
      future: http.get(Uri.parse('$baseUrl/programs')),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        try {
          final decodedData = json.decode(utf8.decode(snapshot.data!.bodyBytes));
          // 매뉴얼: <empPgmSchdInviteList> 안의 <empPgmSchdInvite>
          final items = _ensureList(decodedData['empPgmSchdInviteList']?['empPgmSchdInvite']);
          if (items.isEmpty) return const Center(child: Text('프로그램 정보가 없습니다.'));
          
          return _buildListView(items, (item) => _buildCardUI(
            logoUrl: null, 
            title: item['pgmNm'], // 프로그램명
            badgeText: item['orgNm'], // 센터명
            description: '[과정] ${item['pgmSubNm']}\n[기간] ${item['pgmStdt']} ~ ${item['pgmEndt']}' 
          ));
        } catch (e) { return const Center(child: Text('데이터를 불러오지 못했습니다.')); }
      },
    );
  }

  // 4. 🛠️ 직무정보 (NCS 데이터 - JSON 처리 완벽 연동!)
  Widget _buildDutiesTab() {
    return FutureBuilder<http.Response>(
      future: http.get(Uri.parse('$baseUrl/duties')),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        try {
          final decodedData = json.decode(utf8.decode(snapshot.data!.bodyBytes));
          // 매뉴얼: JSON의 result 안의 값들을 가져옵니다.
          final Map<String, dynamic> resultObj = decodedData['result'] ?? {};
          final List<dynamic> items = resultObj.values.toList(); // 딕셔너리를 리스트로 변환

          if (items.isEmpty) return const Center(child: Text('직무 정보가 없습니다.'));
          
          return _buildListView(items, (item) => _buildCardUI(
            logoUrl: null, 
            title: item['job_sdvn'], // NCS 능력단위명
            badgeText: item['job_mcn'], // NCS 중분류명
            description: item['ablt_def'] // 능력단위 정의
          ));
        } catch (e) { return const Center(child: Text('데이터를 불러오지 못했습니다.')); }
      },
    );
  }

  // 5. 💼 직업정보 (매뉴얼 적용 완벽 연동!)
  Widget _buildOccupationsTab() {
    return FutureBuilder<http.Response>(
      future: http.get(Uri.parse('$baseUrl/occupations')),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        try {
          final decodedData = json.decode(utf8.decode(snapshot.data!.bodyBytes));
          // 매뉴얼: <jobsList> 안의 <jobList>
          final items = _ensureList(decodedData['jobsList']?['jobList']);
          if (items.isEmpty) return const Center(child: Text('직업 정보가 없습니다.'));
          
          return _buildListView(items, (item) => _buildCardUI(
            logoUrl: null, 
            title: item['jobNm'], // 직업명
            badgeText: item['jobClcdNM'], // 직업분류명
            description: '직업코드: ${item['jobCd']}' 
          ));
        } catch (e) { return const Center(child: Text('데이터를 불러오지 못했습니다.')); }
      },
    );
  }

  // 🎨 리스트뷰 생성 공통 함수 (코드 길이 단축)
  Widget _buildListView(List<dynamic> items, Widget Function(dynamic) itemBuilder) {
    return ListView.separated(
      padding: const EdgeInsets.all(20), physics: const BouncingScrollPhysics(), itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => itemBuilder(items[index]),
    );
  }

  // 🎨 공통 카드 UI
 // 🎨 공통 카드 UI (클릭 기능 추가!)
  // 💡 onTap 이라는 '눌렀을 때 할 행동'을 파라미터로 추가로 받습니다.
  Widget _buildCardUI({required dynamic logoUrl, required dynamic title, required dynamic badgeText, required dynamic description, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap, // 카드를 누르면 넘겨받은 행동을 실행!
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 45, height: 45,
                  decoration: BoxDecoration(color: AppColors.badgeBg, borderRadius: BorderRadius.circular(8)),
                  child: logoUrl != null && logoUrl.toString().isNotEmpty
                      ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(logoUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.business, color: AppColors.textSub, size: 24)))
                      : const Icon(Icons.business, color: AppColors.textSub, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title ?? '이름 없음', style: const TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      if (badgeText != null && badgeText.toString().isNotEmpty)
                        Text(badgeText.toString(), style: const TextStyle(color: AppColors.pointOrange, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                // 상세페이지로 넘어간다는 걸 직관적으로 보여주는 화살표 아이콘으로 변경!
                const Icon(Icons.chevron_right, color: AppColors.textSub, size: 24),
              ],
            ),
            const SizedBox(height: 16),
            Text(description ?? '', style: const TextStyle(color: AppColors.textMain, fontSize: 14, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}