using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Capa_Datos
{
    public class D_Proveedor
    {
        private IMongoCollection<ProveedorMongo> _proveedores;
        // Colección de productos necesaria para el borrado en cascada (Soft Delete VIP)
        private IMongoCollection<ProductoMongo> _productos;

        public D_Proveedor()
        {
            // Instanciamos tu conexión a Mongo
            var conexion = new ConexionMongo();
            _proveedores = conexion.database.GetCollection<ProveedorMongo>("Proveedores");
            _productos = conexion.database.GetCollection<ProductoMongo>("Productos");
        }

        // ==========================================
        // TRADUCTORES (El secreto para no romper nada)
        // ==========================================
        private tbl_proveedor MapToSQL(ProveedorMongo m)
        {
            if (m == null) return null;
            return new tbl_proveedor
            {
                prov_id = m.prov_id,
                prov_nombre = m.prov_nombre,
                prov_contacto = m.prov_contacto,
                prov_email = m.prov_email,
                prov_estado = m.prov_estado,
                prov_fecha_registro = m.prov_fecha_registro
            };
        }

        private ProveedorMongo MapToMongo(tbl_proveedor s)
        {
            if (s == null) return null;
            return new ProveedorMongo
            {
                prov_id = s.prov_id,
                prov_nombre = s.prov_nombre,
                prov_contacto = s.prov_contacto,
                prov_email = s.prov_email,
                prov_estado = s.prov_estado,
                prov_fecha_registro = s.prov_fecha_registro
            };
        }

        // ==========================================
        // 1. LISTAR (Solo los activos)
        // ==========================================
        public List<tbl_proveedor> ListarProveedoresActivos()
        {
            var filtro = Builders<ProveedorMongo>.Filter.Eq(p => p.prov_estado, true);
            var listaMongo = _proveedores.Find(filtro).ToList();

            // Traducimos la lista de Mongo a la lista que espera tu Capa de Negocio
            return listaMongo.Select(MapToSQL).ToList();
        }

        // ==========================================
        // 2. INSERTAR
        // ==========================================
        public bool InsertarProveedor(tbl_proveedor nuevoProv)
        {
            try
            {
                var provMongo = MapToMongo(nuevoProv);

                // Autoincrementable manual (Mongo no tiene IDENTITY como SQL)
                var ultimoProv = _proveedores.Find(Builders<ProveedorMongo>.Filter.Empty)
                                             .SortByDescending(p => p.prov_id)
                                             .FirstOrDefault();

                provMongo.prov_id = (ultimoProv != null) ? ultimoProv.prov_id + 1 : 1;
                provMongo.prov_estado = true;
                provMongo.prov_fecha_registro = DateTime.Now;

                _proveedores.InsertOne(provMongo);
                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }

        // ==========================================
        // 3. ACTUALIZAR
        // ==========================================
        public bool ActualizarProveedor(tbl_proveedor provModificado)
        {
            try
            {
                var filtro = Builders<ProveedorMongo>.Filter.Eq(p => p.prov_id, provModificado.prov_id);
                var update = Builders<ProveedorMongo>.Update
                    .Set(p => p.prov_nombre, provModificado.prov_nombre)
                    .Set(p => p.prov_contacto, provModificado.prov_contacto)
                    .Set(p => p.prov_email, provModificado.prov_email);

                var resultado = _proveedores.UpdateOne(filtro, update);
                return resultado.ModifiedCount > 0;
            }
            catch (Exception)
            {
                return false;
            }
        }

        // ==========================================
        // 4. ELIMINAR (Soft Delete VIP + Cascada)
        // ==========================================
        public bool EliminarProveedorLogico(int idProv)
        {
            try
            {
                // Paso 1: Desactivar el proveedor
                var filtroProv = Builders<ProveedorMongo>.Filter.Eq(p => p.prov_id, idProv);
                var updateProv = Builders<ProveedorMongo>.Update.Set(p => p.prov_estado, false);
                var resultadoProv = _proveedores.UpdateOne(filtroProv, updateProv);

                if (resultadoProv.ModifiedCount > 0)
                {
                    // Paso 2: Desactivar en cascada sus productos vinculados
                    var filtroProd = Builders<ProductoMongo>.Filter.Eq(p => p.prov_id, idProv);
                    var updateProd = Builders<ProductoMongo>.Update.Set(p => p.pro_estado, false);
                    _productos.UpdateMany(filtroProd, updateProd);

                    return true;
                }
                return false;
            }
            catch (Exception)
            {
                return false;
            }
        }
    }
}