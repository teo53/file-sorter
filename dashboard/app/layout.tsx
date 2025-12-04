import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
    title: "파일 정리 시스템 대시보드",
    description: "AI 기반 자동 파일 정리 시스템 모니터링 및 관리",
};

export default function RootLayout({
    children,
}: Readonly<{
    children: React.ReactNode;
}>) {
    return (
        <html lang="ko">
            <body className="antialiased">
                {children}
            </body>
        </html>
    );
}
