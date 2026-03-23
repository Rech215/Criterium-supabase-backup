/**
 * TeacherProfileScreen.tsx
 * Pantalla de perfil del Maestro.
 *
 * CONEXIÓN:
 *   - Botón "Cerrar Sesión" → signOut() del contexto
 *     Esto desmonta el TeacherStack y muestra el AuthStack (Login).
 */

import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { useAuth } from '../context/AuthContext';
import type { TeacherScreenProps } from '../navigation/types';

const TeacherProfileScreen: React.FC<TeacherScreenProps<'TeacherProfile'>> = () => {
    const { signOut } = useAuth();

    return (
        <View style={estilos.contenedor}>
            {/* Avatar y datos del profesor */}
            <View style={estilos.seccionPerfil}>
                <View style={estilos.avatarGrande}>
                    <Text style={estilos.avatarTexto}>PM</Text>
                </View>
                <Text style={estilos.nombre}>Prof. Martínez</Text>
                <Text style={estilos.correo}>p.martinez@criterium.edu</Text>
            </View>

            {/* Información del perfil */}
            <View style={estilos.cardInfo}>
                <View style={estilos.filaInfo}>
                    <Text style={estilos.etiqueta}>Departamento</Text>
                    <Text style={estilos.valor}>Ingeniería de Software</Text>
                </View>
                <View style={estilos.separador} />
                <View style={estilos.filaInfo}>
                    <Text style={estilos.etiqueta}>Clases Activas</Text>
                    <Text style={estilos.valor}>3</Text>
                </View>
                <View style={estilos.separador} />
                <View style={estilos.filaInfo}>
                    <Text style={estilos.etiqueta}>Alumnos Totales</Text>
                    <Text style={estilos.valor}>47</Text>
                </View>
            </View>

            {/* ── Botón Cerrar Sesión → signOut() ──
       *  Llama a signOut() del AuthContext.
       *  Esto establece userToken = null, lo cual hace que
       *  AppNavigator desmonte el TeacherStack y muestre el AuthStack.
       */}
            <TouchableOpacity
                style={estilos.botonCerrarSesion}
                onPress={signOut}
                activeOpacity={0.8}
            >
                <Text style={estilos.textoCerrarSesion}>Cerrar Sesión</Text>
            </TouchableOpacity>
        </View>
    );
};

const estilos = StyleSheet.create({
    contenedor: {
        flex: 1,
        backgroundColor: '#F8F9FA',
        padding: 24,
    },
    seccionPerfil: {
        alignItems: 'center',
        marginTop: 20,
        marginBottom: 32,
    },
    avatarGrande: {
        width: 90,
        height: 90,
        borderRadius: 45,
        backgroundColor: '#0A1931',
        justifyContent: 'center',
        alignItems: 'center',
        marginBottom: 16,
    },
    avatarTexto: {
        color: '#FFFFFF',
        fontWeight: 'bold',
        fontSize: 28,
    },
    nombre: {
        fontSize: 24,
        fontWeight: 'bold',
        color: '#0A1931',
    },
    correo: {
        fontSize: 14,
        color: '#999999',
        marginTop: 4,
    },
    cardInfo: {
        backgroundColor: '#FFFFFF',
        borderRadius: 20,
        padding: 20,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.05,
        shadowRadius: 8,
        elevation: 2,
    },
    filaInfo: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        paddingVertical: 14,
    },
    etiqueta: {
        fontSize: 15,
        color: '#0A1931',
    },
    valor: {
        fontSize: 15,
        fontWeight: 'bold',
        color: '#0A1931',
    },
    separador: {
        height: 1,
        backgroundColor: '#F1F3F5',
    },
    botonCerrarSesion: {
        marginTop: 40,
        paddingVertical: 16,
        borderRadius: 30,
        borderWidth: 1.5,
        borderColor: '#E53E3E',
        alignItems: 'center',
    },
    textoCerrarSesion: {
        fontSize: 16,
        fontWeight: 'bold',
        color: '#E53E3E',
    },
});

export default TeacherProfileScreen;
