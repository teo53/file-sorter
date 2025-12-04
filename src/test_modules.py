"""
모듈 테스트 스크립트
각 Python 모듈이 정상적으로 로드되고 작동하는지 확인합니다.
"""

import sys
import os

print("="*70)
print("[TEST] File Sorting System Module Test")
print("="*70)

# 1. 모듈 Import 테스트
print("\n[1/8] Module Import Test...")
try:
    from file_scanner import FileScanner
    print("  [OK] file_scanner.py")
    
    from metadata_reader import MetadataReader
    print("  [OK] metadata_reader.py")
    
    from categorizer import FileCategorizer
    print("  [OK] categorizer.py")
    
    from ocr_handler import OCRHandler
    print("  [OK] ocr_handler.py")
    
    from renamer import FileRenamer
    print("  [OK] renamer.py")
    
    from mover import FileMover
    print("  [OK] mover.py")
    
    from logger import FileLogger
    print("  [OK] logger.py")
    
    from rollback import FileRollback
    print("  [OK] rollback.py")
    
    print("  [PASS] All modules loaded successfully!")
except Exception as e:
    print(f"  [FAIL] Error: {e}")
    sys.exit(1)

# 2. FileScanner 테스트
print("\n[2/8] FileScanner Test...")
try:
    scanner = FileScanner()
    print(f"  - Scan directory: {scanner.scan_directory}")
    print(f"  - Excluded dirs: {len(scanner.excluded_dirs)}")
    print("  [PASS] FileScanner initialized!")
except Exception as e:
    print(f"  [FAIL] Error: {e}")

# 3. MetadataReader 테스트
print("\n[3/8] MetadataReader Test...")
try:
    reader = MetadataReader()
    print(f"  - Screenshot threshold: {reader.screenshot_max_dimension}px")
    print("  [PASS] MetadataReader initialized!")
except Exception as e:
    print(f"  [FAIL] Error: {e}")

# 4. FileCategorizer 테스트
print("\n[4/8] FileCategorizer Test...")
try:
    categorizer = FileCategorizer()
    categories = list(categorizer.category_rules.keys())
    print(f"  - Categories: {len(categories)}")
    print(f"  - List: {', '.join(categories[:3])}...")
    
    # 테스트 분류
    test_metadata = {
        'file_name': 'screenshot_test.png',
        'file_ext': '.png',
        'is_likely_screenshot': True
    }
    category, rule, keywords = categorizer.categorize(
        'test.png', test_metadata, None
    )
    print(f"  - Test: '{test_metadata['file_name']}' -> {category} ({rule})")
    print("  [PASS] FileCategorizer working!")
except Exception as e:
    print(f"  [FAIL] Error: {e}")

# 5. OCRHandler 테스트
print("\n[5/8] OCRHandler Test...")
try:
    ocr = OCRHandler(enabled=True)
    if ocr.enabled:
        print("  [PASS] OCR enabled (Tesseract installed)")
    else:
        print("  [WARN] OCR disabled (Tesseract not found)")
        print("     -> System works fine without OCR")
except Exception as e:
    print(f"  [FAIL] Error: {e}")

# 6. FileRenamer 테스트
print("\n[6/8] FileRenamer Test...")
try:
    renamer = FileRenamer()
    new_name = renamer.generate_new_name(
        category='images/screenshots',
        keywords=['test', 'check'],
        date='2024-12-04',
        original_name='screenshot.png'
    )
    print(f"  - Generated: {new_name}")
    print("  [PASS] FileRenamer working!")
except Exception as e:
    print(f"  [FAIL] Error: {e}")

# 7. FileMover 테스트
print("\n[7/8] FileMover Test...")
try:
    mover = FileMover()
    print(f"  - Base dir: {mover.base_directory}")
    
    # 미리보기 테스트
    test_path = r"C:\Users\mapdr\Desktop\test.png"
    old, new = mover.preview_move(test_path, 'images/screenshots', 'screenshots_test_2024-12-04.png')
    print(f"  - Preview: {os.path.basename(old)} -> {os.path.basename(new)}")
    print("  [PASS] FileMover working!")
except Exception as e:
    print(f"  [FAIL] Error: {e}")

# 8. FileLogger 테스트
print("\n[8/8] FileLogger Test...")
try:
    logger = FileLogger()
    print(f"  - Log file: {logger.log_file}")
    
    # 통계 확인
    stats = logger.get_statistics()
    print(f"  - Current: {stats['total_moves']} moves, {stats['total_rollbacks']} rollbacks")
    print("  [PASS] FileLogger working!")
except Exception as e:
    print(f"  [FAIL] Error: {e}")

# 최종 결과
print("\n" + "="*70)
print("[SUCCESS] All module tests completed!")
print("="*70)
print("\n[NEXT STEPS]")
print("  1. Create test files: python create_test_files.py")
print("  2. Run dry-run mode: python main.py --dry-run")
print("  3. Run actual sorting: python main.py")
print("="*70)
