/**
 * LoginScreen.tsx
 * Pantalla de inicio de sesión.
 * Permite seleccionar rol (Maestro/Alumno) y autenticarse.
 *
 * CONEXIONES:
 *   - Botón "Entrar como Maestro" → signIn('teacher') → Monta TeacherStack
 *   - Botón "Entrar como Alumno"  → signIn('student') → Monta StudentStack
 */

import React, { useState } from 'react';
import {
    View,
    Text,
    TextInput,
    TouchableOpacity,
    StyleSheet,
    ScrollView,
} from 'react-native';
import { useAuth } from '../context/AuthContext';
import type { AuthScreenProps } from '../navigation/types';

const LoginScreen: React.FC<AuthScreenProps<'Login'>> = () => {
    const { signIn } = useAuth();
    const [esAlumno, setEsAlumno] = useState(true);
    const [correo, setCorreo] = useState('');
    const [contrasena, setContrasena] = useState('');

    /**
     * Maneja el inicio de sesión.
     * Llama a signIn() del contexto de autenticación,
     * lo cual hace que AppNavigator monte el stack correspondiente.
     */
    const manejarInicioSesion = () => {
        if (esAlumno) {
            // ── Al autenticar como Alumno ──
            // Esto desmonta el AuthStack y monta el StudentStack
            signIn('student');
        } else {
            // ── Al autenticar como Maestro ──
            // Esto desmonta el AuthStack y monta el TeacherStack
            signIn('teacher');
        }
    };

    return (
        <ScrollView
            style={estilos.scroll}
            contentContainerStyle={estilos.contenedor}
        >
            {/* Encabezado */}
            <Text style={estilos.logo}>📐</Text>
            <Text style={estilos.titulo}>{'Bienvenido a\nCriterium'}</Text>
            <Text style={estilos.subtitulo}>
                Gestiona tus clases de forma eficiente
            </Text>

            {/* ── Selector de Rol: Maestro / Alumno ── */}
            <View style={estilos.selectorRol}>
                <TouchableOpacity
                    style={[
                        estilos.botonRol,
                        !esAlumno && estilos.botonRolActivo,
                    ]}
                    onPress={() => setEsAlumno(false)}
                >
                    <Text
                        style={[
                            estilos.textoRol,
                            !esAlumno && estilos.textoRolActivo,
                        ]}
                    >
                        Soy Maestro
                    </Text>
                </TouchableOpacity>

                <TouchableOpacity
                    style={[
                        estilos.botonRol,
                        esAlumno && estilos.botonRolActivo,
                    ]}
                    onPress={() => setEsAlumno(true)}
                >
                    <Text
                        style={[
                            estilos.textoRol,
                            esAlumno && estilos.textoRolActivo,
                        ]}
                    >
                        Soy Alumno
                    </Text>
                </TouchableOpacity>
            </View>

            {/* ── Campos de Texto ── */}
            <Text style={estilos.etiqueta}>Correo electrónico</Text>
            <TextInput
                style={estilos.input}
                placeholder="ejemplo@correo.com"
                placeholderTextColor="#999999"
                value={correo}
                onChangeText={setCorreo}
                keyboardType="email-address"
                autoCapitalize="none"
            />

            <Text style={estilos.etiqueta}>Contraseña</Text>
            <TextInput
                style={estilos.input}
                placeholder="••••••••"
                placeholderTextColor="#999999"
                value={contrasena}
                onChangeText={setContrasena}
                secureTextEntry
            />

            {/* ── Botón de Entrar ──
       *  CONEXIÓN CLAVE:
       *  Llama a signIn('teacher') o signIn('student')
       *  según la selección del toggle.
       *  Esto NO usa navigation.navigate(), sino que cambia
       *  el estado del AuthContext, lo cual automáticamente
       *  desmonta este stack y monta el stack correspondiente.
       */}
            <TouchableOpacity
                style={estilos.botonEntrar}
                onPress={manejarInicioSesion}
                activeOpacity={0.8}
            >
                <Text style={estilos.textoBotonEntrar}>
                    Entrar como {esAlumno ? 'Alumno' : 'Maestro'}
                </Text>
                <Text style={estilos.flechaBoton}>→</Text>
            </TouchableOpacity>

            {/* ── Links inferiores ── */}
            <TouchableOpacity style={estilos.linkOlvide}>
                <Text style={estilos.textoLinkOlvide}>¿Olvidaste tu contraseña?</Text>
            </TouchableOpacity>

            <View style={estilos.filaRegistro}>
                <Text style={estilos.textoGris}>¿No tienes cuenta? </Text>
                <TouchableOpacity>
                    <Text style={estilos.linkRegistro}>Regístrate</Text>
                </TouchableOpacity>
            </View>
        </ScrollView>
    );
};

const estilos = StyleSheet.create({
    scroll: {
        flex: 1,
        backgroundColor: '#FFFFFF',
    },
    contenedor: {
        padding: 24,
        alignItems: 'center',
    },
    logo: {
        fontSize: 60,
        marginTop: 20,
    },
    titulo: {
        fontSize: 32,
        fontWeight: 'bold',
        color: '#0A1931',
        textAlign: 'center',
        marginTop: 16,
    },
    subtitulo: {
        fontSize: 16,
        color: '#999999',
        marginTop: 8,
        textAlign: 'center',
    },
    // ── Selector de Rol ──
    selectorRol: {
        flexDirection: 'row',
        backgroundColor: '#F1F3F5',
        borderRadius: 30,
        marginTop: 32,
        padding: 4,
        width: '100%',
    },
    botonRol: {
        flex: 1,
        paddingVertical: 12,
        borderRadius: 26,
        alignItems: 'center',
    },
    botonRolActivo: {
        backgroundColor: '#FFFFFF',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 4,
        elevation: 2,
    },
    textoRol: {
        fontWeight: 'bold',
        color: '#999999',
    },
    textoRolActivo: {
        color: '#0A1931',
    },
    // ── Campos ──
    etiqueta: {
        alignSelf: 'flex-start',
        fontWeight: 'bold',
        color: '#0A1931',
        marginTop: 24,
        marginBottom: 8,
    },
    input: {
        width: '100%',
        borderWidth: 1,
        borderColor: '#E0E0E0',
        borderRadius: 12,
        padding: 14,
        fontSize: 16,
        color: '#0A1931',
    },
    // ── Botón Entrar ──
    botonEntrar: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        width: '100%',
        paddingVertical: 16,
        borderRadius: 30,
        marginTop: 32,
        backgroundColor: '#134E5E', // Gradiente simulado con color sólido
    },
    textoBotonEntrar: {
        fontSize: 18,
        fontWeight: 'bold',
        color: '#FFFFFF',
    },
    flechaBoton: {
        fontSize: 18,
        color: '#FFFFFF',
        marginLeft: 8,
    },
    // ── Links ──
    linkOlvide: {
        marginTop: 24,
    },
    textoLinkOlvide: {
        fontWeight: 'bold',
        color: '#0A1931',
    },
    filaRegistro: {
        flexDirection: 'row',
        marginTop: 12,
    },
    textoGris: {
        color: '#999999',
    },
    linkRegistro: {
        fontWeight: 'bold',
        color: '#0A1931',
    },
});

export default LoginScreen;
