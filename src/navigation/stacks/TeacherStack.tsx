/**
 * TeacherStack.tsx
 * Pila de navegación privada para el rol de Maestro.
 * Contiene todas las pantallas del flujo docente.
 */

import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { TeacherStackParamList } from '../types';

// Pantallas del Maestro
import TeacherDashboardScreen from '../../screens/TeacherDashboardScreen';
import AssignmentSubmissionsScreen from '../../screens/AssignmentSubmissionsScreen';
import SplitViewGradingScreen from '../../screens/SplitViewGradingScreen';
import TeacherSuccessScreen from '../../screens/TeacherSuccessScreen';
import CreateAssignmentScreen from '../../screens/CreateAssignmentScreen';
import RubricBuilderScreen from '../../screens/RubricBuilderScreen';
import TeacherProfileScreen from '../../screens/TeacherProfileScreen';

const Stack = createNativeStackNavigator<TeacherStackParamList>();

// Color principal de la app (azul marino)
const AZUL_MARINO = '#0A1931';

/**
 * Pila del Maestro.
 * Se monta cuando: userToken existe Y userRole === 'teacher'.
 * Pantalla inicial: TeacherDashboard.
 */
const TeacherStack: React.FC = () => {
    return (
        <Stack.Navigator
            initialRouteName="TeacherDashboard"
            screenOptions={{
                headerStyle: { backgroundColor: '#FFFFFF' },
                headerTintColor: AZUL_MARINO,
                headerTitleStyle: { fontWeight: 'bold' },
                animation: 'slide_from_right',
            }}
        >
            {/* Panel Principal del Maestro */}
            <Stack.Screen
                name="TeacherDashboard"
                component={TeacherDashboardScreen}
                options={{
                    title: 'Mi Panel',
                    headerShown: false, // El dashboard tiene su propio header personalizado
                }}
            />

            {/* Lista de Entregas / Alumnos */}
            <Stack.Screen
                name="AssignmentSubmissions"
                component={AssignmentSubmissionsScreen}
                options={{
                    title: 'Entregas de Alumnos',
                    // El botón "Atrás" regresa al Dashboard automáticamente
                }}
            />

            {/* Vista Dividida de Calificación */}
            <Stack.Screen
                name="SplitViewGrading"
                component={SplitViewGradingScreen}
                options={{
                    title: 'Calificar Entrega',
                }}
            />

            {/* Confirmación de Calificación Enviada */}
            <Stack.Screen
                name="TeacherSuccess"
                component={TeacherSuccessScreen}
                options={{
                    title: '¡Calificación Enviada!',
                    headerShown: false, // Pantalla de éxito sin header
                    // Evitar que el usuario regrese con gesto/botón atrás
                    gestureEnabled: false,
                }}
            />

            {/* Formulario de Nueva Tarea */}
            <Stack.Screen
                name="CreateAssignment"
                component={CreateAssignmentScreen}
                options={{
                    title: 'Nueva Tarea',
                }}
            />

            {/* Configurador de Rúbrica */}
            <Stack.Screen
                name="RubricBuilder"
                component={RubricBuilderScreen}
                options={{
                    title: 'Configurar Rúbrica',
                }}
            />

            {/* Perfil del Maestro */}
            <Stack.Screen
                name="TeacherProfile"
                component={TeacherProfileScreen}
                options={{
                    title: 'Mi Perfil',
                }}
            />
        </Stack.Navigator>
    );
};

export default TeacherStack;
