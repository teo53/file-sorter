"""
파일 스캐너 모듈
Desktop 폴더를 스캔하여 정리할 파일 목록을 반환합니다.
"""

import os
from pathlib import Path
from typing import List


class FileScanner:
    """Desktop 파일 스캐너"""
    
    def __init__(self, scan_directory: str = None):
        """
        Args:
            scan_directory: 스캔할 디렉토리 (기본값: Desktop)
        """
        if scan_directory is None:
            # Windows Desktop 경로
            self.scan_directory = os.path.join(os.environ['USERPROFILE'], 'Desktop')
        else:
            self.scan_directory = scan_directory
        
        # 제외할 디렉토리 (이미 정리된 폴더는 스캔 안 함)
        self.excluded_dirs = {
            'images',
            'documents',
            'project_files',
            'etc',
            '$RECYCLE.BIN',
            'System Volume Information',
        }
        
        # 제외할 파일 패턴 (시스템 파일 + 프로그램 파일)
        self.excluded_files = {
            'desktop.ini',
            'thumbs.db',
            '.ds_store',
            # 바로가기 및 실행 파일
            'file sorter.lnk',
            'dashboard.lnk',
            'rollback.lnk',
            # 배치 파일
            'auto_sort.bat',
            'dashboard.bat',
            'create_shortcuts.bat',
            'rollback.bat',
            # 로그 파일
            'movement_log.json',
        }
        
        # 제외할 파일 확장자
        self.excluded_extensions = {
            '.lnk',  # 모든 바로가기
        }
    
    def scan_files(self, recursive: bool = False, max_depth: int = 1) -> List[str]:
        """
        Desktop 폴더의 파일들을 스캔합니다.
        
        Args:
            recursive: 하위 폴더까지 스캔할지 여부
            max_depth: 최대 스캔 깊이 (1 = Desktop만, 2 = 1단계 하위폴더까지)
            
        Returns:
            파일 경로 리스트
        """
        file_paths = []
        
        if not os.path.exists(self.scan_directory):
            print(f"경고: 스캔 디렉토리가 존재하지 않습니다: {self.scan_directory}")
            return file_paths
        
        if recursive:
            file_paths = self._scan_recursive(max_depth)
        else:
            file_paths = self._scan_single_directory()
        
        return file_paths
    
    def _scan_single_directory(self) -> List[str]:
        """Desktop 디렉토리만 스캔 (하위 폴더 제외)"""
        file_paths = []
        
        try:
            for item in os.listdir(self.scan_directory):
                item_path = os.path.join(self.scan_directory, item)
                
                # 파일만 포함 (디렉토리 제외)
                if os.path.isfile(item_path):
                    # 제외 파일 확인
                    if item.lower() not in self.excluded_files:
                        # 확장자 확인
                        file_ext = Path(item_path).suffix.lower()
                        if file_ext not in self.excluded_extensions:
                            file_paths.append(item_path)
        
        except PermissionError:
            print(f"경고: 접근 권한 없음: {self.scan_directory}")
        except Exception as e:
            print(f"오류 발생: {e}")
        
        return file_paths
    
    def _scan_recursive(self, max_depth: int) -> List[str]:
        """하위 폴더까지 재귀적으로 스캔"""
        file_paths = []
        
        for root, dirs, files in os.walk(self.scan_directory):
            # 현재 깊이 계산
            current_depth = root[len(self.scan_directory):].count(os.sep)
            
            # 최대 깊이 제한
            if current_depth >= max_depth:
                dirs[:] = []  # 더 이상 하위 폴더 탐색 안 함
                continue
            
            # 제외 디렉토리 필터링
            dirs[:] = [d for d in dirs if d not in self.excluded_dirs]
            
            # 파일 추가
            for file in files:
                if file.lower() not in self.excluded_files:
                    file_ext = Path(file).suffix.lower()
                    if file_ext not in self.excluded_extensions:
                        file_path = os.path.join(root, file)
                        file_paths.append(file_path)
        
        return file_paths
    
    def get_file_count(self) -> int:
        """Desktop의 파일 개수 반환 (디렉토리 제외)"""
        return len(self.scan_files(recursive=False))
    
    def print_scan_summary(self, file_paths: List[str]):
        """스캔 결과 요약 출력"""
        print(f"\n{'='*60}")
        print(f"[SCAN] Directory: {self.scan_directory}")
        print(f"[SCAN] Files found: {len(file_paths)}")
        print(f"{'='*60}\n")
        
        if file_paths:
            print("발견된 파일 목록:")
            for i, file_path in enumerate(file_paths[:10], 1):  # 처음 10개만 출력
                print(f"  {i}. {os.path.basename(file_path)}")
            
            if len(file_paths) > 10:
                print(f"  ... 외 {len(file_paths) - 10}개 파일")
        else:
            print("정리할 파일이 없습니다.")


if __name__ == '__main__':
    # 테스트 코드
    scanner = FileScanner()
    
    # Desktop 파일 스캔
    files = scanner.scan_files(recursive=False)
    scanner.print_scan_summary(files)
    
    # 파일 상세 정보
    if files:
        print("\n상세 정보:")
        for file_path in files[:5]:  # 처음 5개만
            file_size = os.path.getsize(file_path)
            file_size_kb = file_size / 1024
            print(f"  - {os.path.basename(file_path)} ({file_size_kb:.1f} KB)")
