import { Statistics } from '../page';
import { FileText, RotateCcw, TrendingUp, Clock } from 'lucide-react';
import { format } from 'date-fns';
import { ko } from 'date-fns/locale';

interface StatsCardsProps {
    stats: Statistics;
}

export default function StatsCards({ stats }: StatsCardsProps) {
    const formatDate = (timestamp: string | null) => {
        if (!timestamp) return '-';
        try {
            return format(new Date(timestamp), 'yyyy년 MM월 dd일 HH:mm', { locale: ko });
        } catch {
            return timestamp;
        }
    };

    const totalFiles = stats.total_moves + stats.total_rollbacks;

    return (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {/* 총 정리 파일 수 */}
            <div className="bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl shadow-lg p-6 text-white">
                <div className="flex items-center justify-between mb-4">
                    <FileText className="w-10 h-10 opacity-80" />
                    <div className="text-right">
                        <p className="text-sm opacity-80">총 정리 파일</p>
                        <p className="text-4xl font-bold">{stats.total_moves}</p>
                    </div>
                </div>
                <div className="flex items-center gap-2 text-sm opacity-80">
                    <TrendingUp className="w-4 h-4" />
                    <span>현재까지 정리됨</span>
                </div>
            </div>

            {/* 롤백 파일 수 */}
            <div className="bg-gradient-to-br from-purple-500 to-purple-600 rounded-xl shadow-lg p-6 text-white">
                <div className="flex items-center justify-between mb-4">
                    <RotateCcw className="w-10 h-10 opacity-80" />
                    <div className="text-right">
                        <p className="text-sm opacity-80">롤백 파일</p>
                        <p className="text-4xl font-bold">{stats.total_rollbacks}</p>
                    </div>
                </div>
                <div className="flex items-center gap-2 text-sm opacity-80">
                    <span>원위치 복원됨</span>
                </div>
            </div>

            {/* 카테고리 수 */}
            <div className="bg-gradient-to-br from-green-500 to-green-600 rounded-xl shadow-lg p-6 text-white">
                <div className="flex items-center justify-between mb-4">
                    <div className="w-10 h-10 flex items-center justify-center bg-white/20 rounded-lg">
                        <span className="text-2xl">📁</span>
                    </div>
                    <div className="text-right">
                        <p className="text-sm opacity-80">카테고리</p>
                        <p className="text-4xl font-bold">{Object.keys(stats.by_category).length}</p>
                    </div>
                </div>
                <div className="flex items-center gap-2 text-sm opacity-80">
                    <span>분류 카테고리 수</span>
                </div>
            </div>

            {/* 마지막 업데이트 */}
            <div className="bg-gradient-to-br from-orange-500 to-orange-600 rounded-xl shadow-lg p-6 text-white">
                <div className="flex items-center justify-between mb-4">
                    <Clock className="w-10 h-10 opacity-80" />
                    <div className="text-right">
                        <p className="text-sm opacity-80">마지막 업데이트</p>
                        <p className="text-lg font-semibold">
                            {stats.last_updated ? format(new Date(stats.last_updated), 'HH:mm', { locale: ko }) : '-'}
                        </p>
                    </div>
                </div>
                <div className="text-sm opacity-80">
                    {formatDate(stats.last_updated)}
                </div>
            </div>

            {/* 카테고리별 상세 통계 */}
            {Object.keys(stats.by_category).length > 0 && (
                <div className="col-span-full bg-white rounded-xl shadow-sm border border-gray-200 p-6">
                    <h3 className="text-lg font-semibold text-gray-900 mb-4">카테고리별 분류 현황</h3>
                    <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-7 gap-4">
                        {Object.entries(stats.by_category).map(([category, count]) => (
                            <div key={category} className="text-center p-3 bg-gray-50 rounded-lg">
                                <p className="text-2xl font-bold text-primary-600">{count}</p>
                                <p className="text-xs text-gray-600 mt-1">{category.split('/').pop()}</p>
                            </div>
                        ))}
                    </div>
                </div>
            )}
        </div>
    );
}
