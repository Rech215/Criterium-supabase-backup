/**
 * App.tsx
 * Punto de entrada de la aplicación Criterium (React Native).
 *
 * Envuelve toda la app con el AuthProvider para que
 * todos los componentes tengan acceso al contexto de autenticación.
 */

import React from 'react';
import { AuthProvider } from './context/AuthContext';
import AppNavigator from './navigation/AppNavigator';

const App: React.FC = () => {
    return (
        <AuthProvider>
            <AppNavigator />
        </AuthProvider>
    );
};

export default App;
