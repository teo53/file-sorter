import { Filter, Calendar, Search } from 'lucide-react';

interface FiltersProps {
    categoryFilter: string;
    setCategoryFilter: (value: string) => void;
    dateFilter: string;
    setDateFilter: (value: string) => void;
    keywordFilter: string;
    setKeywordFilter: (value: string) => void;
    categories: Record<string, number>;
}

export default function Filters({
    categoryFilter,
    setCategoryFilter,
    dateFilter,
    setDateFilter,
    keywordFilter,
    setKeywordFilter,
    categories,
}: FiltersProps) {
    return (
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
            <div className="flex items-center gap-2 mb-4">
                <Filter className="w-5 h-5 text-gray-600" />
                <h3 className="text-lg font-semibold text-gray-900">필터</h3>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                {/* 카테고리 필터 */}
                <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                        카테고리
                    </label>
                    <select
                        value={categoryFilter}
                        onChange={(e) => setCategoryFilter(e.target.value)}
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    >
                        <option value="all">전체</option>
                        {Object.keys(categories).map((category) => (
                            <option key={category} value={category}>
                                {category} ({categories[category]})
                            </option>
                        ))}
                    </select>
                </div>

                {/* 날짜 필터 */}
                <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                        <Calendar className="inline w-4 h-4 mr-1" />
                        날짜
                    </label>
                    <input
                        type="date"
                        value={dateFilter}
                        onChange={(e) => setDateFilter(e.target.value)}
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    />
                </div>

                {/* 키워드 검색 */}
                <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                        <Search className="inline w-4 h-4 mr-1" />
                        키워드 검색
                    </label>
                    <input
                        type="text"
                        value={keywordFilter}
                        onChange={(e) => setKeywordFilter(e.target.value)}
                        placeholder="파일명 또는 키워드 입력"
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    />
                </div>
            </div>

            {/* 필터 초기화 버튼 */}
            {(categoryFilter !== 'all' || dateFilter || keywordFilter) && (
                <div className="mt-4 flex justify-end">
                    <button
                        onClick={() => {
                            setCategoryFilter('all');
                            setDateFilter('');
                            setKeywordFilter('');
                        }}
                        className="px-4 py-2 text-sm text-gray-600 hover:text-gray-900 transition"
                    >
                        필터 초기화
                    </button>
                </div>
            )}
        </div>
    );
}
