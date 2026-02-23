import "./index.css";
import { Composition } from "remotion";
import { Teste } from "./Teste";
import { HeroSection } from "./HeroSection";
import { HeroSectionDesktop } from "./HeroSectionDesktop";
import { RitmoFundacao } from "./RitmoFundacao";
import { RitmoHabito } from "./RitmoHabito";
import { RitmoRadar } from "./RitmoRadar";
import { RitmoPaz } from "./RitmoPaz";

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

      {/* ── O RITMO: 4 explanatory clips ── */}
      <Composition
        id="RitmoFundacao"
        component={RitmoFundacao}
        durationInFrames={150}
        fps={30}
        width={1280}
        height={720}
      />
      <Composition
        id="RitmoHabito"
        component={RitmoHabito}
        durationInFrames={150}
        fps={30}
        width={630}
        height={1120}
      />
      <Composition
        id="RitmoRadar"
        component={RitmoRadar}
        durationInFrames={150}
        fps={30}
        width={1280}
        height={720}
      />
      <Composition
        id="RitmoPaz"
        component={RitmoPaz}
        durationInFrames={150}
        fps={30}
        width={1280}
        height={720}
      />
    </>
  );
};

