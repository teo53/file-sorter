"""
메인 실행 스크립트
Desktop 파일 자동 정리 시스템
"""

import os
import sys
from pathlib import Path
from typing import List

# src 모듈 import
from file_scanner import FileScanner
from metadata_reader import MetadataReader
from categorizer import FileCategorizer
from ocr_handler import OCRHandler
from renamer import FileRenamer
from mover import FileMover
from logger import FileLogger
from config import get_config
from utils import format_size, calculate_total_size, print_progress_bar, is_hidden_file


class AutoFileSorter:
    """자동 파일 정리 시스템"""
    
    def __init__(self, enable_ocr: bool = True, dry_run: bool = False, auto_mode: bool = False, target_directory: str = None):
        """
        Args:
            enable_ocr: OCR 활성화 여부
            dry_run: 테스트 모드 (실제 이동 안 함)
            auto_mode: 자동 모드 (사용자 확인 없이 실행)
            target_directory: 정리할 대상 폴더 (기본값: Desktop)
        """
        self.scanner = FileScanner(scan_directory=target_directory)
        self.metadata_reader = MetadataReader()
        self.categorizer = FileCategorizer()
        self.ocr_handler = OCRHandler(enabled=enable_ocr)
        self.renamer = FileRenamer()
        self.mover = FileMover(base_directory=target_directory)
        self.logger = FileLogger()
        
        self.dry_run = dry_run
        self.enable_ocr = enable_ocr
        self.auto_mode = auto_mode
        self.target_directory = target_directory or self.scanner.scan_directory
    
    def run(self):
        """파일 정리 실행"""
        config = get_config()
        use_emoji = config.get('ui', 'use_emoji')
        
        # 헤더
        emoji = "🤖 " if use_emoji else ""
        print("\n" + "="*80)
        print(f"{emoji}파일 자동 정리 시스템")
        print("="*80)
        
        # 1단계: 파일 스캔
        print(f"\n{'📂 ' if use_emoji else ''}[1/5] 파일 스캔 중...")
        file_paths = self.scanner.scan_files(recursive=False)
        
        if not file_paths:
            print(f"\n{'✅ ' if use_emoji else ''}정리할 파일이 없습니다.")
            return
        
        print(f"{'✓ ' if use_emoji else ''}발견된 파일: {len(file_paths)}개")
        
        # 2단계: 안전 검사
        print(f"\n{'🛡️ ' if use_emoji else ''}[2/5] 안전 검사 중...")
        file_paths = self._safety_check(file_paths)
        
        if not file_paths:
            print(f"\n{'⚠️ ' if use_emoji else ''}모든 파일이 필터링되었습니다.")
            return
        
        # 3단계: 미리보기
        if config.get('processing', 'preview_before_execute') and not self.auto_mode:
            print(f"\n{'👀 ' if use_emoji else ''}[3/5] 미리보기")
            if not self._show_preview(file_paths):
                print(f"\n{'🚫 ' if use_emoji else ''}작업이 취소되었습니다.")
                return
        
        # 4단계: 파일 처리
        print(f"\n{'⚙️ ' if use_emoji else ''}[4/5] 파일 처리 중...")
        processed_count, failed_count = self._process_files(file_paths)
        
        # 5단계: 결과 요약
        print(f"\n{'📊 ' if use_emoji else ''}[5/5] 완료")
        self._print_summary(processed_count, failed_count)
    
    def _safety_check(self, file_paths: List[str]) -> List[str]:
        """안전 검사 수행"""
        config = get_config()
        use_emoji = config.get('ui', 'use_emoji')
        
        # 필터링된 파일 목록
        safe_files = []
        
        # 1. 제외 확장자 확인
        exclude_exts = config.get('safety', 'exclude_extensions')
        
        # 2. 숨김 파일 확인
        protect_hidden = config.get('safety', 'protect_hidden_files')
        
        # 3. 대용량 파일 리스트
        large_threshold_mb = config.get('safety', 'large_file_threshold_mb')
        large_files = []
        
        for file_path in file_paths:
            # 확장자 검사
            file_ext = Path(file_path).suffix.lower()
            if file_ext in exclude_exts:
                print(f"  {'⏭️ ' if use_emoji else ''}제외: {os.path.basename(file_path)} (실행 파일)")
                continue
            
            # 숨김 파일 검사
            if protect_hidden and is_hidden_file(file_path):
                print(f"  {'👻 ' if use_emoji else ''}제외: {os.path.basename(file_path)} (숨김 파일)")
                continue
            
            # 대용량 파일 체크
            file_size = os.path.getsize(file_path)
            if file_size > large_threshold_mb * 1024 * 1024:
                large_files.append((file_path, file_size))
            
            safe_files.append(file_path)
        
        # 파일 수 경고
        max_files = config.get('safety', 'max_files_warning')
        if len(safe_files) > max_files and not self.auto_mode:
            print(f"\n{'⚠️ ' if use_emoji else ''}경고: {len(safe_files)}개 파일을 처리합니다 (권장: {max_files}개 이하)")
            response = input("계속하시겠습니까? (y/n): ")
            if response.lower() != 'y':
                return []
        
        # 대용량 파일 경고
        if large_files and not self.auto_mode:
            print(f"\n{'📦 ' if use_emoji else ''}대용량 파일 발견:")
            for file_path, size in large_files[:5]:  # 최대 5개만 표시
                print(f"  - {os.path.basename(file_path)}: {format_size(size)}")
            if len(large_files) > 5:
                print(f"  ... 외 {len(large_files) - 5}개")
            
            response = input("이 파일들도 처리하시겠습니까? (y/n): ")
            if response.lower() != 'y':
                # 대용량 파일 제외
                large_file_paths = {fp for fp, _ in large_files}
                safe_files = [fp for fp in safe_files if fp not in large_file_paths]
        
        print(f"{'✅ ' if use_emoji else ''}안전 검사 통과: {len(safe_files)}개 파일")
        return safe_files
    
    def _show_preview(self, file_paths: List[str]) -> bool:
        """미리보기 표시"""
        config = get_config()
        use_emoji = config.get('ui', 'use_emoji')
        
        print("\n" + "="*80)
        print("처리될 파일 미리보기")
        print("="*80)
        
        # 총 크기 계산
        total_size = calculate_total_size(file_paths)
        print(f"\n총 {len(file_paths)}개 파일, {format_size(total_size)}")
        
        # 처음 10개 파일만 표시
        print("\n이동될 파일:")
        for i, file_path in enumerate(file_paths[:10], 1):
            file_name = os.path.basename(file_path)
            file_size = format_size(os.path.getsize(file_path))
            print(f"  {i}. {file_name} ({file_size})")
        
        if len(file_paths) > 10:
            print(f"  ... 외 {len(file_paths) - 10}개 파일")
        
        print("\n" + "="*80)
        response = input(f"{'✨ ' if use_emoji else ''}파일 정리를 시작하시겠습니까? (y/n): ")
        return response.lower() == 'y'
    
    def _process_files(self, file_paths: List[str]) -> tuple:
        """파일 처리 (진행 바 포함)"""
        config = get_config()
        show_progress = config.get('processing', 'show_progress')
        use_emoji = config.get('ui', 'use_emoji')
        
        processed_count = 0
        failed_count = 0
        total = len(file_paths)
        
        for i, file_path in enumerate(file_paths, 1):
            # 진행 바 표시
            if show_progress:
                print_progress_bar(i - 1, total, prefix=f"{'⏳ ' if use_emoji else ''}진행:", suffix=f"{i-1}/{total}")
            
            success = self._process_file(file_path)
            
            if success:
                processed_count += 1
            else:
                failed_count += 1
        
        # 완료 진행 바
        if show_progress:
            print_progress_bar(total, total, prefix=f"{'✅ ' if use_emoji else ''}완료:", suffix=f"{total}/{total}")
        
        return processed_count, failed_count
    
    def _process_file(self, file_path: str) -> bool:
        """
        단일 파일 처리
        
        Args:
            file_path: 파일 경로
            
        Returns:
            성공 여부
        """
        try:
            original_name = os.path.basename(file_path)
            print(f"  [FILE] {original_name}")
            
            # 2단계: 메타데이터 읽기
            metadata = self.metadata_reader.read_metadata(file_path)
            
            # 3단계: OCR (필요 시)
            ocr_keywords = []
            if self.enable_ocr and self.ocr_handler.should_use_ocr(metadata):
                print(f"    [OCR] Processing...")
                ocr_keywords = self.ocr_handler.extract_keywords(file_path, max_keywords=3)
                if ocr_keywords:
                    print(f"    [OK] Keywords: {', '.join(ocr_keywords)}")
            
            # 4단계: 파일 분류
            category, rule, keywords = self.categorizer.categorize(
                file_path, metadata, ocr_keywords
            )
            print(f"    [CATEGORY] {category} (rule: {rule})")
            
            # 5단계: 파일명 생성
            date = metadata.get('creation_date', metadata.get('modified_date'))
            destination_dir = self.mover._get_category_directory(category)
            
            new_filename = self.renamer.generate_new_name(
                category=category,
                keywords=keywords,
                date=date,
                original_name=original_name,
                destination_dir=destination_dir
            )
            print(f"    [RENAME] {new_filename}")
            
            # 6단계: 파일 이동
            if self.dry_run:
                # 테스트 모드: 이동 미리보기만
                old_path, new_path = self.mover.preview_move(file_path, category, new_filename)
                print(f"    [DRY-RUN] Would move to: {new_path}")
                return True
            else:
                # 실제 이동
                success, old_path, new_path = self.mover.move_file(
                    file_path, category, new_filename
                )
                
                if success:
                    print(f"    [MOVED] {new_path}")
                    
                    # 7단계: 로그 기록
                    self.logger.log_movement(
                        original_name=original_name,
                        new_name=new_filename,
                        old_path=old_path,
                        new_path=new_path,
                        category=category,
                        rule=rule,
                        keywords=keywords
                    )
                    return True
                else:
                    print(f"    [FAIL] Move failed")
                    return False
        
        except Exception as e:
            print(f"    [ERROR] {e}")
            return False
    
    def _print_summary(self, processed: int, failed: int):
        """결과 요약 출력"""
        print("\n" + "="*80)
        print("[SUMMARY] Task Completed")
        print("="*80)
        print(f"[SUCCESS] {processed} files")
        print(f"[FAILED] {failed} files")
        print(f"[LOG] movement_log.json")
        print("="*80 + "\n")
        
        # 통계 출력
        if not self.dry_run:
            self.logger.print_statistics()


def main():
    """메인 함수"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Desktop 파일 자동 정리 시스템')
    parser.add_argument('--no-ocr', action='store_true', help='OCR 비활성화')
    parser.add_argument('--dry-run', action='store_true', help='테스트 모드 (실제 이동 X)')
    parser.add_argument('--auto', action='store_true', help='자동 모드 (확인 없이 바로 실행)')
    parser.add_argument('--target', type=str, default=None, help='정리할 대상 폴더 경로 (기본값: Desktop)')
    
    args = parser.parse_args()
    
    # 폴더 선택
    target_directory = args.target
    
    # CLI에서 폴더를 지정하지 않았고, auto 모드가 아니면 GUI로 선택
    if target_directory is None and not args.auto:
        target_directory = select_folder_gui()
        if target_directory is None:
            print("\n폴더 선택이 취소되었습니다.")
            return
    
    # 시스템 실행
    sorter = AutoFileSorter(
        enable_ocr=not args.no_ocr,
        dry_run=args.dry_run,
        auto_mode=args.auto,
        target_directory=target_directory
    )
    
    try:
        sorter.run()
    except KeyboardInterrupt:
        print("\n\n작업이 중단되었습니다.")
        sys.exit(0)
    except Exception as e:
        print(f"\n\n오류 발생: {e}")
        sys.exit(1)


def select_folder_gui():
    """GUI로 폴더 선택"""
    try:
        import tkinter as tk
        from tkinter import filedialog
        
        # Tkinter 루트 윈도우 생성 (숨김)
        root = tk.Tk()
        root.withdraw()
        root.attributes('-topmost', True)
        
        # 폴더 선택 다이얼로그
        folder_path = filedialog.askdirectory(
            title='정리할 폴더를 선택하세요',
            initialdir=os.path.join(os.environ['USERPROFILE'], 'Desktop')
        )
        
        root.destroy()
        
        return folder_path if folder_path else None
    
    except ImportError:
        print("\n[경고] GUI를 사용할 수 없습니다. 기본값(Desktop)을 사용합니다.")
        return None
    except Exception as e:
        print(f"\n[경고] 폴더 선택 중 오류 발생: {e}")
        return None


if __name__ == '__main__':
    main()
