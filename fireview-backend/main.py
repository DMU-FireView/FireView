import os
import requests
import xmltodict
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

load_dotenv()
app = FastAPI(title="FireView Backend (Python)")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 1. 공채기업정보
@app.get("/api/public-companies")
def get_public_companies():
    try:
        api_key = os.getenv("JOB_API_KEY", "").strip()
        url = f"https://www.work24.go.kr/cm/openApi/call/wk/callOpenApiSvcInfo210L31.do?authKey={api_key}&callTp=L&returnType=XML&startPage=1&display=10"
        response = requests.get(url)
        return xmltodict.parse(response.content)
    except Exception as e:
        return {"error": str(e)}

# 2. 강소기업 정보
@app.get("/api/small-giants")
def get_small_giants():
    try:
        api_key = os.getenv("GANGSO_API_KEY", "").strip()
        url = f"https://www.work24.go.kr/cm/openApi/call/wk/callOpenApiSvcInfo216L01.do?authKey={api_key}&returnType=XML&startPage=1&display=10"
        response = requests.get(url)
        return xmltodict.parse(response.content)
    except Exception as e:
        return {"error": str(e)}

# 3. 💡 구직자취업역량 강화프로그램 (사장님 매뉴얼 적용!)
@app.get("/api/programs")
def get_programs():
    try:
        api_key = os.getenv("PROGRAM_API_KEY", "").strip()
        url = f"https://www.work24.go.kr/cm/openApi/call/wk/callOpenApiSvcInfo217L01.do?authKey={api_key}&returnType=XML&startPage=1&display=10"
        response = requests.get(url)
        return xmltodict.parse(response.content)
    except Exception as e:
        return {"error": str(e)}

# 4. 🛠️ 직무정보 (NCS 표준직무기술서) - 💡 XML이 아니라 JSON으로 바로 받습니다!
@app.get("/api/duties")
def get_duties(jobCont: str = "소프트웨어"): # 기본 검색어를 '소프트웨어'로 세팅
    try:
        api_key = os.getenv("DUTY_API_KEY", "").strip()
        # limit=10으로 세팅, returnType=JSON 필수!
        url = f"https://www.work24.go.kr/cm/openApi/call/wk/callOpenApiSvcInfo215L01.do?authKey={api_key}&jobCont={jobCont}&limit=10&returnType=JSON"
        response = requests.get(url)
        return response.json() # 이미 JSON이므로 xmltodict 안 씁니다!
    except Exception as e:
        return {"error": str(e)}

# 5. 💼 직업정보 (사장님 매뉴얼 적용!)
@app.get("/api/occupations")
def get_occupations():
    try:
        api_key = os.getenv("OCCU_API_KEY", "").strip()
        # target=JOBCD 필수!
        url = f"https://www.work24.go.kr/cm/openApi/call/wk/callOpenApiSvcInfo212L01.do?authKey={api_key}&returnType=XML&target=JOBCD"
        response = requests.get(url)
        return xmltodict.parse(response.content)
    except Exception as e:
        return {"error": str(e)}