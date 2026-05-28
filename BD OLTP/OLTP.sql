CREATE DATABASE DonShabis_DB;
GO
USE DonShabis_DB;
GO

CREATE TABLE Roles (
    id_rol INT IDENTITY(1,1) PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Usuarios (
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    clave_hash VARCHAR(255) NOT NULL,
    id_rol INT NOT NULL,
    estado CHAR(1) NOT NULL DEFAULT 'A' CHECK (estado IN ('A','I')),
    CONSTRAINT FK_Usuarios_Roles FOREIGN KEY (id_rol) REFERENCES Roles(id_rol)
);

CREATE TABLE Clientes (
    id_cliente INT IDENTITY(1,1) PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    telefono VARCHAR(15),
    correo VARCHAR(120),
    distrito VARCHAR(80)
);

CREATE TABLE Categorias (
    id_categoria INT IDENTITY(1,1) PRIMARY KEY,
    nombre_categoria VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE Productos (
    id_producto INT IDENTITY(1,1) PRIMARY KEY,
    id_categoria INT NOT NULL,
    nombre_producto VARCHAR(120) NOT NULL,
    precio_venta DECIMAL(10,2) NOT NULL CHECK (precio_venta >= 0),
    stock_actual DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (stock_actual >= 0),
    stock_minimo DECIMAL(10,2) NOT NULL DEFAULT 5 CHECK (stock_minimo >= 0),
    estado CHAR(1) NOT NULL DEFAULT 'A' CHECK (estado IN ('A','I')),
    CONSTRAINT FK_Productos_Categorias FOREIGN KEY (id_categoria) REFERENCES Categorias(id_categoria)
);

CREATE TABLE Pedidos (
    id_pedido INT IDENTITY(1,1) PRIMARY KEY,
    id_cliente INT NULL,
    id_usuario INT NOT NULL,
    fecha_pedido DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    canal_venta VARCHAR(20) NOT NULL CHECK (canal_venta IN ('SALON','LLEVAR','DELIVERY')),
    metodo_pago VARCHAR(20) NOT NULL CHECK (metodo_pago IN ('EFECTIVO','TARJETA','YAPE','PLIN')),
    estado_pedido VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE' CHECK (estado_pedido IN ('PENDIENTE','PREPARACION','ENTREGADO','ANULADO')),
    total DECIMAL(10,2) NOT NULL DEFAULT 0,
    CONSTRAINT FK_Pedidos_Clientes FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente),
    CONSTRAINT FK_Pedidos_Usuarios FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
);

CREATE TABLE Detalle_Pedido (
    id_detalle INT IDENTITY(1,1) PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad DECIMAL(10,2) NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10,2) NOT NULL CHECK (precio_unitario >= 0),
    subtotal AS (cantidad * precio_unitario) PERSISTED,
    CONSTRAINT FK_Detalle_Pedido FOREIGN KEY (id_pedido) REFERENCES Pedidos(id_pedido),
    CONSTRAINT FK_Detalle_Producto FOREIGN KEY (id_producto) REFERENCES Productos(id_producto)
);

CREATE TABLE Proveedores (
    id_proveedor INT IDENTITY(1,1) PRIMARY KEY,
    razon_social VARCHAR(120) NOT NULL,
    ruc VARCHAR(20) UNIQUE,
    telefono VARCHAR(15),
    direccion VARCHAR(180)
);

CREATE TABLE Inventario_Movimientos (
    id_movimiento INT IDENTITY(1,1) PRIMARY KEY,
    id_producto INT NOT NULL,
    tipo_movimiento VARCHAR(20) NOT NULL CHECK (tipo_movimiento IN ('ENTRADA','SALIDA','MERMA')),
    cantidad DECIMAL(10,2) NOT NULL CHECK (cantidad > 0),
    fecha_movimiento DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    id_usuario INT NULL,
    observacion VARCHAR(250),
    CONSTRAINT FK_Mov_Producto FOREIGN KEY (id_producto) REFERENCES Productos(id_producto),
    CONSTRAINT FK_Mov_Usuario FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
);

CREATE TABLE AUD_Operaciones (
    id_auditoria INT IDENTITY(1,1) PRIMARY KEY,
    tabla_afectada VARCHAR(80) NOT NULL,
    tipo_operacion VARCHAR(20) NOT NULL,
    descripcion VARCHAR(500) NOT NULL,
    fecha_operacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    usuario_bd SYSNAME NOT NULL DEFAULT SUSER_SNAME()
);
GO

INSERT INTO Roles(nombre_rol) VALUES
('ADMINISTRADOR'),('CAJERO'),('ALMACEN'),('COCINA'),('SUPERVISOR');

INSERT INTO Usuarios(usuario, clave_hash, id_rol) VALUES
('admin','hash_admin_demo',1),
('cajero01','hash_cajero_demo',2),
('almacen01','hash_almacen_demo',3),
('cocina01','hash_cocina_demo',4),
('supervisor01','hash_supervisor_demo',5);

INSERT INTO Categorias(nombre_categoria) VALUES
('Comida'),('Bebida'),('Complemento'),('Postre'),('Combo');

INSERT INTO Clientes(nombres, telefono, correo, distrito) VALUES
('Juan Perez','987654321','juan.perez@correo.com','San Martin de Porres'),
('Maria Lopez','912345678','maria.lopez@correo.com','Los Olivos'),
('Carlos Diaz','999888777','carlos.diaz@correo.com','Independencia'),
('Ana Torres','955444111','ana.torres@correo.com','Comas'),
('Pedro Ramos','988777666','pedro.ramos@correo.com','San Martin de Porres');

INSERT INTO Productos(id_categoria, nombre_producto, precio_venta, stock_actual, stock_minimo) VALUES
(1,'1/4 de pollo con papas',22.00,80,10),
(1,'1/2 pollo con papas',38.00,60,8),
(1,'Pollo entero con papas',68.00,35,5),
(2,'Gaseosa 1.5L',8.00,100,15),
(5,'Combo familiar',130.00,25,4),
(3,'Papas fritas familiar',15.00,50,10),
(2,'Chicha morada 1L',10.00,45,8),
(4,'Pie de manzana',8.00,30,5);
GO

/* Procedimiento almacenado: registra cabecera del pedido */
CREATE OR ALTER PROCEDURE sp_registrar_pedido
    @id_cliente INT = NULL,
    @id_usuario INT,
    @canal_venta VARCHAR(20),
    @metodo_pago VARCHAR(20),
    @id_pedido INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Pedidos(id_cliente, id_usuario, canal_venta, metodo_pago)
    VALUES(@id_cliente, @id_usuario, @canal_venta, @metodo_pago);

    SET @id_pedido = SCOPE_IDENTITY();
END;
GO

/* Procedimiento almacenado: agrega detalle, actualiza total y depende del trigger de stock */
CREATE OR ALTER PROCEDURE sp_agregar_detalle_pedido
    @id_pedido INT,
    @id_producto INT,
    @cantidad DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @precio DECIMAL(10,2);

    SELECT @precio = precio_venta
    FROM Productos
    WHERE id_producto = @id_producto AND estado = 'A';

    IF @precio IS NULL
        THROW 50001, 'Producto no existe o está inactivo.', 1;

    INSERT INTO Detalle_Pedido(id_pedido, id_producto, cantidad, precio_unitario)
    VALUES(@id_pedido, @id_producto, @cantidad, @precio);

    UPDATE Pedidos
    SET total = (
        SELECT SUM(subtotal)
        FROM Detalle_Pedido
        WHERE id_pedido = @id_pedido
    )
    WHERE id_pedido = @id_pedido;
END;
GO

/* Función: total de ventas por fecha */
CREATE OR ALTER FUNCTION fn_total_ventas_dia(@fecha DATE)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @total DECIMAL(10,2);

    SELECT @total = ISNULL(SUM(total), 0)
    FROM Pedidos
    WHERE CAST(fecha_pedido AS DATE) = @fecha
      AND estado_pedido <> 'ANULADO';

    RETURN @total;
END;
GO

/* Trigger: descuenta stock cuando se inserta un detalle de pedido */
CREATE OR ALTER TRIGGER trg_descontar_stock_detalle
ON Detalle_Pedido
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Productos p ON p.id_producto = i.id_producto
        WHERE p.stock_actual < i.cantidad
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50002, 'Stock insuficiente para registrar el pedido.', 1;
    END;

    UPDATE p
    SET p.stock_actual = p.stock_actual - i.cantidad
    FROM Productos p
    JOIN inserted i ON p.id_producto = i.id_producto;

    INSERT INTO Inventario_Movimientos(id_producto, tipo_movimiento, cantidad, observacion)
    SELECT id_producto, 'SALIDA', cantidad, 'Salida automática por venta'
    FROM inserted;
END;
GO

/* Trigger de auditoría: registra cambios de precio o stock en productos */
CREATE OR ALTER TRIGGER trg_auditoria_productos
ON Productos
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO AUD_Operaciones(tabla_afectada, tipo_operacion, descripcion)
    SELECT 'Productos', 'UPDATE',
           CONCAT('Producto ', i.id_producto, ' actualizado. Precio: ', d.precio_venta, ' -> ', i.precio_venta,
                  '; Stock: ', d.stock_actual, ' -> ', i.stock_actual)
    FROM inserted i
    JOIN deleted d ON i.id_producto = d.id_producto
    WHERE ISNULL(i.precio_venta,0) <> ISNULL(d.precio_venta,0)
       OR ISNULL(i.stock_actual,0) <> ISNULL(d.stock_actual,0);
END;
GO

/* Vista operativa con nombres */
CREATE OR ALTER VIEW vw_pedidos_detalle
AS
SELECT
    p.id_pedido,
    p.fecha_pedido,
    ISNULL(c.nombres, 'Cliente anónimo') AS cliente,
    u.usuario AS usuario_registro,
    pr.nombre_producto,
    dp.cantidad,
    dp.precio_unitario,
    dp.subtotal,
    p.canal_venta,
    p.metodo_pago,
    p.estado_pedido,
    p.total
FROM Pedidos p
LEFT JOIN Clientes c ON p.id_cliente = c.id_cliente
JOIN Usuarios u ON p.id_usuario = u.id_usuario
JOIN Detalle_Pedido dp ON p.id_pedido = dp.id_pedido
JOIN Productos pr ON dp.id_producto = pr.id_producto;
GO
