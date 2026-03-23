/**
 * CreateAssignmentScreen.tsx
 * Formulario para crear una nueva tarea.
 *
 * CONEXIÓN:
 *   - Botón "Siguiente" → navigation.navigate('RubricBuilder')
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
import type { TeacherScreenProps } from '../navigation/types';

const CreateAssignmentScreen: React.FC<TeacherScreenProps<'CreateAssignment'>> = ({
    navigation,
}) => {
    const [titulo, setTitulo] = useState('');
    const [descripcion, setDescripcion] = useState('');
    const [fechaLimite, setFechaLimite] = useState('');

    return (
        <View style={estilos.contenedor}>
            <ScrollView style={estilos.cuerpo}>
                <Text style={estilos.tituloSeccion}>Información de la Tarea</Text>

                <Text style={estilos.etiqueta}>Título de la tarea</Text>
                <TextInput
                    style={estilos.input}
                    placeholder="Ej: Sprint 3 - Entrega Final"
                    placeholderTextColor="#999999"
                    value={titulo}
                    onChangeText={setTitulo}
                />

                <Text style={estilos.etiqueta}>Descripción</Text>
                <TextInput
                    style={[estilos.input, estilos.inputMultilinea]}
                    placeholder="Instrucciones para los alumnos..."
                    placeholderTextColor="#999999"
                    value={descripcion}
                    onChangeText={setDescripcion}
                    multiline
                    numberOfLines={4}
                    textAlignVertical="top"
                />

                <Text style={estilos.etiqueta}>Fecha límite</Text>
                <TextInput
                    style={estilos.input}
                    placeholder="DD/MM/AAAA"
                    placeholderTextColor="#999999"
                    value={fechaLimite}
                    onChangeText={setFechaLimite}
                />
            </ScrollView>

            {/* ── Botón Siguiente → Navega a configurar la Rúbrica ── */}
            <View style={estilos.barraAccion}>
                <TouchableOpacity
                    style={estilos.botonSiguiente}
                    onPress={() => navigation.navigate('RubricBuilder')}
                    activeOpacity={0.8}
                >
                    <Text style={estilos.textoSiguiente}>Siguiente: Configurar Rúbrica</Text>
                    <Text style={estilos.flechaSiguiente}>→</Text>
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
    tituloSeccion: {
        fontSize: 22,
        fontWeight: 'bold',
        color: '#0A1931',
        marginBottom: 24,
    },
    etiqueta: {
        fontWeight: 'bold',
        color: '#0A1931',
        marginTop: 20,
        marginBottom: 8,
    },
    input: {
        backgroundColor: '#FFFFFF',
        borderWidth: 1,
        borderColor: '#E0E0E0',
        borderRadius: 12,
        padding: 14,
        fontSize: 16,
        color: '#0A1931',
    },
    inputMultilinea: {
        height: 120,
        paddingTop: 14,
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
    botonSiguiente: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        paddingVertical: 16,
        borderRadius: 30,
        backgroundColor: '#134E5E',
    },
    textoSiguiente: {
        fontSize: 16,
        fontWeight: 'bold',
        color: '#FFFFFF',
    },
    flechaSiguiente: {
        fontSize: 18,
        color: '#FFFFFF',
        marginLeft: 8,
    },
});

export default CreateAssignmentScreen;
