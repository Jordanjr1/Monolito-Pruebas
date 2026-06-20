using System;
using System.Collections.Generic;
using Capa_Datos;

namespace Capa_Negocio
{
    public class N_Proveedor
    {
        private D_Proveedor objDatos = new D_Proveedor();

        // 1. LISTAR
        public List<tbl_proveedor> ListarProveedoresActivos()
        {
            return objDatos.ListarProveedoresActivos();
        }

        // 2. INSERTAR CON VALIDACIONES VIP
        public string InsertarProveedor(tbl_proveedor nuevoProv)
        {
            // Validaciones de negocio
            if (string.IsNullOrWhiteSpace(nuevoProv.prov_nombre))
                return "Protocolo denegado: El nombre del proveedor es obligatorio.";

            // Escudo Anti-Duplicados
            var listaProveedores = objDatos.ListarProveedoresActivos();
            if (listaProveedores.Exists(p => p.prov_nombre.Equals(nuevoProv.prov_nombre, StringComparison.OrdinalIgnoreCase)))
                return "Protocolo denegado: Ya existe un proveedor registrado con ese nombre.";

            // Si pasa todo, mandamos a guardar
            bool exito = objDatos.InsertarProveedor(nuevoProv);
            return exito ? "OK" : "Error interno: No se pudo guardar el proveedor en la Base de Datos.";
        }

        // 3. ACTUALIZAR
        public string ActualizarProveedor(tbl_proveedor provModificado)
        {
            if (string.IsNullOrWhiteSpace(provModificado.prov_nombre))
                return "Protocolo denegado: El nombre del proveedor no puede quedar vacío.";

            bool exito = objDatos.ActualizarProveedor(provModificado);
            return exito ? "OK" : "Error interno: No se pudo actualizar el proveedor.";
        }

        // 4. ELIMINAR
        public string EliminarProveedor(int idProv)
        {
            bool exito = objDatos.EliminarProveedorLogico(idProv);
            return exito ? "OK" : "Error interno: No se pudo eliminar el proveedor.";
        }
    }
}