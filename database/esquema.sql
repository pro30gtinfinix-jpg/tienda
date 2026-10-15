-- =====================================================
-- GENGAR STUDIO - Esquema de base de datos (SQLite)
-- Para usar con "DB Browser for SQLite"
-- =====================================================
-- Instrucciones:
-- 1. Abre DB Browser for SQLite.
-- 2. Archivo > Nueva base de datos... > guárdala como "gengar_studio.db"
--    dentro de la carpeta /database/ de tu proyecto.
-- 3. Ve a la pestaña "Ejecutar SQL".
-- 4. Pega todo este archivo y presiona "Ejecutar todo" (el ícono de play).
-- 5. Ve a "Escribir cambios" para guardar el archivo .db.
-- =====================================================

-- Tabla de productos: es la única fuente de verdad del catálogo.
--
-- Cada prenda es única (normalmente 1 sola unidad), así que en vez de
-- un "stock" numérico, el inventario se controla con un estado:
--   'Disponible' -> se muestra en el catálogo público, se puede comprar
--   'Reservada'  -> un cliente ya envió el pedido por WhatsApp, se
--                   esconde del catálogo público mientras se confirma
--                   el pago, pero TODAVÍA NO se cuenta como venta
--   'Vendida'    -> el administrador confirmó el pago; venta definitiva
--
-- El campo "imagen" guarda la URL de la foto como texto. Ya no existe
-- la carpeta /imagenes/: cambiar una foto es cambiar la URL.
CREATE TABLE productos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    descripcion TEXT,
    categoria TEXT NOT NULL,
    talla TEXT,
    color TEXT,
    precio_compra REAL NOT NULL,
    precio_venta REAL NOT NULL,
    estado_inventario TEXT NOT NULL DEFAULT 'Disponible',
    imagen TEXT
);

-- Tabla de pedidos: un pedido = una compra realizada por un cliente.
-- fecha_pedido: cuándo el cliente lo envió por WhatsApp.
-- fecha_pago: cuándo el administrador confirmó el pago (queda vacío
-- hasta que eso ocurre). Esta es la fecha que se usa en el historial
-- de ventas, porque es cuando la venta se vuelve definitiva.
CREATE TABLE pedidos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cliente TEXT NOT NULL,
    whatsapp TEXT NOT NULL,
    lugar TEXT NOT NULL,
    fecha TEXT NOT NULL,
    hora TEXT NOT NULL,
    total REAL NOT NULL,
    estado TEXT NOT NULL DEFAULT 'Pendiente',
    fecha_pedido TEXT NOT NULL DEFAULT (datetime('now')),
    fecha_pago TEXT
);

-- Tabla de detalle_pedido: qué productos (y cuántos) tiene cada pedido.
-- Se guarda una "foto" del nombre y los precios en el momento de la
-- compra (producto_nombre, precio_venta_unitario, precio_compra_unitario)
-- para que, si el admin borra o cambia el precio de un producto después,
-- el historial de ventas y las ganancias pasadas no se alteren.
-- Esta misma tabla es la que alimenta el historial de ventas.
-- precio_final: lo escribe el administrador en "Ventas y ganancias" una vez
-- confirmado el pago. Mientras esté vacío (NULL) se puede escribir; cuando
-- ya tiene valor, queda bloqueado y la venta cuenta en las ganancias.
CREATE TABLE detalle_pedido (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    pedido_id INTEGER NOT NULL,
    producto_id INTEGER,
    producto_nombre TEXT NOT NULL,
    cantidad INTEGER NOT NULL,
    precio_venta_unitario REAL NOT NULL,
    precio_compra_unitario REAL NOT NULL,
    precio_final REAL,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);

-- =====================================================
-- Catálogo inicial: 15 prendas únicas. Orden de precios: compra, venta (Bs).
-- El campo imagen guarda la URL (enlace de Google Drive compartido
-- como 'Cualquier persona con el enlace'); la página lo convierte sola.
-- =====================================================
INSERT INTO productos (nombre, descripcion, categoria, talla, color, precio_compra, precio_venta, estado_inventario, imagen) VALUES
('Buso deportivo azul marino franjas gris', 'Buso deportivo azul marino con franjas grises. Corte para dama.', 'Busos/Pantalones', 'L', 'Azul marino', 40, 50, 'Disponible', 'https://drive.google.com/file/d/1ZhsnLZryq06998Ez11JbrRzQZUaDc8dd/view?usp=sharing'),
('Buso Kappa cierre bota pie', 'Buso Kappa con cierre en el bota pie.', 'Busos/Pantalones', 'M/L', 'Negro', 10, 45, 'Disponible', 'https://drive.google.com/file/d/1YOxG8DXtUMY0WwU2nOZmVnfiqVgKxW5c/view?usp=sharing'),
('Canguro Great Smoky', 'Canguro celeste con estampado Great Smoky.', 'Canguros/Sudaderas/Chaquetas', 'S', 'Celeste', 20, 35, 'Disponible', 'https://drive.google.com/file/d/1CephAkdiPCO4rjosawWUfuxIuO9CbDZw/view?usp=sharing'),
('Canguro deportivo Blue Devils Baseball', 'Canguro deportivo bicolor Blue Devils Baseball.', 'Canguros/Sudaderas/Chaquetas', 'S', 'Gris claro y azul', 35, 45, 'Disponible', 'https://drive.google.com/file/d/14oAyo7rDFyPpxsnYMlq4-wCtombIq33J/view?usp=sharing'),
('Canguro Seton Hall', 'Canguro gris claro Seton Hall.', 'Canguros/Sudaderas/Chaquetas', 'S', 'Gris claro', 35, 45, 'Disponible', 'https://drive.google.com/file/d/1ATF15Dq4EWwYKY9B2yAu6Zv3dBoEegTY/view?usp=sharing'),
('Canguro Addams Family', 'Canguro gris oscuro The Addams Family.', 'Canguros/Sudaderas/Chaquetas', 'S', 'Gris oscuro', 35, 45, 'Disponible', 'https://drive.google.com/file/d/1sraVKH_I_8P5gObuujMo24wyDWJoH6ao/view?usp=sharing'),
('Canguro Crusaders Adidas', 'Canguro plomo Crusaders de Adidas.', 'Canguros/Sudaderas/Chaquetas', 'XL', 'Plomo', 20, 40, 'Disponible', 'https://drive.google.com/file/d/1MwZjro-sbArUhqUrEahZc009H6HiqN4t/view?usp=sharing'),
('Canguro Reebok Detroit Pistons', 'Canguro Reebok Detroit Pistons azul marino.', 'Canguros/Sudaderas/Chaquetas', 'L', 'Azul marino', 35, 50, 'Disponible', 'https://drive.google.com/file/d/1oyrwd68_F0oUptAidLWJ_TB9JXfAr7ud/view?usp=sharing'),
('Canguro Stitch', 'Canguro Stitch azul marino. Corte para dama.', 'Canguros/Sudaderas/Chaquetas', 'XL', 'Azul marino', 35, 50, 'Disponible', 'https://drive.google.com/file/d/1g7dmWE9T4jHm8zVlXiGqaq8hOIB_N4J_/view?usp=sharing'),
('Chaqueta polar Vita', 'Chaqueta polar Vita combinada negro con gris claro.', 'Canguros/Sudaderas/Chaquetas', 'M', 'Negro y gris claro', 36, 70, 'Disponible', 'https://drive.google.com/file/d/1zKSmC1rZOf28y4qlHPAThQ4Vaqde4DU2/view?usp=sharing'),
('Chaqueta universitaria Dogg Supply', 'Chaqueta universitaria Dogg Supply.', 'Canguros/Sudaderas/Chaquetas', 'M', '', 35, 100, 'Disponible', 'https://drive.google.com/file/d/1zN3wdlpMJGSI4vfOTpBEt-bTlgTE3e_5/view?usp=sharing'),
('Chompa polar medio cierre 47''', 'Chompa polar con medio cierre, marca 47''.', 'Canguros/Sudaderas/Chaquetas', 'M/L', 'Gris claro', 35, 50, 'Disponible', 'https://drive.google.com/file/d/1C3aSaYRtAcis_8dZVrNCkuBBmhR-Z4hr/view?usp=sharing'),
('Sudadera Dickies', 'Sudadera gris Dickies.', 'Canguros/Sudaderas/Chaquetas', 'M', 'Gris', 35, 80, 'Disponible', 'https://drive.google.com/file/d/1wwT5wBgwa39mJ1BZgmQR3-EdWiimNva6/view?usp=sharing'),
('Sudadera Carnegie Mellon 47'' unisex', 'Sudadera Carnegie Mellon de 47'', unisex.', 'Canguros/Sudaderas/Chaquetas', 'S', 'Gris claro', 35, 50, 'Disponible', 'https://drive.google.com/file/d/1Ocr9Vyb91SPf0vZrrcfXZXmRbvnnW2i7/view?usp=sharing'),
('Sudadera Flamin''Hot oversize llamas en mangas', 'Sudadera oversize Flamin''Hot con llamas en las mangas, unisex.', 'Canguros/Sudaderas/Chaquetas', 'S', 'Negro', 35, 50, 'Disponible', 'https://drive.google.com/file/d/1UszzjI2l4Ye-4bXbTFOquCV_qMjYU98D/view?usp=sharing');
