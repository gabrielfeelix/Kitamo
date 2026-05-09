import React from 'react';
import Svg, { Circle, Path } from 'react-native-svg';

import { KITAMO } from '@/theme/tokens';

type Props = { size?: number; color?: string };

export function KitamoLogo({ size = 36, color = KITAMO.brand }: Props): React.JSX.Element {
    return (
        <Svg width={size} height={size} viewBox="0 0 64 64" fill="none">
            <Circle cx="32" cy="32" r="30" stroke={color} strokeWidth="4" />
            <Path
                d="M22 18v28M22 32l16-14M22 32l16 14"
                stroke={color}
                strokeWidth="5"
                strokeLinecap="round"
                strokeLinejoin="round"
            />
            <Circle cx="46" cy="22" r="4" fill={color} />
        </Svg>
    );
}
