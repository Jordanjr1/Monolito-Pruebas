using System;
using System.Web.UI;
using Capa_Negocio;

namespace monolito
{
    public partial class ValidacionQR : Page
    {
        private N_Usuario objNegocio = new N_Usuario();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // SEGURIDAD: Verifica la variable PreAuth, no la oficial.
                if (Session["PreAuth_Email"] == null)
                {
                    Response.Redirect("~/Login.aspx", true);
                }
            }
        }

        protected void btnValidar_Click(object sender, EventArgs e)
        {
            // EL ESCUDO: Todo va dentro de un bloque try-catch para evitar Pantallas Amarillas
            try
            {
                // 1. Verificamos que la sesión no sea NULA justo al hacer clic (Evita tu error en la línea 26)
                if (Session["PreAuth_Email"] == null)
                {
                    Response.Redirect("~/Login.aspx", true);
                    return;
                }

                string email = Session["PreAuth_Email"].ToString();
                string codigoEscaneado = hfCodigoQR.Value;

                string respuesta = objNegocio.ValidarToken2FA(email, codigoEscaneado);

                if (respuesta == "OK")
                {
                    // GUARDAR EL REGISTRO (LOG) EN LA BASE DE DATOS
                    int idUser = Convert.ToInt32(Session["PreAuth_IdUser"]);
                    objNegocio.RegistrarAccesoExitoso(idUser);

                    // =========================================================
                    // FASE 2: CREACIÓN DE TOKEN VIP Y TRANSFERENCIA DE DATOS
                    // =========================================================

                    // 1. Generamos un Token Único Global
                    Session["AuthTokenVIP"] = Guid.NewGuid().ToString("N");

                    // 2. Transferimos las variables temporales a las oficiales
                    Session["IdUser"] = Session["PreAuth_IdUser"];
                    Session["FirstName"] = Session["PreAuth_FirstName"];
                    Session["LastName"] = Session["PreAuth_LastName"];
                    Session["Email"] = Session["PreAuth_Email"];
                    Session["Username"] = Session["PreAuth_Username"];

                    // SALVAVIDAS: Si PreAuth_UserTypeId no existe (null), conservamos el UserTypeId que tal vez ya venía del Login
                    Session["UserTypeId"] = Session["PreAuth_UserTypeId"];
                    Session["UserPhotoBase64"] = Session["PreAuth_UserPhoto"];

                    // 3. Destruimos las variables Pre-Auth por seguridad de memoria
                    Session.Remove("PreAuth_IdUser");
                    Session.Remove("PreAuth_FirstName");
                    Session.Remove("PreAuth_LastName");
                    Session.Remove("PreAuth_Email");
                    Session.Remove("PreAuth_Username");
                    Session.Remove("PreAuth_UserTypeId");
                    Session.Remove("PreAuth_UserPhoto");

                    // 4. Ingreso al Dashboard (Usamos 'true' para obligar a ASP.NET a guardar la sesión antes de irse)
                    Response.Redirect("~/Default.aspx", true);
                    Context.ApplicationInstance.CompleteRequest();
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", $"showErrorAlert('Acceso Denegado', '{respuesta}');", true);
                }
            }
            catch (NullReferenceException)
            {
                // ATRAE EL ERROR DE TU FOTO si la BD devuelve un null por un código falso
                ScriptManager.RegisterStartupScript(this, GetType(), "alertQR", "showErrorAlert('Código Incorrecto', 'El código que ingresaste no coincide o es inválido.');", true);
            }
            catch (Exception ex)
            {
                // ATRAE CUALQUIER OTRO ERROR (Problemas de red, BD caída, etc.)
                string mensajeLimpio = ex.Message.Replace("'", "\\'").Replace("\n", " ");
                ScriptManager.RegisterStartupScript(this, GetType(), "alertQR", $"showErrorAlert('Error del Sistema', '{mensajeLimpio}');", true);
            }
        }
    }
}