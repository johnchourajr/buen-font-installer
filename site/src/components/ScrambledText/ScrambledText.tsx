"use client";

import { useTextScramble } from "../hooks/useTextScramble";

type ScrambledTextProps = {
  texts: string[];
  className?: string;
  config?: {
    scrambleDuration?: number;
    resolveDuration?: number;
    pauseDuration?: number;
    cycleDelay?: number;
    scrambleChars?: string;
    scrambleSpeed?: number;
  };
  autoStart?: boolean;
};

export function ScrambledText({
  texts,
  className = "",
  config = {},
  autoStart = true,
}: ScrambledTextProps) {
  const { displayText, isScrambling, isResolving, isPaused } = useTextScramble({
    texts,
    config,
    autoStart,
  });

  return (
    <span
      className={`${className} ${
        isScrambling
          ? "opacity-80"
          : isResolving
          ? "opacity-90"
          : isPaused
          ? "opacity-100"
          : "opacity-100"
      } transition-opacity duration-200`}
    >
      {displayText}
    </span>
  );
}
