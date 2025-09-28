import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Inicializar Firebase Admin SDK
admin.initializeApp();

const db = admin.firestore();

// Interfaz para datos de empleado
interface EmployeeData {
  employeeCode: string;
  cedula: string;
  name: string;
  email: string;
  department: string;
  position: string;
  phone: string;
  isActive: boolean;
}

// Interfaz para datos de usuario
interface UserData {
  email: string;
  name: string;
  role: string;
  department: string;
}

/**
 * Función para autenticar usuarios con código de empleado y cédula
 * Esta función verifica las credenciales del empleado y retorna información del usuario
 */
export const authenticateEmployee = functions.https.onCall(async (data, context) => {
  try {
    const { employeeCode, cedula } = data;

    // Validar parámetros de entrada
    if (!employeeCode || !cedula) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Código de empleado y cédula son requeridos'
      );
    }

    // Buscar empleado en Firestore
    const employeeQuery = await db
      .collection('employees')
      .where('employeeCode', '==', employeeCode)
      .where('cedula', '==', cedula)
      .where('isActive', '==', true)
      .limit(1)
      .get();

    if (employeeQuery.empty) {
      throw new functions.https.HttpsError(
        'not-found',
        'Empleado no encontrado o credenciales incorrectas'
      );
    }

    const employeeDoc = employeeQuery.docs[0];
    const employeeData = employeeDoc.data() as EmployeeData;

    // Buscar usuario asociado por email
    const userQuery = await db
      .collection('users')
      .where('email', '==', employeeData.email)
      .limit(1)
      .get();

    if (userQuery.empty) {
      throw new functions.https.HttpsError(
        'not-found',
        'Usuario no encontrado en el sistema'
      );
    }

    const userDoc = userQuery.docs[0];
    const userData = userDoc.data() as UserData;

    // Retornar información del usuario (sin datos sensibles)
    return {
      success: true,
      user: {
        id: userDoc.id,
        email: userData.email,
        name: userData.name,
        role: userData.role,
        department: userData.department,
      },
      employee: {
        employeeCode: employeeData.employeeCode,
        position: employeeData.position,
      }
    };

  } catch (error) {
    console.error('Error en authenticateEmployee:', error);
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError(
      'internal',
      'Error interno del servidor'
    );
  }
});

/**
 * Función para verificar si un código de empleado existe
 */
export const verifyEmployeeCode = functions.https.onCall(async (data, context) => {
  try {
    const { employeeCode } = data;

    if (!employeeCode) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Código de empleado es requerido'
      );
    }

    const employeeQuery = await db
      .collection('employees')
      .where('employeeCode', '==', employeeCode)
      .where('isActive', '==', true)
      .limit(1)
      .get();

    return {
      exists: !employeeQuery.empty,
      employeeCode: employeeCode
    };

  } catch (error) {
    console.error('Error en verifyEmployeeCode:', error);
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError(
      'internal',
      'Error interno del servidor'
    );
  }
});

/**
 * Función para obtener información de un empleado por código
 */
export const getEmployeeByCode = functions.https.onCall(async (data, context) => {
  try {
    const { employeeCode } = data;

    if (!employeeCode) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Código de empleado es requerido'
      );
    }

    const employeeQuery = await db
      .collection('employees')
      .where('employeeCode', '==', employeeCode)
      .where('isActive', '==', true)
      .limit(1)
      .get();

    if (employeeQuery.empty) {
      throw new functions.https.HttpsError(
        'not-found',
        'Empleado no encontrado'
      );
    }

    const employeeDoc = employeeQuery.docs[0];
    const employeeData = employeeDoc.data() as EmployeeData;

    // Retornar información básica del empleado (sin datos sensibles)
    return {
      success: true,
      employee: {
        id: employeeDoc.id,
        employeeCode: employeeData.employeeCode,
        name: employeeData.name,
        department: employeeData.department,
        position: employeeData.position,
        isActive: employeeData.isActive,
      }
    };

  } catch (error) {
    console.error('Error en getEmployeeByCode:', error);
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError(
      'internal',
      'Error interno del servidor'
    );
  }
});

/**
 * Función para crear un nuevo empleado (solo administradores)
 */
export const createEmployee = functions.https.onCall(async (data, context) => {
  try {
    // Verificar autenticación
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Usuario no autenticado'
      );
    }

    const { employeeData } = data;

    if (!employeeData) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Datos del empleado son requeridos'
      );
    }

    // Verificar si el usuario es administrador
    const userDoc = await db.collection('users').doc(context.auth.uid).get();
    const userData = userDoc.data() as UserData;

    if (!userData || userData.role !== 'admin') {
      throw new functions.https.HttpsError(
        'permission-denied',
        'Solo los administradores pueden crear empleados'
      );
    }

    // Verificar que el código de empleado no exista
    const existingEmployeeQuery = await db
      .collection('employees')
      .where('employeeCode', '==', employeeData.employeeCode)
      .limit(1)
      .get();

    if (!existingEmployeeQuery.empty) {
      throw new functions.https.HttpsError(
        'already-exists',
        'El código de empleado ya existe'
      );
    }

    // Verificar que la cédula no exista
    const existingCedulaQuery = await db
      .collection('employees')
      .where('cedula', '==', employeeData.cedula)
      .limit(1)
      .get();

    if (!existingCedulaQuery.empty) {
      throw new functions.https.HttpsError(
        'already-exists',
        'La cédula ya existe'
      );
    }

    // Crear empleado
    const employeeRef = await db.collection('employees').add({
      ...employeeData,
      isActive: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      createdBy: context.auth.uid,
    });

    return {
      success: true,
      employeeId: employeeRef.id,
      message: 'Empleado creado exitosamente'
    };

  } catch (error) {
    console.error('Error en createEmployee:', error);
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError(
      'internal',
      'Error interno del servidor'
    );
  }
});

/**
 * Función para actualizar información de un empleado (solo administradores)
 */
export const updateEmployee = functions.https.onCall(async (data, context) => {
  try {
    // Verificar autenticación
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Usuario no autenticado'
      );
    }

    const { employeeId, employeeData } = data;

    if (!employeeId || !employeeData) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'ID del empleado y datos son requeridos'
      );
    }

    // Verificar si el usuario es administrador
    const userDoc = await db.collection('users').doc(context.auth.uid).get();
    const userData = userDoc.data() as UserData;

    if (!userData || userData.role !== 'admin') {
      throw new functions.https.HttpsError(
        'permission-denied',
        'Solo los administradores pueden actualizar empleados'
      );
    }

    // Verificar que el empleado existe
    const employeeDoc = await db.collection('employees').doc(employeeId).get();
    if (!employeeDoc.exists) {
      throw new functions.https.HttpsError(
        'not-found',
        'Empleado no encontrado'
      );
    }

    // Actualizar empleado
    await db.collection('employees').doc(employeeId).update({
      ...employeeData,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: context.auth.uid,
    });

    return {
      success: true,
      message: 'Empleado actualizado exitosamente'
    };

  } catch (error) {
    console.error('Error en updateEmployee:', error);
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError(
      'internal',
      'Error interno del servidor'
    );
  }
});

/**
 * Función para desactivar un empleado (solo administradores)
 */
export const deactivateEmployee = functions.https.onCall(async (data, context) => {
  try {
    // Verificar autenticación
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Usuario no autenticado'
      );
    }

    const { employeeId } = data;

    if (!employeeId) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'ID del empleado es requerido'
      );
    }

    // Verificar si el usuario es administrador
    const userDoc = await db.collection('users').doc(context.auth.uid).get();
    const userData = userDoc.data() as UserData;

    if (!userData || userData.role !== 'admin') {
      throw new functions.https.HttpsError(
        'permission-denied',
        'Solo los administradores pueden desactivar empleados'
      );
    }

    // Verificar que el empleado existe
    const employeeDoc = await db.collection('employees').doc(employeeId).get();
    if (!employeeDoc.exists) {
      throw new functions.https.HttpsError(
        'not-found',
        'Empleado no encontrado'
      );
    }

    // Desactivar empleado
    await db.collection('employees').doc(employeeId).update({
      isActive: false,
      deactivatedAt: admin.firestore.FieldValue.serverTimestamp(),
      deactivatedBy: context.auth.uid,
    });

    return {
      success: true,
      message: 'Empleado desactivado exitosamente'
    };

  } catch (error) {
    console.error('Error en deactivateEmployee:', error);
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError(
      'internal',
      'Error interno del servidor'
    );
  }
});

/**
 * Función para obtener lista de empleados (solo administradores)
 */
export const getEmployees = functions.https.onCall(async (data, context) => {
  try {
    // Verificar autenticación
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Usuario no autenticado'
      );
    }

    // Verificar si el usuario es administrador
    const userDoc = await db.collection('users').doc(context.auth.uid).get();
    const userData = userDoc.data() as UserData;

    if (!userData || userData.role !== 'admin') {
      throw new functions.https.HttpsError(
        'permission-denied',
        'Solo los administradores pueden ver la lista de empleados'
      );
    }

    const { department, limit = 50 } = data;

    let query = db.collection('employees').orderBy('name');

    if (department) {
      query = query.where('department', '==', department);
    }

    const employeesQuery = await query.limit(limit).get();

    const employees = employeesQuery.docs.map(doc => {
      const data = doc.data() as EmployeeData;
      return {
        id: doc.id,
        employeeCode: data.employeeCode,
        name: data.name,
        email: data.email,
        department: data.department,
        position: data.position,
        isActive: data.isActive,
      };
    });

    return {
      success: true,
      employees: employees,
      total: employees.length
    };

  } catch (error) {
    console.error('Error en getEmployees:', error);
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError(
      'internal',
      'Error interno del servidor'
    );
  }
});
