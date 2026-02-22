import { Composition } from 'remotion';
import { OHabito } from './OHabito';
import './style.css';

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="OHabito"
        component={OHabito}
        durationInFrames={150}
        fps={30}
        width={720}
        height={1280}
      />
    </>
  );
};
