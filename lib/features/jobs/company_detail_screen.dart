import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
class CompanyDetailScreen extends StatelessWidget {
  // 💡 이전 화면(리스트)에서 통째로 넘겨받을 기업 데이터 주머니!
  final Map<String, dynamic> company;

  const CompanyDetailScreen({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    // 주머니에서 필요한 데이터 쏙쏙 빼기
    final logoUrl = company['regLogImgNm'];
    final name = company['coNm'] ?? '이름 없음';
    final category = company['coClcdNm'];
    final summary = company['coIntroSummaryCont'];
    final description = company['coIntroCont'] ?? '상세 소개 내용이 없습니다.';
    final homepage = company['homepg'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text(name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // 뒤로가기 버튼 까맣게
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 헤더 영역 (로고 + 회사명 + 배지)
            Row(
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                  child: logoUrl != null && logoUrl.toString().isNotEmpty
                      ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(logoUrl, fit: BoxFit.contain, errorBuilder: (_,__,___) => const Icon(Icons.business, size: 40, color: Colors.grey)))
                      : const Icon(Icons.business, size: 40, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (category != null && category.toString().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: const Color(0xFFFF512F), borderRadius: BorderRadius.circular(6)),
                          child: Text(category, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 30),

            // 2. 한 줄 요약 영역
            if (summary != null && summary.toString().isNotEmpty) ...[
              const Text('✨ 핵심 요약', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(12)),
                child: Text(summary, style: const TextStyle(fontSize: 15, color: Color(0xFF1967D2), fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 30),
            ],

            // 3. 🏢 상세 소개 영역 (엄청 긴 텍스트가 들어가는 곳!)
            const Text('🏢 기업 소개', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))]),
              // 💡 텍스트가 엄청 기니까 줄바꿈(\r\n)을 플러터가 이해할 수 있게 변환해줍니다.
              child: Text(description.replaceAll('\r\n', '\n'), style: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF191F28))),
            ),
            const SizedBox(height: 40),

            // 4. 🌐 홈페이지 이동 버튼
       // 4. 🌐 홈페이지 이동 버튼
              if (homepage != null && homepage.toString().isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF191F28),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    // 🚀 여기에 진짜 브라우저 띄우는 마법 장착!
                    onPressed: () async {
                      final url = Uri.parse(homepage); // 인터넷 주소 형식으로 변환
                      if (await canLaunchUrl(url)) {
                        // 앱 밖의 진짜 브라우저(크롬, 사파리 등)로 시원하게 열어줍니다!
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      } else {
                        // 만약 링크가 깨졌거나 이상하면 에러 메시지 띄우기
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('홈페이지 주소가 유효하지 않습니다.')),
                        );
                      }
                    },
                    child: const Text('🌐 홈페이지 방문하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}