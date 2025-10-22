import Link from "next/link";
import { SliceWrapper } from "../SliceWrapper";

type FeatureItem = {
  title: string;
  description: string;
};

// Have you ever downloaded a new font family and thought, "I just want to install these TTFs right now without opening Font Book"? Or maybe you're drowning in a pile of mixed font files and just need them organized? Well today is your lucky day. Meet Buen Font Installer, the macOS menu bar app for all your font installing and organizing needs.

const why: string[] = [
  "We've all (maybe) been here before: the moment of installing a who bunch of fonts. The barrage of those windows and repeated clicking and clicking and clicking and clicking and resolving duplicates, and more clicking.",
  "May your pain be forever eased by the handy-dandy Buen Font Installer™ by John Choura.",
  "Just drag your font folders into the app and it sorts, deduplicates, and installs them almost instantly.",
];

export function SliceWhy() {
  return (
    <SliceWrapper title="WHY" innerClassName="gap-y-6 py-[8vw]">
      <div className="flex flex-col items-start col-span-full gap-y-4">
        {why.map((item, index) => {
          return (
            <p
              key={index}
              className="headline-display-xl text-start indent-2em"
            >
              {item}
            </p>
          );
        })}
        <Link
          href="https://github.com/johnchourajr/buen-font-installer/releases/latest"
          className="headline-display-xl text-start indent-2em underline decoration-[0.025em] underline-offset-[0.1em] decoration-foreground hover:decoration-white"
          target="_blank"
          rel="noopener noreferrer"
        >
          (Download ↗)
        </Link>
      </div>
    </SliceWrapper>
  );
}
