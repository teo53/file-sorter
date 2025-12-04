"""
Test Files Creator
Desktop에 테스트용 파일들을 생성합니다.
"""

import os
from PIL import Image
from datetime import datetime

desktop = os.path.join(os.environ['USERPROFILE'], 'Desktop')

print("="*70)
print("[TEST] Creating Test Files on Desktop")
print("="*70)

# 1. 스크린샷 이미지 (작은 해상도)
print("\n[1/5] Creating screenshot image...")
try:
    img = Image.new('RGB', (800, 600), color='lightblue')
    screenshot_path = os.path.join(desktop, 'screenshot_test_2024.png')
    img.save(screenshot_path)
    print(f"  [OK] {screenshot_path}")
except Exception as e:
    print(f"  [FAIL] {e}")

# 2. 제품 관련 문서 (텍스트 파일로 대체)
print("\n[2/5] Creating product document...")
try:
    product_path = os.path.join(desktop, 'product_euroform_estimate.txt')
    with open(product_path, 'w', encoding='utf-8') as f:
        f.write("Euroform Estimate Document\n")
        f.write("Product: Euroform\n")
        f.write("Date: 2024-12-04\n")
    print(f"  [OK] {product_path}")
except Exception as e:
    print(f"  [FAIL] {e}")

# 3. UI 디자인 이미지
print("\n[3/5] Creating UI design image...")
try:
    img = Image.new('RGB', (1200, 800), color='white')
    ui_path = os.path.join(desktop, 'ui_design_mockup.png')
    img.save(ui_path)
    print(f"  [OK] {ui_path}")
except Exception as e:
    print(f"  [FAIL] {e}")

# 4. 일반 문서
print("\n[4/5] Creating general document...")
try:
    doc_path = os.path.join(desktop, 'report_2024.txt')
    with open(doc_path, 'w', encoding='utf-8') as f:
        f.write("General Report Document\n")
        f.write(f"Created: {datetime.now()}\n")
    print(f"  [OK] {doc_path}")
except Exception as e:
    print(f"  [FAIL] {e}")

# 5. 프로젝트 파일
print("\n[5/5] Creating project file...")
try:
    project_path = os.path.join(desktop, 'test_script.py')
    with open(project_path, 'w', encoding='utf-8') as f:
        f.write("# Test Python Script\n")
        f.write("print('Hello, World!')\n")
    print(f"  [OK] {project_path}")
except Exception as e:
    print(f"  [FAIL] {e}")

print("\n" + "="*70)
print("[SUCCESS] All test files created!")
print("="*70)
print("\n[NEXT] Run: python main.py --dry-run")
print("="*70)
