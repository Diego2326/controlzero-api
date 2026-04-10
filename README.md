# ControlZero API

Backend del sistema de control de alcoholemia laboral.

Hoy el proyecto expone una API REST con autenticacion JWT, persistencia en MariaDB, migraciones Flyway y documentacion interactiva con Swagger UI.

## Estado actual

- Spring Boot 4.0.5 + Kotlin + Gradle.
- JPA con MariaDB.
- Flyway para esquema y datos semilla.
- Spring Security con JWT stateless.
- Swagger/OpenAPI con soporte `Authorize` para bearer token.
- Modulos activos:
  - `auth`
  - `empleado`
  - `usuario`
  - `rol`
  - `permiso`
  - `auditoria/login`

## Requisitos

- JDK 21
- Docker y Docker Compose

## Estructura

```text
.
├── build.gradle.kts
├── compose.yaml
├── src
│   ├── main
│   │   ├── kotlin/com/controlzero/api
│   │   │   ├── auditoria
│   │   │   ├── auth
│   │   │   ├── config
│   │   │   ├── empleado
│   │   │   ├── permiso
│   │   │   ├── rol
│   │   │   ├── security
│   │   │   └── usuario
│   │   └── resources
│   │       ├── application.properties
│   │       ├── db/migration
│   │       └── static
│   └── test
│       ├── kotlin
│       └── resources
```

## Configuracion local

### Base de datos

El repositorio incluye MariaDB en `compose.yaml`.

```bash
docker compose up -d mariadb
```

Configuracion del contenedor:

- Host: `localhost`
- Puerto: `3307`
- Database: `controlzero-db`
- User: `controlzero-api`
- Password: `control0`

Comandos utiles:

```bash
docker compose stop mariadb
docker compose down
```

### Propiedades actuales

El proyecto ya incluye una configuracion funcional en `src/main/resources/application.properties`:

```properties
server.port=7070

spring.datasource.url=jdbc:mariadb://localhost:3307/controlzero-db
spring.datasource.username=controlzero-api
spring.datasource.password=control0

spring.flyway.enabled=true
spring.jpa.hibernate.ddl-auto=validate

security.jwt.secret=replace-this-secret-with-at-least-32-characters
security.jwt.session-ttl-minutes=30
security.jwt.refresh-ttl-days=7
```

Para entornos reales debes sobreescribir `security.jwt.secret` con un valor propio y seguro.

## Ejecutar en desarrollo

1. Levanta MariaDB:

```bash
docker compose up -d mariadb
```

2. Arranca la API:

```bash
./gradlew bootRun
```

3. URLs principales:

- API base: `http://localhost:7070`
- Health: `http://localhost:7070/actuator/health`
- Swagger UI: `http://localhost:7070/swagger-ui`
- OpenAPI JSON: `http://localhost:7070/v3/api-docs`

## Swagger y autenticacion

Rutas publicas actuales:

- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/refresh`
- `/swagger-ui`
- `/v3/api-docs`
- `/actuator/health`

Todo lo demas requiere JWT en:

```text
Authorization: Bearer <token>
```

Uso recomendado desde Swagger:

1. Ejecuta `POST /api/v1/auth/login`.
2. Copia `sessionToken` de la respuesta.
3. Haz clic en `Authorize`.
4. Pega solo el JWT.

Swagger agrega el prefijo `Bearer` automaticamente.

Nota: hoy los endpoints protegidos exigen un JWT valido, pero todavia no hay reglas finas por rol o permiso en los controladores.

## Datos semilla

Flyway aplica dos migraciones base:

- `V1__crear_tabla_Login_usuarios_y_roles.sql`
- `V2__insertar_empleados_y_usuarios_admin.sql`

La segunda migracion crea:

- Estado de empleado `ACTIVO`
- Puesto `Recursos Humanos`
- Rol `ADMINISTRADOR`
- 5 empleados
- 5 usuarios administrativos

Correos sembrados:

- `ana.lucia@controlzero.local`
- `carlos.andres@controlzero.local`
- `maria.fernanda@controlzero.local`
- `jose.manuel@controlzero.local`
- `luisa.daniela@controlzero.local`

Password por defecto para esas cuentas:

```text
Admin123!
```

## Empaquetado

Para generar el jar ejecutable de Spring Boot:

```bash
./gradlew bootJar
```

Artefacto generado:

```text
build/libs/controlzero-api-0.0.1-SNAPSHOT.jar
```

Ese es el jar que debes ejecutar:

```bash
java -jar build/libs/controlzero-api-0.0.1-SNAPSHOT.jar
```

Gradle tambien genera:

```text
build/libs/controlzero-api-0.0.1-SNAPSHOT-plain.jar
```

El `plain.jar` no incluye dependencias y no es el artefacto recomendado para correr la API.

## Ejecutar el jar con otra configuracion

Si no vas a usar la base local del `compose.yaml`, puedes sobreescribir propiedades al arrancar:

```bash
java -jar build/libs/controlzero-api-0.0.1-SNAPSHOT.jar \
  --spring.datasource.url=jdbc:mariadb://HOST:PUERTO/controlzero-db \
  --spring.datasource.username=controlzero-api \
  --spring.datasource.password=control0 \
  --security.jwt.secret=un-secret-de-al-menos-32-caracteres
```

## Pruebas

Comando base:

```bash
./gradlew test
```

Los tests usan H2 en memoria y no requieren levantar MariaDB local.

## Problemas comunes

### `Task 'shadowJar' not found`

Este proyecto no usa el plugin Shadow. El empaquetado correcto es:

```bash
./gradlew bootJar
```

### `Could not find or load main class`

Estas ejecutando el jar sin `-jar`.

Correcto:

```bash
java -jar /ruta/al/controlzero-api-0.0.1-SNAPSHOT.jar
```

### `Socket fail to connect to localhost:3307`

La API no encontro MariaDB.

Solucion:

```bash
docker compose up -d mariadb
```

o ejecuta el jar sobreescribiendo `spring.datasource.url`, `spring.datasource.username` y `spring.datasource.password`.

## Comandos utiles

```bash
docker compose up -d mariadb
docker compose stop mariadb
./gradlew bootRun
./gradlew test
./gradlew bootJar
./gradlew clean build
```
