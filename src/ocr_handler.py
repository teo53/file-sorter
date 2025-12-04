"""
OCR 처리 모듈
스크린샷 이미지에서 텍스트를 추출하여 키워드를 반환합니다.
(Tesseract OCR 필요)
"""

from typing import List, Optional
import re


class OCRHandler:
    """OCR 텍스트 추출 및 키워드 처리"""
    
    def __init__(self, enabled: bool = True):
        """
        Args:
            enabled: OCR 활성화 여부 (Tesseract 미설치 시 False)
        """
        self.enabled = enabled
        self.pytesseract = None
        self.Image = None
        
        if enabled:
            try:
                import pytesseract
                from PIL import Image
                self.pytesseract = pytesseract
                self.Image = Image
                
                # Tesseract 경로 설정 (Windows)
                # 기본 설치 경로를 시도
                try:
                    # Tesseract가 설치되어 있는지 테스트
                    pytesseract.get_tesseract_version()
                except:
                    # 일반적인 설치 경로 지정
                    pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'
                
            except ImportError:
                print("경고: pytesseract가 설치되지 않았습니다. OCR 기능이 비활성화됩니다.")
                print("설치 방법: pip install pytesseract")
                self.enabled = False
            except Exception as e:
                print(f"경고: OCR 초기화 실패 - {e}")
                self.enabled = False
    
    def extract_text(self, image_path: str) -> Optional[str]:
        """
        이미지에서 텍스트 추출
        
        Args:
            image_path: 이미지 파일 경로
            
        Returns:
            추출된 텍스트 (실패 시 None)
        """
        if not self.enabled:
            return None
        
        try:
            # 한국어 + 영어 OCR
            img = self.Image.open(image_path)
            text = self.pytesseract.image_to_string(img, lang='kor+eng')
            return text.strip()
        
        except Exception as e:
            print(f"OCR 오류: {image_path} - {e}")
            return None
    
    def extract_keywords(
        self, 
        image_path: str, 
        max_keywords: int = 5
    ) -> List[str]:
        """
        이미지에서 키워드 추출
        
        Args:
            image_path: 이미지 파일 경로
            max_keywords: 최대 키워드 개수
            
        Returns:
            키워드 리스트
        """
        text = self.extract_text(image_path)
        
        if not text:
            return []
        
        # 텍스트 전처리 및 키워드 추출
        keywords = self._process_text_to_keywords(text, max_keywords)
        return keywords
    
    def _process_text_to_keywords(self, text: str, max_keywords: int) -> List[str]:
        """
        텍스트를 처리하여 의미있는 키워드 추출
        
        Args:
            text: OCR로 추출된 텍스트
            max_keywords: 최대 키워드 개수
            
        Returns:
            키워드 리스트
        """
        # 줄바꿈을 공백으로 변환
        text = text.replace('\n', ' ').replace('\r', ' ')
        
        # 특수문자 제거 (한글, 영문, 숫자만 유지)
        text = re.sub(r'[^\w\s가-힣]', ' ', text)
        
        # 공백으로 분리
        words = text.split()
        
        # 불용어 제거 (너무 짧거나 의미없는 단어)
        stop_words = {'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
                     '이', '그', '저', '것', '등', '및', '를', '을', '가', '이'}
        
        keywords = []
        for word in words:
            word = word.strip()
            
            # 길이 체크 (2글자 이상)
            if len(word) < 2:
                continue
            
            # 불용어 체크
            if word.lower() in stop_words:
                continue
            
            # 숫자만 있는 단어 제외
            if word.isdigit():
                continue
            
            keywords.append(word)
        
        # 중복 제거하면서 순서 유지
        seen = set()
        unique_keywords = []
        for kw in keywords:
            if kw not in seen:
                seen.add(kw)
                unique_keywords.append(kw)
        
        # 상위 N개만 반환
        return unique_keywords[:max_keywords]
    
    def should_use_ocr(self, metadata: dict) -> bool:
        """
        OCR을 사용해야 하는지 판단
        (스크린샷으로 판단된 이미지만 OCR 처리)
        
        Args:
            metadata: 파일 메타데이터
            
        Returns:
            OCR 사용 여부
        """
        if not self.enabled:
            return False
        
        # 스크린샷으로 판단된 경우만 OCR 수행
        is_screenshot = metadata.get('is_likely_screenshot', False)
        is_image = metadata.get('is_image', False)
        
        return is_image and is_screenshot


if __name__ == '__main__':
    # 테스트 코드
    ocr = OCRHandler(enabled=True)
    
    if ocr.enabled:
        print("OCR이 활성화되었습니다.\n")
        
        # 테스트 이미지 경로 (실제 스크린샷 파일이 있어야 함)
        test_image = r"C:\Users\mapdr\Desktop\test_screenshot.png"
        
        import os
        if os.path.exists(test_image):
            print(f"테스트 이미지: {test_image}")
            
            # 텍스트 추출
            text = ocr.extract_text(test_image)
            print(f"\n추출된 텍스트:\n{text}\n")
            
            # 키워드 추출
            keywords = ocr.extract_keywords(test_image, max_keywords=5)
            print(f"추출된 키워드: {keywords}")
        else:
            print(f"테스트 이미지가 없습니다: {test_image}")
            print("스크린샷 이미지를 Desktop에 'test_screenshot.png'로 저장해주세요.")
    else:
        print("OCR이 비활성화되었습니다.")
        print("\nTesseract OCR 설치 방법:")
        print("1. https://github.com/UB-Mannheim/tesseract/wiki 에서 Windows 설치 파일 다운로드")
        print("2. 설치 시 'Additional language data' 에서 Korean 선택")
        print("3. 설치 후 Python 패키지 설치: pip install pytesseract")
