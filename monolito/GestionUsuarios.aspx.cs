using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using Capa_Negocio;

namespace monolito
{
    public partial class GestionUsuarios : Page
    {
        private N_Usuario objNegocio = new N_Usuario();


        protected void Page_Load(object sender, EventArgs e)
        {
            // Seguridad: Solo los Administradores (Rol 1) pueden ver esta página
            if (Session["UserTypeId"] == null || Session["UserTypeId"].ToString() != "1")
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                CargarUsuarios();
            }
        }

        private void CargarUsuarios()
        {
            try
            {
                // Llamamos a la lista completa para ver activos y bloqueados
                var lista = objNegocio.ObtenerTodosLosUsuarios();
                gvUsuarios.DataSource = lista;
                gvUsuarios.DataBind();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", $"showErrorAlert('Error', 'No se pudieron cargar los datos: {ex.Message.Replace("'", "\\'")}');", true);
            }
        }

        protected void gvUsuarios_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            try
            {
                int idUser = Convert.ToInt32(e.CommandArgument);

                if (e.CommandName == "Desbloquear")
                {
                    string resultado = objNegocio.DesbloquearUsuario(idUser);
                    if (resultado == "OK")
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "alert", "showSuccessAlert('Usuario Desbloqueado', 'El usuario ahora tiene acceso libre al sistema.');", true);
                        CargarUsuarios(); // Recargamos la tabla para ver el cambio de color
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "alert", $"showErrorAlert('Aviso', '{resultado}');", true);
                    }
                }
                else if (e.CommandName == "Bloquear")
                {
                    // Nota: Si no tienes método de "BloquearUsuario" en tu capa de negocio, 
                    // te enseño cómo agregarlo en el paso 3.
                    string resultado = objNegocio.BloquearUsuarioManual(idUser);
                    if (resultado == "OK")
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "alert", "showSuccessAlert('Usuario Bloqueado', 'Se ha revocado el acceso a este usuario manualmente.');", true);
                        CargarUsuarios(); // Recargamos la tabla
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "alert", $"showErrorAlert('Aviso', '{resultado}');", true);
                    }
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", $"showErrorAlert('Error de ejecución', '{ex.Message.Replace("'", "\\'")}');", true);
            }
        }
    }
}