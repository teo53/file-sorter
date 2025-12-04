"""
롤백 모듈
movement_log.json을 읽어 파일을 원래 위치로 복원합니다.
"""

import json
import os
from typing import List, Dict
from pathlib import Path


class FileRollback:
    """파일 롤백 처리 클래스"""
    
    def __init__(self, log_file: str = None):
        """
        Args:
            log_file: 로그 파일 경로
        """
        if log_file is None:
            project_root = Path(__file__).parent.parent
            self.log_file = os.path.join(project_root, 'movement_log.json')
        else:
            self.log_file = log_file
    
    def rollback_by_path(self, new_path: str) -> bool:
        """
        특정 경로의 파일을 원래 위치로 복원
        
        Args:
            new_path: 현재 파일 경로
            
        Returns:
            성공 여부
        """
        # 로그에서 해당 파일 찾기
        logs = self._read_logs()
        
        for log in reversed(logs):  # 최신 로그부터 검색
            if log.get('action') == 'move' and log.get('new_path') == new_path:
                return self._restore_file(log)
        
        print(f"✗ 로그를 찾을 수 없습니다: {new_path}")
        return False
    
    def rollback_by_filename(self, filename: str) -> bool:
        """
        파일명으로 롤백
        
        Args:
            filename: 새 파일명
            
        Returns:
            성공 여부
        """
        logs = self._read_logs()
        
        for log in reversed(logs):
            if log.get('action') == 'move' and log.get('new_name') == filename:
                return self._restore_file(log)
        
        print(f"✗ 로그를 찾을 수 없습니다: {filename}")
        return False
    
    def rollback_by_category(self, category: str) -> int:
        """
        특정 카테고리의 모든 파일 롤백
        
        Args:
            category: 카테고리 (예: 'images/screenshots')
            
        Returns:
            롤백된 파일 개수
        """
        logs = self._read_logs()
        count = 0
        
        for log in reversed(logs):
            if log.get('action') == 'move' and log.get('category') == category:
                if self._restore_file(log):
                    count += 1
        
        print(f"✓ {category} 카테고리 {count}개 파일 롤백 완료")
        return count
    
    def rollback_by_date_range(self, start_date: str, end_date: str) -> int:
        """
        날짜 범위 내의 모든 파일 롤백
        
        Args:
            start_date: 시작 날짜 (YYYY-MM-DD)
            end_date: 종료 날짜 (YYYY-MM-DD)
            
        Returns:
            롤백된 파일 개수
        """
        logs = self._read_logs()
        count = 0
        
        for log in reversed(logs):
            if log.get('action') == 'move':
                log_date = log.get('timestamp', '')[:10]
                
                if start_date <= log_date <= end_date:
                    if self._restore_file(log):
                        count += 1
        
        print(f"✓ {start_date} ~ {end_date} 기간 {count}개 파일 롤백 완료")
        return count
    
    def rollback_latest(self, count: int = 1) -> int:
        """
        최근 N개 파일 롤백
        
        Args:
            count: 롤백할 파일 개수
            
        Returns:
            실제 롤백된 파일 개수
        """
        logs = self._read_logs()
        
        # 최근 이동 로그만 필터링
        move_logs = [log for log in logs if log.get('action') == 'move']
        
        # 최신 N개 선택
        latest_logs = move_logs[-count:] if len(move_logs) >= count else move_logs
        
        rollback_count = 0
        for log in reversed(latest_logs):
            if self._restore_file(log):
                rollback_count += 1
        
        print(f"✓ 최근 {rollback_count}개 파일 롤백 완료")
        return rollback_count
    
    def _restore_file(self, log_entry: Dict) -> bool:
        """
        로그 엔트리를 기반으로 파일 복원
        
        Args:
            log_entry: 이동 로그 엔트리
            
        Returns:
            성공 여부
        """
        current_path = log_entry.get('new_path')
        original_path = log_entry.get('old_path')
        
        if not current_path or not original_path:
            print("✗ 로그 정보가 불완전합니다.")
            return False
        
        # 파일이 현재 위치에 존재하는지 확인
        if not os.path.exists(current_path):
            print(f"✗ 파일이 존재하지 않습니다: {current_path}")
            return False
        
        try:
            # 원본 디렉토리 생성 (필요한 경우)
            original_dir = os.path.dirname(original_path)
            os.makedirs(original_dir, exist_ok=True)
            
            # 파일 이동 (복원)
            import shutil
            shutil.move(current_path, original_path)
            
            # 롤백 로그 기록
            self._log_rollback(log_entry)
            
            print(f"✓ 복원 완료: {os.path.basename(current_path)} → {original_path}")
            return True
        
        except Exception as e:
            print(f"✗ 복원 실패: {e}")
            return False
    
    def _read_logs(self) -> List[Dict]:
        """로그 파일 읽기"""
        if not os.path.exists(self.log_file):
            print(f"✗ 로그 파일이 없습니다: {self.log_file}")
            return []
        
        try:
            with open(self.log_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            print(f"로그 읽기 오류: {e}")
            return []
    
    def _log_rollback(self, original_log: Dict):
        """롤백 작업 로그 추가"""
        from datetime import datetime
        
        logs = self._read_logs()
        
        rollback_entry = {
            'timestamp': datetime.now().isoformat(),
            'action': 'rollback',
            'file_name': original_log.get('new_name'),
            'from_path': original_log.get('new_path'),
            'to_path': original_log.get('old_path'),
            'original_log_timestamp': original_log.get('timestamp'),
        }
        
        logs.append(rollback_entry)
        
        try:
            with open(self.log_file, 'w', encoding='utf-8') as f:
                json.dump(logs, f, ensure_ascii=False, indent=2)
        except Exception as e:
            print(f"롤백 로그 쓰기 오류: {e}")
    
    def list_rollbackable_files(self) -> List[Dict]:
        """
        롤백 가능한 파일 목록 반환
        
        Returns:
            롤백 가능한 로그 엔트리 리스트
        """
        logs = self._read_logs()
        
        # 이동 작업만 필터링
        move_logs = [log for log in logs if log.get('action') == 'move']
        
        # 실제 파일이 존재하는 것만 필터링
        rollbackable = []
        for log in move_logs:
            new_path = log.get('new_path')
            if new_path and os.path.exists(new_path):
                rollbackable.append(log)
        
        return rollbackable


if __name__ == '__main__':
    # 테스트 코드
    rollback = FileRollback()
    
    # 롤백 가능한 파일 목록
    files = rollback.list_rollbackable_files()
    
    print(f"\n롤백 가능한 파일: {len(files)}개\n")
    
    for i, file_log in enumerate(files[-5:], 1):  # 최근 5개
        print(f"{i}. {file_log.get('original_name')} → {file_log.get('new_name')}")
        print(f"   카테고리: {file_log.get('category')}")
        print(f"   날짜: {file_log.get('timestamp')[:10]}\n")
    
    # 롤백 예제 (실제 실행은 주석 처리)
    # rollback.rollback_latest(count=1)
    # rollback.rollback_by_category('images/screenshots')
