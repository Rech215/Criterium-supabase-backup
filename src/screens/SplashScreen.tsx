/**
 * SplashScreen.tsx
 * Pantalla de carga inicial (Splash).
 * Navega automáticamente a Login después de 3 segundos.
 */

import React, { useEffect } from 'react';
import { View, Text, ActivityIndicator, StyleSheet } from 'react-native';
import type { AuthScreenProps } from '../navigation/types';

const SplashScreen: React.FC<AuthScreenProps<'Splash'>> = ({ navigation }) => {
    useEffect(() => {
        // Navegar a Login después de 3 segundos
        const temporizador = setTimeout(() => {
            navigation.replace('Login');
        }, 3000);

        return () => clearTimeout(temporizador);
    }, [navigation]);

    return (
        <View style={estilos.contenedor}>
            {/* Logo de la app */}
            <Text style={estilos.logo}>📐</Text>
            <Text style={estilos.titulo}>Criterium</Text>
            <Text style={estilos.subtitulo}>EDUCATION MANAGEMENT</Text>

            <ActivityIndicator
                size="large"
                color="#0A1931"
                style={estilos.cargando}
            />
            <Text style={estilos.textoCargando}>Sincronizando datos del aula...</Text>

            {/* Pie de pantalla */}
            <View style={estilos.pie}>
                <Text style={estilos.textoPie}>DISEÑADO PARA EDUCADORES</Text>
                <Text style={estilos.version}>v 2.4.0</Text>
            </View>
        </View>
    );
};

const estilos = StyleSheet.create({
    contenedor: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#FFFFFF',
    },
    logo: {
        fontSize: 80,
    },
    titulo: {
        fontSize: 36,
        fontWeight: 'bold',
        color: '#0A1931',
        marginTop: 16,
    },
    subtitulo: {
        fontSize: 12,
        letterSpacing: 2,
        color: '#999999',
        fontWeight: 'bold',
        marginTop: 4,
    },
    cargando: {
        marginTop: 60,
    },
    textoCargando: {
        marginTop: 16,
        color: '#0A1931',
        fontSize: 14,
    },
    pie: {
        position: 'absolute',
        bottom: 40,
        alignItems: 'center',
    },
    textoPie: {
        fontSize: 10,
        fontWeight: 'bold',
        color: '#999999',
        letterSpacing: 1.5,
    },
    version: {
        fontSize: 10,
        color: '#999999',
        marginTop: 4,
    },
});

export default SplashScreen;
