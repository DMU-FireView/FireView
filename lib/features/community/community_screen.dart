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

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  // 글쓰기 입력창 컨트롤러 (글자 적는 칸을 조종하는 리모컨)
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // 🪄 글쓰기 버튼을 누르면 밑에서 스르륵 올라오는 팝업(Bottom Sheet) 함수
  void _showWriteBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 키보드 올라올 때 화면을 위로 밀어올려줌
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            top: 24, left: 20, right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20, // 키보드 높이만큼 여백 확보
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('새 게시글 작성', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
              const SizedBox(height: 16),
              // 제목 입력창
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: '제목을 입력하세요',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.pointOrange)),
                ),
              ),
              const SizedBox(height: 12),
              // 내용 입력창
              TextField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: '내용을 입력하세요 (취업 고민, 꿀팁 등)',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.pointOrange)),
                ),
              ),
              const SizedBox(height: 16),
              // 등록 버튼
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.pointOrange),
                  onPressed: () async {
                    if (_titleController.text.isEmpty || _contentController.text.isEmpty) return;
                    
                    // 1. 현재 로그인한 구글 유저 이름 가져오기
                    final user = Supabase.instance.client.auth.currentUser;
                    final authorName = user?.userMetadata?['full_name'] ?? '익명 취준생';

                    // 2. Supabase 창고에 데이터 쾅! 쑤셔넣기
                    await Supabase.instance.client.from('posts').insert({
                      'author_name': authorName,
                      'title': _titleController.text,
                      'content': _contentController.text,
                    });

                    // 3. 입력창 비우고 팝업 스르륵 닫기
                    _titleController.clear();
                    _contentController.clear();
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('게시글 등록', style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          '실시간 커뮤니티',
          style: TextStyle(color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      // 🔥 카톡처럼 실시간으로 데이터를 갱신해 주는 마법의 StreamBuilder!
      body: StreamBuilder<List<Map<String, dynamic>>>(
        // 최신 글이 맨 위에 오도록 'created_at' 기준으로 내림차순(ascending: false) 정렬
        stream: Supabase.instance.client.from('posts').stream(primaryKey: ['id']).order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.pointOrange));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('데이터를 불러오지 못했습니다.'));
          }
          
          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return const Center(child: Text('첫 게시글을 작성해 보세요!', style: TextStyle(color: AppColors.textSub)));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: posts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final post = posts[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.badgeBg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['title'].toString(),
                      style: const TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post['content'].toString(),
                      style: const TextStyle(color: AppColors.textSub, fontSize: 13, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis, // 글이 길면 ... 으로 자르기
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '작성자: ${post['author_name']}',
                          style: const TextStyle(color: AppColors.textSub, fontSize: 11),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.favorite_border, size: 14, color: Colors.redAccent),
                            const SizedBox(width: 4),
                            Text('${post['like_count']}', style: const TextStyle(color: AppColors.textSub, fontSize: 12)),
                            const SizedBox(width: 12),
                            const Icon(Icons.chat_bubble_outline, size: 14, color: Colors.blueAccent),
                            const SizedBox(width: 4),
                            Text('${post['comment_count']}', style: const TextStyle(color: AppColors.textSub, fontSize: 12)),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
      // ✏️ 오른쪽 아래 둥둥 떠 있는 글쓰기 버튼 (Floating Action Button)
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.pointOrange,
        onPressed: _showWriteBottomSheet,
        icon: const Icon(Icons.edit, color: AppColors.white),
        label: const Text('글쓰기', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}