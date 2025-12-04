"""
유틸리티 함수 모듈
파일 크기 계산, 진행 상황 표시 등
"""

import os
from typing import List


def format_size(bytes_size: int) -> str:
    """바이트를 읽기 쉬운 형식으로 변환
    
    Args:
        bytes_size: 바이트 크기
        
    Returns:
        포맷된 문자열 (예: "1.5 MB")
    """
    for unit in ['B', 'KB', 'MB', 'GB']:
        if bytes_size < 1024.0:
            return f"{bytes_size:.1f} {unit}"
        bytes_size /= 1024.0
    return f"{bytes_size:.1f} TB"


def calculate_total_size(file_paths: List[str]) -> int:
    """파일 목록의 총 크기 계산
    
    Args:
        file_paths: 파일 경로 리스트
        
    Returns:
        총 크기 (바이트)
    """
    total_size = 0
    for file_path in file_paths:
        try:
            if os.path.exists(file_path):
                total_size += os.path.getsize(file_path)
        except Exception:
            pass
    return total_size


def print_progress_bar(current: int, total: int, prefix: str = '', suffix: str = '', length: int = 50):
    """진행 상황 바 출력
    
    Args:
        current: 현재 진행 수
        total: 전체 작업 수
        prefix: 앞에 표시할 문자열
        suffix: 뒤에 표시할 문자열
        length: 진행 바 길이
    """
    if total == 0:
        percent = 100
    else:
        percent = int((current / total) * 100)
    
    filled_length = int(length * current // total) if total > 0 else length
    bar = '█' * filled_length + '░' * (length - filled_length)
    
    print(f'\r{prefix} |{bar}| {percent}% {suffix}', end='', flush=True)
    
    if current == total:
        print()  # 완료 시 줄바꿈


def is_hidden_file(file_path: str) -> bool:
    """숨김 파일 여부 확인 (Windows)
    
    Args:
        file_path: 파일 경로
        
    Returns:
        숨김 파일이면 True
    """
    try:
        import ctypes
        attrs = ctypes.windll.kernel32.GetFileAttributesW(file_path)
        return attrs != -1 and bool(attrs & 2)  # FILE_ATTRIBUTE_HIDDEN = 2
    except Exception:
        # Windows가 아니거나 오류 발생 시
        return os.path.basename(file_path).startswith('.')


if __name__ == '__main__':
    # 테스트
    print("=== 유틸리티 함수 테스트 ===\n")
    
    # 크기 포맷팅
    print("크기 포맷팅:")
    print(f"  1024 bytes = {format_size(1024)}")
    print(f"  1048576 bytes = {format_size(1048576)}")
    print(f"  1073741824 bytes = {format_size(1073741824)}\n")
    
    # 진행 바
    print("진행 바 테스트:")
    import time
    for i in range(101):
        print_progress_bar(i, 100, prefix='진행:', suffix='완료')
        time.sleep(0.01)
