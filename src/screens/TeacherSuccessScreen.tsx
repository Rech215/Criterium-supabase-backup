/**
 * TeacherSuccessScreen.tsx
 * Pantalla de confirmación después de publicar una calificación.
 *
 * CONEXIONES:
 *   - Botón "Calificar otro alumno" → navigation.popToTop() luego navigate('AssignmentSubmissions')
 *     IMPORTANTE: Usa popToTop() primero para limpiar el stack y evitar ciclos infinitos.
 *   - Botón "Ir al Inicio"          → navigation.popToTop() (Vuelve al TeacherDashboard)
 */

import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import type { TeacherScreenProps } from '../navigation/types';

const TeacherSuccessScreen: React.FC<TeacherScreenProps<'TeacherSuccess'>> = ({
    navigation,
}) => {
    /**
     * "Calificar otro alumno":
     * 1. Primero limpia todo el stack con popToTop() → queda en TeacherDashboard
     * 2. Luego navega a AssignmentSubmissions
     * Esto evita que se acumulen pantallas en el stack (ciclos infinitos).
     */
    const calificarOtro = () => {
        navigation.popToTop();
        navigation.navigate('AssignmentSubmissions');
    };

    /**
     * "Ir al Inicio":
     * Simplemente hace popToTop() para volver al TeacherDashboard
     * (que es la pantalla inicial del TeacherStack).
     */
    const irAlInicio = () => {
        navigation.popToTop();
    };

    return (
        <View style={estilos.contenedor}>
            {/* Círculo de éxito */}
            <View style={estilos.circuloExterior}>
                <View style={estilos.circuloInterior}>
                    <Text style={estilos.iconoCheck}>✓</Text>
                </View>
            </View>

            <Text style={estilos.titulo}>¡Calificación Publicada!</Text>
            <Text style={estilos.descripcion}>
                El alumno recibirá una notificación{'\n'}
                en su panel de Criterium en breve.
            </Text>

            {/* ── Botón: Calificar otro alumno ── */}
            <TouchableOpacity
                style={estilos.botonPrimario}
                onPress={calificarOtro}
                activeOpacity={0.8}
            >
                <Text style={estilos.textoPrimario}>Calificar otro alumno</Text>
            </TouchableOpacity>

            {/* ── Botón: Ir al Inicio ── */}
            <TouchableOpacity
                style={estilos.botonSecundario}
                onPress={irAlInicio}
                activeOpacity={0.8}
            >
                <Text style={estilos.textoSecundario}>Ir al Inicio</Text>
            </TouchableOpacity>
        </View>
    );
};

const estilos = StyleSheet.create({
    contenedor: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#FFFFFF',
        padding: 32,
    },
    circuloExterior: {
        width: 120,
        height: 120,
        borderRadius: 60,
        backgroundColor: 'rgba(46, 204, 113, 0.1)',
        justifyContent: 'center',
        alignItems: 'center',
        marginBottom: 32,
    },
    circuloInterior: {
        width: 72,
        height: 72,
        borderRadius: 36,
        backgroundColor: '#2ECC71',
        justifyContent: 'center',
        alignItems: 'center',
    },
    iconoCheck: {
        fontSize: 36,
        color: '#FFFFFF',
        fontWeight: 'bold',
    },
    titulo: {
        fontSize: 26,
        fontWeight: 'bold',
        color: '#0A1931',
        textAlign: 'center',
    },
    descripcion: {
        fontSize: 14,
        color: '#999999',
        textAlign: 'center',
        marginTop: 12,
        lineHeight: 22,
    },
    botonPrimario: {
        width: '100%',
        paddingVertical: 16,
        borderRadius: 30,
        backgroundColor: '#0A1931',
        alignItems: 'center',
        marginTop: 40,
    },
    textoPrimario: {
        fontSize: 16,
        fontWeight: 'bold',
        color: '#FFFFFF',
    },
    botonSecundario: {
        width: '100%',
        paddingVertical: 16,
        borderRadius: 30,
        borderWidth: 1,
        borderColor: '#CCCCCC',
        alignItems: 'center',
        marginTop: 12,
    },
    textoSecundario: {
        fontSize: 16,
        fontWeight: 'bold',
        color: '#0A1931',
    },
});

export default TeacherSuccessScreen;
