import functions_framework
import psycopg2
import json
import os
import bcrypt
import uuid
from datetime import datetime

DB_CONFIG = {
    "host": os.environ.get("DB_HOST"),
    "port": os.environ.get("DB_PORT", "5432"),
    "dbname": os.environ.get("DB_NAME"),
    "user": os.environ.get("DB_USER"),
    "password": os.environ.get("DB_PASSWORD"),
}

def get_conn():
    return psycopg2.connect(**DB_CONFIG)

def json_response(data, status=200):
    return (json.dumps(data, default=str), status, {"Content-Type": "application/json", "Access-Control-Allow-Origin": "*"})

@functions_framework.http
def api(request):
    if request.method == "OPTIONS":
        return ("", 204, {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE",
            "Access-Control-Allow-Headers": "Content-Type, Authorization",
        })

    path = request.path.rstrip("/")
    method = request.method

    try:
        # Auth
        if path == "/registro" and method == "POST":
            return registro(request)
        if path == "/login" and method == "POST":
            return login(request)

        # Negocios
        if path == "/negocios" and method == "POST":
            return crear_negocio(request)
        if path == "/negocios" and method == "GET":
            return listar_negocios(request)

        # Categorias
        if path.startswith("/negocios/") and path.endswith("/categorias") and method == "POST":
            negocio_id = path.split("/")[2]
            return crear_categoria(request, negocio_id)
        if path.startswith("/negocios/") and path.endswith("/categorias") and method == "GET":
            negocio_id = path.split("/")[2]
            return listar_categorias(negocio_id)

        # Productos
        if path.startswith("/categorias/") and path.endswith("/productos") and method == "POST":
            categoria_id = path.split("/")[2]
            return crear_producto(request, categoria_id)

        return json_response({"error": "Ruta no encontrada"}, 404)

    except Exception as e:
        return json_response({"error": str(e)}, 500)


def registro(request):
    data = request.get_json()
    correo = data.get("correo")
    password = data.get("password")
    nombre = data.get("nombre", "")
    if not correo or not password:
        return json_response({"error": "Correo y contraseña requeridos"}, 400)
    password_hash = bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()
    with get_conn() as conn:
        with conn.cursor() as cur:
            try:
                cur.execute(
                    "INSERT INTO usuarios (correo, password_hash, nombre) VALUES (%s, %s, %s) RETURNING id",
                    (correo, password_hash, nombre)
                )
            except Exception:
                cur.execute(
                    "INSERT INTO usuarios (correo, password_hash) VALUES (%s, %s) RETURNING id",
                    (correo, password_hash)
                )
            user_id = cur.fetchone()[0]
        conn.commit()
    return json_response({"id": str(user_id), "correo": correo})


def login(request):
    data = request.get_json()
    correo = data.get("correo")
    password = data.get("password")
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT id, password_hash FROM usuarios WHERE correo = %s", (correo,))
            row = cur.fetchone()
    if not row:
        return json_response({"error": "Usuario no encontrado"}, 404)
    if not bcrypt.checkpw(password.encode(), row[1].encode()):
        return json_response({"error": "Contraseña incorrecta"}, 401)
    return json_response({"id": str(row[0]), "correo": correo})


def crear_negocio(request):
    data = request.get_json()
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO negocios (usuario_id, nombre, tipo, direccion, lat, lng) VALUES (%s, %s, %s, %s, %s, %s) RETURNING id",
                (data.get("usuario_id"), data["nombre"], data["tipo"], data["direccion"], data.get("lat"), data.get("lng"))
            )
            negocio_id = cur.fetchone()[0]
        conn.commit()
    return json_response({"id": str(negocio_id)})


def listar_negocios(request):
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT id, nombre, tipo, direccion, lat, lng, publicado FROM negocios WHERE publicado = TRUE")
            rows = cur.fetchall()
    negocios = [
        {"id": str(r[0]), "nombre": r[1], "tipo": r[2], "direccion": r[3], "lat": r[4], "lng": r[5], "publicado": r[6]}
        for r in rows
    ]
    return json_response(negocios)


def crear_categoria(request, negocio_id):
    data = request.get_json()
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO categorias (negocio_id, nombre, orden) VALUES (%s, %s, %s) RETURNING id",
                (negocio_id, data["nombre"], data.get("orden", 0))
            )
            cat_id = cur.fetchone()[0]
        conn.commit()
    return json_response({"id": str(cat_id)})


def listar_categorias(negocio_id):
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT c.id, c.nombre, p.id, p.emoji, p.nombre, p.descripcion, p.precio
                FROM categorias c
                LEFT JOIN productos p ON p.categoria_id = c.id
                WHERE c.negocio_id = %s
                ORDER BY c.orden, p.nombre
                """,
                (negocio_id,)
            )
            rows = cur.fetchall()

    categorias = {}
    for r in rows:
        cat_id = str(r[0])
        if cat_id not in categorias:
            categorias[cat_id] = {"id": cat_id, "nombre": r[1], "productos": []}
        if r[2]:
            categorias[cat_id]["productos"].append({
                "id": str(r[2]), "emoji": r[3], "nombre": r[4],
                "descripcion": r[5], "precio": r[6]
            })
    return json_response(list(categorias.values()))


def crear_producto(request, categoria_id):
    data = request.get_json()
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO productos (categoria_id, emoji, nombre, descripcion, precio) VALUES (%s, %s, %s, %s, %s) RETURNING id",
                (categoria_id, data.get("emoji"), data["nombre"], data.get("descripcion"), data["precio"])
            )
            prod_id = cur.fetchone()[0]
        conn.commit()
    return json_response({"id": str(prod_id)})
