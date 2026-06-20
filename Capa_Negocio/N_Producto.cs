using System;
using System.Collections.Generic;
using Capa_Datos;

namespace Capa_Negocio
{
    public class N_Producto
    {
        private D_Producto objDatos = new D_Producto();

        // 1. LISTAR
        public List<tbl_producto> ListarProductosActivos()
        {
            return objDatos.ListarProductosActivos();
        }

        // 2. BUSCADOR ESTILO FACEBOOK
        public List<tbl_producto> BuscarProductos(string filtro)
        {
            // Si el usuario borra la búsqueda y manda vacío, le devolvemos toda la lista
            if (string.IsNullOrWhiteSpace(filtro))
                return ListarProductosActivos();

            return objDatos.BuscarProductos(filtro);
        }

        // 3. INSERTAR CON VALIDACIONES ESTRICTAS DE INVENTARIO
        public string InsertarProducto(tbl_producto nuevoProd)
        {
            // Reglas de Negocio
            if (string.IsNullOrWhiteSpace(nuevoProd.pro_nombre)) return "El nombre del producto es obligatorio.";

            // SOLUCIÓN: Ahora validamos la llave foránea (cat_id) en lugar del texto viejo
            if (nuevoProd.cat_id <= 0) return "Debes clasificar el producto en una categoría válida.";

            if (nuevoProd.pro_precio <= 0) return "El precio de venta debe ser mayor a $0.00.";
            if (nuevoProd.pro_cantidad < 0) return "El stock inicial no puede ser negativo.";

            // Validar Foreign Key de Proveedor
            if (nuevoProd.prov_id == null || nuevoProd.prov_id <= 0)
                return "Debes vincular este producto a un proveedor registrado.";

            // Escudo Anti-Duplicados
            var listaProductos = objDatos.ListarProductosActivos();
            if (listaProductos.Exists(p => p.pro_nombre.Equals(nuevoProd.pro_nombre, StringComparison.OrdinalIgnoreCase)))
                return "Ya existe un producto en el inventario con ese nombre.";

            bool exito = objDatos.InsertarProducto(nuevoProd);
            return exito ? "OK" : "Error al registrar el producto en la Base de Datos.";
        }

        // 4. ACTUALIZAR
        public string ActualizarProducto(tbl_producto prodModificado)
        {
            if (string.IsNullOrWhiteSpace(prodModificado.pro_nombre)) return "El nombre del producto es obligatorio.";

            // SOLUCIÓN: Validamos la llave foránea
            if (prodModificado.cat_id <= 0) return "La categoría es obligatoria.";

            if (prodModificado.pro_precio <= 0) return "El precio de venta no puede ser $0.00 ni negativo.";
            if (prodModificado.pro_cantidad < 0) return "El stock no puede ser menor a 0.";

            bool exito = objDatos.ActualizarProducto(prodModificado);
            return exito ? "OK" : "Error interno al actualizar el producto.";
        }

        // 5. ELIMINAR
        public string EliminarProducto(int idProd)
        {
            bool exito = objDatos.EliminarProductoLogico(idProd);
            return exito ? "OK" : "Error al intentar dar de baja el producto.";
        }

        // 6. EJECUCIÓN MASIVA (Actualizado para recibir la Categoría y Proveedor por separado)
        public string EjecutarSPMasivo(tbl_producto producto, string nombreCategoria, string nombreProveedor)
        {
            return objDatos.EjecutarSPMasivo(producto, nombreCategoria, nombreProveedor);
        }


        // 7. PROCESAR LISTA MASIVA (Actualizado con los 3 parámetros para que no marque error)
        public string ProcesarSubidaMasiva(List<tbl_producto> listaProductos, List<string> nombresCategorias, List<string> nombresProveedores)
        {
            int errores = 0;
            for (int i = 0; i < listaProductos.Count; i++)
            {
                // Llamamos al SP con la nueva firma
                string resultado = objDatos.EjecutarSPMasivo(listaProductos[i], nombresCategorias[i], nombresProveedores[i]);
                if (resultado != "OK") errores++;
            }
            return errores == 0 ? "OK" : $"Se procesó el archivo, pero {errores} registros fallaron.";
        }
    }
}