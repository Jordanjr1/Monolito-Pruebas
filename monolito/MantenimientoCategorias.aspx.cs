using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Script.Serialization;
using Capa_Datos;

namespace monolito
{
    public partial class MantenimientoCategorias : Page
    {
        // Instancia de nuestra nueva Capa de Datos Mongo
        private D_Categoria dCategoria = new D_Categoria();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) CargarGrid();
        }

        private void CargarGrid()
        {
            try
            {
                // El GridView es capaz de leer directamente la lista de objetos
                gvCategorias.DataSource = dCategoria.ListarCategorias(chkVerEliminados.Checked);
                gvCategorias.DataBind();
            }
            catch (Exception ex) { Alertar("Error", ex.Message, "error"); }
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            string nombre = txtNombreCat.Text.Trim().ToUpper();
            string desc = txtDescripcionCat.Text.Trim();
            int id = Convert.ToInt32(hfIdCategoria.Value);

            if (string.IsNullOrEmpty(nombre)) { Alertar("Validación", "Nombre obligatorio", "warning"); return; }

            try
            {
                // Validación Anti-Duplicado consultando a Mongo
                if (dCategoria.ExisteCategoria(nombre, id))
                {
                    Alertar("Duplicado", "Esta categoría ya existe activa.", "warning");
                    return;
                }

                // Guardamos o actualizamos
                bool exito = id == 0
                    ? dCategoria.InsertarCategoria(nombre, desc)
                    : dCategoria.ActualizarCategoria(id, nombre, desc);

                if (exito)
                {
                    LimpiarFormulario();
                    CargarGrid();
                    Alertar("Éxito", "Operación ejecutada.", "success");
                }
                else
                {
                    Alertar("Error", "No se pudo guardar la categoría.", "error");
                }
            }
            catch (Exception ex) { Alertar("Error", ex.Message, "error"); }
        }

        protected void gvCategorias_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Editar")
            {
                int index = Convert.ToInt32(e.CommandArgument);
                GridViewRow row = gvCategorias.Rows[index];
                hfIdCategoria.Value = gvCategorias.DataKeys[index].Value.ToString();

                txtNombreCat.Text = Server.HtmlDecode(row.Cells[1].Text).Trim();
                txtDescripcionCat.Text = Server.HtmlDecode(row.Cells[2].Text).Trim() == "&nbsp;" ? "" : Server.HtmlDecode(row.Cells[2].Text).Trim();

                lblTituloFormulario.InnerHtml = "<i class='fas fa-pen'></i> Editando";
                btnGuardar.Text = "Actualizar";
            }
            else if (e.CommandName == "Eliminar") { CambiarEstado(Convert.ToInt32(e.CommandArgument), false); }
            else if (e.CommandName == "Restaurar") { CambiarEstado(Convert.ToInt32(e.CommandArgument), true); }
            else if (e.CommandName == "EliminarDefinitivo") { EjecutarHardDelete(Convert.ToInt32(e.CommandArgument)); }
        }

        private void CambiarEstado(int id, bool nuevoEstado)
        {
            dCategoria.CambiarEstado(id, nuevoEstado);
            CargarGrid();
        }

        // Método blindado para el Hard Delete en MongoDB
        private void EjecutarHardDelete(int id)
        {
            try
            {
                string resultado = dCategoria.EliminarDefinitivo(id);

                if (resultado == "EN_USO")
                {
                    Alertar("Acción Bloqueada", "No puedes destruir esta categoría porque existen productos vinculados a ella. Reasigna o elimina los productos primero para proteger la integridad.", "error");
                }
                else if (resultado == "OK")
                {
                    Alertar("Destrucción Confirmada", "La categoría ha sido eliminada permanentemente.", "success");
                    CargarGrid();
                }
                else
                {
                    Alertar("Error", "Error interno al intentar eliminar.", "error");
                }
            }
            catch (Exception ex)
            {
                Alertar("Error Crítico", ex.Message, "error");
            }
        }

        protected void chkVerEliminados_CheckedChanged(object sender, EventArgs e) { CargarGrid(); }
        protected void btnLimpiar_Click(object sender, EventArgs e) { LimpiarFormulario(); }

        private void LimpiarFormulario()
        {
            hfIdCategoria.Value = "0";
            txtNombreCat.Text = "";
            txtDescripcionCat.Text = "";
            lblTituloFormulario.InnerHtml = "<i class='fas fa-folder-plus'></i> Nueva Categoría";
            btnGuardar.Text = "Registrar Categoría";
        }

        private void Alertar(string t, string m, string icon)
        {
            var ser = new JavaScriptSerializer();
            string jsonMsg = ser.Serialize(m);
            ScriptManager.RegisterStartupScript(this, GetType(), "alertVIP", $"showAlert('{t}', {jsonMsg}, '{icon}');", true);
        }
    }
}