USE DonShabis_DM_Ventas
GO

-- LIMPIEZA DE TABLAS DEL DATA MART --
DELETE FROM dbo.Fact_Ventas;

DELETE FROM dbo.Dim_Cliente;
DELETE FROM dbo.Dim_Empleado;
DELETE FROM dbo.Dim_Producto;
DELETE FROM dbo.Dim_Sucursal;
DELETE FROM dbo.Dim_Tiempo;
GO

--CARGA DE DIMENSIONES --

--Carga de clientes--
BULK INSERT dbo.Dim_Cliente
FROM 'C:\datos\clientes.txt'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001'
);
GO

-- Carga de empleados --
BULK INSERT dbo.Dim_Empleado
FROM 'C:\datos\empleados.txt'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001'
);
GO

--Carga de productos--
BULK INSERT dbo.Dim_Producto
FROM 'C:\datos\productos.txt'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001'
);
GO

--Carga de sucursales--
BULK INSERT dbo.Dim_Sucursal
FROM 'C:\datos\sucursales.txt'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001'
);
GO

--Carga de tiempo--
BULK INSERT dbo.Dim_Tiempo
FROM 'C:\datos\tiempo.txt'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001'
);
GO

--CARGA DE TABLA DE HECHOS--
BULK INSERT dbo.Fact_Ventas
FROM 'C:\datos\ventas.txt'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001'
);
GO

--VALIDACIÓN DE CARGA--
SELECT 'Dim_Cliente' AS tabla, COUNT(*) AS registros FROM dbo.Dim_Cliente
UNION ALL
SELECT 'Dim_Empleado', COUNT(*) FROM dbo.Dim_Empleado
UNION ALL
SELECT 'Dim_Producto', COUNT(*) FROM dbo.Dim_Producto
UNION ALL
SELECT 'Dim_Sucursal', COUNT(*) FROM dbo.Dim_Sucursal
UNION ALL
SELECT 'Dim_Tiempo', COUNT(*) FROM dbo.Dim_Tiempo
UNION ALL
SELECT 'Fact_Ventas', COUNT(*) FROM dbo.Fact_Ventas;
GO

--CONSULTA DE COMPROBACIÓN--
SELECT TOP 20
    f.id_venta,
    c.nombre AS cliente,
    p.nombre_producto AS producto,
    e.nombre AS empleado,
    s.nombre_sucursal AS sucursal,
    t.fecha,
    f.cantidad_vendida,
    f.total_venta,
    f.costo_estimado,
    f.ganancia
FROM dbo.Fact_Ventas f
INNER JOIN dbo.Dim_Cliente c ON f.id_cliente = c.id_cliente
INNER JOIN dbo.Dim_Producto p ON f.id_producto = p.id_producto
INNER JOIN dbo.Dim_Empleado e ON f.id_empleado = e.id_empleado
INNER JOIN dbo.Dim_Sucursal s ON f.id_sucursal = s.id_sucursal
INNER JOIN dbo.Dim_Tiempo t ON f.id_tiempo = t.id_tiempo
ORDER BY f.id_venta;
GO
