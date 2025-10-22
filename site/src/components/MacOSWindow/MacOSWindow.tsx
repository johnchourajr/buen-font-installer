"use client";

type MacOSWindowProps = {
  className?: string;
};

export function MacOSWindow({ className = "" }: MacOSWindowProps) {
  return (
    <div className={`relative ${className}`}>
      {/* macOS Window Container - Exact colors and dimensions from screenshot */}
      <div className="relative bg-[#2c2c2cd9] backdrop-blur-lg rounded-[12px] shadow-[0_25px_50px_-12px_rgba(0,0,0,0.8)] border border-gray-600/20 overflow-hidden">
        {/* Inner dashed border - exactly 2px thick, light gray, positioned 2px from edge */}
        <div className="absolute inset-[10px] top-[40px] border-[1.5px] border-dashed border-gray-400/40 rounded-[10px] pointer-events-none" />

        {/* Title Bar - Exact height (28px) and styling */}
        <div className="relative flex items-center justify-between px-[16px] h-[40px]">
          {/* Traffic Light Buttons - Exact macOS colors and sizes */}
          <div className="flex items-center space-x-[8px]">
            {/* Close Button - Exact red color #FF5F57 */}
            <div className="w-[12px] h-[12px] rounded-full bg-[#FF5F57] shadow-[inset_0_1px_0_rgba(255,255,255,0.1)] flex items-center justify-center">
              <div className="w-[6px] h-[6px] rounded-full bg-[#FF5F57] opacity-0" />
            </div>
            {/* Minimize Button - Exact yellow color #FFBD2E */}
            <div className="w-[12px] h-[12px] rounded-full bg-[#FFBD2E] shadow-[inset_0_1px_0_rgba(255,255,255,0.1)] flex items-center justify-center">
              <div className="w-[6px] h-[6px] rounded-full bg-[#FFBD2E] opacity-0" />
            </div>
            {/* Maximize Button - Exact green color #28CA42 */}
            <div className="w-[12px] h-[12px] rounded-full bg-[#28CA42] shadow-[inset_0_1px_0_rgba(255,255,255,0.1)] flex items-center justify-center">
              <div className="w-[6px] h-[6px] rounded-full bg-[#28CA42] opacity-0" />
            </div>
          </div>

          {/* Window Title - Exact positioning and typography */}
          <div className="absolute left-1/2 transform -translate-x-1/2">
            <h2 className="text-white/50 text-[10px] font-mono tracking-[0.05em] uppercase">
              BUEN FONT INSTALLER
            </h2>
          </div>
        </div>

        {/* Main Content Area - Exact background color and padding */}
        <div className="relative px-[32px] py-[32px] min-h-[320px] flex flex-col items-center justify-center">
          {/* Drag and Drop Area - Exact spacing and layout */}
          <div className="flex flex-col items-center space-y-[24px]">
            {/* Document Icon - Exact size and styling */}
            <div className="relative">
              <svg
                width="48"
                height="48"
                viewBox="0 0 24 24"
                fill="none"
                className="text-white"
              >
                {/* Document shape with exact stroke */}
                <path
                  d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8l-6-6z"
                  stroke="currentColor"
                  strokeWidth="1.5"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
                {/* Down arrow - exact positioning */}
                <path d="M12 15l-3-3h6l-3 3z" fill="currentColor" />
              </svg>
            </div>

            {/* Instruction Text - Exact typography */}
            <p className="text-white text-[13px] font-normal tracking-[0.2px] text-center">
              Drop fonts or folder anywhere
            </p>

            {/* Auto Install Checkbox - Exact macOS checkbox styling */}
            <div className="flex items-center space-x-[12px]">
              <div className="relative w-[18px] h-[18px] rounded-[3px] border-[1px] border-[#007AFF] bg-[#007AFF] flex items-center justify-center">
                <svg
                  width="10"
                  height="10"
                  viewBox="0 0 24 24"
                  fill="none"
                  className="text-white"
                >
                  <path
                    d="M20 6L9 17l-5-5"
                    stroke="currentColor"
                    strokeWidth="2.5"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                </svg>
              </div>
              <span className="text-white text-[13px] font-normal tracking-[0.2px]">
                Auto install
              </span>
            </div>
          </div>

          {/* Settings Icon - Bottom Left - Exact positioning */}
          <div className="absolute bottom-[16px] left-[16px]">
            <div className="p-[8px] text-white">
              <svg
                width="16"
                height="16"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="1.5"
                strokeLinecap="round"
                strokeLinejoin="round"
              >
                <circle cx="12" cy="12" r="3" />
                <path d="M12 1v6m0 6v6m11-7h-6m-6 0H1m15.5-6.5l-4.24 4.24M6.74 17.74l-4.24 4.24m0-15.5l4.24 4.24m10.26 10.26l4.24 4.24" />
              </svg>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
