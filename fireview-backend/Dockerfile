# 1. 뼈대 가져오기: 파이썬 3.9 버전이 깔린 가벼운 리눅스 컴퓨터를 한 대 빌려옵니다.
FROM python:3.9-slim

# 2. 작업 폴더 만들기: 상자 안에 '/app' 이라는 폴더를 만들고 거기로 들어갑니다.
WORKDIR /app

# 3. 부품 주문서 복사: 아까 만든 requirements.txt를 상자 안으로 복사합니다.
COPY requirements.txt .

# 4. 부품 설치: 상자 안에서 파이썬 라이브러리들을 쫙 설치합니다.
RUN pip install --no-cache-dir -r requirements.txt

# 5. 내 코드 복사: 사장님이 짠 main.py 등 모든 코드를 상자 안으로 통째로 복사합니다.
COPY . .

# 6. 실행 명령: 상자가 열리면(실행되면) 이 명령어를 자동으로 쳐라! (포트는 3000번)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "3000"]