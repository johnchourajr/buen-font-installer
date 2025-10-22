import { TypeDefinition } from "@muybuen/type";

export const customHeadlines: Record<
  "display-xxl" | "display-xl",
  TypeDefinition
> = {
  "display-xxl": {
    fontFamily: "NeueBit-Regular",
    clamp: [6, 25],
    lineHeight: 1,
  },
  "display-xl": {
    fontFamily: "OTNeueMontreal-BookSemiSqueezed",
    clamp: [2, 8],
    lineHeight: 1,
  },
};

export const customTexts: Record<
  "body" | "string" | "caption",
  TypeDefinition
> = {
  body: {
    fontFamily: "OTNeueMontreal-BookSemiSqueezed",
    fontSize: "1rem",
    lineHeight: 1.25,
  },
  string: {
    fontFamily: "NeueBit-Bold",
    fontSize: "1.25rem",
    letterSpacing: "0.12em",
    lineHeight: 1,
    textTransform: "uppercase",
  },
  caption: {
    fontFamily: "OTNeueMontreal-BookSemiSqueezed",
    fontSize: ".75rem",
    lineHeight: 1.25,
  },
};
