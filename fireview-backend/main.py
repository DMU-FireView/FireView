import os
import requests
import xmltodict
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

# 1. .env 금고 열기
load_dotenv()

# 2. 초고속 FastAPI 서버 생성
app = FastAPI(title="FireView Backend (Python)")

# 3. 플러터 접근 허용 (CORS)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==========================================
# 🚪 1. 공채기업정보 (기존 성공했던 그 문!)
# ==========================================
@app.get("/api/public-companies")
def get_public_companies():
    try:
        api_key = os.getenv("JOB_API_KEY", "").strip()
        url = f"https://www.work24.go.kr/cm/openApi/call/wk/callOpenApiSvcInfo210L31.do?authKey={api_key}&callTp=L&returnType=XML&startPage=1&display=10"
        
        response = requests.get(url)
        return xmltodict.parse(response.content)
    except Exception as e:
        return {"error": str(e)}

# ==========================================
# 🚪 2. 강소기업 정보
# ==========================================
@app.get("/api/small-giants")
def get_small_giants():
    try:
        api_key = os.getenv("GANGSO_API_KEY", "").strip()
        # 아까 찾았던 강소기업 전용 주소!
        url = f"https://www.work24.go.kr/cm/openApi/call/wk/callOpenApiSvcInfo216L01.do?authKey={api_key}&returnType=XML&startPage=1&display=10"
        
        response = requests.get(url)
        return xmltodict.parse(response.content)
    except Exception as e:
        return {"error": str(e)}

# ==========================================
# 🚪 3. 구직자취업역량 강화프로그램
# ==========================================
@app.get("/api/programs")
def get_programs():
    try:
        api_key = os.getenv("PROGRAM_API_KEY", "").strip()
        # 💡 주의: 고용24 매뉴얼에서 이 프로그램 API의 정확한 주소를 확인해서 아래에 덮어씌워야 합니다!
        url = f"https://www.work24.go.kr/cm/openApi/call/wk/프로그램주소.do?authKey={api_key}&returnType=XML"
        
        response = requests.get(url)
        return xmltodict.parse(response.content)
    except Exception as e:
        return {"error": str(e)}

# ==========================================
# 🚪 4. 직무정보
# ==========================================
@app.get("/api/duties")
def get_duties():
    try:
        api_key = os.getenv("DUTY_API_KEY", "").strip()
        # 💡 주의: 매뉴얼에서 직무정보 API 주소 확인 필요
        url = f"https://openapi.work.go.kr/opi/직무정보주소.do?authKey={api_key}&returnType=XML"
        
        response = requests.get(url)
        return xmltodict.parse(response.content)
    except Exception as e:
        return {"error": str(e)}

# ==========================================
# 🚪 5. 직업정보
# ==========================================
@app.get("/api/occupations")
def get_occupations():
    try:
        api_key = os.getenv("OCCU_API_KEY", "").strip()
        # 💡 주의: 매뉴얼에서 직업정보 API 주소 확인 필요
        url = f"https://openapi.work.go.kr/opi/직업정보주소.do?authKey={api_key}&returnType=XML"
        
        response = requests.get(url)
        return xmltodict.parse(response.content)
    except Exception as e:
        return {"error": str(e)}