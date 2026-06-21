using BCrypt.Net;
using Capa_Datos;
using QRCoder;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Mail;
using System.Net.Mime;
using Twilio;
using Twilio.Rest.Api.V2010.Account;
using Twilio.Types;
using Capa_Datos;

namespace Capa_Negocio
{
    public class N_Usuario
    {
        private D_Usuario objDatos = new D_Usuario();

        public string GenerarYEnviarQRLogin(string email)
        {
            string codigoSecreto = Guid.NewGuid().ToString("N").Substring(0, 8).ToUpper();
            string hashOtp = BCrypt.Net.BCrypt.HashPassword(codigoSecreto);
            bool guardado = objDatos.ActualizarOtp(email, hashOtp);

            if (!guardado) return "Error al guardar el código de seguridad en la base de datos.";

            QRCodeGenerator qrGenerator = new QRCodeGenerator();
            QRCodeData qrCodeData = qrGenerator.CreateQrCode(codigoSecreto, QRCodeGenerator.ECCLevel.Q);
            PngByteQRCode qrCode = new PngByteQRCode(qrCodeData);
            byte[] qrBytes = qrCode.GetGraphic(20);

            return EnviarCorreoQR(email, qrBytes);
        }

        private string EnviarCorreoQR(string destino, byte[] imagenQrBytes)
        {
            try
            {
                System.Net.Mail.MailMessage mail = new System.Net.Mail.MailMessage();
                mail.From = new System.Net.Mail.MailAddress("jordanramos3323@gmail.com");
                mail.To.Add(destino);
                mail.Subject = "🔐 Acceso Seguro 2FA - Sistema VIP";
                mail.IsBodyHtml = true;

                mail.Body = @"
                <div style='font-family: ""Segoe UI"", Helvetica, Arial, sans-serif; max-width: 600px; margin: 0 auto; background-color: #f4f6f9; padding-bottom: 20px;'>
                    <div style='background-color: #1a1a1a; padding: 40px 20px; text-align: center; border-radius: 8px 8px 0 0;'>
                        <h1 style='color: #fad370; margin: 0; font-size: 28px; letter-spacing: 1px;'>SISTEMA VIP</h1>
                        <p style='color: #fad370; margin-top: 5px; font-size: 14px;'>Protocolo de Autenticación 2FA</p>
                    </div>
                    <div style='background-color: #ffffff; padding: 40px; border-radius: 0 0 8px 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.05);'>
                        <h2 style='text-align: center; color: #1a1a1a; font-size: 22px; margin-bottom: 20px;'>Doble Factor de Seguridad</h2>
                        <p style='color: #555; font-size: 15px; line-height: 1.6; text-align: center;'>Escanea el siguiente Código QR en la pantalla de validación de la aplicación para confirmar tu identidad y acceder al sistema.</p>
                        
                        <div style='text-align: center; margin: 30px 0; background-color: #f8f9fa; padding: 20px; border-radius: 12px; border: 2px dashed #fad370;'>
                            <img src='cid:qrCodeImage' alt='Código QR de Acceso' style='max-width: 250px; border-radius: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.1);' />
                        </div>
                        
                        <p style='color: #888; font-size: 12px; text-align: center;'>Este código es de uso único. Si no intentaste iniciar sesión, ignora este mensaje.</p>
                    </div>
                </div>";

                AlternateView avHtml = AlternateView.CreateAlternateViewFromString(mail.Body, null, MediaTypeNames.Text.Html);
                System.IO.Stream stream = new System.IO.MemoryStream(imagenQrBytes);
                LinkedResource lr = new LinkedResource(stream, "image/png");
                lr.ContentId = "qrCodeImage";

                avHtml.LinkedResources.Add(lr);
                mail.AlternateViews.Add(avHtml);

                System.Net.Mail.SmtpClient smtp = new System.Net.Mail.SmtpClient("smtp.gmail.com", 587);
                smtp.Credentials = new System.Net.NetworkCredential("jordanramos3323@gmail.com", "semtpkgjpwywdmhx");
                smtp.EnableSsl = true;

                smtp.Send(mail);
                return "OK";
            }
            catch (Exception ex)
            {
                return "Error al enviar correo con QR: " + ex.Message;
            }
        }

        public System.Collections.Generic.List<Users> ObtenerTodosLosUsuarios()
        {
            return objDatos.ObtenerTodosLosUsuarios();
        }

        public string VerificarDuplicados(string cedula, string email, string celular)
        {
            try
            {
                var usuarios = objDatos.ObtenerTodosLosUsuarios();

                if (usuarios.Any(u => u.tbl_cedula == cedula))
                    return "Protocolo de Seguridad: La cédula ingresada ya se encuentra registrada en el sistema.";

                if (usuarios.Any(u => u.tbl_email.ToLower() == email.ToLower()))
                    return "Protocolo de Seguridad: El correo electrónico ya posee una cuenta activa.";

                if (usuarios.Any(u => u.tbl_celular == celular))
                    return "Protocolo de Seguridad: Este número de celular ya está vinculado a otro dispositivo.";

                return "OK";
            }
            catch (Exception ex)
            {
                return "Error al verificar duplicados: " + ex.Message;
            }
        }

        public string RegistrarUsuario(Users nuevoUsuario)
        {
            try
            {
                string validacion = VerificarDuplicados(nuevoUsuario.tbl_cedula, nuevoUsuario.tbl_email, nuevoUsuario.tbl_celular);
                if (validacion != "OK") return validacion;

                bool creado = objDatos.RegistrarUsuario(nuevoUsuario);
                return creado ? "OK" : "Error de conexión al intentar guardar en la base de datos.";
            }
            catch (Exception ex)
            {
                return "Error en la capa de negocio (Registro): " + ex.Message;
            }
        }

        // Actualizado: int idUser cambiado por string idUser
        public string BloquearUsuarioManual(int idUser)
        {
            bool exito = objDatos.BloquearUsuarioManual(idUser);
            return exito ? "OK" : "Error al intentar bloquear al usuario en la base de datos.";
        }

        public int ObtenerTotalValidaciones2FA()
        {
            return objDatos.ObtenerTotalValidaciones2FA();
        }

        public System.Collections.Generic.List<Users> ObtenerUsuariosBloqueados()
        {
            return objDatos.ObtenerUsuariosBloqueados();
        }

        // Actualizado: int idUser cambiado por string idUser
        public string DesbloquearUsuario(int idUser)
        {
            bool exito = objDatos.DesbloquearUsuario(idUser);
            return exito ? "OK" : "Error al intentar desbloquear al usuario en la base de datos.";
        }

        public string RecuperarPassword(string email)
        {
            Users usuario = objDatos.ObtenerUsuarioPorEmail(email);
            if (usuario == null) return "Este correo no está registrado en el sistema.";

            string tempPass = Guid.NewGuid().ToString().Substring(0, 6) + "A1!";
            string hashString = BCrypt.Net.BCrypt.HashPassword(tempPass);
            byte[] hashBytes = System.Text.Encoding.UTF8.GetBytes(hashString);

            bool guardado = objDatos.ActualizarPassword(email, hashBytes, "TEMP");
            if (!guardado) return "Ocurrió un error al procesar la solicitud en la BD.";

            string resultadoCorreo = EnviarCorreoRecuperacion(usuario, tempPass);

            if (resultadoCorreo == "OK")
            {
                if (!string.IsNullOrEmpty(usuario.tbl_celular))
                {
                    string mensajeWpp = $"*Seguridad del Sistema VIP*\n\nHola {usuario.tbl_nombre},\nHas solicitado recuperar tu clave.\n\nTu contraseña temporal es: *{tempPass}*\n\nIngresa al sistema para cambiarla inmediatamente.";
                    EnviarMensajeWhatsApp(usuario.tbl_celular, mensajeWpp);
                }
                return "OK";
            }
            else
            {
                return "Error al enviar correo: " + resultadoCorreo;
            }
        }

        private string EnviarCorreoRecuperacion(Users usuario, string claveTemporal)
        {
            try
            {
                System.Net.Mail.MailMessage mail = new System.Net.Mail.MailMessage();
                mail.From = new System.Net.Mail.MailAddress("jordanramos3323@gmail.com");
                mail.To.Add(usuario.tbl_email);
                mail.Subject = "Recuperación de Contraseña - Seguridad VIP";
                mail.IsBodyHtml = true;

                mail.Body = $@"
                <div style='font-family: ""Segoe UI"", Helvetica, Arial, sans-serif; max-width: 600px; margin: 0 auto; background-color: #f4f6f9; padding-bottom: 20px;'>
                    <div style='background-color: #1a1a1a; padding: 40px 20px; text-align: center; border-radius: 8px 8px 0 0;'>
                        <h1 style='color: #fad370; margin: 0; font-size: 28px; letter-spacing: 1px;'>SISTEMA VIP</h1>
                        <p style='color: #fad370; margin-top: 5px; font-size: 14px;'>Gestión de seguridad. Inspira confianza.</p>
                    </div>
                    <div style='background-color: #ffffff; padding: 40px; border-radius: 0 0 8px 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.05);'>
                        <div style='text-align: center; margin-bottom: 30px;'>
                            <div style='background-color: #1a1a1a; width: 60px; height: 60px; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; margin: 0 auto;'>
                                <span style='font-size: 30px;'>🔐</span>
                            </div>
                        </div>
                        <h2 style='text-align: center; color: #1a1a1a; font-size: 22px; margin-bottom: 30px;'>Recuperación de Contraseña</h2>
                        <p style='color: #333; font-size: 15px;'>Hola <strong>{usuario.tbl_nombre.ToUpper()} {usuario.tbl_apellido.ToUpper()}</strong>,</p>
                        <p style='color: #555; font-size: 15px; line-height: 1.6;'>Hemos recibido una solicitud para recuperar tu contraseña en <strong>Sistema VIP</strong>. A continuación te proporcionamos una contraseña temporal:</p>
                        <div style='background-color: #f8f9fa; border: 2px dashed #fad370; border-radius: 12px; padding: 25px; text-align: center; margin: 30px 0;'>
                            <p style='color: #888; font-size: 12px; font-weight: bold; letter-spacing: 2px; margin-top: 0; margin-bottom: 15px;'>CONTRASEÑA TEMPORAL</p>
                            <div style='background-color: #1a1a1a; color: #fad370; font-family: ""Courier New"", Courier, monospace; font-size: 28px; font-weight: bold; padding: 15px; border-radius: 8px; letter-spacing: 4px; display: inline-block;'>
                                {claveTemporal}
                            </div>
                        </div>
                        <div style='background-color: #fdf8e4; border-left: 4px solid #fad370; padding: 20px; border-radius: 6px; margin-bottom: 30px;'>
                            <p style='margin: 0; color: #8a6d3b; font-size: 14px;'><strong style='color: #d59c00;'>⚠️ Importante:</strong> Por seguridad, deberás cambiar esta contraseña temporal al iniciar sesión.</p>
                            <p style='margin: 10px 0 0 0; color: #8a6d3b; font-size: 13px;'>Para acceder al sistema, utiliza tu correo (<strong>{usuario.tbl_email}</strong>) y esta contraseña temporal.</p>
                        </div>
                        <div style='background-color: #f8f9fa; border-radius: 8px; padding: 25px; border: 1px solid #eee;'>
                            <p style='margin-top: 0; font-weight: bold; color: #333; font-size: 14px;'>📋 Requisitos para tu nueva contraseña:</p>
                            <div style='display: flex; flex-wrap: wrap; gap: 10px;'>
                                <div style='background: #fff; border: 1px solid #ddd; padding: 10px; border-radius: 6px; font-size: 13px; color: #555; flex: 1; min-width: 40%;'>✓ 8-12 caracteres</div>
                                <div style='background: #fff; border: 1px solid #ddd; padding: 10px; border-radius: 6px; font-size: 13px; color: #555; flex: 1; min-width: 40%;'>✓ 1 mayúscula</div>
                                <div style='background: #fff; border: 1px solid #ddd; padding: 10px; border-radius: 6px; font-size: 13px; color: #555; flex: 1; min-width: 40%;'>✓ 1 minúscula</div>
                                <div style='background: #fff; border: 1px solid #ddd; padding: 10px; border-radius: 6px; font-size: 13px; color: #555; flex: 1; min-width: 40%;'>✓ 1 número</div>
                                <div style='background: #fff; border: 1px solid #ddd; padding: 10px; border-radius: 6px; font-size: 13px; color: #555; width: 100%; text-align: center;'>✓ 1 carácter especial (@#$%^&+=!.,;)</div>
                            </div>
                        </div>
                        <p style='color: #888; font-size: 12px; margin-top: 30px; text-align: center;'><strong>Nota:</strong> Si no solicitaste esta recuperación, por favor contacta inmediatamente al administrador.</p>
                    </div>
                    <div style='background-color: #1a1a1a; padding: 25px; text-align: center; border-radius: 0 0 8px 8px; margin-top: 20px;'>
                        <p style='color: #fad370; margin: 0; font-size: 14px;'>Sistema VIP - Gestión de Seguridad</p>
                        <p style='color: #777; font-size: 12px; margin-top: 5px;'>&copy; 2026 Todos los derechos reservados.<br>Este es un correo automático, por favor no responder.</p>
                    </div>
                </div>";

                System.Net.Mail.SmtpClient smtp = new System.Net.Mail.SmtpClient("smtp.gmail.com", 587);
                smtp.Credentials = new System.Net.NetworkCredential("jordanramos3323@gmail.com", "semtpkgjpwywdmhx");
                smtp.EnableSsl = true;

                smtp.Send(mail);
                return "OK";
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        public string CambiarPasswordObligatorio(string email, string nuevaClave)
        {
            string hashString = BCrypt.Net.BCrypt.HashPassword(nuevaClave);
            byte[] hashBytes = System.Text.Encoding.UTF8.GetBytes(hashString);

            bool exito = objDatos.ActualizarPassword(email, hashBytes, null);
            return exito ? "OK" : "Error al actualizar la base de datos.";
        }

        public string ValidarToken2FA(string email, string tokenEscaneado)
        {
            Users usuario = objDatos.ObtenerUsuarioPorEmail(email);

            if (usuario == null) return "Usuario no encontrado.";
            if (string.IsNullOrEmpty(usuario.tbl_OtpCode) || usuario.tbl_OtpCode == "TEMP")
                return "No hay un código de validación pendiente.";

            bool esValido = BCrypt.Net.BCrypt.Verify(tokenEscaneado, usuario.tbl_OtpCode);

            if (esValido)
            {
                objDatos.ActualizarOtp(email, null);
                return "OK";
            }
            else
            {
                return "El Código QR es incorrecto o pertenece a una sesión antigua.";
            }
        }

        public Users ValidarLogin(string identificador, string password, out string mensaje)
        {
            mensaje = "";
            Users usuario = objDatos.Login(identificador);

            if (usuario == null)
            {
                mensaje = "El usuario no existe.";
                return null;
            }

            if (usuario.tbl_ultimo_intento.HasValue && usuario.tbl_ultimo_intento.Value.Date < DateTime.Now.Date)
            {
                usuario.tbl_numerodeintentos_fallidos = 0;
                usuario.tbl_activo = true;
            }

            if (usuario.tbl_activo == false)
            {
                mensaje = "Tu cuenta está bloqueada por demasiados intentos fallidos. Intenta mañana o contacta al administrador.";
                return null;
            }

            bool claveCorrecta = BCrypt.Net.BCrypt.Verify(password, System.Text.Encoding.UTF8.GetString(usuario.tbl_PasswordHash.ToArray()));

            if (claveCorrecta)
            {
                usuario.tbl_numerodeintentos_fallidos = 0;
                usuario.tbl_ultimo_intento = DateTime.Now;
                objDatos.ActualizarEntidad(usuario);
                return usuario;
            }
            else
            {
                usuario.tbl_numerodeintentos_fallidos += 1;
                usuario.tbl_ultimo_intento = DateTime.Now;

                if (usuario.tbl_numerodeintentos_fallidos >= 3)
                {
                    usuario.tbl_activo = false;
                    mensaje = "Has agotado tus 3 intentos. Tu cuenta ha sido bloqueada hasta mañana.";
                }
                else
                {
                    int restantes = 3 - (int)usuario.tbl_numerodeintentos_fallidos;
                    mensaje = $"Contraseña incorrecta. Te quedan {restantes} intentos.";
                }

                objDatos.ActualizarEntidad(usuario);
                return null;
            }
        }

        // Actualizado: int idUser cambiado por string idUser
        public void RegistrarAccesoExitoso(int idUser)
        {
            objDatos.RegistrarLogAcceso(idUser);
        }

        private void EnviarMensajeWhatsApp(string numeroDestino, string mensaje)
        {
            try
            {
                string accountSid = "TU_TWILIO_ACCOUNT_SID_AQUI";
                string authToken = "TU_TWILIO_AUTH_TOKEN_AQUI";

                TwilioClient.Init(accountSid, authToken);

                string numeroFormateado = "+593" + numeroDestino.TrimStart('0');
                var messageOptions = new CreateMessageOptions(new PhoneNumber("whatsapp:" + numeroFormateado));

                messageOptions.From = new PhoneNumber("whatsapp:+14155238886");
                messageOptions.Body = mensaje;

                var msg = MessageResource.Create(messageOptions);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error de Twilio: " + ex.Message);
            }
        }
    }
}