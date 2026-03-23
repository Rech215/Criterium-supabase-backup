/**
 * RubricBuilderScreen.tsx
 * Configuración de criterios de rúbrica para una tarea.
 *
 * CONEXIÓN:
 *   - Botón "Guardar Rúbrica" → navigation.popToTop() (Regresa al TeacherDashboard)
 */

import React from 'react';
import {
    View,
    Text,
    TouchableOpacity,
    StyleSheet,
    ScrollView,
} from 'react-native';
import type { TeacherScreenProps } from '../navigation/types';

// Criterios de ejemplo para la rúbrica
const CRITERIOS_EJEMPLO = [
    { nombre: 'Funcionalidad', peso: 30 },
    { nombre: 'Diseño Visual', peso: 25 },
    { nombre: 'Código Limpio', peso: 25 },
    { nombre: 'Documentación', peso: 20 },
];

const RubricBuilderScreen: React.FC<TeacherScreenProps<'RubricBuilder'>> = ({
    navigation,
}) => {
    return (
        <View style={estilos.contenedor}>
            <ScrollView style={estilos.cuerpo}>
                <Text style={estilos.titulo}>Criterios de Evaluación</Text>
                <Text style={estilos.subtitulo}>
                    Define los criterios y su peso en la calificación final.
                </Text>

                {/* Lista de criterios */}
                {CRITERIOS_EJEMPLO.map((criterio, index) => (
                    <View key={index} style={estilos.cardCriterio}>
                        <View style={estilos.fila}>
                            <Text style={estilos.nombreCriterio}>{criterio.nombre}</Text>
                            <View style={estilos.badgePeso}>
                                <Text style={estilos.textoPeso}>{criterio.peso}%</Text>
                            </View>
                        </View>
                        {/* Barra visual de peso */}
                        <View style={estilos.barraFondo}>
                            <View
                                style={[estilos.barraProgreso, { width: `${criterio.peso}%` }]}
                            />
                        </View>
                    </View>
                ))}

                {/* Botón para agregar criterio */}
                <TouchableOpacity style={estilos.botonAgregar}>
                    <Text style={estilos.textoAgregar}>+ Agregar criterio</Text>
                </TouchableOpacity>
            </ScrollView>

            {/* ── Botón Guardar → popToTop() → Regresa al TeacherDashboard ── */}
            <View style={estilos.barraAccion}>
                <TouchableOpacity
                    style={estilos.botonGuardar}
                    onPress={() => navigation.popToTop()}
                    activeOpacity={0.8}
                >
                    <Text style={estilos.textoGuardar}>Guardar Rúbrica</Text>
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
        fontSize: 22,
        fontWeight: 'bold',
        color: '#0A1931',
    },
    subtitulo: {
        fontSize: 14,
        color: '#999999',
        marginTop: 8,
        marginBottom: 24,
    },
    cardCriterio: {
        backgroundColor: '#FFFFFF',
        borderRadius: 16,
        padding: 20,
        marginBottom: 12,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.05,
        shadowRadius: 4,
        elevation: 1,
    },
    fila: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: 12,
    },
    nombreCriterio: {
        fontSize: 16,
        fontWeight: '600',
        color: '#0A1931',
    },
    badgePeso: {
        backgroundColor: '#E8F5E9',
        paddingHorizontal: 12,
        paddingVertical: 4,
        borderRadius: 10,
    },
    textoPeso: {
        fontSize: 13,
        fontWeight: 'bold',
        color: '#2E7D32',
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
    botonAgregar: {
        borderWidth: 1.5,
        borderColor: '#0A1931',
        borderStyle: 'dashed',
        borderRadius: 16,
        padding: 16,
        alignItems: 'center',
        marginTop: 8,
    },
    textoAgregar: {
        fontSize: 14,
        fontWeight: 'bold',
        color: '#0A1931',
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
    botonGuardar: {
        paddingVertical: 16,
        borderRadius: 30,
        backgroundColor: '#134E5E',
        alignItems: 'center',
    },
    textoGuardar: {
        fontSize: 16,
        fontWeight: 'bold',
        color: '#FFFFFF',
    },
});

export default RubricBuilderScreen;
