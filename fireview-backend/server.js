require('dotenv').config();
const express = require('express');
const axios = require('axios');
const cors = require('cors');
const { XMLParser } = require('fast-xml-parser'); 

const app = express();
app.use(cors());

const parser = new XMLParser(); 

// ==========================================
// 🚪 3번 문: [공채기업정보] 가져오기 (개인회원 전용 꿀통!)
// ==========================================
app.get('/api/public-companies', async (req, res) => {
  try {
    // 💡 열쇠 뒤에 .trim()을 붙여서 투명 빈칸/엔터를 완벽하게 제거!! (이게 핵심입니다)
    const apiKey = process.env.JOB_API_KEY.trim(); 
    
    const companyName = req.query.coNm || ''; 
    
    let url = `https://www.work24.go.kr/cm/openApi/call/wk/callOpenApiSvcInfo210L31.do?authKey=${apiKey}&callTp=L&returnType=XML&startPage=1&display=10`;
    
    if (companyName) {
      url += `&coNm=${encodeURI(companyName)}`;
    }

    console.log('🔗 공채기업정보 찌르는 중...', url);

    const response = await axios.get(url);
    const jsonObj = parser.parse(response.data);
    
    res.status(200).json(jsonObj);
    console.log('✅ 공채기업정보 JSON 번역 전송 완료!');
    
  } catch (error) {
    console.error('❌ 에러 발생:', error.message);
    res.status(500).json({ error: '데이터를 가져오는데 실패했습니다.' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 FireView 백엔드 서버 작동 중! (포트: ${PORT})`);
});