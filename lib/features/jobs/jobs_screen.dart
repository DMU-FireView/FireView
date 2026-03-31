import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'company_detail_screen.dart'; 

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
  final String baseUrl = "https://fireview-backend-bwaudkejhxeeg6fm.koreacentral-01.azurewebsites.net/api";
  final Set<String> _bookmarkedItems = {};

  @override
  void initState() {
    super.initState();
    _loadBookmarks(); 
  }

  Future<void> _loadBookmarks() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final data = await Supabase.instance.client.from('bookmarks').select('title').eq('user_id', user.id);
    setState(() {
      for (var item in data) {
        _bookmarkedItems.add(item['title'] as String); 
      }
    });
  }

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
          backgroundColor: AppColors.white, elevation: 0,
          title: const Text('채용/기업', style: TextStyle(color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            isScrollable: true, labelColor: AppColors.pointOrange, unselectedLabelColor: AppColors.textSub, indicatorColor: AppColors.pointOrange, indicatorWeight: 3, labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            tabs: [Tab(text: '🔥 공채'), Tab(text: '⭐ 강소'), Tab(text: '💡 프로그램'), Tab(text: '🛠️ 직무'), Tab(text: '💼 직업')],
          ),
        ),
        body: TabBarView(
          physics: const BouncingScrollPhysics(),
          children: [
            _buildPublicCompaniesTab(), _buildSmallGiantsTab(), _buildProgramsTab(), _buildDutiesTab(), _buildOccupationsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPublicCompaniesTab() {
    return FutureBuilder<http.Response>(
      future: http.get(Uri.parse('$baseUrl/public-companies')),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.pointOrange));
        try {
          final decodedData = json.decode(utf8.decode(snapshot.data!.bodyBytes));
          final items = _ensureList(decodedData['dhsOpenEmpHireInfoList']?['dhsOpenEmpHireInfo']);
          if (items.isEmpty) return const Center(child: Text('공채 기업이 없습니다.'));
          
          return _buildListView(items, (item) => _buildCardUI(
            logoUrl: item['regLogImgNm'], title: item['coNm'], badgeText: item['coClcdNm'], description: item['coIntroSummaryCont'],
            rawItemData: item, // 🚀 전체 데이터 묶음 전달!
            onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => CompanyDetailScreen(company: item))); }
          ));
        } catch (e) { return const Center(child: Text('에러가 발생했습니다.')); }
      },
    );
  }

  Widget _buildSmallGiantsTab() {
    return FutureBuilder<http.Response>(
      future: http.get(Uri.parse('$baseUrl/small-giants')),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.pointOrange));
        try {
          final decodedData = json.decode(utf8.decode(snapshot.data!.bodyBytes));
          final items = _ensureList(decodedData['smallGiantsList']?['smallGiant']);
          if (items.isEmpty) return const Center(child: Text('강소 기업이 없습니다.'));
          
          return _buildListView(items, (item) {
            final mappedCompanyData = {
              'regLogImgNm': null, 'coNm': item['coNm'], 'coClcdNm': item['sgBrandNm'],
              'coIntroSummaryCont': '주요 사업: ${item['coMainProd'] ?? '정보 없음'}',
              'coIntroCont': '🏢 산업군: ${item['superIndTpNm']} > ${item['indTpNm']}\n\n📍 주소: ${item['coAddr']}\n\n👥 직원수: ${item['alwaysWorkerCnt']}명\n\n💡 고용노동부가 공식 인증한 우수 강소기업입니다.',
              'homepg': null, 'busino': item['busiNo'], // 🚀 임금체불 조회를 위해 번호 포함!
            };
            return _buildCardUI(
              logoUrl: null, title: item['coNm'], badgeText: item['sgBrandNm'], description: '${item['superIndTpNm']} | ${item['regionNm']}\n직원수: ${item['alwaysWorkerCnt']}명',
              rawItemData: mappedCompanyData, // 🚀 맵핑된 데이터 전달!
              onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => CompanyDetailScreen(company: mappedCompanyData))); }
            );
          });
        } catch (e) { return const Center(child: Text('에러가 발생했습니다.')); }
      },
    );
  }

  Widget _buildProgramsTab() {
    return FutureBuilder<http.Response>(
      future: http.get(Uri.parse('$baseUrl/programs')),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        try {
          final decodedData = json.decode(utf8.decode(snapshot.data!.bodyBytes));
          final items = _ensureList(decodedData['empPgmSchdInviteList']?['empPgmSchdInvite']);
          if (items.isEmpty) return const Center(child: Text('프로그램 정보가 없습니다.'));
          
          return _buildListView(items, (item) {
            final mappedData = {
              'regLogImgNm': null, 'coNm': item['pgmNm'], 'coClcdNm': '취업프로그램',
              'coIntroSummaryCont': '📍 주관: ${item['orgNm']} | 🎯 대상: ${item['pgmTarget'] ?? '제한없음'}',
              'coIntroCont': '📅 교육 기간: ${item['pgmStdt']} ~ ${item['pgmEndt']}\n\n⏰ 교육 시간: ${item['openTime']} 시작 (${item['operationTime']})\n\n📍 교육 장소: ${item['openPlcCont'] ?? '정보 없음'}\n\n📚 상세 과정: ${item['pgmSubNm']}',
              'homepg': null,
            };
            return _buildCardUI(
              logoUrl: null, title: item['pgmNm'], badgeText: item['orgNm'], description: '[과정] ${item['pgmSubNm']}\n[기간] ${item['pgmStdt']} ~ ${item['pgmEndt']}',
              rawItemData: mappedData, // 🚀 전달!
              onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => CompanyDetailScreen(company: mappedData))); }
            );
          });
        } catch (e) { return const Center(child: Text('데이터를 불러오지 못했습니다.')); }
      },
    );
  }

  Widget _buildDutiesTab() {
    return FutureBuilder<http.Response>(
      future: http.get(Uri.parse('$baseUrl/duties')),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        try {
          final decodedData = json.decode(utf8.decode(snapshot.data!.bodyBytes));
          final Map<String, dynamic> resultObj = decodedData['result'] ?? {};
          final List<dynamic> items = resultObj.values.toList(); 
          if (items.isEmpty) return const Center(child: Text('직무 정보가 없습니다.'));
          
          return _buildListView(items, (item) {
            final mappedData = {
              'regLogImgNm': null, 'coNm': item['job_sdvn'], 'coClcdNm': 'NCS 직무정보',
              'coIntroSummaryCont': '분류: ${item['job_lcfn']} > ${item['job_mcn']} > ${item['job_scfn']}',
              'coIntroCont': '📝 [직무 정의]\n${item['ablt_def']}', 'homepg': null,
            };
            return _buildCardUI(
              logoUrl: null, title: item['job_sdvn'], badgeText: item['job_mcn'], description: item['ablt_def'],
              rawItemData: mappedData, // 🚀 전달!
              onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => CompanyDetailScreen(company: mappedData))); }
            );
          });
        } catch (e) { return const Center(child: Text('데이터를 불러오지 못했습니다.')); }
      },
    );
  }

  Widget _buildOccupationsTab() {
    return FutureBuilder<http.Response>(
      future: http.get(Uri.parse('$baseUrl/occupations')),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        try {
          final decodedData = json.decode(utf8.decode(snapshot.data!.bodyBytes));
          final items = _ensureList(decodedData['jobsList']?['jobList']);
          if (items.isEmpty) return const Center(child: Text('직업 정보가 없습니다.'));
          
          return _buildListView(items, (item) {
            final basicData = { // 직업은 API를 또 찔러야해서 임시 데이터 저장
              'regLogImgNm': null, 'coNm': item['jobNm'], 'coClcdNm': '직업 상세정보',
              'coIntroSummaryCont': '직업 상세정보입니다.', 'coIntroCont': '직업코드: ${item['jobCd']}', 'homepg': null,
            };
            return _buildCardUI(
              logoUrl: null, title: item['jobNm'], badgeText: item['jobClcdNM'], description: '직업코드: ${item['jobCd']}',
              rawItemData: basicData, // 🚀 임시 데이터 전달!
              onTap: () async {
                final response = await http.get(Uri.parse('$baseUrl/occupations/detail?jobCd=${item['jobCd']}'));
                final detail = json.decode(utf8.decode(response.bodyBytes))['jobSum'] ?? {}; 
                final mappedData = {
                  'regLogImgNm': null, 'coNm': item['jobNm'], 'coClcdNm': '직업 상세정보',
                  'coIntroSummaryCont': '💰 평균 임금: ${detail['sal'] ?? '정보 없음'}\n📈 직업 전망: ${detail['jobProspect'] ?? '정보 없음'}',
                  'coIntroCont': '🛠️ [하는 일]\n${detail['jobSum'] ?? '정보가 없습니다.'}\n\n🎓 [되는 길]\n${detail['way'] ?? '정보가 없습니다.'}', 'homepg': null,
                };
                if (context.mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => CompanyDetailScreen(company: mappedData)));
              }
            );
          });
        } catch (e) { return const Center(child: Text('데이터를 불러오지 못했습니다.')); }
      },
    );
  }

  Widget _buildListView(List<dynamic> items, Widget Function(dynamic) itemBuilder) {
    return ListView.separated(padding: const EdgeInsets.all(20), physics: const BouncingScrollPhysics(), itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(height: 16), itemBuilder: (context, index) => itemBuilder(items[index]));
  }

  // 🎨 공통 카드 UI (🚀 rawItemData 파라미터 추가됨!)
  Widget _buildCardUI({required dynamic logoUrl, required dynamic title, required dynamic badgeText, required dynamic description, required dynamic rawItemData, VoidCallback? onTap}) {
    final bool isBookmarked = _bookmarkedItems.contains(title);

    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 45, height: 45, decoration: BoxDecoration(color: AppColors.badgeBg, borderRadius: BorderRadius.circular(8)),
                  child: logoUrl != null && logoUrl.toString().isNotEmpty ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(logoUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.business, color: AppColors.textSub, size: 24))) : const Icon(Icons.business, color: AppColors.textSub, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title ?? '이름 없음', style: const TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 4), if (badgeText != null && badgeText.toString().isNotEmpty) Text(badgeText.toString(), style: const TextStyle(color: AppColors.pointOrange, fontSize: 12, fontWeight: FontWeight.w600))])),
                IconButton(
                  padding: EdgeInsets.zero, constraints: const BoxConstraints(), icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: AppColors.pointOrange, size: 26),
                  onPressed: () async {
                    final userId = Supabase.instance.client.auth.currentUser?.id;
                    if (userId == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.'))); return; }
                    if (isBookmarked) {
                      setState(() { _bookmarkedItems.remove(title); });
                      try { await Supabase.instance.client.from('bookmarks').delete().match({'user_id': userId, 'title': title}); } catch (e) { setState(() { _bookmarkedItems.add(title); }); }
                    } else {
                      setState(() { _bookmarkedItems.add(title); });
                      try {
                        await Supabase.instance.client.from('bookmarks').insert({
                          'user_id': userId, 'title': title,
                          'item_data': {
                            'logoUrl': logoUrl, 'title': title, 'badgeText': badgeText, 'description': description,
                            'fullData': rawItemData // 🚀 핵심!! 여기에 홈페이지랑 사업자번호 통째로 숨김!
                          }
                        });
                      } catch (e) { setState(() { _bookmarkedItems.remove(title); }); }
                    }
                  },
                ),
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