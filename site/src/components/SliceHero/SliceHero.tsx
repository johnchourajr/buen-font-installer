"use client";

import { useRef, useState } from "react";
import { useTextScramble } from "../../hooks/useTextScramble";
import { MacOSWindow } from "../MacOSWindow";

export function SliceHero() {
  const containerRef = useRef<HTMLDivElement>(null);

  const headlineTexts = ["Install", "Fonts", "In Bulk"];

  const [scrambleConfig, setScrambleConfig] = useState({
    scrambleDuration: 1500, // How long to scramble each line
    resolveDuration: 800, // How long to resolve each line
    pauseDuration: 0, // How long to pause between lines
    cycleDelay: 0, // How long to pause before starting next cycle
    scrambleChars: "!@#$%^&*()_+-=[]{}|;:,.<>?~`",
    scrambleSpeed: 40, // Speed of scrambling (ms between changes)
  });

  // First word - starts immediately
  const firstWord = useTextScramble({
    text: "Install",
    config: scrambleConfig,
    autoStart: true,
    delay: 0,
  });

  // Second word - starts after first completes (wait + scramble + resolve + pause)
  const secondWord = useTextScramble({
    text: "Fonts",
    config: scrambleConfig,
    autoStart: true,
    delay: scrambleConfig.scrambleDuration - 1000, // ~1.3 seconds
  });

  // Third word - starts after second completes
  const thirdWord = useTextScramble({
    text: "In Bulk",
    config: scrambleConfig,
    autoStart: true,
    delay: (scrambleConfig.scrambleDuration - 1000) * 2, // ~2.6 seconds
  });

  return (
    <section
      ref={containerRef}
      className="col-span-full relative flex flex-col items-center justify-end min-h-[50vh] mt-40"
    >
      <h1 className="w-full h-full headline-display-xxl leading-none uppercase flex flex-col gap-0 justify-between">
        <span className="self-end h-[0.9em]">
          <span
            className={`inline-block ${
              firstWord.isScrambling
                ? "opacity-80"
                : firstWord.isResolving
                ? "opacity-90"
                : "opacity-100"
            } transition-opacity duration-200`}
          >
            {firstWord.displayText}
          </span>
        </span>
        <span className="self-start h-[0.9em]">
          <span
            className={`inline-block ${
              secondWord.isScrambling
                ? "opacity-80"
                : secondWord.isResolving
                ? "opacity-90"
                : "opacity-100"
            } transition-opacity duration-200`}
          >
            {secondWord.displayText}
          </span>
        </span>
        <span className="self-end h-[0.9em]">
          <span
            className={`inline-block ${
              thirdWord.isScrambling
                ? "opacity-80"
                : thirdWord.isResolving
                ? "opacity-90"
                : "opacity-100"
            } transition-opacity duration-200`}
          >
            {thirdWord.displayText}
          </span>
        </span>
      </h1>

      {/* macOS Window - Absolutely positioned in center */}
      <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 z-10">
        <MacOSWindow className="w-[400px] h-[350px] sm:w-[450px] sm:h-[380px] md:w-[500px] md:h-[420px]" />
      </div>
    </section>
  );
}
