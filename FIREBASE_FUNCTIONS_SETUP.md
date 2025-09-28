# Configuración de Firebase Functions para Evelyn

Este documento describe cómo configurar y desplegar las Firebase Functions para el microservicio de autenticación de Evelyn.

## Prerrequisitos

1. **Node.js**: Versión 18 o superior
2. **Firebase CLI**: Instalado globalmente
3. **Proyecto Firebase**: Configurado y vinculado

## Instalación

### 1. Instalar Firebase CLI (si no está instalado)

```bash
npm install -g firebase-tools
```

### 2. Iniciar sesión en Firebase

```bash
firebase login
```

### 3. Instalar dependencias de las Functions

```bash
cd functions
npm install
```

### 4. Compilar las Functions

```bash
npm run build
```

## Despliegue

### 1. Desplegar todas las Functions

```bash
firebase deploy --only functions
```

### 2. Desplegar una Function específica

```bash
firebase deploy --only functions:authenticateEmployee
```

### 3. Desplegar con configuración específica

```bash
firebase deploy --only functions --project horariostutorias7mo
```

## Funciones Disponibles

### 1. `authenticateEmployee`

- **Descripción**: Autentica usuarios con código de empleado y cédula
- **Parámetros**: `employeeCode`, `cedula`
- **Retorna**: Información del usuario autenticado

### 2. `verifyEmployeeCode`

- **Descripción**: Verifica si un código de empleado existe
- **Parámetros**: `employeeCode`
- **Retorna**: `exists` (boolean)

### 3. `getEmployeeByCode`

- **Descripción**: Obtiene información de un empleado por código
- **Parámetros**: `employeeCode`
- **Retorna**: Información básica del empleado

### 4. `createEmployee`

- **Descripción**: Crea un nuevo empleado (solo administradores)
- **Parámetros**: `employeeData`
- **Retorna**: ID del empleado creado

### 5. `updateEmployee`

- **Descripción**: Actualiza información de un empleado (solo administradores)
- **Parámetros**: `employeeId`, `employeeData`
- **Retorna**: Confirmación de actualización

### 6. `deactivateEmployee`

- **Descripción**: Desactiva un empleado (solo administradores)
- **Parámetros**: `employeeId`
- **Retorna**: Confirmación de desactivación

### 7. `getEmployees`

- **Descripción**: Obtiene lista de empleados (solo administradores)
- **Parámetros**: `department` (opcional), `limit` (opcional)
- **Retorna**: Lista de empleados

## Desarrollo Local

### 1. Ejecutar emulador local

```bash
firebase emulators:start --only functions
```

### 2. Ejecutar con hot reload

```bash
npm run serve
```

### 3. Ver logs en tiempo real

```bash
firebase functions:log
```

## Estructura de Datos

### Colección `employees`

```json
{
  "employeeCode": "EMP001",
  "cedula": "12345678",
  "name": "Juan Pérez",
  "email": "juan.perez@empresa.com",
  "department": "IT",
  "position": "Desarrollador",
  "phone": "+1234567890",
  "isActive": true,
  "createdAt": "timestamp",
  "createdBy": "admin_uid"
}
```

### Colección `users`

```json
{
  "email": "juan.perez@empresa.com",
  "name": "Juan Pérez",
  "role": "user",
  "department": "IT"
}
```

## Seguridad

### Reglas de Firestore

- Los usuarios solo pueden leer/escribir sus propios datos
- Los administradores tienen acceso completo
- Los empleados activos son visibles para usuarios autenticados

### Autenticación

- Todas las funciones requieren autenticación
- Verificación de roles para operaciones administrativas
- Validación de parámetros de entrada

## Monitoreo

### 1. Ver métricas de las Functions

```bash
firebase functions:log --only authenticateEmployee
```

### 2. Monitorear en Firebase Console

- Ir a Firebase Console > Functions
- Ver métricas, logs y errores

## Troubleshooting

### Error: "Function not found"

- Verificar que la función esté desplegada
- Comprobar el nombre de la función en el código

### Error: "Permission denied"

- Verificar reglas de Firestore
- Comprobar autenticación del usuario
- Verificar roles de administrador

### Error: "Invalid argument"

- Verificar parámetros de entrada
- Comprobar tipos de datos

## Contacto

Para soporte técnico o preguntas sobre la implementación, contactar al equipo de desarrollo.
