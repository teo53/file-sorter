"""
파일 이름 변경 모듈
[카테고리]_[키워드]_[날짜] 형식으로 새 파일명을 생성합니다.
"""

import os
import re
from pathlib import Path
from typing import List, Tuple


class FileRenamer:
    """파일 이름 자동 생성 클래스"""
    
    def __init__(self):
        pass
    
    def generate_new_name(
        self,
        category: str,
        keywords: List[str],
        date: str,
        original_name: str,
        destination_dir: str = None
    ) -> str:
        """
        새로운 파일명 생성 (기존 파일명 유지 + 분류 정보 접두사)
        
        Args:
            category: 파일 카테고리 (예: 'images/screenshots')
            keywords: 키워드 리스트 (사용 안 함, 호환성 유지)
            date: 날짜 문자열 (사용 안 함, 호환성 유지)
            original_name: 원본 파일명
            destination_dir: 대상 디렉토리 (중복 확인용)
            
        Returns:
            새로운 파일명 (확장자 포함)
        """
        # 확장자 분리
        name_without_ext = Path(original_name).stem
        file_ext = Path(original_name).suffix.lower()
        
        # 원본 파일명 정제 (특수문자는 유지하되 Windows 불가능 문자만 제거)
        cleaned_name = self._sanitize_filename(name_without_ext)
        
        # 카테고리 단순화 (마지막 부분만 사용)
        category_name = category.split('/')[-1]
        
        # 새 파일명 구성: [카테고리]_[기존파일명].[확장자]
        # 예: "screenshots_스크린샷 2024-12-04.png"
        new_name = f"{category_name}_{cleaned_name}{file_ext}"
        
        # 중복 파일명 처리
        if destination_dir:
            new_name = self._handle_duplicate(new_name, destination_dir)
        
        return new_name
    
    def _sanitize_filename(self, filename: str) -> str:
        """
        파일명에서 사용할 수 없는 문자 제거 (기존 파일명 최대한 보존)
        
        Args:
            filename: 원본 파일명
            
        Returns:
            정제된 파일명
        """
        # Windows에서 사용 불가능한 문자만 제거: < > : " / \ | ? *
        invalid_chars = r'[<>:"/\\|?*]'
        
        # 불가능한 문자를 공백으로 대체 (언더스코어 대신)
        sanitized = re.sub(invalid_chars, ' ', filename)
        
        # 연속된 공백을 하나로
        sanitized = re.sub(r'\s{2,}', ' ', sanitized)
        
        # 앞뒤 공백 제거
        sanitized = sanitized.strip()
        
        return sanitized
    
    def _handle_duplicate(self, filename: str, destination_dir: str) -> str:
        """
        중복 파일명 처리 (번호 추가)
        
        Args:
            filename: 파일명
            destination_dir: 대상 디렉토리
            
        Returns:
            중복되지 않는 파일명
        """
        # 파일이 존재하지 않으면 그대로 반환
        full_path = os.path.join(destination_dir, filename)
        if not os.path.exists(full_path):
            return filename
        
        # 파일명과 확장자 분리
        name, ext = os.path.splitext(filename)
        
        # 번호 추가하여 중복 회피
        counter = 1
        while True:
            new_filename = f"{name}_{counter:03d}{ext}"  # 001, 002, ...
            new_path = os.path.join(destination_dir, new_filename)
            
            if not os.path.exists(new_path):
                return new_filename
            
            counter += 1
            
            # 안전장치 (무한루프 방지)
            if counter > 999:
                # 타임스탬프 추가
                from datetime import datetime
                timestamp = datetime.now().strftime('%H%M%S')
                return f"{name}_{timestamp}{ext}"
    
    def preview_rename(
        self,
        original_path: str,
        category: str,
        keywords: List[str],
        date: str
    ) -> Tuple[str, str]:
        """
        이름 변경 미리보기
        
        Args:
            original_path: 원본 파일 경로
            category: 카테고리
            keywords: 키워드
            date: 날짜
            
        Returns:
            (원본 파일명, 새 파일명)
        """
        original_name = os.path.basename(original_path)
        new_name = self.generate_new_name(category, keywords, date, original_name)
        
        return original_name, new_name


if __name__ == '__main__':
    # 테스트 코드
    renamer = FileRenamer()
    
    # 테스트 케이스
    test_cases = [
        {
            'category': 'images/screenshots',
            'keywords': ['주문내역', '확인'],
            'date': '2024-12-04',
            'original_name': '스크린샷 2024-12-04 오전 11시.png',
        },
        {
            'category': 'images/products',
            'keywords': ['유로폼'],
            'date': '2024-11-20',
            'original_name': '유로폼_견적서.pdf',
        },
        {
            'category': 'documents',
            'keywords': [],
            'date': '2024-12-01',
            'original_name': 'report.docx',
        },
    ]
    
    print("파일명 변경 테스트:\n")
    for test in test_cases:
        new_name = renamer.generate_new_name(
            test['category'],
            test['keywords'],
            test['date'],
            test['original_name']
        )
        print(f"원본: {test['original_name']}")
        print(f"  → 새 파일명: {new_name}")
        print(f"  → 카테고리: {test['category']}")
        print(f"  → 키워드: {test['keywords']}\n")
