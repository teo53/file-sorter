# 📦 설치 가이드

이 문서는 AI 기반 자동 파일 정리 시스템의 상세한 설치 과정을 안내합니다.

## 🎯 목차

1. [시스템 요구사항](#시스템-요구사항)
2. [Python 환경 설정](#python-환경-설정)
3. [Tesseract OCR 설치](#tesseract-ocr-설치)
4. [Node.js 환경 설정](#nodejs-환경-설정)
5. [의존성 설치](#의존성-설치)
6. [설치 확인](#설치-확인)

---

## 시스템 요구사항

### 필수 요구사항

- **운영체제**: Windows 10/11
- **Python**: 3.10 이상
- **Node.js**: 18 이상
- **디스크 공간**: 최소 500MB

### 선택 요구사항

- **Tesseract OCR**: 스크린샷 텍스트 추출용 (선택사항)

---

## Python 환경 설정

### 1. Python 설치 확인

PowerShell을 열고 다음 명령어를 실행:

```powershell
python --version
```

**출력 예시**: `Python 3.11.5`

Python이 설치되지 않았다면:
1. https://www.python.org/downloads/ 접속
2. 최신 Python 3.11+ 다운로드
3. 설치 시 **"Add Python to PATH"** 체크 ✅

### 2. pip 업그레이드

```powershell
python -m pip install --upgrade pip
```

---

## Tesseract OCR 설치

> **중요**: 스크린샷에서 텍스트를 추출하려면 필수입니다. 설치하지 않으면 OCR 기능만 비활성화됩니다.

### Windows 설치 (권장)

#### 단계 1: 설치 파일 다운로드

1. https://github.com/UB-Mannheim/tesseract/wiki 접속
2. 최신 버전 다운로드 (예: `tesseract-ocr-w64-setup-5.3.3.20231005.exe`)

#### 단계 2: 설치 진행

1. 다운로드한 `.exe` 파일 실행
2. **중요**: 설치 옵션에서 다음 선택:
   - ✅ **Additional language data (download)** → **Korean** 선택
   - ✅ **Additional script data (download)** → 기본값 유지

![Tesseract 설치](https://user-images.githubusercontent.com/placeholder/tesseract-install.png)

#### 단계 3: 기본 설치 경로 확인

기본 경로: `C:\Program Files\Tesseract-OCR\`

#### 단계 4: 환경 변수 확인 (자동 설정됨)

PowerShell에서 확인:

```powershell
tesseract --version
```

**출력 예시**:
```
tesseract 5.3.3
 leptonica-1.83.1
  libpng 1.6.40 : zlib 1.2.13
```

만약 오류가 발생하면 시스템 재시작 후 다시 시도.

---

## Node.js 환경 설정

### 1. Node.js 설치 확인

```powershell
node --version
npm --version
```

**출력 예시**:
```
v20.10.0
10.2.3
```

### 2. Node.js 설치 (미설치 시)

1. https://nodejs.org/ 접속
2. **LTS 버전** 다운로드 (권장)
3. 설치 진행 (기본 옵션 사용)

---

## 의존성 설치

### 1. 프로젝트 폴더로 이동

```powershell
cd "C:\Users\mapdr\Desktop\폴더 정리툴"
```

### 2. Python 의존성 설치

```powershell
# 메인 시스템 의존성
pip install -r requirements.txt
```

**설치 패키지**:
- `Pillow` - 이미지 처리
- `pytesseract` - OCR 엔진
- `python-dateutil` - 날짜 처리
- `PyYAML` - 설정 파일 파싱

### 3. FastAPI 의존성 설치

```powershell
cd api
pip install -r requirements.txt
cd ..
```

**설치 패키지**:
- `fastapi` - API 프레임워크
- `uvicorn` - ASGI 서버
- `pydantic` - 데이터 검증

### 4. Next.js 대시보드 의존성 설치

```powershell
cd dashboard
npm install
cd ..
```

**설치 패키지**:
- `react`, `react-dom` - UI 프레임워크
- `next` - React 프레임워크
- `axios` - HTTP 클라이언트
- `tailwindcss` - CSS 프레임워크
- `lucide-react` - 아이콘
- `date-fns` - 날짜 포맷팅

---

## 설치 확인

### 1. Python 모듈 테스트

```powershell
cd src
python -c "from file_scanner import FileScanner; print('✓ Python 모듈 로드 성공')"
```

**예상 출력**: `✓ Python 모듈 로드 성공`

### 2. Tesseract OCR 테스트

```powershell
python -c "import pytesseract; print(pytesseract.get_tesseract_version())"
```

**예상 출력**: `5.3.3`

만약 오류 발생:
```python
# src/ocr_handler.py 파일에서 경로 수동 지정
pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'
```

### 3. FastAPI 서버 테스트

```powershell
cd api
python main.py
```

브라우저에서 http://localhost:8000/docs 접속

**예상 화면**: Swagger API 문서 페이지

`Ctrl+C`로 서버 종료

### 4. Next.js 대시보드 테스트

```powershell
cd dashboard
npm run dev
```

브라우저에서 http://localhost:3000 접속

**예상 화면**: 파일 정리 시스템 대시보드

`Ctrl+C`로 서버 종료

---

## 🎉 설치 완료!

모든 테스트가 성공했다면 설치가 완료되었습니다.

다음 단계: [README.md](./README.md)의 "실행 방법" 참고

---

## ⚠️ 문제 해결

### Python 모듈을 찾을 수 없음

```
ModuleNotFoundError: No module named 'PIL'
```

**해결책**:
```powershell
pip install Pillow
```

### Tesseract 경로 오류

```
TesseractNotFoundError
```

**해결책**:
1. Tesseract가 설치되어 있는지 확인
2. `src/ocr_handler.py` 열기
3. 경로 수동 설정:
```python
pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'
```

### npm 설치 오류

```
EACCES: permission denied
```

**해결책**:
```powershell
# PowerShell을 관리자 권한으로 실행 후
cd dashboard
rm -rf node_modules
npm install
```

### FastAPI 포트 충돌

```
Address already in use
```

**해결책**:
```powershell
# 포트 변경 (api/main.py)
uvicorn.run(app, host="0.0.0.0", port=8001)  # 8000 → 8001
```

---

## 📞 추가 도움말

설치 중 문제가 발생하면 다음을 확인하세요:

1. **Windows 버전**: Windows 10/11 (64비트)
2. **관리자 권한**: PowerShell을 관리자로 실행
3. **방화벽**: Python, Node.js 허용
4. **안티바이러스**: 일시적으로 비활성화

---

**설치 완료 체크리스트**:

- [ ] Python 3.10+ 설치 확인
- [ ] pip 업그레이드
- [ ] Tesseract OCR 설치 (Korean 언어팩 포함)
- [ ] Node.js 18+ 설치
- [ ] Python 의존성 설치 완료
- [ ] FastAPI 의존성 설치 완료
- [ ] Next.js 의존성 설치 완료
- [ ] 모든 테스트 통과

모든 항목이 체크되었다면 시스템 사용 준비 완료! 🚀
