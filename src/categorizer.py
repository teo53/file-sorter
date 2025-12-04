"""
파일 분류 모듈
파일명, 메타데이터, OCR 결과를 기반으로 파일을 카테고리별로 분류합니다.
"""

from typing import Dict, List, Tuple
import re


class FileCategorizer:
    """파일 카테고리 분류 클래스"""
    
    def __init__(self):
        # 카테고리별 규칙 정의
        self.category_rules = {
            'images/screenshots': {
                'priority': 1,  # 우선순위 (낮을수록 먼저 검사)
                'filename_keywords': ['캡처', 'screenshot', '스크린샷', 'capture'],
                'extensions': ['.png', '.jpg', '.jpeg'],
                'metadata_check': 'is_likely_screenshot',
            },
            'images/products': {
                'priority': 2,
                'filename_keywords': ['유로폼', '폼워크', '잭서포트', '가설재', '비계', '동바리'],
                'extensions': ['.png', '.jpg', '.jpeg', '.webp'],
                'metadata_check': None,
            },
            'images/ui': {
                'priority': 3,
                'filename_keywords': ['ui', 'design', 'mockup', 'wireframe', '디자인', '목업'],
                'extensions': ['.png', '.jpg', '.jpeg', '.svg', '.figma'],
                'metadata_check': None,
            },
            'images/photos': {
                'priority': 4,
                'filename_keywords': [],
                'extensions': ['.jpg', '.jpeg', '.heic', '.raw'],
                'metadata_check': 'is_camera_photo',
            },
            'documents': {
                'priority': 5,
                'filename_keywords': [],
                'extensions': ['.pdf', '.docx', '.doc', '.hwp', '.txt', '.xlsx', '.xls', '.pptx'],
                'metadata_check': None,
            },
            'project_files': {
                'priority': 6,
                'filename_keywords': [],
                'extensions': ['.py', '.js', '.jsx', '.ts', '.tsx', '.html', '.css', '.json', 
                              '.yaml', '.yml', '.md', '.xml', '.sql', '.sh', '.bat'],
                'metadata_check': None,
            },
            'etc': {
                'priority': 999,  # 마지막 fallback
                'filename_keywords': [],
                'extensions': [],
                'metadata_check': None,
            }
        }
    
    def categorize(
        self, 
        file_path: str, 
        metadata: Dict, 
        ocr_keywords: List[str] = None
    ) -> Tuple[str, str, List[str]]:
        """
        파일을 분류하고 카테고리를 반환합니다.
        
        Args:
            file_path: 파일 경로
            metadata: 메타데이터 딕셔너리
            ocr_keywords: OCR로 추출한 키워드 리스트
            
        Returns:
            (카테고리, 적용된 규칙, 추출된 키워드)
        """
        filename = metadata.get('file_name', '').lower()
        file_ext = metadata.get('file_ext', '').lower()
        
        # 우선순위 순으로 카테고리 검사
        sorted_categories = sorted(
            self.category_rules.items(),
            key=lambda x: x[1]['priority']
        )
        
        for category, rules in sorted_categories:
            # 1단계: 파일명 키워드 검사 (최우선)
            if rules['filename_keywords']:
                if any(keyword in filename for keyword in rules['filename_keywords']):
                    keywords = self._extract_keywords_from_filename(filename, rules['filename_keywords'])
                    return category, 'filename_pattern', keywords
            
            # 2단계: 파일 확장자 + 메타데이터 검사
            if file_ext in rules['extensions']:
                # 메타데이터 특별 조건 확인
                metadata_check = rules.get('metadata_check')
                if metadata_check:
                    if metadata.get(metadata_check, False):
                        keywords = self._extract_keywords_from_filename(filename, [])
                        return category, 'metadata_match', keywords
                else:
                    # 확장자만으로 판단
                    keywords = self._extract_keywords_from_filename(filename, [])
                    return category, 'extension_match', keywords
            
            # 3단계: OCR 키워드 검사 (스크린샷만 해당)
            if ocr_keywords and category == 'images/screenshots':
                keywords = ocr_keywords[:3]  # 상위 3개 키워드
                return category, 'ocr_match', keywords
        
        # 기본 카테고리 (etc)
        return 'etc', 'default', []
    
    def _extract_keywords_from_filename(
        self, 
        filename: str, 
        matched_keywords: List[str]
    ) -> List[str]:
        """
        파일명에서 의미있는 키워드 추출
        
        Args:
            filename: 소문자로 변환된 파일명
            matched_keywords: 매칭된 키워드 리스트
            
        Returns:
            추출된 키워드 리스트
        """
        keywords = []
        
        # 매칭된 키워드 추가
        for kw in matched_keywords:
            if kw in filename:
                keywords.append(kw)
        
        # 파일명에서 추가 키워드 추출 (숫자, 특수문자 제거)
        # 예: "유로폼_견적서_2024.pdf" -> ["유로폼", "견적서"]
        cleaned = re.sub(r'[0-9\-_\.\(\)\[\]]', ' ', filename)
        words = [w.strip() for w in cleaned.split() if len(w.strip()) > 1]
        
        # 확장자 제거
        words = [w for w in words if not w.startswith('.')]
        
        # 상위 3개까지만
        for word in words[:3]:
            if word not in keywords:
                keywords.append(word)
        
        return keywords[:3]  # 최대 3개
    
    def get_category_path(self, category: str, base_dir: str) -> str:
        """
        카테고리에 해당하는 전체 경로 반환
        
        Args:
            category: 카테고리 (예: 'images/screenshots')
            base_dir: 기본 디렉토리 (예: Desktop)
            
        Returns:
            전체 경로
        """
        import os
        return os.path.join(base_dir, category.replace('/', os.sep))


if __name__ == '__main__':
    # 테스트 코드
    categorizer = FileCategorizer()
    
    # 테스트 케이스
    test_cases = [
        {
            'file_path': 'C:\\Users\\mapdr\\Desktop\\스크린샷_2024-12-04.png',
            'metadata': {
                'file_name': '스크린샷_2024-12-04.png',
                'file_ext': '.png',
                'is_likely_screenshot': True,
            },
            'ocr_keywords': None,
        },
        {
            'file_path': 'C:\\Users\\mapdr\\Desktop\\유로폼_견적서.pdf',
            'metadata': {
                'file_name': '유로폼_견적서.pdf',
                'file_ext': '.pdf',
            },
            'ocr_keywords': None,
        },
        {
            'file_path': 'C:\\Users\\mapdr\\Desktop\\IMG_1234.jpg',
            'metadata': {
                'file_name': 'IMG_1234.jpg',
                'file_ext': '.jpg',
                'is_camera_photo': True,
            },
            'ocr_keywords': None,
        },
    ]
    
    print("파일 분류 테스트:\n")
    for test in test_cases:
        category, rule, keywords = categorizer.categorize(
            test['file_path'],
            test['metadata'],
            test['ocr_keywords']
        )
        print(f"파일: {test['metadata']['file_name']}")
        print(f"  → 카테고리: {category}")
        print(f"  → 적용 규칙: {rule}")
        print(f"  → 키워드: {keywords}\n")
