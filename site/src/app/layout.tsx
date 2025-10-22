import { GlobalFooter } from "@/components/GlobalFooter";
import { GlobalHeader } from "@/components/GlobalHeader";
import type { Metadata } from "next";
import React from "react";
import "./globals.css";

export const metadata: Metadata = {
  title: "Buen Font Installer",
  description:
    "A macOS menu bar app for installing and organizing fonts with drag and drop simplicity",
  openGraph: {
    images: [
      {
        url: "/og.png",
        alt: "Buen Font Installer",
      },
    ],
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="font-sans">
        <GlobalHeader />
        {children}
        <GlobalFooter />
      </body>
    </html>
  );
}
