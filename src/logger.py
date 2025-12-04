"""
로깅 모듈
모든 파일 이동 작업을 JSON 형식으로 기록합니다.
"""

import json
import os
from datetime import datetime
from typing import Dict, List
from pathlib import Path


class FileLogger:
    """파일 이동 로그 기록 클래스"""
    
    def __init__(self, log_file: str = None):
        """
        Args:
            log_file: 로그 파일 경로 (기본값: movement_log.json)
        """
        if log_file is None:
            # 프로젝트 루트의 movement_log.json
            project_root = Path(__file__).parent.parent
            self.log_file = os.path.join(project_root, 'movement_log.json')
        else:
            self.log_file = log_file
    
    def log_movement(
        self,
        original_name: str,
        new_name: str,
        old_path: str,
        new_path: str,
        category: str,
        rule: str,
        keywords: List[str]
    ):
        """
        파일 이동 기록 추가
        
        Args:
            original_name: 원본 파일명
            new_name: 새 파일명
            old_path: 원본 경로
            new_path: 새 경로
            category: 카테고리
            rule: 적용된 규칙
            keywords: 추출된 키워드
        """
        # 로그 엔트리 생성
        log_entry = {
            'timestamp': datetime.now().isoformat(),
            'original_name': original_name,
            'new_name': new_name,
            'old_path': old_path,
            'new_path': new_path,
            'category': category,
            'rule': rule,
            'keywords': keywords,
            'action': 'move'
        }
        
        # 기존 로그 읽기
        logs = self._read_logs()
        
        # 새 로그 추가
        logs.append(log_entry)
        
        # 로그 저장
        self._write_logs(logs)
        
        print(f"✓ 로그 기록: {original_name} → {new_name}")
    
    def log_rollback(
        self,
        file_name: str,
        current_path: str,
        original_path: str
    ):
        """
        롤백 작업 기록
        
        Args:
            file_name: 파일명
            current_path: 현재 경로
            original_path: 복원된 경로
        """
        log_entry = {
            'timestamp': datetime.now().isoformat(),
            'file_name': file_name,
            'from_path': current_path,
            'to_path': original_path,
            'action': 'rollback'
        }
        
        logs = self._read_logs()
        logs.append(log_entry)
        self._write_logs(logs)
        
        print(f"✓ 롤백 로그 기록: {file_name}")
    
    def _read_logs(self) -> List[Dict]:
        """
        로그 파일 읽기
        
        Returns:
            로그 엔트리 리스트
        """
        if not os.path.exists(self.log_file):
            return []
        
        try:
            with open(self.log_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        except json.JSONDecodeError:
            print(f"경고: 로그 파일 파싱 실패, 새로 생성합니다.")
            return []
        except Exception as e:
            print(f"로그 읽기 오류: {e}")
            return []
    
    def _write_logs(self, logs: List[Dict]):
        """
        로그 파일 쓰기
        
        Args:
            logs: 로그 엔트리 리스트
        """
        try:
            with open(self.log_file, 'w', encoding='utf-8') as f:
                json.dump(logs, f, ensure_ascii=False, indent=2)
        except Exception as e:
            print(f"로그 쓰기 오류: {e}")
    
    def get_logs(
        self,
        category: str = None,
        start_date: str = None,
        end_date: str = None,
        action: str = None
    ) -> List[Dict]:
        """
        조건에 맞는 로그 조회
        
        Args:
            category: 카테고리 필터
            start_date: 시작 날짜 (YYYY-MM-DD)
            end_date: 종료 날짜 (YYYY-MM-DD)
            action: 작업 타입 ('move', 'rollback')
            
        Returns:
            필터링된 로그 리스트
        """
        logs = self._read_logs()
        filtered_logs = []
        
        for log in logs:
            # 카테고리 필터
            if category and log.get('category') != category:
                continue
            
            # 날짜 필터
            log_date = log.get('timestamp', '')[:10]  # YYYY-MM-DD 부분만
            if start_date and log_date < start_date:
                continue
            if end_date and log_date > end_date:
                continue
            
            # 작업 타입 필터
            if action and log.get('action') != action:
                continue
            
            filtered_logs.append(log)
        
        return filtered_logs
    
    def get_statistics(self) -> Dict:
        """
        로그 통계 정보 반환
        
        Returns:
            통계 딕셔너리
        """
        logs = self._read_logs()
        
        stats = {
            'total_moves': 0,
            'total_rollbacks': 0,
            'by_category': {},
            'by_rule': {},
            'last_updated': None,
        }
        
        for log in logs:
            action = log.get('action', 'move')
            
            if action == 'move':
                stats['total_moves'] += 1
                
                # 카테고리별 집계
                category = log.get('category', 'unknown')
                stats['by_category'][category] = stats['by_category'].get(category, 0) + 1
                
                # 규칙별 집계
                rule = log.get('rule', 'unknown')
                stats['by_rule'][rule] = stats['by_rule'].get(rule, 0) + 1
            
            elif action == 'rollback':
                stats['total_rollbacks'] += 1
        
        # 마지막 업데이트 시간
        if logs:
            stats['last_updated'] = logs[-1].get('timestamp')
        
        return stats
    
    def print_statistics(self):
        """통계 정보 출력"""
        stats = self.get_statistics()
        
        print(f"\n{'='*60}")
        print(f"📊 파일 정리 통계")
        print(f"{'='*60}")
        print(f"총 이동 파일: {stats['total_moves']}개")
        print(f"총 롤백 파일: {stats['total_rollbacks']}개")
        
        if stats['by_category']:
            print(f"\n카테고리별 분류:")
            for category, count in stats['by_category'].items():
                print(f"  - {category}: {count}개")
        
        if stats['by_rule']:
            print(f"\n규칙별 분류:")
            for rule, count in stats['by_rule'].items():
                print(f"  - {rule}: {count}개")
        
        if stats['last_updated']:
            print(f"\n마지막 업데이트: {stats['last_updated']}")
        
        print(f"{'='*60}\n")


if __name__ == '__main__':
    # 테스트 코드
    logger = FileLogger()
    
    # 테스트 로그 추가
    logger.log_movement(
        original_name='스크린샷_2024.png',
        new_name='screenshots_주문내역_2024-12-04.png',
        old_path=r'C:\Users\mapdr\Desktop\스크린샷_2024.png',
        new_path=r'C:\Users\mapdr\Desktop\images\screenshots\screenshots_주문내역_2024-12-04.png',
        category='images/screenshots',
        rule='filename_pattern',
        keywords=['주문내역']
    )
    
    # 통계 출력
    logger.print_statistics()
    
    # 로그 조회
    print("\n최근 로그:")
    recent_logs = logger.get_logs()
    for log in recent_logs[-3:]:  # 최근 3개
        print(f"  - {log['original_name']} → {log['new_name']} ({log['timestamp']})")
