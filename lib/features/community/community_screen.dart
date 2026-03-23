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

// ==========================================
// 1. 커뮤니티 메인 화면 (게시글 리스트)
// ==========================================
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  void _showWriteBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            top: 24, left: 20, right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: '제목을 입력하세요', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(hintText: '내용을 입력하세요', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.pointOrange),
                  onPressed: () async {
                    if (_titleController.text.isEmpty || _contentController.text.isEmpty) return;
                    final user = Supabase.instance.client.auth.currentUser;
                    final authorName = user?.userMetadata?['full_name'] ?? '익명 취준생';

                    await Supabase.instance.client.from('posts').insert({
                      'author_name': authorName,
                      'title': _titleController.text,
                      'content': _contentController.text,
                    });
                    _titleController.clear();
                    _contentController.clear();
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('게시글 등록', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
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
        backgroundColor: AppColors.white, elevation: 0,
        title: const Text('실시간 커뮤니티', style: TextStyle(color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client.from('posts').stream(primaryKey: ['id']).order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.pointOrange));
          final posts = snapshot.data!;
          if (posts.isEmpty) return const Center(child: Text('첫 게시글을 작성해 보세요!', style: TextStyle(color: AppColors.textSub)));

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: posts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final post = posts[index];
              // 🚀 카드를 터치하면 상세 화면으로 넘어가게 해주는 마법의 GestureDetector!
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.badgeBg)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post['title'].toString(), style: const TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(post['content'].toString(), style: const TextStyle(color: AppColors.textSub, fontSize: 13, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('작성자: ${post['author_name']}', style: const TextStyle(color: AppColors.textSub, fontSize: 11)),
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
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.pointOrange,
        onPressed: _showWriteBottomSheet,
        icon: const Icon(Icons.edit, color: AppColors.white),
        label: const Text('글쓰기', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ==========================================
// 2. 🔥 게시글 상세 화면 (본문 + 댓글 리스트)
// ==========================================
class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white, elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textMain), // 뒤로가기 버튼
        title: const Text('게시글 상세', style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // 본문 영역
          Container(
            width: double.infinity, color: AppColors.white, padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.post['title'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                const SizedBox(height: 12),
                Text('작성자: ${widget.post['author_name']}', style: const TextStyle(fontSize: 12, color: AppColors.textSub)),
                const Divider(height: 30, color: AppColors.badgeBg),
                Text(widget.post['content'], style: const TextStyle(fontSize: 15, color: AppColors.textMain, height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          
          // 실시간 댓글 리스트 영역
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              // 🚀 현재 게시글(post_id)에 달린 댓글만 가져옵니다!
              stream: Supabase.instance.client
                  .from('comments')
                  .stream(primaryKey: ['id'])
                  .eq('post_id', widget.post['id'])
                  .order('created_at', ascending: true),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.pointOrange));
                final comments = snapshot.data!;
                if (comments.isEmpty) return const Center(child: Text('첫 댓글을 남겨보세요!', style: TextStyle(color: AppColors.textSub)));
                
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: comments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(comment['author_name'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSub)),
                          const SizedBox(height: 4),
                          Text(comment['content'], style: const TextStyle(fontSize: 14, color: AppColors.textMain)),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 하단 댓글 입력창
          Container(
            color: AppColors.white,
            padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: '댓글을 입력하세요...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      filled: true, fillColor: AppColors.badgeBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.pointOrange),
                  onPressed: () async {
                    if (_commentController.text.isEmpty) return;
                    final user = Supabase.instance.client.auth.currentUser;
                    final authorName = user?.userMetadata?['full_name'] ?? '익명 취준생';
                    
                    // 🚀 Supabase 댓글 창고에 데이터 밀어넣기!
                    await Supabase.instance.client.from('comments').insert({
                      'post_id': widget.post['id'],
                      'author_name': authorName,
                      'content': _commentController.text,
                    });
                    _commentController.clear();
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}