import 'package:evelyn/models/employee_model.dart';
import 'package:evelyn/models/employee_schedule_model.dart';
import 'package:evelyn/models/work_day_model.dart';
import 'package:evelyn/services/employee_service.dart';
import 'package:evelyn/services/employee_schedule_service.dart';

class EmployeeDataImporter {
  static final EmployeeService _employeeService = EmployeeService();
  static final EmployeeScheduleService _scheduleService =
      EmployeeScheduleService();

  /// Crear empleados de ejemplo para pruebas
  static Future<void> createSampleEmployees() async {
    print('🏗️ Creando empleados de ejemplo...');

    final sampleEmployees = [
      EmployeeModel(
        employeeId: 'EMP001',
        name: 'Ana García Martínez',
        email: 'ana.garcia@empresa.com',
        department: 'Ventas',
        position: 'Ejecutiva de Ventas',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EmployeeModel(
        employeeId: 'EMP002',
        name: 'Carlos López Rodríguez',
        email: 'carlos.lopez@empresa.com',
        department: 'Sistemas',
        position: 'Desarrollador',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EmployeeModel(
        employeeId: 'EMP003',
        name: 'María Fernández Silva',
        email: 'maria.fernandez@empresa.com',
        department: 'Recursos Humanos',
        position: 'Coordinadora RRHH',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EmployeeModel(
        employeeId: 'EMP004',
        name: 'José Martín Torres',
        email: 'jose.martin@empresa.com',
        department: 'Operaciones',
        position: 'Supervisor',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EmployeeModel(
        employeeId: 'EMP005',
        name: 'Laura Sánchez Ruiz',
        email: 'laura.sanchez@empresa.com',
        department: 'Finanzas',
        position: 'Analista Financiera',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    final created = await _employeeService.createEmployeesBatch(
      sampleEmployees,
    );
    print('✅ Creados $created empleados de ejemplo');
  }

  /// Crear horarios de ejemplo para los empleados
  static Future<void> createSampleSchedules() async {
    print('📅 Creando horarios de ejemplo...');

    final currentWeek = _scheduleService.getCurrentWeekInfo();
    final weekNumber = currentWeek['weekNumber'] as int;
    final year = currentWeek['year'] as int;

    final schedules = [
      // Ana García - Horario estándar
      EmployeeScheduleModel.standardWorkWeek(
        employeeId: 'EMP001',
        weekNumber: weekNumber,
        year: year,
        startTime: '08:00',
        endTime: '17:00',
      ),

      // Carlos López - Horario de sistemas (entrada tarde)
      EmployeeScheduleModel(
        id: '',
        employeeId: 'EMP002',
        weekNumber: weekNumber,
        year: year,
        monday: WorkDayModel.workDay(startTime: '10:00', endTime: '19:00'),
        tuesday: WorkDayModel.workDay(startTime: '10:00', endTime: '19:00'),
        wednesday: WorkDayModel.workDay(startTime: '10:00', endTime: '19:00'),
        thursday: WorkDayModel.workDay(startTime: '10:00', endTime: '19:00'),
        friday: WorkDayModel.workDay(startTime: '10:00', endTime: '19:00'),
        saturday: WorkDayModel.dayOff(),
        sunday: WorkDayModel.dayOff(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // María Fernández - Horario de medio tiempo
      EmployeeScheduleModel(
        id: '',
        employeeId: 'EMP003',
        weekNumber: weekNumber,
        year: year,
        monday: WorkDayModel.workDay(startTime: '08:00', endTime: '13:00'),
        tuesday: WorkDayModel.workDay(startTime: '08:00', endTime: '13:00'),
        wednesday: WorkDayModel.workDay(startTime: '08:00', endTime: '13:00'),
        thursday: WorkDayModel.workDay(startTime: '08:00', endTime: '13:00'),
        friday: WorkDayModel.workDay(startTime: '08:00', endTime: '13:00'),
        saturday: WorkDayModel.dayOff(),
        sunday: WorkDayModel.dayOff(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // José Martín - Horario con sábados
      EmployeeScheduleModel(
        id: '',
        employeeId: 'EMP004',
        weekNumber: weekNumber,
        year: year,
        monday: WorkDayModel.workDay(startTime: '07:00', endTime: '15:00'),
        tuesday: WorkDayModel.workDay(startTime: '07:00', endTime: '15:00'),
        wednesday: WorkDayModel.workDay(startTime: '07:00', endTime: '15:00'),
        thursday: WorkDayModel.workDay(startTime: '07:00', endTime: '15:00'),
        friday: WorkDayModel.workDay(startTime: '07:00', endTime: '15:00'),
        saturday: WorkDayModel.workDay(startTime: '08:00', endTime: '12:00'),
        sunday: WorkDayModel.dayOff(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // Laura Sánchez - Horario estándar
      EmployeeScheduleModel.standardWorkWeek(
        employeeId: 'EMP005',
        weekNumber: weekNumber,
        year: year,
        startTime: '08:30',
        endTime: '17:30',
      ),
    ];

    final created = await _scheduleService.createSchedulesBatch(schedules);
    print('✅ Creados $created horarios de ejemplo');
  }

  /// Inicializar datos completos de ejemplo
  static Future<void> initializeSampleData() async {
    print('🚀 Inicializando datos de ejemplo...');

    try {
      await createSampleEmployees();
      await createSampleSchedules();
      print('🎉 Datos de ejemplo inicializados correctamente');
    } catch (e) {
      print('❌ Error al inicializar datos de ejemplo: $e');
    }
  }

  /// Crear empleados masivos (simulando importación desde Excel)
  static Future<void> createMassiveEmployees(int count) async {
    print('📊 Creando $count empleados masivos...');

    final departments = [
      'Ventas',
      'Sistemas',
      'RRHH',
      'Operaciones',
      'Finanzas',
      'Marketing',
      'Producción',
    ];
    final positions = [
      'Analista',
      'Coordinador',
      'Supervisor',
      'Especialista',
      'Ejecutivo',
      'Técnico',
    ];
    final names = [
      'Ana',
      'Carlos',
      'María',
      'José',
      'Laura',
      'Pedro',
      'Carmen',
      'Luis',
      'Rosa',
      'Miguel',
    ];
    final lastNames = [
      'García',
      'López',
      'Martínez',
      'González',
      'Rodríguez',
      'Fernández',
      'Sánchez',
      'Pérez',
    ];

    final employees = <EmployeeModel>[];

    for (int i = 1; i <= count; i++) {
      final employeeId = 'EMP${i.toString().padLeft(3, '0')}';
      final name =
          '${names[i % names.length]} ${lastNames[i % lastNames.length]} ${lastNames[(i + 1) % lastNames.length]}';
      final department = departments[i % departments.length];
      final position = positions[i % positions.length];

      employees.add(
        EmployeeModel(
          employeeId: employeeId,
          name: name,
          email: '${name.toLowerCase().replaceAll(' ', '.')}@empresa.com',
          department: department,
          position: position,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }

    final created = await _employeeService.createEmployeesBatch(employees);
    print('✅ Creados $created empleados masivos');
  }

  /// Obtener estadísticas actuales
  static Future<void> printCurrentStats() async {
    print('📊 Estadísticas actuales:');

    final stats = await _employeeService.getEmployeeStats();
    stats.forEach((key, value) {
      print('  • $key: $value');
    });
  }

  /// Validar integridad de datos
  static Future<Map<String, dynamic>> validateDataIntegrity() async {
    print('🔍 Validando integridad de datos...');

    final results = <String, dynamic>{};

    try {
      // Obtener empleados activos
      final employees = await _employeeService.getActiveEmployees();
      results['totalEmployees'] = employees.length;

      // Verificar horarios
      final currentWeek = _scheduleService.getCurrentWeekInfo();
      final schedules = await _scheduleService.getSchedulesForWeek(
        currentWeek['weekNumber'],
        currentWeek['year'],
      );
      results['totalSchedules'] = schedules.length;

      // Empleados sin horario
      final employeesWithoutSchedule = employees.where((emp) {
        return !schedules.any((sch) => sch.employeeId == emp.employeeId);
      }).toList();
      results['employeesWithoutSchedule'] = employeesWithoutSchedule.length;

      // Horarios huérfanos (sin empleado)
      final orphanSchedules = <String>[];
      for (final schedule in schedules) {
        final hasEmployee = employees.any(
          (emp) => emp.employeeId == schedule.employeeId,
        );
        if (!hasEmployee) {
          orphanSchedules.add(schedule.employeeId);
        }
      }
      results['orphanSchedules'] = orphanSchedules.length;

      print('✅ Validación completada:');
      results.forEach((key, value) {
        print('  • $key: $value');
      });
    } catch (e) {
      print('❌ Error en validación: $e');
      results['error'] = e.toString();
    }

    return results;
  }
}
