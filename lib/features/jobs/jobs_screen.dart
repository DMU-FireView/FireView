import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 👈 Supabase 연결

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
  // 💡 데이터 불일치 해결: DB에 저장된 실제 태그 이름들로 카테고리 버튼을 완벽하게 맞췄습니다!
  final List<String> _categories = ['전체', '웹 프론트', '인프라', 'Mobile', 'Python', 'AI'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          '채용/기업',
          style: TextStyle(color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textMain),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. 카테고리 필터 영역 (여전히 오렌지색 상태 변화는 여기서 담당)
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? AppColors.white : AppColors.textSub,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.pointOrange,
                      backgroundColor: AppColors.badgeBg,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (selected) {
                        // 버튼을 누르면 화면을 다시 그리면서(_selectedCategory 변경), 아래 FutureBuilder가 데이터를 새로 가져오게 만듭니다.
                        setState(() => _selectedCategory = category);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          const SizedBox(height: 10),

          // 2. 🔥 대망의 진짜 DB 연결 리스트 영역 (필터링 로직 완벽 적용!)
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              // 🚀 마법의 필터링 로직! 
              // 선택된 게 '전체'면 다 가져오고, 아니면 tags 배열에 우리가 선택한 카테고리 글자가 포함된(contains) 녀석만 찾아와!
              future: _selectedCategory == '전체' 
                  ? Supabase.instance.client.from('jobs').select()
                  : Supabase.instance.client.from('jobs').select().contains('tags', [_selectedCategory]),
              builder: (context, snapshot) {
                // 로딩 중일 때 (주황색 동그라미)
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.pointOrange));
                }
                // 에러 났을 때
                if (snapshot.hasError) {
                  return const Center(child: Text('데이터를 불러오지 못했습니다.', style: TextStyle(color: AppColors.textSub)));
                }
                
                final jobList = snapshot.data ?? [];
                
                // 데이터가 없을 때 (필터링 결과가 없을 때)
                if (jobList.isEmpty) {
                  return const Center(child: Text('해당하는 직무의 공채가 없습니다.', style: TextStyle(color: AppColors.textSub)));
                }

                // 성공적으로 가져왔을 때!
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: jobList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final job = jobList[index];
                    return _buildJobCard(job);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 3. 개별 채용 공고 카드 위젯 (디자인은 이전과 동일)
  Widget _buildJobCard(Map<String, dynamic> job) {
    // DB에서 가져온 태그(List<dynamic>)를 플러터가 이해할 수 있는 List<String>으로 변환
    final List<dynamic> rawTags = job['tags'] ?? [];
    final List<String> tags = rawTags.map((e) => e.toString()).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.badgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.business, color: AppColors.textSub, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['company_name'].toString(),
                      style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job['location'].toString(),
                      style: const TextStyle(color: AppColors.textSub, fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.bookmark_border, color: AppColors.textSub, size: 22),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  job['title'].toString(),
                  style: const TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.bold, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTag(job['d_day'].toString(), isHighlight: true),
              ...tags.map((tag) => _buildTag(tag)).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlight ? AppColors.textMain : AppColors.badgeBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isHighlight ? AppColors.white : AppColors.textSub,
          fontSize: 11,
          fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}