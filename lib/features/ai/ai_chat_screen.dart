import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../home/quiz_canvas_screen.dart'; // 👈 아까 만든 퀴즈 캔버스 화면 경로! (경로가 다르면 맞춰주세요)

class AppColors {
  static const Color background = Color(0xFFF5F6F8);
  static const Color textMain = Color(0xFF191F28);
  static const Color textSub = Color(0xFFB0B8C1);
  static const Color badgeBg = Color(0xFFF0F2F5);
  static const Color pointOrange = Color(0xFFFF512F);
  static const Color white = Colors.white;
}

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // 채팅 기록을 저장하는 리스트 (초기 인사말 세팅)
  final List<Map<String, String>> _messages = [
    {'role': 'ai', 'text': '안녕하세요! 1타 AI 취업 비서입니다.\n궁금한 걸 물어보시거나, 키워드를 입력하고 아래의 맞춤 버튼을 눌러보세요!'}
  ];
  
  bool _isLoading = false;

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 화면 맨 아래로 스크롤 내리기
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // 🚀 통합 AI 호출 함수 (일반 채팅 / 퀴즈 / 자소서)
  Future<void> _sendMessage({String? customPrompt, String? actionType}) async {
    final userInput = _chatController.text.trim();
    if (userInput.isEmpty && customPrompt == null) return;

    final queryText = customPrompt ?? userInput;

    setState(() {
      // 내가 보낸 메시지를 채팅창에 추가
      if (customPrompt == null) {
        _messages.add({'role': 'user', 'text': userInput});
      } else {
        _messages.add({'role': 'user', 'text': '[$actionType] 키워드: $userInput'});
      }
      _isLoading = true;
    });
    
    _chatController.clear();
    _scrollToBottom();

    try {
      final apiKey = dotenv.env['AI_API_KEY'];
      if (apiKey == null) throw Exception('API 키가 없습니다.');
      
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey); // 2.5-flash로 바꾸셔도 됩니다!
      
      String prompt = queryText;

      // 🎯 액션 타입별로 프롬프트 조작
      if (actionType == '퀴즈') {
        prompt = '당신은 IT 대기업 면접관입니다. **키워드: $userInput**와 관련된 기술 면접용 객관식 퀴즈 1개를 내주세요. 파싱하기 쉽게 아래 형식으로 마크다운 없이 작성해주세요.\n\n###QUESTION### [문제 내용]\n###OPTS###\nA. [보기 1]\nB. [보기 2]\nC. [보기 3]\nD. [보기 4]\n###ANS### [A/B/C/D 중 정답 글자 하나만]\n###EXP### [자세한 해설]';
      } else if (actionType == '자소서') {
        // 실제 인적사항을 불러와도 좋고, 일단 MVP용 하드코딩
        String profile = '김세나님, 신입, 웹 프론트엔드 직무 희망, 새로운 기술 습득 빠름';
        prompt = '당신은 1타 취업 컨설턴트입니다. **인적사항: $profile, 키워드: $userInput** 정보를 기반으로 프론트엔드 개발자 자기소개서 "지원동기" 초안을 300자 내외로 작성해주세요. 1타 컨설턴트의 TIP도 추가해주세요.';
      }

      final response = await model.generateContent([Content.text(prompt)]);
      final aiText = response.text ?? '답변을 생성하지 못했습니다.';

      setState(() {
        _isLoading = false;
        if (actionType == '퀴즈') {
          _messages.add({'role': 'ai', 'text': '퀴즈 생성이 완료되었습니다! 화면을 이동합니다 🚀'});
        } else {
          _messages.add({'role': 'ai', 'text': aiText});
        }
      });
      _scrollToBottom();

      // 퀴즈인 경우 캔버스 화면으로 이동
      if (actionType == '퀴즈' && mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => QuizCanvasScreen(rawText: aiText)));
      }

    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.add({'role': 'ai', 'text': '앗, 오류가 발생했어요. 다시 시도해주세요! ($e)'});
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white, elevation: 0,
        title: const Text('AI 취업 비서', style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // 1. 채팅창 영역
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['role'] == 'user';
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.textMain : AppColors.white,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                        bottomLeft: !isMe ? const Radius.circular(0) : const Radius.circular(16),
                      ),
                      border: isMe ? null : Border.all(color: AppColors.badgeBg),
                    ),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(color: isMe ? AppColors.white : AppColors.textMain, height: 1.4),
                    ),
                  ),
                );
              },
            ),
          ),
          
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: AppColors.pointOrange),
            ),

          // 2. 입력 및 퀵 액션 영역
          Container(
            color: AppColors.white,
            padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: MediaQuery.of(context).padding.bottom + 12),
            child: Column(
              children: [
                // 💡 맞춤 기능 버튼 (키워드 입력 후 클릭!)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.psychology, size: 16, color: AppColors.pointOrange),
                        label: const Text('키워드로 퀴즈 내기', style: TextStyle(color: AppColors.textMain, fontSize: 12)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.badgeBg), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        onPressed: () {
                          if (_chatController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('키워드를 먼저 입력해주세요!')));
                            return;
                          }
                          _sendMessage(actionType: '퀴즈');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.history_edu, size: 16, color: AppColors.pointOrange),
                        label: const Text('자소서 초안 짜기', style: TextStyle(color: AppColors.textMain, fontSize: 12)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.badgeBg), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        onPressed: () {
                          if (_chatController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('키워드를 먼저 입력해주세요!')));
                            return;
                          }
                          _sendMessage(actionType: '자소서');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 채팅 입력창
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chatController,
                        decoration: InputDecoration(
                          hintText: '키워드 입력 또는 자유롭게 질문해보세요!',
                          hintStyle: const TextStyle(fontSize: 13),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                          filled: true, fillColor: AppColors.badgeBg,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: AppColors.pointOrange,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: AppColors.white, size: 18),
                        onPressed: () => _sendMessage(),
                      ),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}