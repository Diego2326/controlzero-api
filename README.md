# ControlZero API

Backend del sistema de control de alcoholemia laboral. Este repositorio concentra la API, la persistencia en base de datos y la integración con servicios externos necesarios para soportar la plataforma web administrativa y la app Android usada por encargados en campo.

## Objetivo del backend

El backend debe cubrir estas responsabilidades:

- Autenticación y autorización con JWT y validación de identidad proveniente de Firebase.
- Gestión de empleados, usuarios del sistema, roles y grupos de trabajo.
- Registro de jornadas y pruebas de alcoholemia.
- Persistencia de evidencia fotográfica y metadatos asociados a cada prueba.
- Exposición de APIs para web administrativa, app móvil y futuras integraciones.
- Auditoría, historial, reportes y validaciones operativas.

El backend no controla directamente BLE ni reconocimiento facial en el dispositivo. Esas capacidades viven principalmente en la app Android o en servicios especializados, pero la API sí debe recibir, validar y almacenar sus resultados.

## Estado actual del proyecto

Actualmente el proyecto está en fase base de arranque:

- Stack montado con Spring Boot 4 + Kotlin + Gradle.
- Dependencias listas para JPA, Flyway, Security, Swagger/OpenAPI y Firebase Admin.
- MariaDB disponible vía Docker Compose.
- Aplicación mínima levantando en el puerto `7070`.
- Aún no existen módulos funcionales, entidades, migraciones ni configuración de seguridad implementada.

Este `README` documenta tanto lo que ya existe como la forma en que el equipo debe evolucionar el backend.

## Stack técnico

- Java 21
- Kotlin 2.2
- Spring Boot 4.0.5
- Spring Web MVC
- Spring Data JPA
- Spring Security
- Flyway
- MariaDB
- springdoc OpenAPI / Swagger UI
- Firebase Admin SDK
- Docker Compose

## Estructura actual

```text
.
├── build.gradle.kts
├── compose.yaml
├── src
│   ├── main
│   │   ├── kotlin/com/controlzero/api
│   │   └── resources/application.properties
│   └── test
│       └── kotlin/com/controlzero/api
```

Estructura recomendada a medida que crezca el proyecto:

```text
src/main/kotlin/com/controlzero/api
├── config
├── security
├── auth
├── employee
├── user
├── group
├── shift
├── alcoholtest
├── report
├── audit
├── common
└── integration

src/main/resources
├── application.properties
├── application-local.properties
└── db/migration
```

## Requisitos para desarrollo local

- JDK 21
- Docker y Docker Compose
- Acceso a una cuenta/proyecto de Firebase cuando se implemente autenticación real

## Configuración local

### 1. Levantar la base de datos

El repositorio incluye `compose.yaml` con MariaDB.

```bash
docker compose up -d mariadb
```

Configuración actual del contenedor:

- Host: `localhost`
- Puerto: `3307`
- Database: `controlzero-db`
- User: `controlzero-api`
- Password: `control0`
- Root password: `control0`

Para detener la base:

```bash
docker compose stop mariadb
```

Para eliminar el contenedor:

```bash
docker compose down
```

### 2. Configurar propiedades de la aplicación

Hoy `src/main/resources/application.properties` solo define:

```properties
spring.application.name=controlzero-api
server.port=7070
```

El equipo debe completar una configuración local como esta en `application-local.properties` o mediante variables de entorno:

```properties
spring.datasource.url=jdbc:mariadb://localhost:3307/controlzero-db
spring.datasource.username=controlzero-api
spring.datasource.password=control0
spring.datasource.driver-class-name=org.mariadb.jdbc.Driver

spring.jpa.hibernate.ddl-auto=validate
spring.jpa.open-in-view=false
spring.jpa.properties.hibernate.format_sql=true

spring.flyway.enabled=true
spring.flyway.locations=classpath:db/migration

logging.level.org.flywaydb=info
logging.level.org.springframework.security=info
```

Convención recomendada:

- `application.properties`: defaults compartidos y seguros.
- `application-local.properties`: configuración local del desarrollador.
- Secretos sensibles: variables de entorno o gestor de secretos, nunca en git.

### 3. Ejecutar la API

```bash
./gradlew bootRun
```

La aplicación arranca en:

- API base: `http://localhost:7070`
- Health check esperado: `http://localhost:7070/actuator/health`

## Swagger / OpenAPI

El proyecto ya incluye `springdoc-openapi-starter-webmvc-ui`, por lo que la documentación interactiva debe exponerse cuando existan controladores y la seguridad la permita.

URLs esperadas en local:

- Swagger UI: `http://localhost:7070/swagger-ui/index.html`
- OpenAPI JSON: `http://localhost:7070/v3/api-docs`

Uso recomendado:

1. Levantar la base de datos.
2. Arrancar la API con `./gradlew bootRun`.
3. Abrir Swagger UI.
4. Probar endpoints desde la interfaz.
5. Cuando exista seguridad JWT, configurar el botón `Authorize` en Swagger para enviar el bearer token.

Convenciones para documentar endpoints:

- Usar nombres de operaciones claros y alineados al dominio.
- Documentar códigos `200`, `201`, `400`, `401`, `403`, `404`, `409` y `422` cuando aplique.
- Separar DTOs de request/response de las entidades JPA.
- Incluir ejemplos para flujos críticos: login, empleados, grupos, jornadas y pruebas.

## Flyway

Flyway es el mecanismo oficial para versionar cambios de base de datos. No se deben crear tablas manualmente fuera de migraciones.

### Ubicación de migraciones

Crear scripts SQL en:

```text
src/main/resources/db/migration
```

### Convención de nombres

```text
V1__initial_schema.sql
V2__create_employee_table.sql
V3__create_system_user_table.sql
```

Reglas:

- Una migración por cambio coherente.
- No modificar una migración ya ejecutada en otros entornos.
- Si hay que corregir algo, crear una nueva versión.
- Usar nombres descriptivos.

### Flujo de trabajo con Flyway

1. Crear o actualizar el modelo de dominio.
2. Escribir la migración SQL correspondiente.
3. Levantar MariaDB.
4. Ejecutar la aplicación.
5. Verificar que Flyway aplique la migración al iniciar.
6. Confirmar que JPA valida el esquema sin errores.

### Buenas prácticas

- Usar `spring.jpa.hibernate.ddl-auto=validate`, no `update`.
- Las restricciones de negocio críticas deben existir también en base de datos.
- Crear índices para búsquedas operativas y reportes.
- Versionar datos semilla solo cuando sean parte del sistema base.

## Modelo funcional que debe soportar la API

### 1. Autenticación y acceso

- Login con Firebase/Google y correo/contraseña.
- Validación de JWT.
- Roles: `ADMIN` y `MANAGER` o `ENCARGADO`.
- Asociación entre usuario del sistema y empleado.
- Activación y desactivación de acceso.

### 2. Gestión de personal

- CRUD de empleados.
- Estado activo/inactivo.
- Foto de referencia.
- Fecha de ingreso.
- Búsqueda por nombre y estado.

### 3. Usuarios del sistema

- Empleados con acceso al sistema.
- Relación con `firebase_uid`.
- Rol y estado.

### 4. Grupos de trabajo

- Grupo con nombre.
- Encargado asignado.
- Entre 2 y 5 integrantes.
- Validaciones de reasignación.

### 5. Jornadas

- Inicio y fin de jornada por grupo.
- Estado de jornada.
- Validación de cumplimiento de pruebas.

### 6. Pruebas de alcoholemia

- Empleado evaluado.
- Grupo.
- Encargado.
- Tipo de jornada: inicio o fin.
- Resultado numérico o categórico.
- Fecha y hora.
- Foto/evidencia.
- Identificador del dispositivo si aplica.

### 7. Evidencia y biometría

- URL de imagen capturada.
- Metadatos de evidencia.
- Resultado de validación facial cuando exista.
- Embeddings o referencias biométricas solo si el alcance final lo confirma.

### 8. Historial, reportes y auditoría

- Consulta por fecha, grupo, empleado, encargado y resultado.
- Exportación posterior a Excel/PDF.
- Registro de acciones del sistema.
- Trazabilidad por usuario, fecha e IP.

## Entidades sugeridas

Estas tablas o agregados son una buena base inicial:

- `employees`
- `system_users`
- `roles`
- `work_groups`
- `work_group_members`
- `shifts`
- `alcohol_tests`
- `test_evidences`
- `audit_logs`
- `alerts`

Catálogos o enums recomendados:

- `employee_status`
- `user_status`
- `group_status`
- `shift_type`
- `shift_status`
- `test_result_status`

## Contratos e integraciones

### Web administrativa

Debe consumir APIs para:

- Empleados
- Usuarios del sistema
- Grupos
- Historial
- Reportes
- Auditoría

### App Android

Debe consumir APIs para:

- Login validado con Firebase
- Consulta de grupo asignado
- Inicio/fin de jornada
- Registro de pruebas
- Carga de evidencia
- Consulta de estado de operaciones

### Firebase

Uso esperado del backend:

- Verificar tokens emitidos por Firebase.
- Obtener o mapear `uid` del usuario autenticado.
- Integrar almacenamiento de imágenes si se usa Firebase Storage.

Variables de entorno recomendadas cuando se implemente:

- `FIREBASE_PROJECT_ID`
- `FIREBASE_STORAGE_BUCKET`
- `GOOGLE_APPLICATION_CREDENTIALS`

## Seguridad

Lineamientos para implementación:

- Toda ruta salvo health y documentación técnica controlada debe requerir autenticación.
- Los roles deben validarse tanto en controladores como en servicios críticos.
- No confiar en datos de rol enviados por frontend.
- Centralizar manejo de JWT/Firebase en `security` e `integration/firebase`.
- Registrar accesos, denegaciones y operaciones sensibles.

## Flujo de trabajo del equipo

### Ramas

Convención sugerida:

- `main`: rama estable
- `develop`: integración de desarrollo
- `feature/<nombre>`
- `fix/<nombre>`

### Desarrollo

1. Levantar MariaDB con Docker Compose.
2. Crear migración Flyway antes o junto con el cambio de modelo.
3. Implementar entidades, repositorios, servicios y controladores.
4. Documentar endpoints en Swagger.
5. Escribir pruebas.
6. Validar arranque local y migraciones.

### Pull requests

Cada PR debería incluir:

- Qué módulo funcional cubre.
- Cambios de base de datos introducidos.
- Endpoints agregados o modificados.
- Riesgos o impactos.
- Evidencia de pruebas.

## Pruebas

Comando base:

```bash
./gradlew test
```

Se recomienda cubrir:

- Tests de contexto y configuración.
- Tests de servicios con reglas de negocio.
- Tests de controladores.
- Tests de seguridad.
- Tests de integración con base de datos y Flyway.

Casos críticos:

- Límite de 2 a 5 integrantes por grupo.
- Inicio y fin de jornada con validación completa.
- Restricción por roles.
- Registro obligatorio de foto y resultado.
- Asociación correcta de prueba, grupo, empleado y encargado.

## Convenciones de implementación

- No exponer entidades JPA directamente en la API.
- Separar capas: controller, service, repository, domain/dto.
- Validar negocio en servicios y restricciones importantes en DB.
- Mantener nombres de tablas y columnas consistentes en inglés o español, pero no mezclar sin criterio. Recomendado: inglés técnico para persistencia.
- Los timestamps deben almacenarse en UTC.
- Los archivos o URLs de evidencia deben ser trazables a una prueba.

## Pendientes técnicos prioritarios

El repositorio todavía necesita, como mínimo:

- Configuración de datasource y perfiles.
- Primer esquema Flyway.
- Configuración real de Spring Security.
- Integración con Firebase Admin.
- Primeros módulos: empleados, usuarios, grupos y jornadas.
- Manejo global de errores.
- DTOs y validaciones.
- Auditoría básica.
- Seeds iniciales para roles.

## Comandos útiles

```bash
docker compose up -d mariadb
docker compose stop mariadb
./gradlew bootRun
./gradlew test
./gradlew clean build
```

## Referencia rápida

- Puerto de la API: `7070`
- Puerto de MariaDB local: `3307`
- Swagger UI: `/swagger-ui/index.html`
- OpenAPI JSON: `/v3/api-docs`
- Migraciones Flyway: `src/main/resources/db/migration`

## Nota para el equipo

Este proyecto todavía está en etapa de base técnica. Antes de construir funcionalidades de alto nivel, conviene cerrar el foundation del backend en este orden:

1. Seguridad y autenticación.
2. Esquema base de base de datos con Flyway.
3. Módulos de empleados, usuarios y grupos.
4. Jornadas y pruebas de alcoholemia.
5. Historial, auditoría y reportes.

Si se modifica la arquitectura o se definen nuevos entornos, este `README` debe actualizarse en el mismo PR.
