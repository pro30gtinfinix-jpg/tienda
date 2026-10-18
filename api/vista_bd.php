<?php
// =====================================================
// vista_bd.php
// Solo lectura: devuelve las 3 tablas para mostrarlas en la pestaña
// "Base de datos" del panel admin, o descarga el archivo .db completo
// (?descargar=1) para abrirlo luego en DB Browser for SQLite.
// Pide la clave de administrador en ?clave=
// =====================================================

require "conexion.php";

if (!isset($_GET["clave"]) || $_GET["clave"] !== "gengar2026") {
    http_response_code(403);
    header("Content-Type: application/json");
    echo json_encode(array("error" => "clave_incorrecta"));
    exit;
}

if (isset($_GET["descargar"]) && $esPostgres) {
    // En PostgreSQL no hay un archivo .db: se descarga una copia en JSON
    $copia = array();
    $lista = array("productos", "pedidos", "detalle_pedido");
    for ($i = 0; $i < count($lista); $i++) {
        $copia[$lista[$i]] = $conexion->query("SELECT * FROM " . $lista[$i] . " ORDER BY id")->fetchAll(PDO::FETCH_ASSOC);
    }
    header("Content-Type: application/json");
    header("Content-Disposition: attachment; filename=copia_gengar_studio.json");
    echo json_encode($copia, JSON_PRETTY_PRINT);
    exit;
}

if (isset($_GET["descargar"])) {
    header("Content-Type: application/octet-stream");
    header("Content-Disposition: attachment; filename=gengar_studio.db");
    header("Content-Length: " . filesize($rutaBaseDatos));
    readfile($rutaBaseDatos);
    exit;
}

header("Content-Type: application/json");
$tablas = array("productos", "pedidos", "detalle_pedido");
$resultado = array();
for ($i = 0; $i < count($tablas); $i++) {
    $consulta = $conexion->query("SELECT * FROM " . $tablas[$i] . " ORDER BY id DESC");
    $resultado[$tablas[$i]] = $consulta->fetchAll(PDO::FETCH_ASSOC);
}
echo json_encode($resultado);
?>
