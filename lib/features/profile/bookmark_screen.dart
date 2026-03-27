import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../jobs/company_detail_screen.dart'; // 🚀 경로 완벽!

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(title: const Text('내가 찜한 목록 🔖', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: Supabase.instance.client.from('bookmarks').select().order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFFFF512F)));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('아직 찜한 항목이 없습니다!\n마음에 드는 공고를 북마크 해보세요.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)));

          final bookmarks = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(20), itemCount: bookmarks.length, separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final itemData = bookmarks[index]['item_data'];
              
              return InkWell(
                onTap: () {
                  // 🚀 DB에 통째로 숨겨뒀던 fullData 꺼내기!! (옛날 데이터면 기본값 사용)
                  final fullData = itemData['fullData'] ?? {
                    'regLogImgNm': itemData['logoUrl'], 'coNm': itemData['title'], 'coClcdNm': itemData['badgeText'],
                    'coIntroSummaryCont': '내가 찜한 정보입니다. 🔖', 'coIntroCont': itemData['description'], 'homepg': null,
                  };
                  
                  // 진짜 상세페이지로 이동!!
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CompanyDetailScreen(company: fullData)));
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(width: 45, height: 45, decoration: BoxDecoration(color: const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(8)), child: itemData['logoUrl'] != null ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(itemData['logoUrl'], fit: BoxFit.contain, errorBuilder: (_,__,___) => const Icon(Icons.business, color: Colors.grey))) : const Icon(Icons.business, color: Colors.grey)),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(itemData['title'] ?? '이름 없음', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 4), if (itemData['badgeText'] != null) Text(itemData['badgeText'], style: const TextStyle(color: Color(0xFFFF512F), fontSize: 12, fontWeight: FontWeight.w600))])),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.grey),
                            onPressed: () async {
                              await Supabase.instance.client.from('bookmarks').delete().match({'id': bookmarks[index]['id']});
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('북마크가 삭제되었습니다.')));
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BookmarkScreen())); 
                              }
                            },
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(itemData['description'] ?? '', style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}