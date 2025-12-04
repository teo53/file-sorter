'use client';

import { useState } from 'react';
import axios from 'axios';
import { FolderOpen, Play, ArrowRight, Check, Home, Download, FileText, Folder } from 'lucide-react';
import Link from 'next/link';

const API_BASE_URL = 'http://localhost:8000';

interface PreviewItem {
    original_name: string;
    new_name: string;
    category: string;
    rule: string;
    size: number;
}

// 자주 사용하는 폴더 목록
const QUICK_FOLDERS = [
    {
        id: 'desktop',
        label: '바탕화면',
        path: `C:\\Users\\${process.env.USERNAME || 'mapdr'}\\Desktop`,
        icon: Home,
        color: 'blue'
    },
    {
        id: 'downloads',
        label: '다운로드',
        path: `C:\\Users\\${process.env.USERNAME || 'mapdr'}\\Downloads`,
        icon: Download,
        color: 'green'
    },
    {
        id: 'documents',
        label: '문서',
        path: `C:\\Users\\${process.env.USERNAME || 'mapdr'}\\Documents`,
        icon: FileText,
        color: 'yellow'
    },
    {
        id: 'custom',
        label: '직접 입력',
        path: '',
        icon: Folder,
        color: 'gray'
    }
];

export default function OrganizePage() {
    const [selectedFolder, setSelectedFolder] = useState('');
    const [customPath, setCustomPath] = useState('');
    const [preview, setPreview] = useState<PreviewItem[]>([]);
    const [loading, setLoading] = useState(false);
    const [executing, setExecuting] = useState(false);
    const [step, setStep] = useState<'input' | 'preview' | 'done'>('input');

    const handleQuickSelect = (folder: typeof QUICK_FOLDERS[0]) => {
        if (folder.id === 'custom') {
            setSelectedFolder('custom');
        } else {
            setSelectedFolder(folder.id);
            setCustomPath(folder.path);
        }
    };

    const handleScan = async () => {
        const targetPath = selectedFolder === 'custom' ? customPath :
            QUICK_FOLDERS.find(f => f.id === selectedFolder)?.path || customPath;

        if (!targetPath) {
            alert('폴더를 선택하거나 경로를 입력해주세요');
            return;
        }

        setLoading(true);
        try {
            const response = await axios.post(`${API_BASE_URL}/api/preview`, {
                target_directory: targetPath
            });

            setPreview(response.data.preview || []);
            setStep('preview');
        } catch (error) {
            console.error('미리보기 실패:', error);
            alert('폴더를 찾을 수 없거나 접근할 수 없습니다');
        } finally {
            setLoading(false);
        }
    };

    const handleExecute = async () => {
        if (!confirm(`${preview.length}개의 파일을 정리하시겠습니까?`)) {
            return;
        }

        const targetPath = selectedFolder === 'custom' ? customPath :
            QUICK_FOLDERS.find(f => f.id === selectedFolder)?.path || customPath;

        setExecuting(true);
        try {
            await axios.post(`${API_BASE_URL}/api/execute`, {
                target_directory: targetPath,
                dry_run: false
            });

            setStep('done');
        } catch (error) {
            console.error('실행 실패:', error);
            alert('파일 정리 중 오류가 발생했습니다');
        } finally {
            setExecuting(false);
        }
    };

    return (
        <div className="min-h-screen bg-gray-50">
            <header className="bg-white border-b border-gray-200">
                <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
                    <div className="flex items-center justify-between">
                        <div>
                            <h1 className="text-2xl font-bold text-gray-900">파일 정리</h1>
                            <p className="mt-1 text-sm text-gray-500">
                                AI 기반 자동 파일 분류 및 정리
                            </p>
                        </div>
                        <Link
                            href="/"
                            className="text-sm text-gray-600 hover:text-gray-900 transition"
                        >
                            ← 대시보드
                        </Link>
                    </div>
                </div>
            </header>

            <main className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
                {/* Steps Indicator */}
                <div className="mb-12">
                    <div className="flex items-center justify-center space-x-4">
                        {['폴더 선택', '미리보기', '완료'].map((label, idx) => {
                            const stepIndex = ['input', 'preview', 'done'].indexOf(step);
                            const isActive = idx === stepIndex;
                            const isComplete = idx < stepIndex;

                            return (
                                <div key={label} className="flex items-center">
                                    {idx > 0 && (
                                        <div className={`w-16 h-0.5 ${isComplete ? 'bg-blue-600' : 'bg-gray-300'}`} />
                                    )}
                                    <div className="flex flex-col items-center">
                                        <div
                                            className={`w-10 h-10 rounded-full flex items-center justify-center text-sm font-semibold transition ${isComplete
                                                    ? 'bg-blue-600 text-white'
                                                    : isActive
                                                        ? 'bg-blue-100 text-blue-600 ring-4 ring-blue-50'
                                                        : 'bg-gray-100 text-gray-400'
                                                }`}
                                        >
                                            {isComplete ? <Check className="w-5 h-5" /> : idx + 1}
                                        </div>
                                        <span className={`mt-2 text-xs font-medium ${isActive ? 'text-gray-900' : 'text-gray-500'}`}>
                                            {label}
                                        </span>
                                    </div>
                                </div>
                            );
                        })}
                    </div>
                </div>

                {/* Step 1: Input */}
                {step === 'input' && (
                    <div className="bg-white rounded-2xl shadow-sm border border-gray-200 p-8">
                        <div className="max-w-3xl mx-auto">
                            <div className="text-center mb-8">
                                <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-blue-50 mb-4">
                                    <FolderOpen className="w-8 h-8 text-blue-600" />
                                </div>
                                <h2 className="text-xl font-bold text-gray-900 mb-2">
                                    정리할 폴더를 선택하세요
                                </h2>
                                <p className="text-sm text-gray-500">
                                    자주 사용하는 폴더를 선택하거나 직접 입력할 수 있습니다
                                </p>
                            </div>

                            {/* Quick Folder Selection */}
                            <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
                                {QUICK_FOLDERS.map((folder) => {
                                    const Icon = folder.icon;
                                    const isSelected = selectedFolder === folder.id;

                                    return (
                                        <button
                                            key={folder.id}
                                            onClick={() => handleQuickSelect(folder)}
                                            className={`p-4 rounded-xl border-2 transition-all ${isSelected
                                                    ? 'border-blue-600 bg-blue-50 shadow-md'
                                                    : 'border-gray-200 hover:border-gray-300 hover:shadow-sm'
                                                }`}
                                        >
                                            <div className={`w-10 h-10 rounded-lg mx-auto mb-2 flex items-center justify-center ${isSelected ? 'bg-blue-600' : 'bg-gray-100'
                                                }`}>
                                                <Icon className={`w-5 h-5 ${isSelected ? 'text-white' : 'text-gray-600'}`} />
                                            </div>
                                            <p className={`text-sm font-medium ${isSelected ? 'text-blue-900' : 'text-gray-700'
                                                }`}>
                                                {folder.label}
                                            </p>
                                        </button>
                                    );
                                })}
                            </div>

                            {/* Custom Path Input */}
                            {selectedFolder === 'custom' && (
                                <div className="mb-4">
                                    <label className="block text-sm font-medium text-gray-700 mb-2">
                                        폴더 경로
                                    </label>
                                    <input
                                        type="text"
                                        value={customPath}
                                        onChange={(e) => setCustomPath(e.target.value)}
                                        placeholder="예: C:\Users\mapdr\Desktop"
                                        className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-600 focus:border-transparent transition"
                                    />
                                </div>
                            )}

                            {/* Selected Path Display */}
                            {selectedFolder && selectedFolder !== 'custom' && (
                                <div className="mb-4 p-3 bg-gray-50 rounded-lg">
                                    <p className="text-xs text-gray-500 mb-1">선택된 경로</p>
                                    <p className="text-sm font-mono text-gray-700">
                                        {QUICK_FOLDERS.find(f => f.id === selectedFolder)?.path}
                                    </p>
                                </div>
                            )}

                            <button
                                onClick={handleScan}
                                disabled={loading || !selectedFolder}
                                className="w-full mt-4 px-6 py-3 bg-blue-600 text-white font-semibold rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition flex items-center justify-center space-x-2"
                            >
                                {loading ? (
                                    <>
                                        <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white" />
                                        <span>분석 중...</span>
                                    </>
                                ) : (
                                    <>
                                        <span>미리보기</span>
                                        <ArrowRight className="w-5 h-5" />
                                    </>
                                )}
                            </button>
                        </div>
                    </div>
                )}

                {/* Step 2: Preview */}
                {step === 'preview' && (
                    <div className="space-y-6">
                        <div className="bg-white rounded-2xl shadow-sm border border-gray-200 p-6">
                            <div className="flex items-center justify-between mb-6">
                                <div>
                                    <h2 className="text-lg font-bold text-gray-900">미리보기</h2>
                                    <p className="text-sm text-gray-500 mt-1">
                                        총 {preview.length}개 파일이 정리됩니다
                                    </p>
                                </div>
                                <button
                                    onClick={() => setStep('input')}
                                    className="text-sm text-gray-600 hover:text-gray-900 transition"
                                >
                                    ← 폴더 변경
                                </button>
                            </div>

                            <div className="overflow-hidden border border-gray-200 rounded-lg">
                                <table className="min-w-full divide-y divide-gray-200">
                                    <thead className="bg-gray-50">
                                        <tr>
                                            <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                                                현재 파일명
                                            </th>
                                            <th className="px-4 py-3 text-center text-xs font-medium text-gray-500">

                                            </th>
                                            <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                                                새 파일명
                                            </th>
                                            <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                                                카테고리
                                            </th>
                                        </tr>
                                    </thead>
                                    <tbody className="bg-white divide-y divide-gray-200">
                                        {preview.map((item, idx) => (
                                            <tr key={idx} className="hover:bg-gray-50 transition">
                                                <td className="px-4 py-3 text-sm text-gray-900">
                                                    {item.original_name}
                                                </td>
                                                <td className="px-4 py-3 text-center">
                                                    <ArrowRight className="w-4 h-4 text-gray-400 mx-auto" />
                                                </td>
                                                <td className="px-4 py-3 text-sm font-medium text-gray-900">
                                                    {item.new_name}
                                                </td>
                                                <td className="px-4 py-3">
                                                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-50 text-blue-700">
                                                        {item.category}
                                                    </span>
                                                </td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <button
                            onClick={handleExecute}
                            disabled={executing}
                            className="w-full px-6 py-4 bg-blue-600 text-white font-semibold rounded-xl hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition flex items-center justify-center space-x-2 text-lg"
                        >
                            {executing ? (
                                <>
                                    <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-white" />
                                    <span>정리 중...</span>
                                </>
                            ) : (
                                <>
                                    <Play className="w-6 h-6" />
                                    <span>파일 정리 시작</span>
                                </>
                            )}
                        </button>
                    </div>
                )}

                {/* Step 3: Done */}
                {step === 'done' && (
                    <div className="bg-white rounded-2xl shadow-sm border border-gray-200 p-12">
                        <div className="text-center">
                            <div className="inline-flex items-center justify-center w-20 h-20 rounded-full bg-green-50 mb-6">
                                <Check className="w-10 h-10 text-green-600" />
                            </div>
                            <h2 className="text-2xl font-bold text-gray-900 mb-2">
                                파일 정리 완료!
                            </h2>
                            <p className="text-gray-500 mb-8">
                                {preview.length}개의 파일이 성공적으로 정리되었습니다
                            </p>

                            <div className="flex items-center justify-center space-x-4">
                                <Link
                                    href="/"
                                    className="px-6 py-3 bg-blue-600 text-white font-semibold rounded-lg hover:bg-blue-700 transition"
                                >
                                    대시보드로 이동
                                </Link>
                                <button
                                    onClick={() => {
                                        setStep('input');
                                        setSelectedFolder('');
                                        setCustomPath('');
                                        setPreview([]);
                                    }}
                                    className="px-6 py-3 border border-gray-300 text-gray-700 font-semibold rounded-lg hover:bg-gray-50 transition"
                                >
                                    다시 정리하기
                                </button>
                            </div>
                        </div>
                    </div>
                )}
            </main>
        </div>
    );
}
