CREATE TABLE estado_empleado (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(150) NULL,

    creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

create table empleado_puesto(
    id bigint primary key auto_increment,
    nombre varchar(150) not null unique,
    descripcion varchar(255) null
);


CREATE TABLE empleado (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    dpi VARCHAR(30) NOT NULL UNIQUE,
    telefono VARCHAR(20) NULL,
    empleado_puesto_id BIGINT NULL,
    estado_empleado_id BIGINT NOT NULL,
    fecha_ingreso DATE NOT NULL,

    foto_url VARCHAR(255) NULL,

    creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_empleado_estado
        FOREIGN KEY (estado_empleado_id) REFERENCES estado_empleado(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    constraint fk_empleado_puesto
        foreign key (empleado_puesto_id) references empleado_puesto(id)
        on delete restrict
        on update cascade
);

create table permiso(
    id bigint primary key auto_increment,
    nombre varchar(100) not null unique,
    descripcion varchar(255) null
);

CREATE TABLE rol (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(150) NULL,

    creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

create table permiso_rol(
    rol_id bigint not null,
    permiso_id bigint not null,
    primary key (rol_id, permiso_id),
    constraint fk_permiso_rol_rol
       foreign key (rol_id) references rol(id)
           on delete cascade
           on update cascade,
    constraint fk_permiso_rol_permiso
       foreign key (permiso_id) references permiso(id)
           on delete cascade
           on update cascade
);

CREATE TABLE usuario (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    empleado_id BIGINT NOT NULL UNIQUE,
    rol_id BIGINT NOT NULL,

    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    ultimo_login TIMESTAMP NULL,

    creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_usuario_empleado
        FOREIGN KEY (empleado_id) REFERENCES empleado(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_usuario_rol
        FOREIGN KEY (rol_id) REFERENCES rol(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE auditoria_login (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    usuario_id BIGINT NULL,
    email_intento VARCHAR(150) NULL,
    fecha_evento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    exito BOOLEAN NOT NULL,
    ip_address VARCHAR(45) NULL,
    user_agent VARCHAR(255) NULL,
    detalle VARCHAR(255) NULL,

    CONSTRAINT fk_auditoria_login_usuario
     FOREIGN KEY (usuario_id) REFERENCES usuario(id)
         ON DELETE RESTRICT
         ON UPDATE CASCADE
);