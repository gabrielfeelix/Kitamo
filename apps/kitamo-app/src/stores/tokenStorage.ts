import AsyncStorage from '@react-native-async-storage/async-storage';
import * as SecureStore from 'expo-secure-store';
import { Platform } from 'react-native';

const KEY = 'kitamo.auth.token';

const isSecureStoreAvailable = Platform.OS === 'ios' || Platform.OS === 'android';

export const tokenStorage = {
    async get(): Promise<string | null> {
        if (isSecureStoreAvailable) {
            return SecureStore.getItemAsync(KEY);
        }
        return AsyncStorage.getItem(KEY);
    },
    async set(token: string): Promise<void> {
        if (isSecureStoreAvailable) {
            await SecureStore.setItemAsync(KEY, token);
            return;
        }
        await AsyncStorage.setItem(KEY, token);
    },
    async clear(): Promise<void> {
        if (isSecureStoreAvailable) {
            await SecureStore.deleteItemAsync(KEY);
            return;
        }
        await AsyncStorage.removeItem(KEY);
    },
};
