using Capa_Datos;
using Capa_Negocio;
using System;
using System.Web;
using System.Web.UI;

namespace monolito
{
    public partial class Login : Page
    {
        // Instanciamos la Capa de Negocio (Nuestro cerebro)
        private N_Usuario objNegocio = new N_Usuario();

        // Declaración de controles (Asegúrate que coincidan con tu ID en el ASPX)
        protected global::System.Web.UI.WebControls.TextBox txtIdentifier;
        protected global::System.Web.UI.WebControls.TextBox txtPassword;
        protected global::System.Web.UI.WebControls.HiddenField hfEmailRecuperar;
        protected global::System.Web.UI.WebControls.Button btnOcultoRecuperar;
        protected global::System.Web.UI.WebControls.CheckBox chkRemember;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Limpieza de cualquier sesión previa al cargar el login
                Session.Clear();

                // Recuperación de Cookies si existen
                if (Request.Cookies["UserAuth"] != null)
                {
                    txtIdentifier.Text = Request.Cookies["UserAuth"]["Username"];
                    string base64Password = Request.Cookies["UserAuth"]["Password"];
                    byte[] pwdBytes = Convert.FromBase64String(base64Password);
                    string passwordReal = System.Text.Encoding.UTF8.GetString(pwdBytes);

                    txtPassword.Attributes["value"] = passwordReal;
                    chkRemember.Checked = true;
                }
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string identifier = txtIdentifier.Text.Trim();
            string password = txtPassword.Text;
            string mensajeSalida = "";

            if (string.IsNullOrEmpty(identifier) || string.IsNullOrEmpty(password))
            {
                RegisterStartupScript("showErrorAlert('Campos Incompletos', 'Por favor, introduce tu correo/usuario y contraseña.');");
                return;
            }

            // 1. Validar usando la Capa de Negocio
            Users usuario = objNegocio.ValidarLogin(identifier, password, out mensajeSalida);

            if (usuario != null)
            {
                // =========================================================
                // FASE 1: VARIABLES PRE-AUTH (Cuarentena)
                // Esto evita que el usuario entre al sistema sin pasar por el QR.
                // =========================================================
                Session["PreAuth_IdUser"] = usuario.IdUser;
                Session["PreAuth_FirstName"] = usuario.tbl_nombre;
                Session["PreAuth_LastName"] = usuario.tbl_apellido;
                Session["PreAuth_Email"] = usuario.tbl_email;
                Session["PreAuth_Username"] = usuario.tbl_nickame;
                Session["PreAuth_UserTypeId"] = usuario.tbl_UsertypeID;

                if (usuario.tbl_foto != null)
                {
                    byte[] photoBytes = usuario.tbl_foto.ToArray();
                    string base64String = Convert.ToBase64String(photoBytes, 0, photoBytes.Length);
                    Session["PreAuth_UserPhoto"] = "data:image/jpeg;base64," + base64String;
                }
                else
                {
                    Session["PreAuth_UserPhoto"] = null;
                }

                // Lógica de Cookies
                if (chkRemember.Checked)
                {
                    HttpCookie authCookie = new HttpCookie("UserAuth");
                    authCookie.Values["Username"] = identifier;
                    byte[] pwdBytes = System.Text.Encoding.UTF8.GetBytes(password);
                    authCookie.Values["Password"] = Convert.ToBase64String(pwdBytes);
                    authCookie.Expires = DateTime.Now.AddDays(30);
                    Response.Cookies.Add(authCookie);
                }
                else
                {
                    if (Request.Cookies["UserAuth"] != null)
                    {
                        HttpCookie authCookie = new HttpCookie("UserAuth");
                        authCookie.Expires = DateTime.Now.AddDays(-1);
                        Response.Cookies.Add(authCookie);
                    }
                }

                // Verificación de flujo
                if (usuario.tbl_OtpCode == "TEMP")
                {
                    Session["EmailRecuperacion"] = usuario.tbl_email;
                    Session["ClaveTemporalUsada"] = password;
                    ScriptManager.RegisterStartupScript(this, GetType(), "redirect", "window.location.href = 'CambiarClave.aspx';", true);
                }
                else
                {
                    // Mandamos el QR
                    string respuestaQR = objNegocio.GenerarYEnviarQRLogin(usuario.tbl_email);

                    if (respuestaQR == "OK")
                    {
                        Response.Redirect("~/ValidacionQR.aspx", false);
                        Context.ApplicationInstance.CompleteRequest();
                    }
                    else
                    {
                        RegisterStartupScript($"showErrorAlert('Error de Seguridad 2FA', '{respuestaQR}');");
                    }
                }
            }
            else
            {
                RegisterStartupScript($"showErrorAlert('Aviso de Seguridad', '{mensajeSalida}');");
            }
        }

        protected void btnOcultoRecuperar_Click(object sender, EventArgs e)
        {
            string email = hfEmailRecuperar.Value;
            string respuesta = objNegocio.RecuperarPassword(email);

            if (respuesta == "OK")
            {
                RegisterStartupScript("Swal.fire({ title: '¡Clave Enviada!', text: 'Se ha enviado una contraseña temporal a tu correo. Por favor, revisa tu bandeja de entrada e inicia sesión con ella.', icon: 'success', background: '#1e1e24', color: '#fff', confirmButtonColor: '#fad370' });");
            }
            else
            {
                RegisterStartupScript($"showErrorAlert('Aviso', '{respuesta}');");
            }
        }

        private void RegisterStartupScript(string script)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "alertScript", script, true);
        }
    }
}