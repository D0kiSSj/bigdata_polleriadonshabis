-- Usamos la base de datos analítica (Datamart)
USE BD_OLAP_DonHabis;
GO

-- Primero eliminamos los datos de la tabla de hechos por las llaves foráneas
TRUNCATE TABLE Fact_Ventas;

-- Luego vaciamos las dimensiones
TRUNCATE TABLE Dim_Producto;
TRUNCATE TABLE Dim_Cliente;
TRUNCATE TABLE Dim_Tiempo;
GO

-- === CARGA DE DIMENSIÓN CLIENTE ===
INSERT INTO BD_OLAP_DonHabis.dbo.Dim_Cliente (ClienteID_BK, NombreCompleto, TipoDocumento, NroDocumento)
SELECT 
    id_cliente,
    UPPER(CONCAT(nombres, ' ', apellidos)) AS NombreCompleto, -- Transformación
    ISNULL(tipo_doc, 'S/D') AS TipoDocumento,                  -- Control de nulos
    num_doc
FROM BD_OLTP_DonHabis.dbo.Clientes;
GO

-- === CARGA DE DIMENSIÓN PRODUCTO ===
INSERT INTO BD_OLAP_DonHabis.dbo.Dim_Producto (ProductoID_BK, NombreProducto, Categoria, PrecioUnitario)
SELECT 
    p.id_producto,
    p.nombre_prod,
    c.nombre_categoria, -- Transformación: Traemos el texto de la categoría, no el ID
    p.precio
FROM BD_OLTP_DonHabis.dbo.Productos p
INNER JOIN BD_OLTP_DonHabis.dbo.Categorias c ON p.id_categoria = c.id_categoria;
GO

-- === CARGA DE DIMENSIÓN TIEMPO ===
-- (Opcional: Si manejas una tabla de tiempo estática, extraes las fechas únicas de las ventas)
INSERT INTO BD_OLAP_DonHabis.dbo.Dim_Tiempo (FechaKey, Fecha, Anio, Mes, NombreMes, Dia)
SELECT DISTINCT
    CONVERT(INT, FORMAT(fecha_venta, 'yyyyMMdd')) AS FechaKey,
    fecha_venta,
    YEAR(fecha_venta),
    MONTH(fecha_venta),
    DATENAME(MONTH, fecha_venta),
    DAY(fecha_venta)
FROM BD_OLTP_DonHabis.dbo.Ventas;
GO

-- === CARGA DE TABLA DE HECHOS: VENTAS ===
INSERT INTO BD_OLAP_DonHabis.dbo.Fact_Ventas (ClienteKey, ProductoKey, FechaKey, Cantidad, MontoTotal)
SELECT 
    dc.ClienteKey,     -- Llave autogenerada en el OLAP
    dp.ProductoKey,    -- Llave autogenerada en el OLAP
    CONVERT(INT, FORMAT(v.fecha_venta, 'yyyyMMdd')) AS FechaKey,
    dv.cantidad,
    (dv.cantidad * dv.precio_unitario) AS MontoTotal -- Métrica calculada
FROM BD_OLTP_DonHabis.dbo.Detalle_Ventas dv
INNER JOIN BD_OLTP_DonHabis.dbo.Ventas v ON dv.id_venta = v.id_venta
-- Cruzamos con las dimensiones ya cargadas para capturar los IDs del Datamart
INNER JOIN BD_OLAP_DonHabis.dbo.Dim_Cliente dc ON v.id_cliente = dc.ClienteID_BK
INNER JOIN BD_OLAP_DonHabis.dbo.Dim_Producto dp ON dv.id_producto = dp.ProductoID_BK;
GO