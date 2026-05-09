import React from 'react';
import Svg, { Circle, Path, Rect } from 'react-native-svg';

import { KITAMO } from '@/theme/tokens';

export type IconName =
    | 'home'
    | 'bank'
    | 'chart'
    | 'user'
    | 'plus'
    | 'bell'
    | 'eye'
    | 'arrow'
    | 'check'
    | 'close'
    | 'back'
    | 'down'
    | 'food'
    | 'car'
    | 'house'
    | 'health'
    | 'game'
    | 'bolt'
    | 'card'
    | 'wallet'
    | 'send'
    | 'recv'
    | 'swap'
    | 'tag'
    | 'target'
    | 'lock'
    | 'help'
    | 'info'
    | 'imp'
    | 'exp'
    | 'bot'
    | 'spark'
    | 'bulb'
    | 'face'
    | 'shield'
    | 'dots'
    | 'chat'
    | 'google';

type Props = {
    name: IconName;
    size?: number;
    color?: string;
};

export function Icon({ name, size = 24, color = KITAMO.ink }: Props): React.JSX.Element {
    const stroke = color;
    const sw = 2;
    switch (name) {
        case 'home':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Path d="M3 11l9-8 9 8v10a1 1 0 0 1-1 1h-5v-7h-6v7H4a1 1 0 0 1-1-1z" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'bank':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Path d="M3 21h18M5 21V10M19 21V10M3 10l9-6 9 6M9 21v-7M15 21v-7" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'chart':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Path d="M3 3v18h18M7 14l4-4 3 3 5-6" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'user':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Circle cx="12" cy="8" r="4" stroke={stroke} strokeWidth={sw} />
                    <Path d="M4 21c1-4 5-6 8-6s7 2 8 6" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'plus':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Path d="M12 5v14M5 12h14" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'bell':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Path d="M6 9a6 6 0 0 1 12 0c0 5 2 6 2 7H4c0-1 2-2 2-7zM10 20a2 2 0 0 0 4 0" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'eye':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                    <Circle cx="12" cy="12" r="3" stroke={stroke} strokeWidth={sw} />
                </Svg>
            );
        case 'arrow':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Path d="M5 12h14M13 5l7 7-7 7" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'check':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Path d="M4 12l5 5L20 6" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'close':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Path d="M6 6l12 12M18 6L6 18" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'back':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Path d="M19 12H5M12 5l-7 7 7 7" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'down':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Path d="M6 9l6 6 6-6" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'food':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Path d="M3 11h18M5 11v8a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2v-8M8 7c0-2 2-4 4-4s4 2 4 4" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'car':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Path d="M5 17h14l-2-7H7zM7 17v2M17 17v2" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                    <Circle cx="8" cy="17" r="1.5" fill={stroke} />
                    <Circle cx="16" cy="17" r="1.5" fill={stroke} />
                </Svg>
            );
        case 'house':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Path d="M3 11l9-7 9 7v9a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1z" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'health':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Path d="M12 5l-3 7h2v6l3-7h-2z" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                    <Circle cx="12" cy="12" r="9" stroke={stroke} strokeWidth={sw} />
                </Svg>
            );
        case 'game':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Rect x="2" y="7" width="20" height="10" rx="3" stroke={stroke} strokeWidth={sw} />
                    <Path d="M7 11v2M6 12h2M15 12h.01M18 12h.01" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'bolt':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Path d="M13 2L4 14h7l-1 8 9-12h-7z" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'card':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Rect x="2" y="6" width="20" height="13" rx="2" stroke={stroke} strokeWidth={sw} />
                    <Path d="M2 11h20" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'wallet':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Path d="M3 7a2 2 0 0 1 2-2h13a2 2 0 0 1 2 2v3" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                    <Path d="M21 10v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V7" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                    <Circle cx="17" cy="14" r="1.2" fill={stroke} />
                </Svg>
            );
        case 'send':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Path d="M3 12l18-9-7 18-3-7z" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'recv':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Path d="M21 12L3 21l7-18 3 7z" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'swap':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Path d="M7 4v16M3 8l4-4 4 4M17 20V4M21 16l-4 4-4-4" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'tag':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Path d="M3 12V4h8l10 10-8 8z" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                    <Circle cx="7.5" cy="7.5" r="1.2" fill={stroke} />
                </Svg>
            );
        case 'target':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Circle cx="12" cy="12" r="9" stroke={stroke} strokeWidth={sw} />
                    <Circle cx="12" cy="12" r="5" stroke={stroke} strokeWidth={sw} />
                    <Circle cx="12" cy="12" r="1.5" fill={stroke} />
                </Svg>
            );
        case 'lock':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Rect x="4" y="11" width="16" height="10" rx="2" stroke={stroke} strokeWidth={sw} />
                    <Path d="M8 11V7a4 4 0 0 1 8 0v4" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'help':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Circle cx="12" cy="12" r="9" stroke={stroke} strokeWidth={sw} />
                    <Path d="M9 9a3 3 0 0 1 6 0c0 2-3 2-3 4M12 17h.01" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'info':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Circle cx="12" cy="12" r="9" stroke={stroke} strokeWidth={sw} />
                    <Path d="M12 8h.01M11 12h1v5h1" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'imp':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Path d="M12 3v12M7 10l5 5 5-5M5 21h14" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'exp':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Path d="M12 21V9M7 14l5-5 5 5M5 3h14" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'bot':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Rect x="4" y="8" width="16" height="11" rx="3" stroke={stroke} strokeWidth={sw} />
                    <Path d="M12 4v4M9 14h.01M15 14h.01M9 17h6" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'spark':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Path d="M12 3l2 5 5 2-5 2-2 5-2-5-5-2 5-2zM18 14l1 2 2 1-2 1-1 2-1-2-2-1 2-1z" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'bulb':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Path d="M9 18h6M10 21h4M8 14a5 5 0 1 1 8 0c-1 1-1 2-1 4H9c0-2 0-3-1-4z" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'face':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Circle cx="12" cy="12" r="9" stroke={stroke} strokeWidth={sw} />
                    <Circle cx="9" cy="10" r="0.8" fill={stroke} />
                    <Circle cx="15" cy="10" r="0.8" fill={stroke} />
                    <Path d="M9 15c1 1 2 1.5 3 1.5s2-.5 3-1.5" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'shield':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Path d="M12 3l8 3v6c0 5-4 8-8 9-4-1-8-4-8-9V6z" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                    <Path d="M9 12l2 2 4-4" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'dots':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Circle cx="6" cy="12" r="1.5" fill={stroke} />
                    <Circle cx="12" cy="12" r="1.5" fill={stroke} />
                    <Circle cx="18" cy="12" r="1.5" fill={stroke} />
                </Svg>
            );
        case 'chat':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
                    <Path d="M4 5a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2h-7l-5 4v-4H6a2 2 0 0 1-2-2z" stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" />
                </Svg>
            );
        case 'google':
            return (
                <Svg width={size} height={size} viewBox="0 0 24 24">
                    <Path d="M21.6 12.2c0-.7-.1-1.4-.2-2H12v3.8h5.4c-.2 1.3-1 2.4-2 3.1v2.6h3.3c1.9-1.8 3-4.4 3-7.5z" fill="#4285F4" />
                    <Path d="M12 22c2.7 0 5-1 6.6-2.4l-3.3-2.5c-.9.6-2 1-3.3 1-2.6 0-4.7-1.7-5.5-4H3.1v2.5C4.7 19.6 8.1 22 12 22z" fill="#34A853" />
                    <Path d="M6.5 14.1A6 6 0 0 1 6.2 12c0-.7.1-1.4.3-2.1V7.3H3.1A10 10 0 0 0 2 12c0 1.6.4 3.2 1.1 4.6z" fill="#FBBC04" />
                    <Path d="M12 6c1.5 0 2.8.5 3.8 1.5l2.9-2.9C17 3 14.7 2 12 2 8.1 2 4.7 4.4 3.1 7.3l3.4 2.6C7.3 7.7 9.4 6 12 6z" fill="#EA4335" />
                </Svg>
            );
    }
}
