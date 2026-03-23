/**
 * StudentStack.tsx
 * Pila de navegación privada para el rol de Alumno.
 * Contiene las pantallas de evaluación entre pares.
 */

import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { StudentStackParamList } from '../types';

// Pantallas del Alumno
import PeerEvaluationListScreen from '../../screens/PeerEvaluationListScreen';
import StudentSuccessScreen from '../../screens/StudentSuccessScreen';

const Stack = createNativeStackNavigator<StudentStackParamList>();

// Color principal de la app (azul marino)
const AZUL_MARINO = '#0A1931';

/**
 * Pila del Alumno.
 * Se monta cuando: userToken existe Y userRole === 'student'.
 * Pantalla inicial: PeerEvaluationList.
 */
const StudentStack: React.FC = () => {
    return (
        <Stack.Navigator
            initialRouteName="PeerEvaluationList"
            screenOptions={{
                headerStyle: { backgroundColor: '#FFFFFF' },
                headerTintColor: AZUL_MARINO,
                headerTitleStyle: { fontWeight: 'bold' },
                animation: 'slide_from_right',
            }}
        >
            {/* Lista de Evaluación entre Pares */}
            <Stack.Screen
                name="PeerEvaluationList"
                component={PeerEvaluationListScreen}
                options={{
                    title: 'Evaluación de Compañeros',
                }}
            />

            {/* Confirmación de Evaluación Enviada */}
            <Stack.Screen
                name="StudentSuccess"
                component={StudentSuccessScreen}
                options={{
                    title: '¡Evaluación Enviada!',
                    headerShown: false,
                    // Evitar que el alumno regrese a la evaluación después de enviar
                    gestureEnabled: false,
                }}
            />
        </Stack.Navigator>
    );
};

export default StudentStack;
