/**
 * SplitViewGradingScreen.tsx
 * Vista dividida para calificar la entrega de un alumno.
 *
 * CONEXIONES:
 *   - Botón "Publicar Nota"    → navigation.navigate('TeacherSuccess')
 *   - Botón "Cancelar/Atrás"   → navigation.goBack() (Vuelve a la LISTA, NO al dashboard)
 */

import React, { useState } from 'react';
import {
    View,
    Text,
    TouchableOpacity,
    StyleSheet,
    ScrollView,
} from 'react-native';
import type { TeacherScreenProps } from '../navigation/types';

const SplitViewGradingScreen: React.FC<TeacherScreenProps<'SplitViewGrading'>> = ({
    navigation,
    route,
}) => {
    // Parámetros recibidos de la pantalla anterior
    const { studentId, studentName } = route.params;
    const [calificacion, setCalificacion] = useState(85);

    return (
        <View style={estilos.contenedor}>
            <ScrollView style={estilos.cuerpo}>
                {/* Información del alumno */}
                <View style={estilos.headerAlumno}>
                    <View style={estilos.avatar}>
                        <Text style={estilos.avatarTexto}>{studentName.charAt(0)}</Text>
                    </View>
                    <View style={estilos.infoAlumno}>
                        <Text style={estilos.nombreAlumno}>{studentName}</Text>
                        <Text style={estilos.idAlumno}>ID: {studentId}</Text>
                    </View>
                </View>

                {/* Sección de calificación */}
                <View style={estilos.seccionCalificacion}>
                    <Text style={estilos.etiquetaSeccion}>CALIFICACIÓN</Text>
                    <Text style={estilos.calificacionGrande}>{calificacion}/100</Text>

                    {/* Criterios de rúbrica simulados */}
                    <View style={estilos.criterio}>
                        <Text style={estilos.critNombre}>Funcionalidad</Text>
                        <Text style={estilos.critValor}>25/30</Text>
                    </View>
                    <View style={estilos.criterio}>
                        <Text style={estilos.critNombre}>Diseño</Text>
                        <Text style={estilos.critValor}>20/25</Text>
                    </View>
                    <View style={estilos.criterio}>
                        <Text style={estilos.critNombre}>Código Limpio</Text>
                        <Text style={estilos.critValor}>22/25</Text>
                    </View>
                    <View style={estilos.criterio}>
                        <Text style={estilos.critNombre}>Documentación</Text>
                        <Text style={estilos.critValor}>18/20</Text>
                    </View>
                </View>
            </ScrollView>

            {/* ── Botones de acción ── */}
            <View style={estilos.barraAcciones}>
                {/* Botón Cancelar → goBack() → Vuelve a AssignmentSubmissions (la LISTA) */}
                <TouchableOpacity
                    style={estilos.botonCancelar}
                    onPress={() => navigation.goBack()}
                >
                    <Text style={estilos.textoCancelar}>Cancelar</Text>
                </TouchableOpacity>

                {/* Botón Publicar Nota → Navega a la pantalla de éxito */}
                <TouchableOpacity
                    style={estilos.botonPublicar}
                    onPress={() => navigation.navigate('TeacherSuccess')}
                    activeOpacity={0.8}
                >
                    <Text style={estilos.textoPublicar}>Publicar Nota</Text>
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
    headerAlumno: {
        flexDirection: 'row',
        alignItems: 'center',
        marginBottom: 24,
    },
    avatar: {
        width: 56,
        height: 56,
        borderRadius: 28,
        backgroundColor: '#0A1931',
        justifyContent: 'center',
        alignItems: 'center',
    },
    avatarTexto: {
        color: '#FFFFFF',
        fontWeight: 'bold',
        fontSize: 20,
    },
    infoAlumno: {
        marginLeft: 16,
    },
    nombreAlumno: {
        fontSize: 20,
        fontWeight: 'bold',
        color: '#0A1931',
    },
    idAlumno: {
        fontSize: 13,
        color: '#999999',
        marginTop: 2,
    },
    seccionCalificacion: {
        backgroundColor: '#FFFFFF',
        borderRadius: 20,
        padding: 24,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.05,
        shadowRadius: 8,
        elevation: 2,
    },
    etiquetaSeccion: {
        fontSize: 10,
        fontWeight: 'bold',
        color: '#999999',
        letterSpacing: 1,
    },
    calificacionGrande: {
        fontSize: 48,
        fontWeight: 'bold',
        color: '#2ECC71',
        marginTop: 8,
        marginBottom: 24,
    },
    criterio: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        paddingVertical: 12,
        borderBottomWidth: 1,
        borderBottomColor: '#F1F3F5',
    },
    critNombre: {
        fontSize: 15,
        color: '#0A1931',
    },
    critValor: {
        fontSize: 15,
        fontWeight: 'bold',
        color: '#0A1931',
    },
    barraAcciones: {
        flexDirection: 'row',
        padding: 24,
        backgroundColor: '#FFFFFF',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: -4 },
        shadowOpacity: 0.05,
        shadowRadius: 8,
        elevation: 4,
    },
    botonCancelar: {
        flex: 1,
        paddingVertical: 16,
        borderRadius: 30,
        borderWidth: 1,
        borderColor: '#CCCCCC',
        marginRight: 12,
        alignItems: 'center',
    },
    textoCancelar: {
        fontSize: 16,
        fontWeight: 'bold',
        color: '#0A1931',
    },
    botonPublicar: {
        flex: 2,
        paddingVertical: 16,
        borderRadius: 30,
        backgroundColor: '#134E5E',
        alignItems: 'center',
    },
    textoPublicar: {
        fontSize: 16,
        fontWeight: 'bold',
        color: '#FFFFFF',
    },
});

export default SplitViewGradingScreen;
