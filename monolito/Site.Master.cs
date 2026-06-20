using System;
using System.Web;

namespace monolito
{
    public partial class SiteMaster : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // =========================================================
            // 1. ESCUDO ANTI-CACHÉ (Bloquea la flecha "Atrás" del navegador)
            // =========================================================
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetExpires(DateTime.UtcNow.AddHours(-1));
            Response.Cache.SetNoStore();
            Response.AppendHeader("Pragma", "no-cache");

            string currentPage = Request.AppRelativeCurrentExecutionFilePath.ToLower();

            bool isPublicPage = currentPage.Contains("login") ||
                                currentPage.Contains("cambiarclave") ||
                                currentPage.Contains("registro");

            // =========================================================
            // 2. VERIFICACIÓN DEL TOKEN DE DOBLE FASE (Estilo Facebook)
            // =========================================================
            System.Diagnostics.Debug.WriteLine($"--- CONTROL: Token = {Session["AuthTokenVIP"]}, Rol = {Session["UserTypeId"]}");
            if (Session["AuthTokenVIP"] == null || Session["UserTypeId"] == null)
            {
                // Si no tiene el Token definitivo y NO está en una página pública o en el QR
                if (!isPublicPage && !currentPage.Contains("validacionqr"))
                {
                    Session.Abandon();
                    Response.Redirect("~/Login.aspx", true);
                    return; // Cortamos la ejecución por seguridad
                }
                else
                {
                    // Si está en el login o QR pero sin Token VIP, apagamos los menús
                    sidebar.Visible = false;
                    topbar.Visible = false;
                }
            }
            else
            {
                // ==========================================
                // ¡HAY SESIÓN VIP! El usuario completó el QR
                // ==========================================

                // Si intenta volver al Login o al QR, lo mandamos al Dashboard
                if (currentPage.Contains("login") || currentPage.Contains("validacionqr"))
                {
                    Response.Redirect("~/Default.aspx", true);
                    return;
                }

                if (currentPage.Contains("cambiarclave"))
                {
                    sidebar.Visible = false;
                    topbar.Visible = false;
                }

                if (!IsPostBack)
                {
                    // Capturamos nombre y apellido para el menú y las iniciales
                    string nombre = Session["FirstName"]?.ToString() ?? "V";
                    string apellido = Session["LastName"]?.ToString() ?? "P";

                    lblTopName.Text = nombre + " " + apellido;

                    // Asignación de Roles y Menús
                    string roleId = Session["UserTypeId"]?.ToString();
                    if (roleId == "1")
                    {
                        lblTopRole.Text = "ADMINISTRADOR";
                        phMenuAdmin.Visible = true;
                    }
                    else if (roleId == "2")
                    {
                        lblTopRole.Text = "USUARIO VIP";
                        phMenuUsuario.Visible = true;
                    }

                    // Lógica de la Foto de Perfil
                    if (Session["UserPhotoBase64"] != null)
                    {
                        imgAvatar.ImageUrl = Session["UserPhotoBase64"].ToString();
                        imgAvatar.Visible = true;
                        avatarInitials.Visible = false;
                    }
                    else
                    {
                        string iniciales = (nombre.Substring(0, 1) + apellido.Substring(0, 1)).ToUpper();
                        avatarInitials.InnerText = iniciales;

                        imgAvatar.Visible = false;
                        avatarInitials.Visible = true;
                    }
                }
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            // Destrucción total del Token y la sesión
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Login.aspx", true);
        }
    }
}