"""
파일 이동 모듈
파일을 지정된 카테고리 폴더로 안전하게 이동합니다.
"""

import os
import shutil
from pathlib import Path
from typing import Tuple


class FileMover:
    """파일 이동 처리 클래스"""
    
    def __init__(self, base_directory: str = None):
        """
        Args:
            base_directory: 기본 디렉토리 (기본값: Desktop)
        """
        if base_directory is None:
            self.base_directory = os.path.join(os.environ['USERPROFILE'], 'Desktop')
        else:
            self.base_directory = base_directory
    
    def move_file(
        self,
        source_path: str,
        category: str,
        new_filename: str
    ) -> Tuple[bool, str, str]:
        """
        파일을 카테고리 폴더로 이동
        
        Args:
            source_path: 원본 파일 경로
            category: 카테고리 (예: 'images/screenshots')
            new_filename: 새 파일명
            
        Returns:
            (성공여부, 이전 경로, 새 경로)
        """
        try:
            # 대상 디렉토리 생성
            destination_dir = self._get_category_directory(category)
            self._ensure_directory_exists(destination_dir)
            
            # 최종 파일 경로
            destination_path = os.path.join(destination_dir, new_filename)
            
            # 파일 이동
            shutil.move(source_path, destination_path)
            
            return True, source_path, destination_path
        
        except Exception as e:
            print(f"파일 이동 실패: {source_path} -> {e}")
            return False, source_path, ""
    
    def _get_category_directory(self, category: str) -> str:
        """
        카테고리에 해당하는 디렉토리 경로 반환
        
        Args:
            category: 카테고리 (예: 'images/screenshots')
            
        Returns:
            전체 디렉토리 경로
        """
        # 슬래시를 OS별 경로 구분자로 변환
        category_path = category.replace('/', os.sep)
        return os.path.join(self.base_directory, category_path)
    
    def _ensure_directory_exists(self, directory: str):
        """
        디렉토리가 없으면 생성
        
        Args:
            directory: 디렉토리 경로
        """
        os.makedirs(directory, exist_ok=True)
    
    def preview_move(
        self,
        source_path: str,
        category: str,
        new_filename: str
    ) -> Tuple[str, str]:
        """
        이동 미리보기 (실제 이동은 하지 않음)
        
        Args:
            source_path: 원본 파일 경로
            category: 카테고리
            new_filename: 새 파일명
            
        Returns:
            (원본 경로, 예상 새 경로)
        """
        destination_dir = self._get_category_directory(category)
        destination_path = os.path.join(destination_dir, new_filename)
        
        return source_path, destination_path
    
    def rollback_move(
        self,
        current_path: str,
        original_path: str
    ) -> bool:
        """
        파일을 원래 위치로 되돌림
        
        Args:
            current_path: 현재 파일 경로
            original_path: 원래 파일 경로
            
        Returns:
            성공 여부
        """
        try:
            # 원본 디렉토리가 있는지 확인
            original_dir = os.path.dirname(original_path)
            self._ensure_directory_exists(original_dir)
            
            # 파일 이동 (되돌리기)
            shutil.move(current_path, original_path)
            
            print(f"✓ 롤백 완료: {os.path.basename(current_path)} → {original_path}")
            return True
        
        except Exception as e:
            print(f"✗ 롤백 실패: {current_path} -> {e}")
            return False
    
    def get_directory_size(self, directory: str) -> int:
        """
        디렉토리의 총 파일 크기 계산
        
        Args:
            directory: 디렉토리 경로
            
        Returns:
            총 크기 (bytes)
        """
        total_size = 0
        
        try:
            for dirpath, dirnames, filenames in os.walk(directory):
                for filename in filenames:
                    filepath = os.path.join(dirpath, filename)
                    total_size += os.path.getsize(filepath)
        except Exception as e:
            print(f"디렉토리 크기 계산 실패: {e}")
        
        return total_size


if __name__ == '__main__':
    # 테스트 코드 (실제 파일 이동은 하지 않음)
    mover = FileMover()
    
    # 미리보기 테스트
    test_cases = [
        {
            'source': r'C:\Users\mapdr\Desktop\스크린샷_2024.png',
            'category': 'images/screenshots',
            'new_name': 'screenshots_주문내역_2024-12-04.png',
        },
        {
            'source': r'C:\Users\mapdr\Desktop\문서.pdf',
            'category': 'documents',
            'new_name': 'documents_보고서_2024-12-01.pdf',
        },
    ]
    
    print("파일 이동 미리보기:\n")
    for test in test_cases:
        old_path, new_path = mover.preview_move(
            test['source'],
            test['category'],
            test['new_name']
        )
        print(f"원본: {old_path}")
        print(f"  → 새 위치: {new_path}\n")
    
    # 카테고리 디렉토리 확인
    print("\n생성될 디렉토리:")
    categories = ['images/screenshots', 'images/products', 'documents', 'project_files', 'etc']
    for cat in categories:
        dir_path = mover._get_category_directory(cat)
        print(f"  - {cat}: {dir_path}")
