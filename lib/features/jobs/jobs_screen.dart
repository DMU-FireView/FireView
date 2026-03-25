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
  String _selectedCategory = '전체';
  // 💡 고용24 데이터에 맞게 카테고리 대공사!
  final List<String> _categories = ['전체', '공공기관', '대기업', '공기업', '중견기업', '외국계기업'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text('채용/기업', style: TextStyle(color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.search, color: AppColors.textMain), onPressed: () {})],
      ),
      body: Column(
        children: [
          // 1. 카테고리 필터 영역
          Container(
            color: AppColors.white, padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(), padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category, style: TextStyle(color: isSelected ? AppColors.white : AppColors.textSub, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      selected: isSelected, selectedColor: AppColors.pointOrange, backgroundColor: AppColors.badgeBg, side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (selected) => setState(() => _selectedCategory = category),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 2. 🔥 대망의 고용24 API 연결 영역
          Expanded(
            child: FutureBuilder<http.Response>(
              future: http.get(Uri.parse('http://localhost:3000/api/public-companies')), // Node.js 찌르기!
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.pointOrange));
                if (snapshot.hasError || !snapshot.hasData) return const Center(child: Text('데이터를 불러오지 못했습니다.', style: TextStyle(color: AppColors.textSub)));
                
                final decodedData = json.decode(utf8.decode(snapshot.data!.bodyBytes));
                final List<dynamic> allCompanies = decodedData['dhsOpenEmpHireInfoList']['dhsOpenEmpHireInfo'] ?? [];

                // 🚀 마법의 프론트엔드 필터링! 선택한 카테고리만 걸러냅니다.
                final filteredCompanies = _selectedCategory == '전체' 
                    ? allCompanies 
                    : allCompanies.where((c) => c['coClcdNm'] == _selectedCategory).toList();

                if (filteredCompanies.isEmpty) return const Center(child: Text('해당하는 형태의 기업이 없습니다.', style: TextStyle(color: AppColors.textSub)));

                return ListView.separated(
                  padding: const EdgeInsets.all(20), physics: const BouncingScrollPhysics(), itemCount: filteredCompanies.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) => _buildCompanyCard(filteredCompanies[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 3. 고용24 데이터 전용 기업 카드 위젯!
  Widget _buildCompanyCard(dynamic company) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🖼️ 기업 로고 (💡 여기에 errorBuilder 방패 장착 완료!)
              Container(
                width: 45, height: 45,
                decoration: BoxDecoration(color: AppColors.badgeBg, borderRadius: BorderRadius.circular(8)),
                child: company['regLogImgNm'] != null && company['regLogImgNm'].toString().isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8), 
                        child: Image.network(
                          company['regLogImgNm'], 
                          fit: BoxFit.contain,
                          // 이미지가 깨졌을 때 기본 빌딩 아이콘을 보여주는 마법의 코드!
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.business, color: AppColors.textSub, size: 24);
                          },
                        )
                      )
                    : const Icon(Icons.business, color: AppColors.textSub, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(company['coNm'] ?? '이름 없음', style: const TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(company['coClcdNm'] ?? '분류 없음', style: const TextStyle(color: AppColors.pointOrange, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(), icon: const Icon(Icons.bookmark_border, color: AppColors.textSub, size: 22), onPressed: () {}),
            ],
          ),
          const SizedBox(height: 16),
          // 📝 기업 소개 요약
          Text(
            company['coIntroSummaryCont'] ?? '소개 내용이 없습니다.',
            style: const TextStyle(color: AppColors.textMain, fontSize: 14, height: 1.4),
            maxLines: 2, overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}