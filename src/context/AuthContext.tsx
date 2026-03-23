/**
 * AuthContext.tsx
 * Contexto de autenticación para Criterium.
 * Maneja el estado de sesión (token y rol) usando useReducer.
 * Provee funciones signIn(rol) y signOut() a toda la app.
 */

import React, { createContext, useContext, useReducer, useMemo } from 'react';

// ─────────────────────────────────────────────
// Tipos
// ─────────────────────────────────────────────
type RolUsuario = 'teacher' | 'student';

interface EstadoAuth {
    estaCargando: boolean;
    tokenUsuario: string | null;
    rolUsuario: RolUsuario | null;
}

type AccionAuth =
    | { type: 'RESTAURAR_TOKEN'; token: string | null; rol: RolUsuario | null }
    | { type: 'INICIAR_SESION'; token: string; rol: RolUsuario }
    | { type: 'CERRAR_SESION' };

interface ContextoAuthType {
    /** Token de autenticación actual (null si no ha iniciado sesión) */
    userToken: string | null;
    /** Rol del usuario actual ('teacher' | 'student' | null) */
    userRole: RolUsuario | null;
    /** Indica si se está verificando la sesión al iniciar la app */
    isLoading: boolean;
    /** Inicia sesión con el rol especificado */
    signIn: (rol: RolUsuario) => void;
    /** Cierra la sesión y desmonta el stack privado */
    signOut: () => void;
}

// ─────────────────────────────────────────────
// Reducer
// ─────────────────────────────────────────────
function authReducer(estado: EstadoAuth, accion: AccionAuth): EstadoAuth {
    switch (accion.type) {
        case 'RESTAURAR_TOKEN':
            return {
                ...estado,
                tokenUsuario: accion.token,
                rolUsuario: accion.rol,
                estaCargando: false,
            };
        case 'INICIAR_SESION':
            return {
                ...estado,
                tokenUsuario: accion.token,
                rolUsuario: accion.rol,
                estaCargando: false,
            };
        case 'CERRAR_SESION':
            return {
                ...estado,
                tokenUsuario: null,
                rolUsuario: null,
                estaCargando: false,
            };
        default:
            return estado;
    }
}

// ─────────────────────────────────────────────
// Contexto y Provider
// ─────────────────────────────────────────────
const AuthContext = createContext<ContextoAuthType | undefined>(undefined);

/**
 * Proveedor de autenticación.
 * Envuelve toda la app para dar acceso al estado de sesión.
 *
 * Uso en App.tsx:
 *   <AuthProvider>
 *     <AppNavigator />
 *   </AuthProvider>
 */
export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const [estado, dispatch] = useReducer(authReducer, {
        estaCargando: true,
        tokenUsuario: null,
        rolUsuario: null,
    });

    // Simular verificación de token almacenado al iniciar
    React.useEffect(() => {
        const verificarToken = async () => {
            // TODO: Aquí se recuperaría el token de AsyncStorage/SecureStore
            // Por ahora simulamos que no hay sesión guardada
            await new Promise((resolve) => setTimeout(resolve, 1500));
            dispatch({ type: 'RESTAURAR_TOKEN', token: null, rol: null });
        };
        verificarToken();
    }, []);

    // Memorizar las acciones para evitar re-renders innecesarios
    const accionesAuth = useMemo(
        () => ({
            /**
             * Inicia sesión con el rol proporcionado.
             * Esto causa que el AppNavigator monte el stack correspondiente.
             * @param rol - 'teacher' para maestro, 'student' para alumno
             */
            signIn: (rol: RolUsuario) => {
                // TODO: Aquí iría la lógica real de autenticación (API call)
                // Por ahora generamos un token ficticio
                const tokenFicticio = `token_${rol}_${Date.now()}`;
                dispatch({ type: 'INICIAR_SESION', token: tokenFicticio, rol });
            },

            /**
             * Cierra la sesión del usuario.
             * Esto desmonta el stack privado y muestra el AuthStack (Login).
             */
            signOut: () => {
                // TODO: Aquí se eliminaría el token de AsyncStorage/SecureStore
                dispatch({ type: 'CERRAR_SESION' });
            },
        }),
        [],
    );

    const valorContexto: ContextoAuthType = {
        userToken: estado.tokenUsuario,
        userRole: estado.rolUsuario,
        isLoading: estado.estaCargando,
        ...accionesAuth,
    };

    return (
        <AuthContext.Provider value={valorContexto}>
            {children}
        </AuthContext.Provider>
    );
};

/**
 * Hook para acceder al contexto de autenticación.
 *
 * Uso:
 *   const { signIn, signOut, userToken, userRole } = useAuth();
 */
export const useAuth = (): ContextoAuthType => {
    const contexto = useContext(AuthContext);
    if (!contexto) {
        throw new Error('useAuth debe usarse dentro de un <AuthProvider>');
    }
    return contexto;
};
