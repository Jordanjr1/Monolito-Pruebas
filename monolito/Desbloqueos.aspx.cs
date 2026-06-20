using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Capa_Negocio;

namespace monolito
{
    public partial class Desbloqueos : Page
    {
        N_Usuario objNegocio = new N_Usuario();

        protected void Page_Load(object sender, EventArgs e)
        {
            // Seguridad: Si alguien entra poniendo la URL manual y NO es Admin (1), lo pateamos
            if (Session["UserTypeId"] == null || Session["UserTypeId"].ToString() != "1")
            {
                Response.Redirect("~/Login.aspx");
            }

            if (!IsPostBack)
            {
                CargarUsuariosBloqueados();
            }
        }

        private void CargarUsuariosBloqueados()
        {
            // Pedimos la lista al negocio y la pintamos en la tabla
            gvBloqueados.DataSource = objNegocio.ObtenerUsuariosBloqueados();
            gvBloqueados.DataBind();
        }

        // Este evento salta cuando el Admin le da clic a un botón dentro de la tabla
        protected void gvBloqueados_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Desbloquear")
            {
                // Atrapamos el ID del usuario que está en ese botón
                int idUsuario = Convert.ToInt32(e.CommandArgument);

                string respuesta = objNegocio.DesbloquearUsuario(idUsuario);

                if (respuesta == "OK")
                {
                    // Recargamos la tabla para que el usuario desaparezca de la lista
                    CargarUsuariosBloqueados();
                    ScriptManager.RegisterStartupScript(this, GetType(), "exito", "Swal.fire({ title: '¡Desbloqueado!', text: 'El usuario ya puede ingresar nuevamente al sistema.', icon: 'success', background: '#1e1e24', color: '#fff', confirmButtonColor: '#4cd137' });", true);
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "error", $"Swal.fire('Error', '{respuesta}', 'error');", true);
                }
            }
        }
    }
}