/**
 * TeacherDashboardScreen.tsx
 * Panel principal del Maestro.
 *
 * CONEXIONES:
 *   - Card "Ver Clase"  → navigation.navigate('AssignmentSubmissions')
 *   - Botón FAB (+)     → navigation.navigate('CreateAssignment')
 *   - Avatar            → navigation.navigate('TeacherProfile')
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

const TeacherDashboardScreen: React.FC<TeacherScreenProps<'TeacherDashboard'>> = ({
    navigation,
}) => {
    return (
        <View style={estilos.contenedor}>
            {/* ── Header personalizado ── */}
            <View style={estilos.header}>
                <View>
                    <Text style={estilos.saludo}>Hola, Profesor 👋</Text>
                    <Text style={estilos.subtitulo}>Gestiona tus clases de hoy</Text>
                </View>

                {/* ── Avatar → Navega al Perfil del Maestro ── */}
                <TouchableOpacity
                    onPress={() => navigation.navigate('TeacherProfile')}
                    style={estilos.avatar}
                >
                    <Text style={estilos.avatarTexto}>PM</Text>
                </TouchableOpacity>
            </View>

            <ScrollView style={estilos.cuerpo}>
                {/* ── Card de Clase → Navega a la lista de entregas ── */}
                <TouchableOpacity
                    style={estilos.cardClase}
                    onPress={() => navigation.navigate('AssignmentSubmissions')}
                    activeOpacity={0.7}
                >
                    <View style={estilos.cardHeader}>
                        <Text style={estilos.cardTitulo}>Programación Móvil</Text>
                        <View style={estilos.badge}>
                            <Text style={estilos.badgeTexto}>Activa</Text>
                        </View>
                    </View>
                    <Text style={estilos.cardSubtitulo}>Sprint 3 - Entrega Final</Text>
                    <Text style={estilos.cardDetalle}>12 alumnos • 8 entregas pendientes</Text>
                </TouchableOpacity>

                {/* Card adicional de ejemplo */}
                <TouchableOpacity
                    style={[estilos.cardClase, { backgroundColor: '#F0F4FF' }]}
                    onPress={() => navigation.navigate('AssignmentSubmissions')}
                    activeOpacity={0.7}
                >
                    <View style={estilos.cardHeader}>
                        <Text style={estilos.cardTitulo}>Diseño UX/UI</Text>
                        <View style={[estilos.badge, { backgroundColor: '#FFF3E0' }]}>
                            <Text style={[estilos.badgeTexto, { color: '#E65100' }]}>
                                Próxima
                            </Text>
                        </View>
                    </View>
                    <Text style={estilos.cardSubtitulo}>Prototipo en Figma</Text>
                    <Text style={estilos.cardDetalle}>15 alumnos • Fecha límite: Mañana</Text>
                </TouchableOpacity>
            </ScrollView>

            {/* ── Botón FAB (+) → Navega a Crear nueva Tarea ── */}
            <TouchableOpacity
                style={estilos.fab}
                onPress={() => navigation.navigate('CreateAssignment')}
                activeOpacity={0.8}
            >
                <Text style={estilos.fabTexto}>+</Text>
            </TouchableOpacity>
        </View>
    );
};

const estilos = StyleSheet.create({
    contenedor: {
        flex: 1,
        backgroundColor: '#F8F9FA',
    },
    header: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        padding: 24,
        paddingTop: 60,
        backgroundColor: '#FFFFFF',
    },
    saludo: {
        fontSize: 24,
        fontWeight: 'bold',
        color: '#0A1931',
    },
    subtitulo: {
        fontSize: 14,
        color: '#999999',
        marginTop: 4,
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
        fontSize: 16,
    },
    cuerpo: {
        flex: 1,
        padding: 24,
    },
    cardClase: {
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
    cardHeader: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
    },
    cardTitulo: {
        fontSize: 18,
        fontWeight: 'bold',
        color: '#0A1931',
    },
    badge: {
        backgroundColor: '#E8F5E9',
        paddingHorizontal: 12,
        paddingVertical: 4,
        borderRadius: 12,
    },
    badgeTexto: {
        fontSize: 12,
        fontWeight: 'bold',
        color: '#2E7D32',
    },
    cardSubtitulo: {
        fontSize: 14,
        color: '#555555',
        marginTop: 8,
    },
    cardDetalle: {
        fontSize: 12,
        color: '#999999',
        marginTop: 4,
    },
    fab: {
        position: 'absolute',
        bottom: 30,
        right: 24,
        width: 60,
        height: 60,
        borderRadius: 30,
        backgroundColor: '#134E5E',
        justifyContent: 'center',
        alignItems: 'center',
        shadowColor: '#134E5E',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.3,
        shadowRadius: 8,
        elevation: 6,
    },
    fabTexto: {
        fontSize: 28,
        color: '#FFFFFF',
        fontWeight: '300',
    },
});

export default TeacherDashboardScreen;
