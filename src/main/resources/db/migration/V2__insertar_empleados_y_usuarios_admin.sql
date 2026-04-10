INSERT IGNORE INTO estado_empleado (nombre, descripcion)
VALUES ('ACTIVO', 'Empleado activo');

INSERT IGNORE INTO empleado_puesto (nombre, descripcion)
VALUES ('Recursos Humanos', 'Gestion del talento humano y administracion del personal');

INSERT IGNORE INTO rol (nombre, descripcion)
VALUES ('ADMINISTRADOR', 'Rol con acceso administrativo completo');

SET @estado_activo_id = (
    SELECT id
    FROM estado_empleado
    WHERE nombre = 'ACTIVO'
    LIMIT 1
);

SET @puesto_rrhh_id = (
    SELECT id
    FROM empleado_puesto
    WHERE nombre = 'Recursos Humanos'
    LIMIT 1
);

SET @rol_administrador_id = (
    SELECT id
    FROM rol
    WHERE nombre = 'ADMINISTRADOR'
    LIMIT 1
);

INSERT IGNORE INTO empleado (
    nombres,
    apellidos,
    dpi,
    telefono,
    empleado_puesto_id,
    estado_empleado_id,
    fecha_ingreso,
    foto_url
)
VALUES
    ('Ana Lucia', 'Ramirez Soto', '1000000000001', '5550-1001', @puesto_rrhh_id, @estado_activo_id, '2024-01-15', NULL),
    ('Carlos Andres', 'Lopez Perez', '1000000000002', '5550-1002', @puesto_rrhh_id, @estado_activo_id, '2024-02-01', NULL),
    ('Maria Fernanda', 'Gomez Ruiz', '1000000000003', '5550-1003', @puesto_rrhh_id, @estado_activo_id, '2024-02-15', NULL),
    ('Jose Manuel', 'Castillo Diaz', '1000000000004', '5550-1004', @puesto_rrhh_id, @estado_activo_id, '2024-03-01', NULL),
    ('Luisa Daniela', 'Herrera Morales', '1000000000005', '5550-1005', @puesto_rrhh_id, @estado_activo_id, '2024-03-15', NULL);

-- Password por defecto para los 5 usuarios: Admin123!
INSERT IGNORE INTO usuario (
    empleado_id,
    rol_id,
    email,
    password_hash,
    activo
)
VALUES
    ((SELECT id FROM empleado WHERE dpi = '1000000000001' LIMIT 1), @rol_administrador_id, 'ana.lucia@controlzero.local', '$2y$10$fxW5mu4pLnr4e.NtZc4bJOGYBnUJ.3S0LzccakGNuZNsBmqcyI5HK', TRUE),
    ((SELECT id FROM empleado WHERE dpi = '1000000000002' LIMIT 1), @rol_administrador_id, 'carlos.andres@controlzero.local', '$2y$10$fxW5mu4pLnr4e.NtZc4bJOGYBnUJ.3S0LzccakGNuZNsBmqcyI5HK', TRUE),
    ((SELECT id FROM empleado WHERE dpi = '1000000000003' LIMIT 1), @rol_administrador_id, 'maria.fernanda@controlzero.local', '$2y$10$fxW5mu4pLnr4e.NtZc4bJOGYBnUJ.3S0LzccakGNuZNsBmqcyI5HK', TRUE),
    ((SELECT id FROM empleado WHERE dpi = '1000000000004' LIMIT 1), @rol_administrador_id, 'jose.manuel@controlzero.local', '$2y$10$fxW5mu4pLnr4e.NtZc4bJOGYBnUJ.3S0LzccakGNuZNsBmqcyI5HK', TRUE),
    ((SELECT id FROM empleado WHERE dpi = '1000000000005' LIMIT 1), @rol_administrador_id, 'luisa.daniela@controlzero.local', '$2y$10$fxW5mu4pLnr4e.NtZc4bJOGYBnUJ.3S0LzccakGNuZNsBmqcyI5HK', TRUE);
