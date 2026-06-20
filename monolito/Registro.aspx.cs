using System;
using System.IO;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using BCrypt.Net;
using System.Text.RegularExpressions;
using System.Linq;

// IMPORTAMOS TUS NUEVAS CAPAS ARQUITECTÓNICAS
using Capa_Negocio;
using Capa_Datos;

namespace monolito
{
    public partial class Registro : Page
    {
        // --- DECLARACIÓN MANUAL DE CONTROLES ---
        protected global::System.Web.UI.WebControls.TextBox txtNombres;
        protected global::System.Web.UI.WebControls.TextBox txtLastName;
        protected global::System.Web.UI.WebControls.TextBox txtBirthDate;
        protected global::System.Web.UI.WebControls.RadioButtonList rblGender;
        protected global::System.Web.UI.WebControls.TextBox txtEmail;
        protected global::System.Web.UI.WebControls.TextBox txtEcuadorianId;
        protected global::System.Web.UI.WebControls.TextBox txtCellphone;
        protected global::System.Web.UI.WebControls.TextBox txtUsername;
        protected global::System.Web.UI.WebControls.FileUpload fuPhoto;
        protected global::System.Web.UI.WebControls.TextBox txtPassword;
        protected global::System.Web.UI.WebControls.TextBox txtConfirmPassword;
        protected global::System.Web.UI.WebControls.TextBox txtAddress;
        protected global::System.Web.UI.WebControls.Button btnRegister;

        // Controles de foto añadidos manualmente
        protected global::System.Web.UI.WebControls.Button btnPreview;
        protected global::System.Web.UI.WebControls.Image imgPreview;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl defaultIcon;
        // ---------------------------------------

        // INSTANCIAMOS EL CEREBRO DEL SISTEMA (CAPA DE NEGOCIO)
        private N_Usuario objNegocio = new N_Usuario();

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                try
                {
                    // ==========================================
                    // INICIO DE VALIDACIONES EXTREMAS
                    // ==========================================
                    string nombres = txtNombres.Text.Trim();
                    string apellidos = txtLastName.Text.Trim();
                    string cedula = txtEcuadorianId.Text.Trim();
                    string correo = txtEmail.Text.Trim();
                    string direccion = txtAddress.Text.Trim();
                    string celular = txtCellphone.Text.Trim();

                    // 1. Validar NOMBRES
                    if (string.IsNullOrEmpty(nombres)) { RegisterStartupScript("showErrorAlert('Error', 'Los nombres no pueden quedar en blanco.');"); return; }
                    if (nombres.Length > 100) { RegisterStartupScript("showErrorAlert('Error', 'Los nombres no pueden sobrepasar los 100 caracteres.');"); return; }
                    if (Regex.IsMatch(nombres, @"\d")) { RegisterStartupScript("showErrorAlert('Error', 'Los nombres no pueden contener números.');"); return; }
                    if (nombres.Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries).Length < 2)
                    {
                        RegisterStartupScript("showErrorAlert('Falta un Nombre', 'Debes ingresar 2 nombres obligatoriamente. Si solo tienes un nombre, te recomendamos escribirlo dos veces para evitar caídas del sistema.');");
                        return;
                    }

                    // 2. Validar APELLIDOS
                    if (string.IsNullOrEmpty(apellidos)) { RegisterStartupScript("showErrorAlert('Error', 'Los apellidos no pueden quedar en blanco.');"); return; }
                    if (apellidos.Length > 100) { RegisterStartupScript("showErrorAlert('Error', 'Los apellidos no pueden sobrepasar los 100 caracteres.');"); return; }
                    if (Regex.IsMatch(apellidos, @"\d")) { RegisterStartupScript("showErrorAlert('Error', 'Los apellidos no pueden contener números.');"); return; }
                    if (apellidos.Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries).Length < 2)
                    {
                        RegisterStartupScript("showErrorAlert('Falta un Apellido', 'Debes ingresar 2 apellidos obligatoriamente. Si solo tienes un apellido, te recomendamos escribirlo dos veces para evitar caídas del sistema.');");
                        return;
                    }

                    // 3. Validar CÉDULA
                    if (string.IsNullOrEmpty(cedula)) { RegisterStartupScript("showErrorAlert('Error', 'La cédula no puede estar en blanco.');"); return; }
                    if (!Regex.IsMatch(cedula, @"^\d{1,10}$")) { RegisterStartupScript("showErrorAlert('Error', 'La cédula solo permite hasta 10 números. No se permiten letras ni caracteres especiales.');"); return; }

                    var digitosCedula = cedula.GroupBy(c => c);
                    foreach (var grupo in digitosCedula)
                    {
                        if (grupo.Count() > 7)
                        {
                            RegisterStartupScript("showErrorAlert('Cédula Inválida', 'La cédula no puede contener el mismo número repetido más de 7 veces por seguridad.');");
                            return;
                        }
                    }

                    // 4. Validar CORREO
                    if (string.IsNullOrEmpty(correo)) { RegisterStartupScript("showErrorAlert('Error', 'El correo no puede estar en blanco.');"); return; }
                    if (correo.Length > 150) { RegisterStartupScript("showErrorAlert('Error', 'El correo no puede sobrepasar los 150 caracteres.');"); return; }
                    if (!Regex.IsMatch(correo, @"^[^@\s]+@[^@\s]+\.[^@\s]+$")) { RegisterStartupScript("showErrorAlert('Formato Inválido', 'El correo debe tener el formato correcto (ejemplo@correo.com).');"); return; }

                    // 5. Validar DIRECCIÓN
                    if (string.IsNullOrEmpty(direccion)) { RegisterStartupScript("showErrorAlert('Error', 'La dirección no puede estar en blanco.');"); return; }
                    if (direccion.Length > 100) { RegisterStartupScript("showErrorAlert('Error', 'La dirección no puede sobrepasar los 100 caracteres.');"); return; }

                    // 6. Validar CELULAR
                    if (string.IsNullOrEmpty(celular)) { RegisterStartupScript("showErrorAlert('Error', 'El celular no puede estar en blanco.');"); return; }
                    if (!Regex.IsMatch(celular, @"^\d{1,10}$")) { RegisterStartupScript("showErrorAlert('Error', 'El celular solo permite hasta 10 números, sin letras ni caracteres especiales.');"); return; }

                    // ==========================================
                    // 7. ESCUDO ANTI-DUPLICADOS (Base de Datos)
                    // ==========================================
                    // Llamamos a la Capa de Negocio para verificar la existencia de los datos críticos
                    string mensajeDuplicado = objNegocio.VerificarDuplicados(cedula, correo, celular);

                    if (mensajeDuplicado != "OK")
                    {
                        // Limpiamos saltos de línea por si el mensaje viene desde SQL
                        string mensajeSeguro = mensajeDuplicado.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
                        RegisterStartupScript($"showErrorAlert('Acceso Denegado', '{mensajeSeguro}');");
                        return;
                    }

                    // ==========================================
                    // FIN DE VALIDACIONES
                    // ==========================================

                    Users nuevoUsuario = new Users();

                    nuevoUsuario.tbl_nombre = nombres;
                    nuevoUsuario.tbl_apellido = apellidos;
                    nuevoUsuario.tbl_fecha = DateTime.Parse(txtBirthDate.Text);
                    nuevoUsuario.tbl_email = correo;
                    nuevoUsuario.tbl_cedula = cedula;
                    nuevoUsuario.tbl_celular = celular;
                    nuevoUsuario.tbl_direccion = direccion;

                    nuevoUsuario.tbl_nickame = Request.Form[txtUsername.UniqueID] ?? txtUsername.Text.Trim();
                    nuevoUsuario.tbl_genero = rblGender.SelectedValue;

                    nuevoUsuario.tbl_activo = true;
                    nuevoUsuario.tbl_fecha_de_registro = DateTime.Now;
                    nuevoUsuario.tbl_UsertypeID = 2;
                    nuevoUsuario.tbl_numerodeintentos_fallidos = 0;
                    nuevoUsuario.tbl_OtpCode = null;

                    string passwordHashString = BCrypt.Net.BCrypt.HashPassword(txtPassword.Text);
                    nuevoUsuario.tbl_PasswordHash = new System.Data.Linq.Binary(System.Text.Encoding.UTF8.GetBytes(passwordHashString));

                    // --- LÓGICA DE FOTO ÚNICA ---
                    byte[] photoBytes = null;

                    if (fuPhoto.HasFile)
                    {
                        int length = fuPhoto.PostedFile.ContentLength;
                        photoBytes = new byte[length];
                        fuPhoto.PostedFile.InputStream.Read(photoBytes, 0, length);
                    }
                    else if (Session["TempPhoto"] != null)
                    {
                        photoBytes = (byte[])Session["TempPhoto"];
                        Session.Remove("TempPhoto"); // Limpiamos la memoria
                    }

                    if (photoBytes != null)
                    {
                        nuevoUsuario.tbl_foto = new System.Data.Linq.Binary(photoBytes);
                    }
                    else
                    {
                        nuevoUsuario.tbl_foto = null;
                    }

                    
                    string respuestaDelNegocio = objNegocio.RegistrarUsuario(nuevoUsuario);

                    if (respuestaDelNegocio == "OK")
                    {
                        RegisterStartupScript("showSuccessAlert('¡Registro VIP Exitoso!', 'Tu cuenta ha sido creada y protegida.', 'Login.aspx');");
                    }
                    else
                    {
                        // Limpieza de caracteres de error desde la base de datos
                        string avisoSeguro = respuestaDelNegocio.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
                        RegisterStartupScript($"showErrorAlert('Aviso', '{avisoSeguro}');");
                    }
                }
                catch (Exception ex)
                {
                    // Esto mostrará el error real que viene desde el SQL de la nube
                    string errorSeguro = ex.Message.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
                    RegisterStartupScript($"showErrorAlert('Error de BD', '{errorSeguro}');");
                }
            }
        }

        protected void btnPreview_Click(object sender, EventArgs e)
        {
            if (fuPhoto.HasFile)
            {
                string fileExtension = System.IO.Path.GetExtension(fuPhoto.FileName).ToLower();
                if (fileExtension == ".jpg" || fileExtension == ".jpeg" || fileExtension == ".png")
                {
                    int length = fuPhoto.PostedFile.ContentLength; //leer el tamaño con el ContentLength
                    byte[] photoBytes = new byte[length];
                    fuPhoto.PostedFile.InputStream.Read(photoBytes, 0, length);
                    //extraer datos con el input


                    Session["TempPhoto"] = photoBytes;

                    string base64String = Convert.ToBase64String(photoBytes, 0, photoBytes.Length);
                    imgPreview.ImageUrl = "data:image/jpeg;base64," + base64String;

                    imgPreview.Style["display"] = "block";
                    defaultIcon.Style["display"] = "none";

                    ScriptManager.RegisterStartupScript(this, GetType(), "alertInfo", "Swal.fire({ title: 'Foto cargada', text: 'Tu foto de perfil está lista para guardarse.', icon: 'success', background: '#1e1e24', color: '#fff', confirmButtonColor: '#fad370', timer: 2000 });", true);
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", "showErrorAlert('Formato inválido', 'Solo se permiten imágenes en formato JPG o PNG.');", true);
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "showErrorAlert('Aviso', 'Primero selecciona una foto para subir.');", true);
            }
        }

        private void RegisterStartupScript(string script)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "alertScript", script, true);
        }
    }
}