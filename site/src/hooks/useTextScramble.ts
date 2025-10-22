"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";

type ScrambleConfig = {
  scrambleDuration?: number;
  resolveDuration?: number;
  scrambleChars?: string;
  scrambleSpeed?: number;
};

type UseTextScrambleProps = {
  text: string;
  config?: ScrambleConfig;
  autoStart?: boolean;
  delay?: number; // Delay before starting the animation
};

const DEFAULT_CONFIG: Required<ScrambleConfig> = {
  scrambleDuration: 1500,
  resolveDuration: 800,
  scrambleChars: "!@#$%^&*()_+-=[]{}|;:,.<>?~`",
  scrambleSpeed: 40,
};

export function useTextScramble({
  text,
  config = {},
  autoStart = true,
  delay = 0,
}: UseTextScrambleProps) {
  const [displayText, setDisplayText] = useState(text);
  const [isScrambling, setIsScrambling] = useState(false);
  const [isResolving, setIsResolving] = useState(false);
  const [isPaused, setIsPaused] = useState(false);
  const [isActive, setIsActive] = useState(autoStart);

  const finalConfig = useMemo(
    () => ({ ...DEFAULT_CONFIG, ...config }),
    [config]
  );
  const animationRef = useRef<{
    timeoutId?: NodeJS.Timeout;
    intervalId?: NodeJS.Timeout;
    phase: string;
    progress: number;
  }>({
    phase: "wait",
    progress: 0,
  });

  const scrambleText = useCallback(
    (text: string, progress: number) => {
      const chars = text.split("");
      const scrambleChars = finalConfig.scrambleChars.split("");

      return chars
        .map((char) => {
          if (char === " ") return " ";
          return Math.random() < progress
            ? scrambleChars[Math.floor(Math.random() * scrambleChars.length)]
            : char;
        })
        .join("");
    },
    [finalConfig.scrambleChars]
  );

  const resolveText = useCallback((text: string, progress: number) => {
    const chars = text.split("");
    const targetChars = text.split("");

    return chars
      .map((char, index) => {
        if (char === " ") return " ";
        return Math.random() < progress ? targetChars[index] : char;
      })
      .join("");
  }, []);

  const runAnimation = useCallback(() => {
    if (!isActive || !text) return;

    const timestamp = new Date().toISOString();

    if (animationRef.current.phase === "wait") {
      console.log(`[${timestamp}] ⏳ WAIT phase for: "${text}"`);

      // Show original text
      setDisplayText(text);
      setIsScrambling(false);
      setIsResolving(false);
      setIsPaused(false);

      // Wait before scrambling
      animationRef.current.timeoutId = setTimeout(() => {
        animationRef.current.phase = "scramble";
        animationRef.current.progress = 0;
        setIsScrambling(true);
        console.log(
          `[${new Date().toISOString()}] 🔀 Starting SCRAMBLE phase for: "${text}"`
        );
        runAnimation();
      }, 1000);
    } else if (animationRef.current.phase === "scramble") {
      // Scramble the text
      animationRef.current.progress += 0.1;
      const scrambledText = scrambleText(text, animationRef.current.progress);
      setDisplayText(scrambledText);

      if (animationRef.current.progress >= 1) {
        console.log(
          `[${new Date().toISOString()}] ✅ SCRAMBLE complete for: "${text}"`
        );
        animationRef.current.phase = "resolve";
        animationRef.current.progress = 0;
        setIsScrambling(false);
        setIsResolving(true);

        // Start resolving immediately
        console.log(
          `[${new Date().toISOString()}] 🔄 Starting RESOLVE phase for: "${text}"`
        );
        runAnimation();
      } else {
        animationRef.current.intervalId = setTimeout(
          runAnimation,
          finalConfig.scrambleSpeed
        );
      }
    } else if (animationRef.current.phase === "resolve") {
      // Resolve the text
      animationRef.current.progress += 0.15;
      const resolvedText = resolveText(text, animationRef.current.progress);
      setDisplayText(resolvedText);

      if (animationRef.current.progress >= 1) {
        console.log(
          `[${new Date().toISOString()}] ✅ RESOLVE complete for: "${text}"`
        );

        // Text resolved
        setDisplayText(text);
        setIsResolving(false);
        setIsPaused(true);
      } else {
        animationRef.current.intervalId = setTimeout(
          runAnimation,
          finalConfig.scrambleSpeed
        );
      }
    }
  }, [isActive, text, scrambleText, resolveText, finalConfig]);

  useEffect(() => {
    if (!isActive || !text) {
      console.log(
        `[${new Date().toISOString()}] 🚫 Animation not active or no text`
      );
      return;
    }

    console.log(
      `[${new Date().toISOString()}] 🚀 Starting animation for: "${text}"`
    );
    console.log(`[${new Date().toISOString()}] ⚙️ Config:`, finalConfig);

    // Reset animation state
    animationRef.current = {
      phase: "wait",
      progress: 0,
    };

    // Start with delay
    const startTimeout = setTimeout(() => {
      runAnimation();
    }, delay);

    return () => {
      console.log(
        `[${new Date().toISOString()}] 🛑 Animation cleanup - clearing timeouts`
      );
      clearTimeout(startTimeout);
      if (animationRef.current.timeoutId) {
        clearTimeout(animationRef.current.timeoutId);
      }
      if (animationRef.current.intervalId) {
        clearTimeout(animationRef.current.intervalId);
      }
    };
  }, [isActive, text, runAnimation, delay, finalConfig]);

  const start = useCallback(() => setIsActive(true), []);
  const stop = useCallback(() => setIsActive(false), []);
  const reset = useCallback(() => {
    setDisplayText(text);
    setIsScrambling(false);
    setIsResolving(false);
    setIsPaused(false);
  }, [text]);

  return {
    displayText,
    isScrambling,
    isResolving,
    isPaused,
    isActive,
    start,
    stop,
    reset,
  };
}
