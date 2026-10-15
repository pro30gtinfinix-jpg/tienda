<?php
// =====================================================
// conexion.php
// Abre la conexión hacia el archivo .db usando PDO.
// Todos los demás archivos PHP incluyen este archivo
// con require "conexion.php"; para obtener $conexion.
// =====================================================

// Por defecto la base está en /database/gengar_studio.db. Si el hosting
// define la variable DB_PATH (por ejemplo en Render, apuntando a un
// disco persistente), se usa esa ruta en su lugar.
$rutaBaseDatos = getenv("DB_PATH") ? getenv("DB_PATH") : __DIR__ . "/../database/gengar_studio.db";

try {
    // Si el archivo .db todavía no existe (primer arranque en un servidor
    // nuevo), se crea solo a partir de database/esquema.sql.
    $esNueva = !file_exists($rutaBaseDatos) || filesize($rutaBaseDatos) === 0;
    if ($esNueva && !is_dir(dirname($rutaBaseDatos))) {
        mkdir(dirname($rutaBaseDatos), 0777, true);
    }

    $conexion = new PDO("sqlite:" . $rutaBaseDatos);
    $conexion->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    if ($esNueva) {
        $conexion->exec(file_get_contents(__DIR__ . "/../database/esquema.sql"));
    }

    // Si la base de datos es antigua y todavía no tiene la columna
    // "precio_final" en detalle_pedido, se agrega sola (una única vez).
    $columnas = $conexion->query("PRAGMA table_info(detalle_pedido)")->fetchAll(PDO::FETCH_ASSOC);
    $existe = false;
    for ($i = 0; $i < count($columnas); $i++) {
        if ($columnas[$i]["name"] === "precio_final") { $existe = true; }
    }
    if (!$existe && count($columnas) > 0) {
        $conexion->exec("ALTER TABLE detalle_pedido ADD COLUMN precio_final REAL");
    }
} catch (PDOException $error) {
    header("Content-Type: application/json");
    http_response_code(500);
    echo json_encode(array("error" => "No se pudo conectar a la base de datos: " . $error->getMessage()));
    exit;
}
?>
