using MongoDB.Bson;
using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Capa_Datos
{
    public class D_Producto
    {
        private IMongoCollection<ProductoMongo> _productos;
        private IMongoCollection<ProveedorMongo> _proveedores;
        private IMongoCollection<CategoriaMongo> _categorias;

        public D_Producto()
        {
            var conexion = new ConexionMongo();
            _productos = conexion.database.GetCollection<ProductoMongo>("Productos");
            _proveedores = conexion.database.GetCollection<ProveedorMongo>("Proveedores");
            _categorias = conexion.database.GetCollection<CategoriaMongo>("Categorias");
        }

        // ==========================================
        // TRADUCTORES DE CONTROL
        // ==========================================
        private tbl_producto MapToSQL(ProductoMongo m)
        {
            if (m == null) return null;

            // 1. Buscamos la Categoría para que la UI la pueda mostrar
            tbl_categoria objCategoria = null;
            if (m.cat_id.HasValue)
            {
                var catMongo = _categorias.Find(c => c.cat_id == m.cat_id.Value).FirstOrDefault();
                if (catMongo != null)
                {
                    objCategoria = new tbl_categoria
                    {
                        cat_id = catMongo.cat_id,
                        cat_nombre = catMongo.cat_nombre,
                        cat_descripcion = catMongo.cat_descripcion
                    };
                }
            }

            // 2. Buscamos el Proveedor (Por si tu tabla también lo muestra)
            tbl_proveedor objProveedor = null;
            if (m.prov_id.HasValue)
            {
                var provMongo = _proveedores.Find(p => p.prov_id == m.prov_id.Value).FirstOrDefault();
                if (provMongo != null)
                {
                    objProveedor = new tbl_proveedor
                    {
                        prov_id = provMongo.prov_id,
                        prov_nombre = provMongo.prov_nombre
                    };
                }
            }

            return new tbl_producto
            {
                pro_id = m.pro_id,
                pro_nombre = m.pro_nombre,
                pro_descripcion = m.pro_descripcion,
                pro_cantidad = m.pro_cantidad ?? 0,
                pro_precio = m.pro_precio ?? 0m,
                pro_foto_path = m.pro_foto_path,
                pro_estado = m.pro_estado,
                prov_id = m.prov_id,
                cat_id = m.cat_id,
                pro_fecha_registro = m.pro_fecha_registro,

                // ¡AQUÍ ESTÁ LA SOLUCIÓN! Le adjuntamos los objetos relacionados
                tbl_categoria = objCategoria,
                tbl_proveedor = objProveedor
            };
        }

        private ProductoMongo MapToMongo(tbl_producto s)
        {
            if (s == null) return null;
            return new ProductoMongo
            {
                pro_id = s.pro_id,
                pro_nombre = s.pro_nombre,
                pro_descripcion = s.pro_descripcion,
                pro_cantidad = s.pro_cantidad,
                pro_precio = s.pro_precio,
                pro_foto_path = s.pro_foto_path,
                pro_estado = s.pro_estado,
                prov_id = s.prov_id,
                cat_id = s.cat_id,
                pro_fecha_registro = s.pro_fecha_registro
            };
        }

        // ==========================================
        // 1. LISTAR TODOS LOS ACTIVOS
        // ==========================================
        public List<tbl_producto> ListarProductosActivos()
        {
            var filtro = Builders<ProductoMongo>.Filter.Eq(p => p.pro_estado, true);
            var listaMongo = _productos.Find(filtro).ToList();
            return listaMongo.Select(MapToSQL).ToList();
        }

        // ==========================================
        // 2. BUSCADOR FILTRADO (Estilo Facebook)
        // ==========================================
        public List<tbl_producto> BuscarProductos(string filtro)
        {
            // Filtro 1: Que el producto esté activo
            var filtroBase = Builders<ProductoMongo>.Filter.Eq(p => p.pro_estado, true);

            // Expresión regular para hacer un "Contains" insensible a mayúsculas/minúsculas
            var regex = new BsonRegularExpression(filtro, "i");

            // Buscar por nombre del producto
            var filtroNombre = Builders<ProductoMongo>.Filter.Regex(p => p.pro_nombre, regex);

            // Para buscar por nombre de categoría (Join manual en NoSQL):
            var catFiltro = Builders<CategoriaMongo>.Filter.Regex(c => c.cat_nombre, regex);
            var idsCategorias = _categorias.Find(catFiltro).ToList().Select(c => (int?)c.cat_id).ToList();

            var filtroCategoria = Builders<ProductoMongo>.Filter.In(p => p.cat_id, idsCategorias);

            // Unión de filtros: Activo AND (Nombre OR Categoría)
            var filtroFinal = Builders<ProductoMongo>.Filter.And(
                filtroBase,
                Builders<ProductoMongo>.Filter.Or(filtroNombre, filtroCategoria)
            );

            return _productos.Find(filtroFinal).ToList().Select(MapToSQL).ToList();
        }

        // ==========================================
        // 3. INSERTAR INDIVIDUAL
        // ==========================================
        public bool InsertarProducto(tbl_producto nuevoProd)
        {
            try
            {
                var prodMongo = MapToMongo(nuevoProd);

                // Autoincrementable VIP
                var ultimoProd = _productos.Find(Builders<ProductoMongo>.Filter.Empty)
                                           .SortByDescending(p => p.pro_id)
                                           .FirstOrDefault();

                prodMongo.pro_id = (ultimoProd != null) ? ultimoProd.pro_id + 1 : 1;
                prodMongo.pro_estado = true;
                prodMongo.pro_fecha_registro = DateTime.Now;

                _productos.InsertOne(prodMongo);
                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }

        // ==========================================
        // 4. ACTUALIZAR
        // ==========================================
        public bool ActualizarProducto(tbl_producto prodModificado)
        {
            try
            {
                var filtro = Builders<ProductoMongo>.Filter.Eq(p => p.pro_id, prodModificado.pro_id);

                var update = Builders<ProductoMongo>.Update
                    .Set(p => p.pro_nombre, prodModificado.pro_nombre)
                    .Set(p => p.pro_descripcion, prodModificado.pro_descripcion)
                    .Set(p => p.cat_id, prodModificado.cat_id)
                    .Set(p => p.pro_cantidad, prodModificado.pro_cantidad)
                    .Set(p => p.pro_precio, prodModificado.pro_precio)
                    .Set(p => p.prov_id, prodModificado.prov_id);

                // Solo actualiza la ruta de la foto si subieron una nueva
                if (!string.IsNullOrEmpty(prodModificado.pro_foto_path))
                {
                    update = update.Set(p => p.pro_foto_path, prodModificado.pro_foto_path);
                }

                var resultado = _productos.UpdateOne(filtro, update);
                return resultado.ModifiedCount > 0;
            }
            catch
            {
                return false;
            }
        }

        // ==========================================
        // BONUS: IMAGEN RELACIONAL (Integrada en el documento)
        // ==========================================
        public void InsertarImagenRelacional(int idProducto, string pathImagen)
        {
            // En NoSQL no necesitamos una tabla intermedia, la guardamos directo en el producto
            var filtro = Builders<ProductoMongo>.Filter.Eq(p => p.pro_id, idProducto);
            var update = Builders<ProductoMongo>.Update.Set(p => p.pro_foto_path, pathImagen);
            _productos.UpdateOne(filtro, update);
        }

        // ==========================================
        // 5. REEMPLAZO DEL SP DE CARGA MASIVA
        // ==========================================
        public string EjecutarSPMasivo(tbl_producto producto, string nombreCategoria, string nombreProveedor)
        {
            try
            {
                // 1. Resolver Categoría (Buscar o crear si no existe)
                var cat = _categorias.Find(c => c.cat_nombre.Equals(nombreCategoria, StringComparison.OrdinalIgnoreCase)).FirstOrDefault();
                int catId;
                if (cat == null)
                {
                    var ultimaCat = _categorias.Find(Builders<CategoriaMongo>.Filter.Empty).SortByDescending(c => c.cat_id).FirstOrDefault();
                    catId = (ultimaCat != null) ? ultimaCat.cat_id + 1 : 1;
                    _categorias.InsertOne(new CategoriaMongo { cat_id = catId, cat_nombre = nombreCategoria, cat_estado = true });
                }
                else { catId = cat.cat_id; }

                // 2. Resolver Proveedor (Buscar o crear si no existe)
                var prov = _proveedores.Find(p => p.prov_nombre.Equals(nombreProveedor, StringComparison.OrdinalIgnoreCase)).FirstOrDefault();
                int provId;
                if (prov == null)
                {
                    var ultimoProv = _proveedores.Find(Builders<ProveedorMongo>.Filter.Empty).SortByDescending(p => p.prov_id).FirstOrDefault();
                    provId = (ultimoProv != null) ? ultimoProv.prov_id + 1 : 1;
                    _proveedores.InsertOne(new ProveedorMongo { prov_id = provId, prov_nombre = nombreProveedor, prov_estado = true, prov_fecha_registro = DateTime.Now });
                }
                else { provId = prov.prov_id; }

                // 3. Insertar el Producto con los IDs mapeados
                var prodMongo = MapToMongo(producto);
                var ultimoProd = _productos.Find(Builders<ProductoMongo>.Filter.Empty).SortByDescending(p => p.pro_id).FirstOrDefault();

                prodMongo.pro_id = (ultimoProd != null) ? ultimoProd.pro_id + 1 : 1;
                prodMongo.cat_id = catId;
                prodMongo.prov_id = provId;
                prodMongo.pro_estado = true;
                prodMongo.pro_fecha_registro = DateTime.Now;

                _productos.InsertOne(prodMongo);
                return "OK";
            }
            catch (Exception ex)
            {
                return "EXCEPCIÓN CRÍTICA EN MONGO: " + ex.Message;
            }
        }

        // ==========================================
        // 6. ELIMINAR (Soft Delete)
        // ==========================================
        public bool EliminarProductoLogico(int idProd)
        {
            try
            {
                var filtro = Builders<ProductoMongo>.Filter.Eq(p => p.pro_id, idProd);
                var update = Builders<ProductoMongo>.Update.Set(p => p.pro_estado, false);
                var resultado = _productos.UpdateOne(filtro, update);
                return resultado.ModifiedCount > 0;
            }
            catch (Exception)
            {
                return false;
            }
        }
    }
}