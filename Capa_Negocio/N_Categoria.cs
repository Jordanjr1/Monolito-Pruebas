using System;
using System.Collections.Generic;
using Capa_Datos; // Asegúrate de tener la referencia a tu capa de datos

namespace Capa_Negocio
{
    public class N_Categoria
    {
        private D_Categoria objDatos = new D_Categoria();

        // 1. LISTAR
        // Usamos la misma lista que devuelve tu D_Categoria
        public List<tbl_categoria> Listar(bool verEliminados = false)
        {
            return objDatos.ListarCategorias(verEliminados);
        }

        // 2. INSERTAR
        public bool Insertar(string nombre, string descripcion, out string mensaje)
        {
            mensaje = string.Empty;

            // Validación de campos vacíos
            if (string.IsNullOrWhiteSpace(nombre))
            {
                mensaje = "El nombre de la categoría es obligatorio.";
                return false;
            }

            // Normalizar datos
            nombre = nombre.Trim().ToUpper();
            if (descripcion != null) descripcion = descripcion.Trim();

            // Validar existencia para evitar duplicados (pasamos 0 porque es un registro nuevo)
            if (objDatos.ExisteCategoria(nombre, 0))
            {
                mensaje = $"La categoría '{nombre}' ya se encuentra registrada.";
                return false;
            }

            // Ejecutar inserción
            bool respuesta = objDatos.InsertarCategoria(nombre, descripcion);

            if (!respuesta)
            {
                mensaje = "Ocurrió un error interno al guardar la categoría.";
            }

            return respuesta;
        }

        // 3. ACTUALIZAR
        public bool Actualizar(int id, string nombre, string descripcion, out string mensaje)
        {
            mensaje = string.Empty;

            // Validación de campos vacíos
            if (string.IsNullOrWhiteSpace(nombre))
            {
                mensaje = "El nombre de la categoría es obligatorio.";
                return false;
            }

            // Normalizar datos
            nombre = nombre.Trim().ToUpper();
            if (descripcion != null) descripcion = descripcion.Trim();

            // Validar existencia excluyendo el ID actual para evitar choques con otras categorías
            if (objDatos.ExisteCategoria(nombre, id))
            {
                mensaje = $"Ya existe otra categoría registrada con el nombre '{nombre}'.";
                return false;
            }

            // Ejecutar actualización
            bool respuesta = objDatos.ActualizarCategoria(id, nombre, descripcion);

            if (!respuesta)
            {
                mensaje = "Ocurrió un error interno al actualizar la categoría.";
            }

            return respuesta;
        }

        // 4. CAMBIAR ESTADO (Soft Delete / Restaurar)
        public void CambiarEstado(int id, bool nuevoEstado)
        {
            // Aquí podrías agregar validaciones si, por ejemplo, 
            // no quieres permitir desactivar una categoría si tiene productos activos.
            objDatos.CambiarEstado(id, nuevoEstado);
        }

        // 5. ELIMINAR DEFINITIVO
        public bool EliminarDefinitivo(int id, out string mensaje)
        {
            mensaje = string.Empty;

            // Recibimos la respuesta de la capa de datos
            string resultado = objDatos.EliminarDefinitivo(id);

            // Traducimos los códigos técnicos a mensajes para el usuario
            if (resultado == "EN_USO")
            {
                mensaje = "No se puede eliminar la categoría porque existen productos vinculados a ella.";
                return false;
            }
            else if (resultado == "ERROR")
            {
                mensaje = "Ocurrió un error en la base de datos al intentar eliminar la categoría.";
                return false;
            }

            // Si es "OK", retorna true
            return true;
        }
    }
}