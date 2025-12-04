"""
FastAPI 백엔드
대시보드와 통신하는 API 서버
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from typing import List, Optional
import sys
import os
import shutil
from pathlib import Path

# 상위 디렉토리의 src 모듈 import
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root / 'src'))

from logger import FileLogger
from rollback import FileRollback
from file_scanner import FileScanner
from categorizer import FileCategorizer
from metadata_reader import MetadataReader
from renamer import FileRenamer
from mover import FileMover
from config import get_config, Config
import json


app = FastAPI(title="파일 정리 시스템 API")

# CORS 설정 (로컬 대시보드에서 접근 가능)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://127.0.0.1:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 로거 및 롤백 인스턴스
logger = FileLogger()
rollback = FileRollback()


# Pydantic 모델
class RollbackRequest(BaseModel):
    file_path: str


class BatchRollbackRequest(BaseModel):
    category: Optional[str] = None
    start_date: Optional[str] = None
    end_date: Optional[str] = None
    count: Optional[int] = None

class ScanRequest(BaseModel):
    target_directory: str

class PreviewRequest(BaseModel):
    target_directory: str

class ExecuteRequest(BaseModel):
    target_directory: str
    dry_run: bool = False

class ConfigUpdate(BaseModel):
    config: dict


@app.get("/")
async def root():
    """헬스 체크"""
    return {"status": "ok", "message": "파일 정리 시스템 API"}


@app.get("/api/logs")
async def get_logs(
    category: Optional[str] = None,
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    action: Optional[str] = None
):
    """
    로그 조회
    
    Query Parameters:
        - category: 카테고리 필터
        - start_date: 시작 날짜 (YYYY-MM-DD)
        - end_date: 종료 날짜 (YYYY-MM-DD)
        - action: 작업 타입 ('move', 'rollback')
    """
    try:
        logs = logger.get_logs(
            category=category,
            start_date=start_date,
            end_date=end_date,
            action=action
        )
        return {"logs": logs, "count": len(logs)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/stats")
async def get_statistics():
    """통계 정보 조회"""
    try:
        stats = logger.get_statistics()
        return stats
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/rollback")
async def rollback_file(request: RollbackRequest):
    """
    단일 파일 롤백
    
    Body:
        - file_path: 롤백할 파일의 현재 경로
    """
    try:
        success = rollback.rollback_by_path(request.file_path)
        
        if success:
            return {"success": True, "message": "파일이 복원되었습니다."}
        else:
            raise HTTPException(status_code=404, detail="파일을 찾을 수 없거나 복원에 실패했습니다.")
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/rollback/batch")
async def rollback_batch(request: BatchRollbackRequest):
    """
    일괄 롤백
    
    Body:
        - category: 카테고리별 롤백
        - start_date, end_date: 날짜 범위별 롤백
        - count: 최근 N개 롤백
    """
    try:
        rollback_count = 0
        
        if request.category:
            rollback_count = rollback.rollback_by_category(request.category)
        
        elif request.start_date and request.end_date:
            rollback_count = rollback.rollback_by_date_range(
                request.start_date, request.end_date
            )
        
        elif request.count:
            rollback_count = rollback.rollback_latest(request.count)
        
        else:
            raise HTTPException(
                status_code=400,
                detail="category, (start_date, end_date), 또는 count 중 하나를 지정해야 합니다."
            )
        
        return {
            "success": True,
            "message": f"{rollback_count}개 파일이 복원되었습니다.",
            "count": rollback_count
        }
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/rollbackable")
async def get_rollbackable_files():
    """롤백 가능한 파일 목록"""
    try:
        files = rollback.list_rollbackable_files()
        return {"files": files, "count": len(files)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


from fastapi.staticfiles import StaticFiles
import shutil

# ... existing code ...

class MoveRequest(BaseModel):
    file_path: str
    new_category: str

@app.post("/api/move")
async def move_file_manually(request: MoveRequest):
    """
    파일을 수동으로 다른 카테고리로 이동
    """
    try:
        if not os.path.exists(request.file_path):
            raise HTTPException(status_code=404, detail="File not found")
            
        # Desktop 경로 계산
        desktop_path = os.path.join(os.environ['USERPROFILE'], 'Desktop')
        
        # 새 카테고리 디렉토리 (예: images/screenshots)
        target_dir = os.path.join(desktop_path, request.new_category)
        os.makedirs(target_dir, exist_ok=True)
        
        file_name = os.path.basename(request.file_path)
        new_path = os.path.join(target_dir, file_name)
        
        # 중복 처리
        if os.path.exists(new_path):
            base, ext = os.path.splitext(file_name)
            counter = 1
            while os.path.exists(new_path):
                new_path = os.path.join(target_dir, f"{base}_{counter}{ext}")
                counter += 1
        
        # 이동
        shutil.move(request.file_path, new_path)
        
        # 로그 업데이트 (선택사항: 여기서는 생략하고 성공 응답만)
        
        return {
            "status": "success", 
            "original_path": request.file_path,
            "new_path": new_path
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# 새로운 API 엔드포인트

@app.post("/api/scan")
async def scan_directory(request: ScanRequest):
    """폴더 스캔"""
    try:
        scanner = FileScanner(scan_directory=request.target_directory)
        file_paths = scanner.scan_files(recursive=False)
        
        return {
            "status": "success",
            "file_count": len(file_paths),
            "files": [
                {
                    "path": fp,
                    "name": os.path.basename(fp),
                    "size": os.path.getsize(fp) if os.path.exists(fp) else 0
                }
                for fp in file_paths[:100]  # 최대 100개만
            ]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/preview")
async def preview_organization(request: PreviewRequest):
    """파일 정리 미리보기"""
    try:
        scanner = FileScanner(scan_directory=request.target_directory)
        categorizer = FileCategorizer()
        metadata_reader = MetadataReader()
        renamer = FileRenamer()
        
        file_paths = scanner.scan_files(recursive=False)
        preview_data = []
        
        for fp in file_paths[:50]:  # 최대 50개만 미리보기
            try:
                metadata = metadata_reader.read_metadata(fp)
                category, rule, keywords = categorizer.categorize(fp, metadata)
                
                new_name = renamer.generate_new_name(
                    category=category,
                    keywords=keywords,
                    date=metadata.get('creation_date', ''),
                    original_name=os.path.basename(fp)
                )
                
                preview_data.append({
                    "original_name": os.path.basename(fp),
                    "new_name": new_name,
                    "category": category,
                    "rule": rule,
                    "size": os.path.getsize(fp)
                })
            except Exception:
                continue
        
        return {
            "status": "success",
            "total_files": len(file_paths),
            "preview": preview_data
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/execute")
async def execute_organization(request: ExecuteRequest):
    """파일 정리 실행"""
    try:
        from main import AutoFileSorter
        
        sorter = AutoFileSorter(
            enable_ocr=False,
            dry_run=request.dry_run,
            auto_mode=True,
            target_directory=request.target_directory
        )
        
        # 백그라운드에서 실행하지 않고 즉시 실행
        sorter.run()
        
        return {
            "status": "success",
            "message": "파일 정리가 완료되었습니다."
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/config")
async def get_config_data():
    """설정 조회"""
    try:
        config = get_config()
        return {
            "status": "success",
            "config": config.config
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.put("/api/config")
async def update_config_data(request: ConfigUpdate):
    """설정 업데이트"""
    try:
        config = get_config()
        config.config = request.config
        config.save()
        
        return {
            "status": "success",
            "message": "설정이 저장되었습니다."
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 정적 파일 서빙 (배포용)
# static 디렉토리가 있을 때만 마운트
static_dir = Path(__file__).parent / "static"
if static_dir.exists():
    app.mount("/", StaticFiles(directory=str(static_dir), html=True), name="static")

if __name__ == "__main__":
    import uvicorn
    
    print("\n" + "="*60)
    print("🚀 FastAPI 서버 시작")
    print("="*60)
    print("주소: http://localhost:8000")
    print("API 문서: http://localhost:8000/docs")
    print("="*60 + "\n")
    
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")
