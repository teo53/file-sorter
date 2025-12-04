'use client';

import { useState, useEffect } from 'react';
import axios from 'axios';
import { FileText, RotateCcw, Filter, TrendingUp } from 'lucide-react';
import LogTable from './components/LogTable';
import Filters from './components/Filters';
import StatsCards from './components/StatsCards';

const API_BASE_URL = 'http://localhost:8000';

export interface LogEntry {
    timestamp: string;
    original_name: string;
    new_name: string;
    old_path: string;
    new_path: string;
    category: string;
    rule: string;
    keywords: string[];
    action: string;
}

export interface Statistics {
    total_moves: number;
    total_rollbacks: number;
    by_category: Record<string, number>;
    by_rule: Record<string, number>;
    last_updated: string | null;
}

export default function Dashboard() {
    const [logs, setLogs] = useState<LogEntry[]>([]);
    const [filteredLogs, setFilteredLogs] = useState<LogEntry[]>([]);
    const [stats, setStats] = useState<Statistics | null>(null);
    const [loading, setLoading] = useState(true);

    // 필터 상태
    const [categoryFilter, setCategoryFilter] = useState<string>('all');
    const [dateFilter, setDateFilter] = useState<string>('');
    const [keywordFilter, setKeywordFilter] = useState<string>('');

    // 로그 및 통계 로드
    useEffect(() => {
        loadData();
    }, []);

    // 필터 적용
    useEffect(() => {
        applyFilters();
    }, [logs, categoryFilter, dateFilter, keywordFilter]);

    const loadData = async () => {
        try {
            setLoading(true);

            // 로그 로드
            const logsResponse = await axios.get(`${API_BASE_URL}/api/logs`);
            setLogs(logsResponse.data.logs || []);

            // 통계 로드
            const statsResponse = await axios.get(`${API_BASE_URL}/api/stats`);
            setStats(statsResponse.data);

        } catch (error) {
            console.error('데이터 로드 실패:', error);
            alert('API 서버에 연결할 수 없습니다. FastAPI 서버가 실행 중인지 확인해주세요.');
        } finally {
            setLoading(false);
        }
    };

    const applyFilters = () => {
        let filtered = [...logs];

        // 카테고리 필터
        if (categoryFilter !== 'all') {
            filtered = filtered.filter(log => log.category === categoryFilter);
        }

        // 날짜 필터
        if (dateFilter) {
            filtered = filtered.filter(log => log.timestamp.startsWith(dateFilter));
        }

        // 키워드 필터
        if (keywordFilter) {
            const keyword = keywordFilter.toLowerCase();
            filtered = filtered.filter(log =>
                log.original_name.toLowerCase().includes(keyword) ||
                log.new_name.toLowerCase().includes(keyword) ||
                log.keywords.some(kw => kw.toLowerCase().includes(keyword))
            );
        }

        setFilteredLogs(filtered);
    };

    const handleRollback = async (filePath: string) => {
        if (!confirm('이 파일을 원래 위치로 복원하시겠습니까?')) {
            return;
        }

        try {
            await axios.post(`${API_BASE_URL}/api/rollback`, {
                file_path: filePath
            });

            alert('파일이 성공적으로 복원되었습니다.');
            loadData(); // 데이터 다시 로드

        } catch (error) {
            console.error('롤백 실패:', error);
            alert('파일 복원에 실패했습니다.');
        }
    };

    if (loading) {
        return (
            <div className="min-h-screen bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50 flex items-center justify-center">
                <div className="text-center">
                    <div className="animate-spin rounded-full h-16 w-16 border-b-2 border-primary-600 mx-auto mb-4"></div>
                    <p className="text-gray-600">데이터 로딩 중...</p>
                </div>
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50">
            {/* 헤더 */}
            <header className="bg-white shadow-sm border-b border-gray-200">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
                    <div className="flex items-center justify-between">
                        <div className="flex items-center gap-3">
                            <FileText className="w-8 h-8 text-primary-600" />
                            <div>
                                <h1 className="text-3xl font-bold text-gray-900">
                                    파일 정리 시스템 대시보드
                                </h1>
                                <p className="text-sm text-gray-500 mt-1">
                                    AI 기반 자동 파일 분류 및 관리
                                </p>
                            </div>
                        </div>

                        <button
                            onClick={loadData}
                            className="flex items-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition"
                        >
                            <RotateCcw className="w-4 h-4" />
                            새로고침
                        </button>
                    </div>
                </div>
            </header>

            <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                {/* 통계 카드 */}
                {stats && <StatsCards stats={stats} />}

                {/* 필터 */}
                <div className="mt-8">
                    <Filters
                        categoryFilter={categoryFilter}
                        setCategoryFilter={setCategoryFilter}
                        dateFilter={dateFilter}
                        setDateFilter={setDateFilter}
                        keywordFilter={keywordFilter}
                        setKeywordFilter={setKeywordFilter}
                        categories={stats?.by_category || {}}
                    />
                </div>

                {/* 로그 테이블 */}
                <div className="mt-8">
                    <div className="bg-white rounded-xl shadow-sm border border-gray-200">
                        <div className="px-6 py-4 border-b border-gray-200">
                            <h2 className="text-xl font-semibold text-gray-900">
                                파일 이동 기록
                            </h2>
                            <p className="text-sm text-gray-500 mt-1">
                                총 {filteredLogs.length}개의 기록
                            </p>
                        </div>

                        <LogTable
                            logs={filteredLogs}
                            onRollback={handleRollback}
                        />
                    </div>
                </div>
            </main>
        </div>
    );
}
