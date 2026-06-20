using MongoDB.Bson;
using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Capa_Datos
{
    public class D_Categoria
    {
        private IMongoCollection<CategoriaMongo> _categorias;
        private IMongoCollection<ProductoMongo> _productos; // Necesario para proteger la eliminación

        public D_Categoria()
        {
            var conexion = new ConexionMongo();
            _categorias = conexion.database.GetCollection<CategoriaMongo>("Categorias");
            _productos = conexion.database.GetCollection<ProductoMongo>("Productos");
        }

        private tbl_categoria MapToSQL(CategoriaMongo m)
        {
            if (m == null) return null;
            return new tbl_categoria
            {
                cat_id = m.cat_id,
                cat_nombre = m.cat_nombre,
                cat_descripcion = m.cat_descripcion,
                cat_estado = m.cat_estado ?? true
            };
        }

        // 1. LISTAR CON FILTRO
        public List<tbl_categoria> ListarCategorias(bool verEliminados)
        {
            var filtro = verEliminados
                ? Builders<CategoriaMongo>.Filter.Empty
                : Builders<CategoriaMongo>.Filter.Eq(c => c.cat_estado, true);

            var listaMongo = _categorias.Find(filtro).SortBy(c => c.cat_nombre).ToList();
            return listaMongo.Select(MapToSQL).ToList();
        }

        // 2. VALIDACIÓN ANTI-DUPLICADO
        public bool ExisteCategoria(string nombre, int idExcluido)
        {
            var regex = new BsonRegularExpression($"^{nombre}$", "i"); // Ignora mayúsculas/minúsculas
            var filtro = Builders<CategoriaMongo>.Filter.And(
                Builders<CategoriaMongo>.Filter.Regex(c => c.cat_nombre, regex),
                Builders<CategoriaMongo>.Filter.Ne(c => c.cat_id, idExcluido),
                Builders<CategoriaMongo>.Filter.Eq(c => c.cat_estado, true)
            );
            return _categorias.Find(filtro).Any();
        }

        // 3. INSERTAR
        public bool InsertarCategoria(string nombre, string descripcion)
        {
            try
            {
                var ultimaCat = _categorias.Find(Builders<CategoriaMongo>.Filter.Empty).SortByDescending(c => c.cat_id).FirstOrDefault();
                int nuevoId = (ultimaCat != null) ? ultimaCat.cat_id + 1 : 1;

                var nuevaCat = new CategoriaMongo { cat_id = nuevoId, cat_nombre = nombre, cat_descripcion = descripcion, cat_estado = true };
                _categorias.InsertOne(nuevaCat);
                return true;
            }
            catch { return false; }
        }

        // 4. ACTUALIZAR
        public bool ActualizarCategoria(int id, string nombre, string descripcion)
        {
            try
            {
                var filtro = Builders<CategoriaMongo>.Filter.Eq(c => c.cat_id, id);
                var update = Builders<CategoriaMongo>.Update.Set(c => c.cat_nombre, nombre).Set(c => c.cat_descripcion, descripcion);
                var resultado = _categorias.UpdateOne(filtro, update);
                return resultado.ModifiedCount > 0;
            }
            catch { return false; }
        }

        // 5. CAMBIAR ESTADO (Soft Delete / Restaurar)
        public void CambiarEstado(int id, bool nuevoEstado)
        {
            var filtro = Builders<CategoriaMongo>.Filter.Eq(c => c.cat_id, id);
            var update = Builders<CategoriaMongo>.Update.Set(c => c.cat_estado, nuevoEstado);
            _categorias.UpdateOne(filtro, update);
        }

        // 6. ELIMINAR DEFINITIVO (Simulando la restricción FK 547 de SQL)
        public string EliminarDefinitivo(int id)
        {
            try
            {
                // Verificar si algún producto (activo o inactivo) usa esta categoría
                bool enUso = _productos.Find(p => p.cat_id == id).Any();
                if (enUso) return "EN_USO";

                var filtro = Builders<CategoriaMongo>.Filter.Eq(c => c.cat_id, id);
                _categorias.DeleteOne(filtro);
                return "OK";
            }
            catch { return "ERROR"; }
        }
    }
}