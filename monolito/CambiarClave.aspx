<%@ Page Title="Cambio de Contraseña" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CambiarClave.aspx.cs" Inherits="monolito.CambiarClave" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
        /* Animaciones */
        @keyframes fadeSlideUp {
            0% { opacity: 0; transform: translateY(40px); }
            100% { opacity: 1; transform: translateY(0); }
        }
        
        @keyframes pulseGlow {
            0% { box-shadow: 0 0 15px rgba(250, 211, 112, 0.2); }
            50% { box-shadow: 0 0 30px rgba(250, 211, 112, 0.6); }
            100% { box-shadow: 0 0 15px rgba(250, 211, 112, 0.2); }
        }

        .page-wrapper {
            background-color: #050505;
            margin: -20px -15px; 
            min-height: 90vh;
            display: flex; align-items: center; justify-content: center;
            padding: 40px 20px;
        }

        .split-container {
            display: flex; width: 100%; max-width: 1250px; min-height: 650px;
            background: #0a0a0a; border-radius: 15px; overflow: hidden; 
            box-shadow: 0 20px 50px rgba(0,0,0,0.9);
            border: 1px solid rgba(250, 211, 112, 0.2);
            animation: fadeSlideUp 0.8s ease-out;
        }

        /* PANEL IZQUIERDO */
        .left-panel {
            flex: 1; padding: 50px; display: flex; flex-direction: column; justify-content: center;
            background: linear-gradient(to right, rgba(10, 10, 10, 0.95), rgba(20, 18, 14, 0.8)), url('https://images.unsplash.com/photo-1550751827-4bd374c3f58b?q=80&w=1200') center/cover;
            border-right: 2px solid #fad370;
            position: relative;
        }

        .left-panel h2 { font-family: 'Playfair Display', serif; color: #fad370; font-size: 3em; margin-bottom: 10px; text-transform: uppercase; letter-spacing: 2px; }
        
        .requirements-box {
            background: rgba(0, 0, 0, 0.7); border: 1px solid rgba(250, 211, 112, 0.3);
            padding: 25px; border-radius: 12px; margin-top: 30px; backdrop-filter: blur(5px);
        }
        .requirements-box ul { list-style: none; padding: 0; color: #ddd; font-size: 1em; line-height: 2; margin: 0; }
        
        .requirements-box ul li { 
            animation: fadeSlideUp 0.5s ease-out forwards; opacity: 0; 
            transition: all 0.3s ease; 
        }
        .requirements-box ul li:nth-child(1) { animation-delay: 0.2s; }
        .requirements-box ul li:nth-child(2) { animation-delay: 0.3s; }
        .requirements-box ul li:nth-child(3) { animation-delay: 0.4s; }
        .requirements-box ul li:nth-child(4) { animation-delay: 0.5s; }
        .requirements-box ul li::before { content: "✗"; color: #ff4757; margin-right: 12px; font-weight: bold; font-size: 1.2em; transition: 0.3s; }

        .requirements-box ul li.req-valid { color: #4cd137; text-shadow: 0 0 10px rgba(76, 209, 55, 0.3); }
        .requirements-box ul li.req-valid::before { content: "✓"; color: #4cd137; }

        /* PANEL DERECHO */
        .right-panel { flex: 1.1; padding: 50px 60px; background: #0a0a0a; display: flex; flex-direction: column; justify-content: center; }
        
        .header-info { text-align: center; margin-bottom: 35px; }
        .icon-shield { color: #fad370; font-size: 3em; margin-bottom: 15px; animation: pulseGlow 2s infinite; border-radius: 50%; }
        .header-info h3 { font-family: 'Playfair Display', serif; color: #fff; font-size: 2.2em; margin: 0; }
        
        .user-badge {
            background: rgba(250, 211, 112, 0.05); border: 1px solid rgba(250, 211, 112, 0.2);
            padding: 15px; border-radius: 8px; text-align: center; margin-bottom: 30px;
        }
        .user-badge span { display: block; color: #fad370; font-size: 0.85em; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 5px; }
        .user-badge strong { color: #fff; font-size: 1.1em; letter-spacing: 0.5px; }

        .input-group-vip { position: relative; margin-bottom: 25px; animation: fadeSlideUp 0.6s ease-out forwards; opacity: 0; }
        .input-group-vip:nth-child(3) { animation-delay: 0.2s; }
        .input-group-vip:nth-child(4) { animation-delay: 0.3s; }
        .input-group-vip:nth-child(5) { animation-delay: 0.4s; }
        .input-group-vip:nth-child(6) { animation-delay: 0.5s; }

        .input-group-vip label { display: block; color: #aaa; font-size: 0.85em; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 1px; }
        .input-group-vip input {
            width: 100%; padding: 15px 45px 15px 15px; background: #121212; border: 1px solid #333;
            color: #fff; border-radius: 8px; transition: 0.3s; font-size: 1em; box-sizing: border-box;
        }
        .input-group-vip input:focus:not([readonly]) { border-color: #fad370; outline: none; background: #1a1a1a; box-shadow: 0 0 10px rgba(250, 211, 112, 0.1); }
        
        .input-locked {
            background: rgba(250, 211, 112, 0.05) !important;
            border: 1px dashed #fad370 !important; color: #fad370 !important;
            cursor: not-allowed; font-family: monospace; letter-spacing: 3px; font-weight: bold; opacity: 0.8;
        }

        .toggle-eye { position: absolute; right: 15px; top: 43px; color: #888; cursor: pointer; transition: 0.3s; font-size: 1.1em; }
        .toggle-eye:hover { color: #fad370; }

        /* BOTÓN NORMAL (Dorado) */
        .btn-gold {
            width: 100%; padding: 16px; background: #fad370; color: #0a0a0a;
            border: 2px solid #fad370; border-radius: 8px; font-weight: 800; cursor: pointer;
            transition: all 0.3s ease; margin-top: 15px; text-transform: uppercase; letter-spacing: 1px; font-size: 1.1em;
        }
        .btn-gold:hover { 
            background: transparent; color: #fad370; box-shadow: 0 0 20px rgba(250, 211, 112, 0.3); transform: translateY(-2px); 
        }

        /* ESTADO DEL BOTÓN DESHABILITADO (Seguridad Extrema) */
        .btn-disabled {
            background: #222 !important; color: #555 !important; border: 2px solid #333 !important;
            cursor: not-allowed !important; box-shadow: none !important; transform: none !important;
        }

        @media (max-width: 950px) {
            .split-container { flex-direction: column; }
            .left-panel { padding: 30px; border-right: none; border-bottom: 2px solid #fad370; }
            .right-panel { padding: 30px; }
        }
    </style>

    <div class="page-wrapper">
        <div class="split-container">
            <div class="left-panel">
                <h2>Sistema VIP</h2>
                <p style="color: #bbb; font-size: 1.1em;">Protocolo de seguridad activado. Establece una nueva contraseña definitiva.</p>
                <div class="requirements-box">
                    <ul style="margin: 0;">
                        <li id="req-length">Mínimo 8 caracteres</li>
                        <li id="req-upper">Al menos una letra mayúscula</li>
                        <li id="req-number">Al menos un número (0-9)</li>
                        <li id="req-special">Un carácter especial (@#$%^&+=!)</li>
                    </ul>
                </div>
            </div>

            <div class="right-panel">
                <div class="header-info">
                    <i class="fas fa-shield-alt icon-shield"></i>
                    <h3>Renovar Acceso</h3>
                </div>

                <div class="user-badge input-group-vip">
                    <span>Identidad Confirmada</span>
                    <strong><asp:Label ID="lblNombreUsuario" runat="server"></asp:Label></strong>
                    <br />
                    <small style="color: #888; font-family: monospace; letter-spacing: 1px;"><asp:Label ID="lblCorreoReadOnly" runat="server"></asp:Label></small>
                </div>

                <div class="input-group-vip">
                    <label><i class="fas fa-lock" style="color: #fad370; margin-right: 5px;"></i> Clave Temporal (Auto-completada)</label>
                    <asp:TextBox ID="txtClaveTemporal" runat="server" CssClass="input-locked" ToolTip="Esta clave ya fue validada por el sistema."></asp:TextBox>
                </div>

                <div class="input-group-vip">
                    <label>Nueva Contraseña Definitiva</label>
                    <asp:TextBox ID="txtNuevaClave" runat="server" TextMode="Password" placeholder="Crea tu nueva contraseña"></asp:TextBox>
                    <i class="fas fa-eye-slash toggle-eye" onclick="togglePwd('<%= txtNuevaClave.ClientID %>', this)"></i>
                </div>

                <div class="input-group-vip">
                    <label>Confirmar Nueva Contraseña</label>
                    <asp:TextBox ID="txtConfirmarClave" runat="server" TextMode="Password" placeholder="Repite la contraseña"></asp:TextBox>
                    <i class="fas fa-eye-slash toggle-eye" onclick="togglePwd('<%= txtConfirmarClave.ClientID %>', this)"></i>
                </div>

                <div class="input-group-vip">
                    <asp:Button ID="btnCambiar" runat="server" Text="Actualizar Contraseña" CssClass="btn-gold btn-disabled" Enabled="false" OnClick="btnCambiar_Click" />
                </div>
            </div>
        </div>
    </div>

    <script>
        // Función para el ojito (mostrar/ocultar contraseña)
        function togglePwd(id, icon) {
            var input = document.getElementById(id);
            if (input.type === "password") {
                input.type = "text";
                icon.classList.replace("fa-eye-slash", "fa-eye");
                icon.style.color = "#fad370";
            } else {
                input.type = "password";
                icon.classList.replace("fa-eye", "fa-eye-slash");
                icon.style.color = "#888";
            }
        }

        // Función para alertas
        function mostrarAlerta(titulo, mensaje, icono, redireccion) {
            Swal.fire({
                title: titulo, text: mensaje, icon: icono,
                background: '#1a1a1a', color: '#fff', confirmButtonColor: '#fad370'
            }).then((result) => {
                if (redireccion !== '') window.location.href = redireccion;
            });
        }

        // ========================================================
        // VALIDACIÓN EXTREMA EN TIEMPO REAL
        // ========================================================
        document.addEventListener("DOMContentLoaded", function () {
            var inputNuevaClave = document.getElementById('<%= txtNuevaClave.ClientID %>');
            var inputConfirmar = document.getElementById('<%= txtConfirmarClave.ClientID %>');
            var btnActualizar = document.getElementById('<%= btnCambiar.ClientID %>');

            // BLOQUEO EXTREMO: Prohibir copiar y pegar en la confirmación
            if (inputConfirmar) {
                inputConfirmar.addEventListener('paste', function (e) {
                    e.preventDefault();
                    mostrarAlerta('Seguridad', 'Por protocolo de seguridad, debes escribir la confirmación manualmente.', 'warning', '');
                });

                // Evitar arrastrar y soltar texto
                inputConfirmar.addEventListener('drop', function (e) {
                    e.preventDefault();
                });
            }

            // FUNCIÓN MAESTRA QUE EVALÚA TODO
            function evaluarSeguridad() {
                var pwd = inputNuevaClave.value;
                var confirmPwd = inputConfirmar.value;

                // 1. Evaluar Requisitos (RegEx)
                var hasLength = pwd.length >= 8;
                var hasUpper = /[A-Z]/.test(pwd);
                var hasNumber = /[0-9]/.test(pwd);
                var hasSpecial = /[@#$%^&+=!]/.test(pwd);

                // Aplicar estilos a la lista de requisitos
                document.getElementById('req-length').classList.toggle('req-valid', hasLength);
                document.getElementById('req-upper').classList.toggle('req-valid', hasUpper);
                document.getElementById('req-number').classList.toggle('req-valid', hasNumber);
                document.getElementById('req-special').classList.toggle('req-valid', hasSpecial);

                // 2. Evaluar Coincidencia de Contraseñas
                var sonIguales = (pwd === confirmPwd) && (pwd !== '');
                var estaConfirmando = confirmPwd.length > 0;

                // Feedback visual en la caja de confirmar
                if (estaConfirmando) {
                    if (sonIguales) {
                        inputConfirmar.style.borderColor = '#4cd137'; // Borde Verde
                        inputConfirmar.style.boxShadow = '0 0 10px rgba(76, 209, 55, 0.2)';
                    } else {
                        inputConfirmar.style.borderColor = '#ff4757'; // Borde Rojo
                        inputConfirmar.style.boxShadow = '0 0 10px rgba(255, 71, 87, 0.2)';
                    }
                } else {
                    inputConfirmar.style.borderColor = '#333'; // Gris original
                    inputConfirmar.style.boxShadow = 'none';
                }

                // 3. DESBLOQUEO DEL BOTÓN (La prueba final)
                if (hasLength && hasUpper && hasNumber && hasSpecial && sonIguales) {
                    btnActualizar.disabled = false;
                    btnActualizar.classList.remove('btn-disabled');
                } else {
                    btnActualizar.disabled = true;
                    btnActualizar.classList.add('btn-disabled');
                }
            }

            // Escuchar eventos en ambas cajas de texto
            if (inputNuevaClave && inputConfirmar) {
                inputNuevaClave.addEventListener('input', evaluarSeguridad);
                inputConfirmar.addEventListener('input', evaluarSeguridad);
            }
        });
    </script>
</asp:Content>