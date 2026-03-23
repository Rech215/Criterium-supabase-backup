/**
 * AuthStack.tsx
 * Pila de navegación pública (no autenticada).
 * Contiene las pantallas de Splash y Login.
 */

import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { AuthStackParamList } from '../types';

// Pantallas
import SplashScreen from '../../screens/SplashScreen';
import LoginScreen from '../../screens/LoginScreen';

const Stack = createNativeStackNavigator<AuthStackParamList>();

/**
 * Pila de autenticación.
 * Se muestra cuando el usuario NO tiene un token activo.
 */
const AuthStack: React.FC = () => {
    return (
        <Stack.Navigator
            initialRouteName="Splash"
            screenOptions={{
                headerShown: false, // Sin barra de navegación en pantallas públicas
                animation: 'fade',  // Transición suave entre Splash y Login
            }}
        >
            <Stack.Screen
                name="Splash"
                component={SplashScreen}
                options={{ title: 'Cargando...' }}
            />
            <Stack.Screen
                name="Login"
                component={LoginScreen}
                options={{ title: 'Iniciar Sesión' }}
            />
        </Stack.Navigator>
    );
};

export default AuthStack;
