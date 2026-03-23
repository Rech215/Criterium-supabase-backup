/**
 * PeerEvaluationListScreen.tsx
 * Lista de compañeros de equipo para evaluación entre pares (Alumno).
 *
 * CONEXIÓN:
 *   - Botón "Enviar Evaluación" → navigation.navigate('StudentSuccess')
 */

import React from 'react';
import {
    View,
    Text,
    TouchableOpacity,
    StyleSheet,
    ScrollView,
} from 'react-native';
import type { StudentScreenProps } from '../navigation/types';

// Datos simulados de compañeros de equipo
const COMPANEROS = [
    { id: '1', nombre: 'Andrea Ruiz', rol: 'DESARROLLO FRONTEND' },
    { id: '2', nombre: 'Carlos Sosa', rol: 'DISEÑO UX/UI' },
    { id: '3', nombre: 'Elena Méndez', rol: 'GESTIÓN DE PROYECTOS' },
];

const PeerEvaluationListScreen: React.FC<StudentScreenProps<'PeerEvaluationList'>> = ({
    navigation,
}) => {
    return (
        <View style={estilos.contenedor}>
            <ScrollView style={estilos.cuerpo}>
                <Text style={estilos.titulo}>Evalúa a tu equipo</Text>
                <Text style={estilos.subtitulo}>
                    Califica el desempeño de tus compañeros de forma anónima.
                </Text>

                {/* Tarjetas de compañeros */}
                {COMPANEROS.map((companero) => (
                    <View key={companero.id} style={estilos.cardCompanero}>
                        <View style={estilos.fila}>
                            <View style={estilos.avatar}>
                                <Text style={estilos.avatarTexto}>
                                    {companero.nombre.charAt(0)}
                                </Text>
                            </View>
                            <View style={estilos.info}>
                                <Text style={estilos.nombre}>{companero.nombre}</Text>
                                <Text style={estilos.rol}>{companero.rol}</Text>
                            </View>
                        </View>

                        {/* Sliders simulados */}
                        <View style={estilos.seccionSlider}>
                            <View style={estilos.filaSlider}>
                                <Text style={estilos.etiquetaSlider}>Responsabilidad</Text>
                                <Text style={estilos.valorSlider}>85%</Text>
                            </View>
                            <View style={estilos.barraFondo}>
                                <View style={[estilos.barraProgreso, { width: '85%' }]} />
                            </View>
                        </View>

                        <View style={estilos.seccionSlider}>
                            <View style={estilos.filaSlider}>
                                <Text style={estilos.etiquetaSlider}>Aporte Técnico</Text>
                                <Text style={estilos.valorSlider}>92%</Text>
                            </View>
                            <View style={estilos.barraFondo}>
                                <View style={[estilos.barraProgreso, { width: '92%' }]} />
                            </View>
                        </View>
                    </View>
                ))}
            </ScrollView>

            {/* ── Botón Enviar Evaluación → Navega a StudentSuccess ── */}
            <View style={estilos.barraAccion}>
                <TouchableOpacity
                    style={estilos.botonEnviar}
                    onPress={() => navigation.navigate('StudentSuccess')}
                    activeOpacity={0.8}
                >
                    <Text style={estilos.textoEnviar}>Enviar Evaluación</Text>
                    <Text style={estilos.iconoEnviar}>📤</Text>
                </TouchableOpacity>
            </View>
        </View>
    );
};

const estilos = StyleSheet.create({
    contenedor: {
        flex: 1,
        backgroundColor: '#F8F9FA',
    },
    cuerpo: {
        flex: 1,
        padding: 24,
    },
    titulo: {
        fontSize: 24,
        fontWeight: 'bold',
        color: '#0A1931',
    },
    subtitulo: {
        fontSize: 14,
        color: '#999999',
        marginTop: 8,
        marginBottom: 24,
    },
    cardCompanero: {
        backgroundColor: '#FFFFFF',
        borderRadius: 20,
        padding: 20,
        marginBottom: 16,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.05,
        shadowRadius: 8,
        elevation: 2,
    },
    fila: {
        flexDirection: 'row',
        alignItems: 'center',
        marginBottom: 20,
    },
    avatar: {
        width: 48,
        height: 48,
        borderRadius: 24,
        backgroundColor: '#0A1931',
        justifyContent: 'center',
        alignItems: 'center',
    },
    avatarTexto: {
        color: '#FFFFFF',
        fontWeight: 'bold',
        fontSize: 18,
    },
    info: {
        marginLeft: 16,
    },
    nombre: {
        fontSize: 18,
        fontWeight: 'bold',
        color: '#0A1931',
    },
    rol: {
        fontSize: 10,
        fontWeight: 'bold',
        color: '#2E86DE',
        letterSpacing: 1,
        marginTop: 2,
    },
    seccionSlider: {
        marginBottom: 12,
    },
    filaSlider: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        marginBottom: 6,
    },
    etiquetaSlider: {
        fontSize: 14,
        fontWeight: 'bold',
        color: '#0A1931',
    },
    valorSlider: {
        fontSize: 14,
        fontWeight: 'bold',
        color: '#2EC4B6',
    },
    barraFondo: {
        height: 6,
        backgroundColor: '#F1F3F5',
        borderRadius: 3,
    },
    barraProgreso: {
        height: 6,
        backgroundColor: '#2EC4B6',
        borderRadius: 3,
    },
    barraAccion: {
        padding: 24,
        backgroundColor: '#FFFFFF',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: -4 },
        shadowOpacity: 0.05,
        shadowRadius: 8,
        elevation: 4,
    },
    botonEnviar: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        paddingVertical: 16,
        borderRadius: 30,
        backgroundColor: '#2E86DE',
    },
    textoEnviar: {
        fontSize: 18,
        fontWeight: 'bold',
        color: '#FFFFFF',
    },
    iconoEnviar: {
        fontSize: 18,
        marginLeft: 8,
    },
});

export default PeerEvaluationListScreen;
