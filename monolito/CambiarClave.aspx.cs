using System;
using Capa_Negocio;
using Capa_Datos;
using System.Web.UI;

namespace monolito
{
    public partial class CambiarClave : System.Web.UI.Page
    {
        N_Usuario objNegocio = new N_Usuario();
        D_Usuario objDatos = new D_Usuario();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Verificamos que venga del flujo de recuperación Y que tengamos la clave
                if (Session["EmailRecuperacion"] == null || Session["ClaveTemporalUsada"] == null)
                {
                    Response.Redirect("Login.aspx");
                }
                else
                {
                    string email = Session["EmailRecuperacion"].ToString();
                    lblCorreoReadOnly.Text = email.ToLower();

                    // Llenamos la clave temporal automáticamente y la bloqueamos
                    txtClaveTemporal.Text = Session["ClaveTemporalUsada"].ToString();
                    txtClaveTemporal.ReadOnly = true;

                    Users u = objDatos.ObtenerUsuarioPorEmail(email);
                    if (u != null)
                    {
                        lblNombreUsuario.Text = (u.tbl_nombre + " " + u.tbl_apellido).ToUpper();
                    }
                }
            }
        }

        protected void btnCambiar_Click(object sender, EventArgs e)
        {
            string email = Session["EmailRecuperacion"].ToString();
            string nueva = txtNuevaClave.Text;
            string confirma = txtConfirmarClave.Text;

            if (nueva != confirma)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "err", "mostrarAlerta('Error', 'Las contraseñas no coinciden.', 'error', '');", true);
                return;
            }

            string resultado = objNegocio.CambiarPasswordObligatorio(email, nueva);

            if (resultado == "OK")
            {
                // ===============================================================
                // LA SOLUCIÓN VIP: DESTRUIR LA SESIÓN POR COMPLETO
                // ===============================================================
                // Ya no solo borramos las variables de recuperación, 
                // matamos TODA la sesión para forzar un re-login desde cero.
                Session.Clear();    // Limpia los datos almacenados
                Session.Abandon();  // Destruye el ID de sesión en el servidor

                // Alerta con mensaje actualizado para que el usuario sepa qué hacer
                ScriptManager.RegisterStartupScript(this, GetType(), "ok", "mostrarAlerta('¡Protocolo Exitoso!', 'Contraseña actualizada. Por favor, inicia sesión con tus nuevas credenciales.', 'success', 'Login.aspx');", true);
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "err", $"mostrarAlerta('Error', '{resultado}', 'error', '');", true);
            }
        }
    }
}