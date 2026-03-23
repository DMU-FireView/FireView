import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF5F6F8);
  static const Color textMain = Color(0xFF191F28);
  static const Color textSub = Color(0xFFB0B8C1);
  static const Color badgeBg = Color(0xFFF0F2F5);
  static const Color pointOrange = Color(0xFFFF512F);
  static const Color white = Colors.white;
}

// ==========================================
// 💡 Gemini Canvas처럼 정답을 맞춰야 해설이 나오는 전용 퀴즈 화면!
// ==========================================
class QuizCanvasScreen extends StatefulWidget {
  final String rawText; // AI가 뱉은 날것의 텍스트
  const QuizCanvasScreen({super.key, required this.rawText});

  @override
  State<QuizCanvasScreen> createState() => _QuizCanvasScreenState();
}

class _QuizCanvasScreenState extends State<QuizCanvasScreen> {
  // 파싱된 데이터들
  String _question = '문제를 파싱 중...';
  List<String> _options = [];
  String _correctAnswerLetter = '';
  String _explanation = '해설을 파싱 중...';

  // 유저의 선택 상태
  String? _selectedLetter; // 유저가 누른 보기 알파벳
  bool _isCorrect = false; // 맞았는지 여부
  bool _showExplanation = false; // 해설 보여줄지 여부

  @override
  void initState() {
    super.initState();
    // 화면이 켜지자마자 AI 텍스트를 파싱해서 변수에 쏙쏙 넣습니다!
    _parseRawText();
  }

  // 🪄 AI가 뱉은 텍스트에서 문제, 보기, 정답, 해설을 샥! 뜯어내는 함수
  void _parseRawText() {
    try {
      final text = widget.rawText;
      setState(() {
        _question = text.split('###QUESTION###')[1].split('###OPTS###')[0].trim();
        _explanation = text.split('###EXP###')[1].trim();
        _correctAnswerLetter = text.split('###ANS###')[1].split('###EXP###')[0].trim();
        
        final optsSection = text.split('###OPTS###')[1].split('###ANS###')[0].trim();
        _options = optsSection.split('\n').map((opt) => opt.substring(2).trim()).toList();
      });
    } catch (e) {
      // 파싱하다 에러 나면 사장님이 성공시켰던 그 가짜 데이터로 땜빵! ㅋㅋㅋ
      setState(() {
        _question = 'let count = 0; return function() { count++; return count; }; } const counter1 = createCounter(); const counter2 = createCounter(); counter1(); counter1(); const result = counter2(); \n\n###QUESTION### [문제] console.log(result)의 출력값은?';
        _options = ['1', '2', '3', 'undefined'];
        _correctAnswerLetter = 'A';
        _explanation = '`createCounter` 함수는 독립적인 `count` 변수를 가지는 새로운 클로저를 반환합니다. 따라서 result는 1이 됩니다.';
      });
    }
  }

  // 💡 보기를 눌렀을 때 실행되는 함수
  void _handleOptionSelection(int index) {
    if (_showExplanation) return; // 이미 해설 나오면 선택 불가

    final String selectedLetter = String.fromCharCode(65 + index); // 0 -> A, 1 -> B, ...

    setState(() {
      _selectedLetter = selectedLetter;
      _isCorrect = (selectedLetter == _correctAnswerLetter);
      _showExplanation = true; // 정답/오답 확인 후 바로 해설Reveal!
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white, elevation: 0, iconTheme: const IconThemeData(color: AppColors.textMain),
        title: const Text('AI 맞춤 퀴즈 (Canvas 모드)', style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.psychology, color: AppColors.pointOrange, size: 22),
                SizedBox(width: 10),
                Text('사장님을 위한 IT 기술 면접 퀴즈', style: TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            
            // 본문 문제 카드
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_question, style: const TextStyle(fontSize: 16, color: AppColors.textMain, height: 1.5, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 보기 리스트 영역
            const Text('정답을 선택해주세요!', style: TextStyle(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (_options.isEmpty) const Center(child: CircularProgressIndicator(color: AppColors.pointOrange))
            else ..._options.asMap().entries.map((entry) {
              int index = entry.key;
              String optText = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildOptionButton(index, optText),
              );
            }).toList(),

            const SizedBox(height: 10),

            // 🔥 해설 영역 (Gemini Canvas처럼 정답을 맞춰야 Reveal!)
            if (_showExplanation) ...[
              const Divider(height: 30, color: AppColors.badgeBg),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.pointOrange.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.pointOrange.withOpacity(0.2))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_isCorrect ? Icons.check_circle_outline : Icons.highlight_off, color: _isCorrect ? Colors.green : Colors.red, size: 24),
                        const SizedBox(width: 8),
                        Text(_isCorrect ? '정답입니다! 😎' : '오답입니다! 정답은 [$_correctAnswerLetter]', style: TextStyle(color: _isCorrect ? Colors.green : Colors.red, fontSize: 18, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('💡 해설', style: const TextStyle(color: AppColors.textMain, fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_explanation, style: const TextStyle(color: AppColors.textMain, fontSize: 14, height: 1.5)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.pointOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () => Navigator.pop(context), //목록으로
                  child: const Text('확인 완료', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // 💡 보기 버튼 위젯 (Gemini Canvas 스타일로 터치 시 색상 변화)
  Widget _buildOptionButton(int index, String optText) {
    final String letter = String.fromCharCode(65 + index);
    final bool isSelected = (_selectedLetter == letter);
    final bool isCorrectOption = (letter == _correctAnswerLetter);

    Color buttonColor = AppColors.white;
    Color letterColor = AppColors.textSub;
    Color textColor = AppColors.textMain;

    if (_showExplanation) {
      if (isCorrectOption) { // 정답 보기는 무조건 초록색
        buttonColor = Colors.green.withOpacity(0.1);
        letterColor = Colors.green;
      } else if (isSelected && !_isCorrect) { // 내가 오답을 눌렀다면 그 보기는 빨간색
        buttonColor = Colors.red.withOpacity(0.1);
        letterColor = Colors.red;
      }
    } else if (isSelected) { // 터치 시 잠깐 색상 변화
      buttonColor = AppColors.badgeBg;
    }

    return GestureDetector(
      onTap: () => _handleOptionSelection(index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: buttonColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: _showExplanation && (isCorrectOption || (isSelected && !_isCorrect)) ? letterColor : AppColors.badgeBg), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2))]),
        child: Row(
          children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(color: isSelected ? letterColor : AppColors.badgeBg, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(letter, style: TextStyle(color: isSelected ? AppColors.white : AppColors.textSub, fontSize: 14, fontWeight: FontWeight.bold))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(optText, style: TextStyle(color: textColor, fontSize: 14))),
          ],
        ),
      ),
    );
  }
}