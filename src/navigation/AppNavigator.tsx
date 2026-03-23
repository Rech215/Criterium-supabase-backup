/**
 * AppNavigator.tsx
 * Navegador raíz de la aplicación Criterium.
 *
 * Lógica condicional:
 *   - Si isLoading         → Muestra pantalla de carga (Splash)
 *   - Si !userToken        → Muestra el AuthStack (Splash → Login)
 *   - Si userRole=teacher  → Muestra el TeacherStack
 *   - Si userRole=student  → Muestra el StudentStack
 */

import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { ActivityIndicator, View, StyleSheet, Text } from 'react-native';

import { useAuth } from '../context/AuthContext';
import AuthStack from './stacks/AuthStack';
import TeacherStack from './stacks/TeacherStack';
import StudentStack from './stacks/StudentStack';

/**
 * Componente raíz del sistema de navegación.
 * Debe estar envuelto por <AuthProvider> en App.tsx.
 */
const AppNavigator: React.FC = () => {
    const { userToken, userRole, isLoading } = useAuth();

    // ─────────────────────────────────────────────
    // Estado de carga: verificando sesión guardada
    // ─────────────────────────────────────────────
    if (isLoading) {
        return (
            <View style={estilos.contenedorCarga}>
                <ActivityIndicator size="large" color="#0A1931" />
                <Text style={estilos.textoCarga}>Cargando Criterium...</Text>
            </View>
        );
    }

    // ─────────────────────────────────────────────
    // Selección del stack según estado de autenticación
    // ─────────────────────────────────────────────
    const obtenerStackActivo = () => {
        // Sin token → Pantallas públicas (Splash + Login)
        if (!userToken) {
            return <AuthStack />;
        }

        // Con token + Rol Maestro → Pantallas del docente
        if (userRole === 'teacher') {
            return <TeacherStack />;
        }

        // Con token + Rol Alumno → Pantallas del estudiante
        if (userRole === 'student') {
            return <StudentStack />;
        }

        // Caso de seguridad: token sin rol válido → volver a Login
        return <AuthStack />;
    };

    return (
        <NavigationContainer>
            {obtenerStackActivo()}
        </NavigationContainer>
    );
};

// ─────────────────────────────────────────────
// Estilos
// ─────────────────────────────────────────────
const estilos = StyleSheet.create({
    contenedorCarga: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#FFFFFF',
    },
    textoCarga: {
        marginTop: 16,
        fontSize: 16,
        color: '#0A1931',
        fontWeight: '600',
    },
});

export default AppNavigator;
