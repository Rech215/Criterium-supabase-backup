/**
 * types.ts
 * Definición de tipos para las rutas de navegación de Criterium.
 * Utiliza @react-navigation/native v6+ con soporte completo de TypeScript.
 */

import type { NativeStackScreenProps } from '@react-navigation/native-stack';

// ─────────────────────────────────────────────
// Pila de Autenticación (Público)
// ─────────────────────────────────────────────
export type AuthStackParamList = {
  /** Pantalla de carga inicial */
  Splash: undefined;
  /** Pantalla de inicio de sesión */
  Login: { redirigirA?: string } | undefined;
};

// ─────────────────────────────────────────────
// Pila del Maestro (Privado - Rol: 'teacher')
// ─────────────────────────────────────────────
export type TeacherStackParamList = {
  /** Panel principal del maestro */
  TeacherDashboard: undefined;
  /** Lista de entregas/alumnos de una tarea */
  AssignmentSubmissions: undefined;
  /** Vista dividida para calificación */
  SplitViewGrading: {
    studentId: string;
    studentName: string;
  };
  /** Confirmación de calificación enviada */
  TeacherSuccess: undefined;
  /** Formulario para crear nueva tarea */
  CreateAssignment: undefined;
  /** Configuración de rúbrica */
  RubricBuilder: undefined;
  /** Perfil del maestro */
  TeacherProfile: undefined;
};

// ─────────────────────────────────────────────
// Pila del Alumno (Privado - Rol: 'student')
// ─────────────────────────────────────────────
export type StudentStackParamList = {
  /** Lista de compañeros para evaluación entre pares */
  PeerEvaluationList: undefined;
  /** Confirmación de evaluación enviada */
  StudentSuccess: undefined;
};

// ─────────────────────────────────────────────
// Props tipados para cada pantalla
// Uso: const MiPantalla: React.FC<AuthScreenProps<'Login'>> = ({ navigation, route }) => { ... }
// ─────────────────────────────────────────────
export type AuthScreenProps<T extends keyof AuthStackParamList> =
  NativeStackScreenProps<AuthStackParamList, T>;

export type TeacherScreenProps<T extends keyof TeacherStackParamList> =
  NativeStackScreenProps<TeacherStackParamList, T>;

export type StudentScreenProps<T extends keyof StudentStackParamList> =
  NativeStackScreenProps<StudentStackParamList, T>;
