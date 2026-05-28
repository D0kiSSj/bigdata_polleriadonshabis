# 📊 Proyecto T2 - Inteligencia de Negocios para Pollería "Don SHabis"

## 👥 Integrantes
* **Grados Tarazona, Alexander** 
* [Apellido, Nombre] 
* [Apellido, Nombre]
* [Apellido, Nombre] 

---

## 🎥 5. Video Demostrativo (Máximo 10 minutos)
¡Obligatorio para la calificación! Revisa el funcionamiento completo del proyecto aquí:
 **[HAZ CLIC AQUÍ PARA VER EL VIDEO DEMOSTRATIVO](AQUÍ_PEGA_EL_LINK_DE_YOUTUBE_O_DRIVE)**

*El video incluye: Demostración de la BD transaccional, ejecución del proceso ETL, el Datamart en SQL Server y la explicación de los indicadores en Power BI.*

---

## 📁 Estructura de los Entregables

De acuerdo con los requerimientos de la evaluación, los archivos se encuentran organizados de forma independiente en las siguientes carpetas:

### 1. 📁 BD OLTP (Base de Datos Transaccional)
* Contiene el script de creación (`OLTP.sql`) o backup de la base de datos origen en SQL Server. Se incluyen tablas, llaves primarias, foráneas y restricciones necesarias para el negocio de la pollería.

### 2. 📁 BD OLAP (Base de Datos Analítica / Datamart)
* Contiene el script (`OLAP.sql`) con la estructura del modelo estrella (Tablas de Hechos y Dimensiones) optimizado para las consultas analíticas del negocio.

### 3. 📁 Proceso ETL (Extracción, Transformación y Carga)
* Scripts correspondientes a la migración y limpieza de datos desde el entorno OLTP hacia el Datamart final.

### 4. 📁 POWER BI (Dashboard e Indicadores)
* Archivo `.pbix` (`DASHBOARD POLLERIA.pbix`) que se conecta al Datamart. Incluye los reportes, gráficos interactivos e indicadores clave de rendimiento (KPIs) solicitados por el cliente.

---

## ⚙️ Tecnologías Utilizadas
* **Motor de Base de Datos:** SQL Server Management Studio (SSMS)
* **Herramienta de Analítica:** Power BI Desktop
* **Control de Versiones:** Git & GitHub
