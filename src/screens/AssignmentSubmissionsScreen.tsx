/**
 * AssignmentSubmissionsScreen.tsx
 * Lista de alumnos que han entregado una tarea.
 *
 * CONEXIONES:
 *   - Al seleccionar alumno → navigation.navigate('SplitViewGrading', { studentId, studentName })
 *   - Botón Atrás (Header Back) → Regresa al Dashboard automáticamente
 */

import React from 'react';
import {
    View,
    Text,
    TouchableOpacity,
    StyleSheet,
    FlatList,
} from 'react-native';
import type { TeacherScreenProps } from '../navigation/types';

// Datos simulados de alumnos
const ALUMNOS_EJEMPLO = [
    { id: '1', nombre: 'Andrea Ruiz', estado: 'Entregado', hora: 'Hace 2h' },
    { id: '2', nombre: 'Carlos Sosa', estado: 'Entregado', hora: 'Hace 4h' },
    { id: '3', nombre: 'Elena Méndez', estado: 'Entregado', hora: 'Hace 5h' },
    { id: '4', nombre: 'Miguel Ángel Torres', estado: 'Pendiente', hora: '—' },
    { id: '5', nombre: 'Sofía Hernández', estado: 'Entregado', hora: 'Hace 1h' },
];

const AssignmentSubmissionsScreen: React.FC<TeacherScreenProps<'AssignmentSubmissions'>> = ({
    navigation,
}) => {
    /**
     * Al seleccionar un alumno → Navegar a SplitViewGrading con sus datos.
     * Nota: Solo permite navegar si el alumno ya entregó.
     */
    const seleccionarAlumno = (studentId: string, studentName: string) => {
        navigation.navigate('SplitViewGrading', {
            studentId,
            studentName,
        });
    };

    const renderizarAlumno = ({ item }: { item: typeof ALUMNOS_EJEMPLO[0] }) => {
        const entregado = item.estado === 'Entregado';

        return (
            <TouchableOpacity
                style={estilos.cardAlumno}
                onPress={() => entregado && seleccionarAlumno(item.id, item.nombre)}
                activeOpacity={entregado ? 0.7 : 1}
                disabled={!entregado}
            >
                {/* Avatar del alumno */}
                <View style={[estilos.avatar, !entregado && estilos.avatarInactivo]}>
                    <Text style={estilos.avatarTexto}>
                        {item.nombre.charAt(0)}
                    </Text>
                </View>

                {/* Información del alumno */}
                <View style={estilos.info}>
                    <Text style={estilos.nombre}>{item.nombre}</Text>
                    <Text style={estilos.hora}>{item.hora}</Text>
                </View>

                {/* Estado de entrega */}
                <View
                    style={[
                        estilos.badgeEstado,
                        entregado ? estilos.badgeEntregado : estilos.badgePendiente,
                    ]}
                >
                    <Text
                        style={[
                            estilos.textoEstado,
                            entregado ? estilos.textoEntregado : estilos.textoPendiente,
                        ]}
                    >
                        {item.estado}
                    </Text>
                </View>
            </TouchableOpacity>
        );
    };

    return (
        <View style={estilos.contenedor}>
            {/* Encabezado informativo */}
            <View style={estilos.encabezado}>
                <Text style={estilos.titulo}>Entregas de Alumnos</Text>
                <Text style={estilos.subtitulo}>
                    Sprint 3 - Entrega Final • {ALUMNOS_EJEMPLO.filter(a => a.estado === 'Entregado').length}/{ALUMNOS_EJEMPLO.length} entregas
                </Text>
            </View>

            {/* Lista de alumnos */}
            <FlatList
                data={ALUMNOS_EJEMPLO}
                keyExtractor={(item) => item.id}
                renderItem={renderizarAlumno}
                contentContainerStyle={estilos.lista}
            />
        </View>
    );
};

const estilos = StyleSheet.create({
    contenedor: {
        flex: 1,
        backgroundColor: '#F8F9FA',
    },
    encabezado: {
        padding: 24,
        paddingBottom: 8,
    },
    titulo: {
        fontSize: 22,
        fontWeight: 'bold',
        color: '#0A1931',
    },
    subtitulo: {
        fontSize: 14,
        color: '#999999',
        marginTop: 4,
    },
    lista: {
        padding: 24,
        paddingTop: 16,
    },
    cardAlumno: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: '#FFFFFF',
        borderRadius: 16,
        padding: 16,
        marginBottom: 12,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.05,
        shadowRadius: 4,
        elevation: 1,
    },
    avatar: {
        width: 44,
        height: 44,
        borderRadius: 22,
        backgroundColor: '#0A1931',
        justifyContent: 'center',
        alignItems: 'center',
    },
    avatarInactivo: {
        backgroundColor: '#CCCCCC',
    },
    avatarTexto: {
        color: '#FFFFFF',
        fontWeight: 'bold',
        fontSize: 16,
    },
    info: {
        flex: 1,
        marginLeft: 16,
    },
    nombre: {
        fontSize: 16,
        fontWeight: '600',
        color: '#0A1931',
    },
    hora: {
        fontSize: 12,
        color: '#999999',
        marginTop: 2,
    },
    badgeEstado: {
        paddingHorizontal: 12,
        paddingVertical: 6,
        borderRadius: 12,
    },
    badgeEntregado: {
        backgroundColor: '#E8F5E9',
    },
    badgePendiente: {
        backgroundColor: '#FFF3E0',
    },
    textoEstado: {
        fontSize: 12,
        fontWeight: 'bold',
    },
    textoEntregado: {
        color: '#2E7D32',
    },
    textoPendiente: {
        color: '#E65100',
    },
});

export default AssignmentSubmissionsScreen;
