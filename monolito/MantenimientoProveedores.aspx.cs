using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using Capa_Negocio;
using Capa_Datos;

namespace monolito
{
    public partial class MantenimientoProveedores : Page
    {
        private N_Proveedor objNegocio = new N_Proveedor();
        private DbMonolitoDataContext db = new DbMonolitoDataContext();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CargarGrid();
            }
        }

        private void CargarGrid()
        {
            try
            {
                var lista = db.tbl_proveedor.ToList();
                gvProveedores.DataSource = lista;
                gvProveedores.DataBind();
            }
            catch (Exception ex)
            {
                string error = ex.Message.Replace("'", "\\'").Replace("\n", " ");
                ScriptManager.RegisterStartupScript(this, GetType(), "errGrid", $"showAlert('Error de Carga', '{error}', 'error');", true);
            }
        }

        protected void chkVerInactivos_CheckedChanged(object sender, EventArgs e)
        {
            CargarGrid();
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            try
            {
                string respuesta = "";
                int id = Convert.ToInt32(hfIdProveedor.Value);

                if (id == 0) // MODO INSERTAR
                {
                    tbl_proveedor objProv = new tbl_proveedor();
                    objProv.prov_nombre = txtNombreProv.Text.Trim();
                    objProv.prov_contacto = txtContactoProv.Text.Trim();
                    objProv.prov_email = txtEmailProv.Text.Trim();
                    objProv.prov_estado = true; // Se mantiene por compatibilidad del modelo de base de datos si el campo es no nulo

                    respuesta = objNegocio.InsertarProveedor(objProv);
                }
                else // MODO ACTUALIZAR
                {
                    var objProv = db.tbl_proveedor.FirstOrDefault(p => p.prov_id == id);
                    if (objProv != null)
                    {
                        objProv.prov_nombre = txtNombreProv.Text.Trim();
                        objProv.prov_contacto = txtContactoProv.Text.Trim();
                        objProv.prov_email = txtEmailProv.Text.Trim();
                        db.SubmitChanges();
                        respuesta = "OK";
                    }
                    else
                    {
                        respuesta = "El proveedor no existe en el sistema.";
                    }
                }

                if (respuesta == "OK")
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "ok", "showAlert('¡Éxito!', 'Proveedor guardado correctamente.', 'success');", true);
                    LimpiarFormulario();
                    CargarGrid();
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "err", $"showAlert('Aviso', '{respuesta}', 'warning');", true);
                }
            }
            catch (Exception ex)
            {
                string error = ex.Message.Replace("'", "\\'").Replace("\n", " ");
                ScriptManager.RegisterStartupScript(this, GetType(), "fatal", $"showAlert('Error Crítico', '{error}', 'error');", true);
            }
        }

        protected void gvProveedores_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Editar")
            {
                int index = Convert.ToInt32(e.CommandArgument);
                GridViewRow row = gvProveedores.Rows[index];
                int idProv = Convert.ToInt32(gvProveedores.DataKeys[index].Value);

                hfIdProveedor.Value = idProv.ToString();
                txtNombreProv.Text = Server.HtmlDecode(row.Cells[1].Text).Trim();
                txtContactoProv.Text = Server.HtmlDecode(row.Cells[2].Text).Trim() == "&nbsp;" ? "" : Server.HtmlDecode(row.Cells[2].Text).Trim();
                txtEmailProv.Text = Server.HtmlDecode(row.Cells[3].Text).Trim() == "&nbsp;" ? "" : Server.HtmlDecode(row.Cells[3].Text).Trim();

                lblTituloFormulario.InnerHtml = "<i class='fas fa-pen'></i> Editando Proveedor";
                btnGuardar.Text = "Actualizar Proveedor";
            }
            else if (e.CommandName == "Eliminar")
            {
                int idProv = Convert.ToInt32(e.CommandArgument);

                using (DbMonolitoDataContext db = new DbMonolitoDataContext())
                {
                    var prov = db.tbl_proveedor.FirstOrDefault(p => p.prov_id == idProv);

                    if (prov != null)
                    {
                        // BORRADO FÍSICO REAL (Lo que pidió el Inge)
                        db.tbl_proveedor.DeleteOnSubmit(prov);
                        db.SubmitChanges();

                        // Gracias al ON DELETE SET NULL de la Base de Datos, los productos de este proveedor
                        // cambian automáticamente su prov_id a NULL de manera instantánea.

                        ScriptManager.RegisterStartupScript(this, GetType(), "delOk", "showAlert('Eliminado', 'El proveedor ha sido borrado físicamente y sus productos ahora están sin proveedor (NULL).', 'success');", true);
                        CargarGrid();
                    }
                }
            }
            // SE REMOVIÓ EL BLOQUE DE REACTIVAR YA QUE EL BORRADO ES FÍSICO DE VERDAD
        }

        protected void btnLimpiar_Click(object sender, EventArgs e)
        {
            LimpiarFormulario();
        }

        private void LimpiarFormulario()
        {
            hfIdProveedor.Value = "0";
            txtNombreProv.Text = "";
            txtContactoProv.Text = "";
            txtEmailProv.Text = "";

            lblTituloFormulario.InnerHtml = "<i class='fas fa-building'></i> Nuevo Proveedor";
            btnGuardar.Text = "Guardar Proveedor";
        }
    }
}