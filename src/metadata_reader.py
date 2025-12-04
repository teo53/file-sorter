"""
메타데이터 읽기 모듈
파일의 EXIF, 생성 날짜, 이미지 크기 등의 메타데이터를 추출합니다.
"""

import os
from datetime import datetime
from pathlib import Path
from typing import Dict, Optional, Tuple
from PIL import Image
from PIL.ExifTags import TAGS


class MetadataReader:
    """파일 메타데이터 추출 클래스"""
    
    def __init__(self):
        self.screenshot_max_dimension = 1500  # 스크린샷 판단 기준 해상도
    
    def read_metadata(self, file_path: str) -> Dict:
        """
        파일의 모든 메타데이터를 읽어옵니다.
        
        Args:
            file_path: 파일 경로
            
        Returns:
            메타데이터 딕셔너리
        """
        metadata = {
            'file_path': file_path,
            'file_name': os.path.basename(file_path),
            'file_ext': Path(file_path).suffix.lower(),
            'file_size': os.path.getsize(file_path),
            'creation_date': self._get_creation_date(file_path),
            'modified_date': self._get_modified_date(file_path),
            'is_image': False,
            'image_dimensions': None,
            'exif_data': {},
            'is_camera_photo': False,
            'is_likely_screenshot': False,
        }
        
        # 이미지 파일인 경우 추가 메타데이터 추출
        if self._is_image_file(file_path):
            metadata['is_image'] = True
            metadata['image_dimensions'] = self._get_image_dimensions(file_path)
            metadata['exif_data'] = self._get_exif_data(file_path)
            metadata['is_camera_photo'] = self._is_camera_photo(metadata['exif_data'])
            metadata['is_likely_screenshot'] = self._is_likely_screenshot(
                metadata['file_name'],
                metadata['image_dimensions'],
                metadata['exif_data']
            )
        
        return metadata
    
    def _is_image_file(self, file_path: str) -> bool:
        """이미지 파일인지 확인"""
        image_extensions = {'.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.tiff'}
        return Path(file_path).suffix.lower() in image_extensions
    
    def _get_creation_date(self, file_path: str) -> str:
        """파일 생성 날짜 가져오기"""
        try:
            timestamp = os.path.getctime(file_path)
            return datetime.fromtimestamp(timestamp).strftime('%Y-%m-%d')
        except Exception:
            return datetime.now().strftime('%Y-%m-%d')
    
    def _get_modified_date(self, file_path: str) -> str:
        """파일 수정 날짜 가져오기"""
        try:
            timestamp = os.path.getmtime(file_path)
            return datetime.fromtimestamp(timestamp).strftime('%Y-%m-%d')
        except Exception:
            return datetime.now().strftime('%Y-%m-%d')
    
    def _get_image_dimensions(self, file_path: str) -> Optional[Tuple[int, int]]:
        """이미지 크기(가로 x 세로) 가져오기"""
        try:
            with Image.open(file_path) as img:
                return img.size  # (width, height)
        except Exception:
            return None
    
    def _get_exif_data(self, file_path: str) -> Dict:
        """EXIF 데이터 추출"""
        exif_data = {}
        try:
            with Image.open(file_path) as img:
                exif_raw = img._getexif()
                if exif_raw:
                    for tag_id, value in exif_raw.items():
                        tag_name = TAGS.get(tag_id, tag_id)
                        exif_data[tag_name] = str(value)
        except Exception:
            pass
        
        return exif_data
    
    def _is_camera_photo(self, exif_data: Dict) -> bool:
        """
        카메라로 촬영한 사진인지 판단
        iPhone, Samsung 등의 카메라 메타데이터 확인
        """
        if not exif_data:
            return False
        
        # 카메라 제조사/모델 확인
        camera_indicators = ['Make', 'Model', 'LensModel', 'FocalLength']
        has_camera_info = any(key in exif_data for key in camera_indicators)
        
        # iPhone, Samsung 등 확인
        make = exif_data.get('Make', '').lower()
        model = exif_data.get('Model', '').lower()
        
        known_cameras = ['iphone', 'samsung', 'canon', 'nikon', 'sony', 'apple']
        has_known_camera = any(cam in make or cam in model for cam in known_cameras)
        
        return has_camera_info or has_known_camera
    
    def _is_likely_screenshot(
        self, 
        filename: str, 
        dimensions: Optional[Tuple[int, int]], 
        exif_data: Dict
    ) -> bool:
        """
        스크린샷일 가능성이 높은지 판단
        
        판단 기준:
        1. 파일명에 "캡처", "screenshot", "스크린샷" 포함
        2. 해상도가 낮음 (가로/세로 중 하나라도 1500px 미만)
        3. EXIF 카메라 정보 없음
        """
        filename_lower = filename.lower()
        screenshot_keywords = ['캡처', 'screenshot', '스크린샷', 'capture']
        
        # 파일명 확인
        has_screenshot_keyword = any(keyword in filename_lower for keyword in screenshot_keywords)
        
        # 해상도 확인
        is_low_resolution = False
        if dimensions:
            width, height = dimensions
            is_low_resolution = width < self.screenshot_max_dimension or height < self.screenshot_max_dimension
        
        # 카메라 정보 없음
        has_no_camera_info = not self._is_camera_photo(exif_data)
        
        # 하나라도 만족하면 스크린샷 가능성 있음
        return has_screenshot_keyword or (is_low_resolution and has_no_camera_info)


if __name__ == '__main__':
    # 테스트 코드
    reader = MetadataReader()
    
    # 테스트 파일 경로 (실제 파일이 있어야 함)
    test_file = r"C:\Users\mapdr\Desktop\test_image.png"
    
    if os.path.exists(test_file):
        metadata = reader.read_metadata(test_file)
        print("메타데이터:")
        for key, value in metadata.items():
            print(f"  {key}: {value}")
    else:
        print(f"테스트 파일이 없습니다: {test_file}")
