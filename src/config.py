"""
설정 파일 로더
config.json 파일을 읽고 기본값을 제공합니다.
"""

import json
import os
from pathlib import Path
from typing import Dict, Any


class Config:
    """설정 관리 클래스"""
    
    # 기본 설정값
    DEFAULT_CONFIG = {
        "safety": {
            "large_file_threshold_mb": 100,
            "max_files_warning": 500,
            "exclude_extensions": [".exe", ".dll", ".sys", ".msi"],
            "exclude_folders": ["Windows", "System32", "Program Files", "Program Files (x86)", "$Recycle.Bin"],
            "protect_hidden_files": True
        },
        "processing": {
            "enable_ocr": False,
            "show_progress": True,
            "preview_before_execute": True,
            "checkpoint_interval": 10,
            "max_filename_length": 200
        },
        "categories": {
            "custom_rules_enabled": False,
            "custom_rules": {}
        },
        "ui": {
            "use_emoji": True,
            "verbose_mode": False,
            "auto_open_log": False
        }
    }
    
    def __init__(self, config_path: str = None):
        """
        Args:
            config_path: config.json 파일 경로 (기본값: 프로젝트 루트)
        """
        if config_path is None:
            # 프로젝트 루트에서 config.json 찾기
            current_dir = Path(__file__).parent.parent
            config_path = current_dir / "config.json"
        
        self.config_path = Path(config_path)
        self.config = self._load_config()
    
    def _load_config(self) -> Dict[str, Any]:
        """설정 파일 로드"""
        if not self.config_path.exists():
            print(f"⚠️  설정 파일을 찾을 수 없습니다: {self.config_path}")
            print("📝 기본 설정을 사용합니다.")
            return self.DEFAULT_CONFIG.copy()
        
        try:
            with open(self.config_path, 'r', encoding='utf-8') as f:
                user_config = json.load(f)
            
            # 기본값과 병합
            config = self._merge_configs(self.DEFAULT_CONFIG.copy(), user_config)
            return config
        
        except json.JSONDecodeError as e:
            print(f"❌ 설정 파일 형식 오류: {e}")
            print("📝 기본 설정을 사용합니다.")
            return self.DEFAULT_CONFIG.copy()
        
        except Exception as e:
            print(f"❌ 설정 파일 로드 실패: {e}")
            print("📝 기본 설정을 사용합니다.")
            return self.DEFAULT_CONFIG.copy()
    
    def _merge_configs(self, default: Dict, user: Dict) -> Dict:
        """기본 설정과 사용자 설정 병합"""
        for key, value in user.items():
            if key in default:
                if isinstance(value, dict) and isinstance(default[key], dict):
                    default[key] = self._merge_configs(default[key], value)
                else:
                    default[key] = value
        return default
    
    def get(self, *keys):
        """설정값 가져오기
        
        Example:
            config.get('safety', 'large_file_threshold_mb')  # 100
        """
        value = self.config
        for key in keys:
            if isinstance(value, dict) and key in value:
                value = value[key]
            else:
                return None
        return value
    
    def save(self):
        """현재 설정을 파일로 저장"""
        try:
            with open(self.config_path, 'w', encoding='utf-8') as f:
                json.dump(self.config, f, indent=2, ensure_ascii=False)
            print(f"✅ 설정이 저장되었습니다: {self.config_path}")
        except Exception as e:
            print(f"❌ 설정 저장 실패: {e}")


# 전역 설정 인스턴스
_config_instance = None

def get_config() -> Config:
    """전역 설정 인스턴스 반환"""
    global _config_instance
    if _config_instance is None:
        _config_instance = Config()
    return _config_instance


if __name__ == '__main__':
    # 테스트
    config = Config()
    
    print("\n=== 설정 테스트 ===")
    print(f"대용량 파일 기준: {config.get('safety', 'large_file_threshold_mb')} MB")
    print(f"제외 확장자: {config.get('safety', 'exclude_extensions')}")
    print(f"진행 상황 표시: {config.get('processing', 'show_progress')}")
    print(f"이모지 사용: {config.get('ui', 'use_emoji')}")
