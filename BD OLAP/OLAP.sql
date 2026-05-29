CREATE DATABASE DonShabis_DM_Ventas;
GO

USE DonShabis_DM_Ventas;
GO

CREATE TABLE Dim_Cliente (
    id_cliente INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(50),
    distrito VARCHAR(80)
);

CREATE TABLE Dim_Producto (
    id_producto INT PRIMARY KEY,
    nombre_producto VARCHAR(120) NOT NULL,
    categoria VARCHAR(80) NOT NULL,
    precio DECIMAL(10,2) NOT NULL
);

CREATE TABLE Dim_Tiempo (
    id_tiempo INT PRIMARY KEY,
    fecha DATE NOT NULL,
    dia INT NOT NULL,
    mes INT NOT NULL,
    nombre_mes VARCHAR(50) NOT NULL,
    anio INT NOT NULL,
    trimestre INT NOT NULL
);

CREATE TABLE Dim_Empleado (
    id_empleado INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    cargo VARCHAR(80) NOT NULL,
    turno VARCHAR(50) NOT NULL
);

CREATE TABLE Dim_Sucursal (
    id_sucursal INT PRIMARY KEY,
    nombre_sucursal VARCHAR(100) NOT NULL,
    direccion VARCHAR(150) NOT NULL,
    distrito VARCHAR(80) NOT NULL
);

CREATE TABLE Fact_Ventas (
    id_venta INT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_producto INT NOT NULL,
    id_tiempo INT NOT NULL,
    id_empleado INT NOT NULL,
    id_sucursal INT NOT NULL,
    cantidad_vendida INT NOT NULL,
    total_venta DECIMAL(10,2) NOT NULL,
    costo_estimado DECIMAL(10,2) NOT NULL,
    ganancia DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_Fact_Cliente FOREIGN KEY (id_cliente) REFERENCES Dim_Cliente(id_cliente),
    CONSTRAINT FK_Fact_Producto FOREIGN KEY (id_producto) REFERENCES Dim_Producto(id_producto),
    CONSTRAINT FK_Fact_Tiempo FOREIGN KEY (id_tiempo) REFERENCES Dim_Tiempo(id_tiempo),
    CONSTRAINT FK_Fact_Empleado FOREIGN KEY (id_empleado) REFERENCES Dim_Empleado(id_empleado),
    CONSTRAINT FK_Fact_Sucursal FOREIGN KEY (id_sucursal) REFERENCES Dim_Sucursal(id_sucursal)
);

GO

--VISTA PARA VISUALIZAR DETALLE DE VENTAS--

CREATE OR ALTER VIEW vw_FactVentasDetalle AS
SELECT
    f.id_venta,
    c.nombre AS cliente,
    c.distrito AS distrito_cliente,
    p.nombre_producto AS producto,
    p.categoria,
    t.fecha,
    t.nombre_mes,
    t.anio,
    e.nombre AS empleado,
    e.cargo,
    s.nombre_sucursal AS sucursal,
    s.distrito AS distrito_sucursal,
    f.cantidad_vendida,
    f.total_venta,
    f.costo_estimado,
    f.ganancia
FROM Fact_Ventas f
JOIN Dim_Cliente c ON f.id_cliente = c.id_cliente
JOIN Dim_Producto p ON f.id_producto = p.id_producto
JOIN Dim_Tiempo t ON f.id_tiempo = t.id_tiempo
JOIN Dim_Empleado e ON f.id_empleado = e.id_empleado
JOIN Dim_Sucursal s ON f.id_sucursal = s.id_sucursal;
GO
