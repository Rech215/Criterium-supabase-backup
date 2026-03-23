/**
 * StudentSuccessScreen.tsx
 * Pantalla de confirmación después de enviar una evaluación (Alumno).
 *
 * CONEXIÓN:
 *   - Botón "Salir" → signOut() del contexto
 *     Cierra la sesión por seguridad (desmonta StudentStack, muestra Login).
 */

import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { useAuth } from '../context/AuthContext';
import type { StudentScreenProps } from '../navigation/types';

const StudentSuccessScreen: React.FC<StudentScreenProps<'StudentSuccess'>> = () => {
    const { signOut } = useAuth();

    return (
        <View style={estilos.contenedor}>
            {/* Círculo de éxito */}
            <View style={estilos.circuloExterior}>
                <View style={estilos.circuloInterior}>
                    <Text style={estilos.iconoCheck}>✓</Text>
                </View>
            </View>

            <Text style={estilos.titulo}>¡Evaluación Enviada!</Text>
            <Text style={estilos.descripcion}>
                Tu evaluación ha sido registrada de forma anónima.{'\n'}
                Gracias por tu participación.
            </Text>

            {/* ── Botón Salir → signOut() ──
       *  Cierra la sesión por seguridad.
       *  Esto establece userToken = null, lo cual hace que
       *  AppNavigator desmonte el StudentStack y muestre el AuthStack.
       */}
            <TouchableOpacity
                style={estilos.botonSalir}
                onPress={signOut}
                activeOpacity={0.8}
            >
                <Text style={estilos.textoSalir}>Salir</Text>
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
        backgroundColor: 'rgba(46, 134, 222, 0.1)',
        justifyContent: 'center',
        alignItems: 'center',
        marginBottom: 32,
    },
    circuloInterior: {
        width: 72,
        height: 72,
        borderRadius: 36,
        backgroundColor: '#2E86DE',
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
    botonSalir: {
        width: '100%',
        paddingVertical: 16,
        borderRadius: 30,
        backgroundColor: '#E53E3E',
        alignItems: 'center',
        marginTop: 40,
    },
    textoSalir: {
        fontSize: 16,
        fontWeight: 'bold',
        color: '#FFFFFF',
    },
});

export default StudentSuccessScreen;
