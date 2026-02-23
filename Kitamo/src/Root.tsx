import "./index.css";
import { Composition } from "remotion";
import { Teste } from "./Teste";
import { HeroSection } from "./HeroSection";
import { HeroSectionDesktop } from "./HeroSectionDesktop";

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="MyComp"
        component={Teste}
        durationInFrames={300}
        fps={30}
        width={1920}
        height={1080}
      />
      <Composition
        id="HeroSection"
        component={HeroSection}
        durationInFrames={135}
        fps={30}
        width={1080}
        height={1920}
      />
      <Composition
        id="HeroSectionDesktop"
        component={HeroSectionDesktop}
        durationInFrames={135}
        fps={30}
        width={1920}
        height={1080}
      />
    </>
  );
};
