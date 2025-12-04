import { useState } from 'react';
import { LogEntry } from '../page';
import { format } from 'date-fns';
import { ko } from 'date-fns/locale';
import { RotateCcw, FileIcon, FolderIcon, ArrowRight, Info, Move } from 'lucide-react';

interface LogTableProps {
    logs: LogEntry[];
    onRollback: (filePath: string) => void;
}

export default function LogTable({ logs, onRollback }: LogTableProps) {
    const [selectedFile, setSelectedFile] = useState<string | null>(null);
    const [showMoveDialog, setShowMoveDialog] = useState(false);

    if (logs.length === 0) {
        return (
            <div className="p-12 text-center text-gray-500 bg-white rounded-xl border border-gray-100 shadow-sm">
                <FileIcon className="w-16 h-16 mx-auto mb-4 text-gray-300" />
                <p className="text-lg font-medium text-gray-600">기록이 없습니다</p>
                <p className="text-sm mt-2 text-gray-400">파일 정리를 실행하면 여기에 기록이 표시됩니다</p>
            </div>
        );
    }

    const formatDate = (timestamp: string) => {
        try {
            return format(new Date(timestamp), 'yyyy-MM-dd HH:mm:ss', { locale: ko });
        } catch {
            return timestamp;
        }
    };

    const getCategoryColor = (category: string) => {
        const colors: Record<string, string> = {
            'images/screenshots': 'bg-blue-50 text-blue-700 border-blue-100',
            'images/products': 'bg-green-50 text-green-700 border-green-100',
            'images/ui': 'bg-purple-50 text-purple-700 border-purple-100',
            'images/photos': 'bg-pink-50 text-pink-700 border-pink-100',
            'documents': 'bg-yellow-50 text-yellow-700 border-yellow-100',
            'project_files': 'bg-indigo-50 text-indigo-700 border-indigo-100',
            'etc': 'bg-gray-50 text-gray-700 border-gray-100',
        };
        return colors[category] || 'bg-gray-50 text-gray-700 border-gray-100';
    };

    const getRuleDescription = (rule: string) => {
        const descriptions: Record<string, string> = {
            'filename_pattern': '파일명 패턴 매칭',
            'metadata_match': '메타데이터 분석',
            'extension_match': '확장자 분류',
            'ocr_match': 'OCR 텍스트 인식',
            'default': '기본 규칙',
        };
        return descriptions[rule] || rule;
    };

    const handleMoveClick = (filePath: string) => {
        // TODO: Implement move dialog
        alert("수동 이동 기능은 준비 중입니다: " + filePath);
    };

    return (
        <div className="overflow-hidden bg-white rounded-xl border border-gray-200 shadow-sm">
            <div className="overflow-x-auto">
                <table className="w-full">
                    <thead className="bg-gray-50 border-b border-gray-200">
                        <tr>
                            <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">시간</th>
                            <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">파일 정보</th>
                            <th className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">분류 결과</th>
                            <th className="px-6 py-4 text-right text-xs font-semibold text-gray-500 uppercase tracking-wider">작업</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-100">
                        {logs.map((log, index) => (
                            <tr key={index} className="hover:bg-gray-50 transition-colors duration-150">
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-400">
                                    {formatDate(log.timestamp)}
                                </td>
                                <td className="px-6 py-4">
                                    <div className="flex flex-col gap-1">
                                        <div className="flex items-center gap-2 text-sm font-medium text-gray-900">
                                            <FileIcon className="w-4 h-4 text-gray-400" />
                                            <span>{log.original_name}</span>
                                        </div>
                                        <div className="flex items-center gap-2 text-xs text-gray-500 ml-6">
                                            <ArrowRight className="w-3 h-3 text-gray-300" />
                                            <span className="text-gray-600">{log.new_name}</span>
                                        </div>
                                    </div>
                                </td>
                                <td className="px-6 py-4">
                                    <div className="flex flex-col gap-2 items-start">
                                        <span className={`px-2.5 py-1 inline-flex text-xs font-medium rounded-md border ${getCategoryColor(log.category)}`}>
                                            {log.category}
                                        </span>
                                        <div className="flex items-center gap-1.5 text-xs text-gray-500">
                                            <Info className="w-3 h-3" />
                                            <span>{getRuleDescription(log.rule)}</span>
                                        </div>
                                    </div>
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-right text-sm">
                                    <div className="flex items-center justify-end gap-2">
                                        {log.action === 'move' && (
                                            <>
                                                <button
                                                    onClick={() => handleMoveClick(log.new_path)}
                                                    className="p-2 text-gray-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                                                    title="다른 폴더로 이동"
                                                >
                                                    <Move className="w-4 h-4" />
                                                </button>
                                                <button
                                                    onClick={() => onRollback(log.new_path)}
                                                    className="flex items-center gap-1.5 px-3 py-1.5 text-red-600 bg-red-50 hover:bg-red-100 rounded-lg transition-colors font-medium text-xs"
                                                    title="원래 위치로 복원"
                                                >
                                                    <RotateCcw className="w-3.5 h-3.5" />
                                                    복원
                                                </button>
                                            </>
                                        )}
                                        {log.action === 'rollback' && (
                                            <span className="px-2 py-1 text-xs font-medium text-gray-400 bg-gray-100 rounded">
                                                롤백됨
                                            </span>
                                        )}
                                    </div>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
}
