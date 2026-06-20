<%@ Page Title="Login" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="monolito.Login" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <link href="https://fonts.googleapis.com/css2?family=Abril+Fatface&family=David+Libre:wght@400;500;700&family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        :root {
            --dorado: #FAD370;
            --negro: #000000;
            --blanco: #FFFFFF;
            --error: #ff4757;
            --exito: #2ed573;
        }

        /* ============================
           FONDO DESENFOCADO
           ============================ */
        .login-wrapper {
            display: flex; justify-content: center; align-items: center;
            min-height: calc(100vh - 80px);
            background-color: var(--negro);
            font-family: 'David Libre', serif;
            margin: -20px; position: relative; overflow: hidden;
            padding: 40px 0; /* Espacio extra para que no choque arriba o abajo */
        }

        .login-wrapper::before {
            content: ''; position: absolute; top: 0; left: 0; width: 100%; height: 100%;
            background: url('https://images.unsplash.com/photo-1614064641936-732b55b9662b?w=1920') center/cover;
            filter: blur(8px) brightness(0.3); z-index: 0;
        }

        /* ============================
           CONTENEDOR DINÁMICO CON LUZ SECUENCIAL
           ============================ */
        .container-animated {
            position: relative;
            width: 90%; max-width: 1200px; 
            min-height: 620px;
            box-shadow: 0 20px 80px rgba(0, 0, 0, 0.9);
            z-index: 10; overflow: hidden; border-radius: 12px;
            animation: fadeIn 0.8s ease-out;
            background: #000; /* Fondo de resguardo */
            
            /* LA MAGIA: El padding crea el borde de luz dinámico */
            padding: 2px; 
            display: flex; 
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(30px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* Magia del Radar: Dos cometas persiguiéndose */
        .container-animated::before {
            content: ''; position: absolute; top: -50%; left: -50%; width: 200%; height: 200%;
            background: conic-gradient(transparent, rgba(250, 211, 112, 0.1), var(--dorado), transparent 25%);
            animation: radarSpin 4s linear infinite; z-index: 1;
        }
        .container-animated::after {
            content: ''; position: absolute; top: -50%; left: -50%; width: 200%; height: 200%;
            background: conic-gradient(transparent, rgba(250, 211, 112, 0.1), var(--dorado), transparent 25%);
            animation: radarSpin 4s linear infinite; animation-delay: -2s; z-index: 1;
        }

        @keyframes radarSpin {
            0%   { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        /* Contenedor Interior que se estira automáticamente */
        .split-layout {
            position: relative; width: 100%; z-index: 3;
            display: grid; grid-template-columns: 1fr 1fr;
            background: #050505; border-radius: 10px; overflow: hidden;
        }

        /* ============================
           LADO IZQUIERDO - IMAGEN VIP
           ============================ */
        .left-side {
            position: relative; overflow: hidden;
            background: url('https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=800') center/cover;
            display: flex; align-items: center; justify-content: center;
        }

        .left-side::before {
            content: ''; position: absolute; top: 0; left: 0; width: 100%; height: 100%;
            background: linear-gradient(135deg, rgba(0, 0, 0, 0.8), rgba(250, 211, 112, 0.15)); z-index: 1;
        }

        .floating-image {
            position: relative; z-index: 2; width: 100%; max-width: 350px;
            border: 2px solid rgba(250, 211, 112, 0.5); border-radius: 8px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.8);
            animation: float 4s ease-in-out infinite;
        }

        @keyframes float {
            0%, 100% { transform: translateY(0); }
            50%      { transform: translateY(-12px); }
        }

        /* ============================
           LADO DERECHO - FORMULARIO EXTREMO
           ============================ */
        .right-side {
            padding: 2.5rem 3.5rem; display: flex; flex-direction: column; justify-content: center;
            background: transparent;
        }

        .logo-header { text-align: center; color: var(--dorado); font-size: 2.5em; margin-bottom: 0.5rem; }
        .form-title { font-family: 'Abril Fatface', cursive; font-size: 2.8rem; color: var(--blanco); text-align: center; margin-bottom: 0.5rem; }
        .form-subtitle { color: rgba(255, 255, 255, 0.6); font-size: 0.95rem; text-align: center; margin-bottom: 2rem; font-family: 'David Libre', serif; letter-spacing: 1px; text-transform: uppercase; }

        /* ============================
           CAJAS DE TEXTO
           ============================ */
        .form-group { margin-bottom: 1.2rem; text-align: left; position: relative; }
        .form-group label { display: block; color: var(--blanco); font-size: 0.95rem; font-weight: 600; margin-bottom: 0.4rem; font-family: 'David Libre', serif; }
        
        .input-wrapper { position: relative; }

        .form-group input {
            width: 100%; padding: 0.9rem 1.2rem;
            background: rgba(255, 255, 255, 0.03) !important;
            border: 1px solid rgba(250, 211, 112, 0.2) !important;
            border-left: 3px solid rgba(250, 211, 112, 0.5) !important; 
            color: var(--blanco) !important; font-family: 'David Libre', serif; font-size: 1rem;
            transition: all 0.3s ease; border-radius: 4px; box-shadow: none !important;
        }

        .form-group input:focus {
            outline: none; background: rgba(255, 255, 255, 0.06) !important;
            border-color: var(--dorado) !important; border-left: 3px solid var(--dorado) !important;
            box-shadow: 0 0 15px rgba(250, 211, 112, 0.1) !important;
        }

        .form-group input::placeholder { color: rgba(255, 255, 255, 0.2); }

        /* Estilos Dinámicos de Validación Extrema */
        .input-wrapper.is-valid input { border-color: var(--exito) !important; border-left: 3px solid var(--exito) !important; box-shadow: 0 0 10px rgba(46, 213, 115, 0.1) !important; }
        .input-wrapper.is-invalid input { border-color: var(--error) !important; border-left: 3px solid var(--error) !important; box-shadow: 0 0 10px rgba(255, 71, 87, 0.1) !important; animation: shake 0.4s; }

        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25%, 75% { transform: translateX(-5px); }
            50%      { transform: translateX(5px); }
        }

        /* Bloqueo Autocompletado de Chrome */
        .form-group input:-webkit-autofill {
            -webkit-box-shadow: 0 0 0 30px #111 inset !important;
            -webkit-text-fill-color: #ffffff !important;
            border: 1px solid rgba(250, 211, 112, 0.3) !important;
        }

        .eye-icon { position: absolute; right: 1rem; top: 50%; transform: translateY(-50%); cursor: pointer; color: rgba(255, 255, 255, 0.4); transition: color 0.3s ease; font-size: 1.1rem; z-index: 5; }
        .eye-icon:hover { color: var(--dorado); }

        .validation-msg { display: flex; align-items: center; gap: 5px; font-size: 0.8rem; min-height: 20px; margin-top: 4px; font-family: 'Poppins', sans-serif; transition: 0.3s; }
        .validation-msg.valid   { color: var(--exito); }
        .validation-msg.invalid { color: var(--error); }

        /* ============================
           CHECKBOX Y LINKS
           ============================ */
        .remember-forgot { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; font-size: 0.9rem; }
        .checkbox-wrapper { display: flex; align-items: center; gap: 0.5rem; }
        .checkbox-wrapper input[type="checkbox"] { width: 16px; height: 16px; cursor: pointer; accent-color: var(--dorado); }
        .checkbox-wrapper label { color: rgba(255, 255, 255, 0.7); cursor: pointer; margin: 0; transition: 0.3s; }
        .checkbox-wrapper:hover label { color: var(--dorado); }

        .forgot-link { color: var(--dorado); text-decoration: none; transition: opacity 0.3s ease; }
        .forgot-link:hover { opacity: 0.7; text-decoration: underline; }

        /* ============================
           BOTONES (Submit y Registro)
           ============================ */
        .button-group {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .btn-submit {
            width: 100%; padding: 1.1rem;
            background: linear-gradient(135deg, var(--dorado) 0%, #e5c864 100%);
            color: var(--negro); border: none; font-family: 'Poppins', sans-serif;
            font-size: 1.05rem; font-weight: 700; cursor: pointer; transition: all 0.3s ease;
            box-shadow: 0 5px 20px rgba(250, 211, 112, 0.3); position: relative; overflow: hidden;
            text-transform: uppercase; letter-spacing: 1px; border-radius: 4px;
        }

        .btn-submit::before {
            content: ''; position: absolute; top: 0; left: -100%; width: 100%; height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.4), transparent);
            transition: left 0.5s ease;
        }
        .btn-submit:hover:not(.btn-disabled)::before { left: 100%; }
        .btn-submit:hover:not(.btn-disabled) { transform: translateY(-2px); box-shadow: 0 8px 30px rgba(250, 211, 112, 0.5); }

        /* Estado Deshabilitado */
        .btn-disabled {
            background: #2a2a2a !important; color: #555 !important;
            box-shadow: none !important; cursor: not-allowed !important; transform: none !important;
        }

        /* Botón de Registro */
        .btn-register {
            width: 100%; padding: 1rem;
            background: transparent;
            color: var(--dorado);
            border: 2px solid var(--dorado);
            font-family: 'Poppins', sans-serif;
            font-size: 1rem; font-weight: 600; cursor: pointer;
            transition: all 0.3s ease;
            text-align: center; text-transform: uppercase; letter-spacing: 1px;
            border-radius: 4px; text-decoration: none; display: block;
        }

        .btn-register:hover {
            background: rgba(250, 211, 112, 0.1);
            box-shadow: 0 5px 20px rgba(250, 211, 112, 0.2);
            transform: translateY(-2px);
        }

        /* ============================
           RESPONSIVE
           ============================ */
        @media (max-width: 968px) {
            .split-layout { grid-template-columns: 1fr; }
            .left-side { display: none; }
            .right-side { padding: 3rem 2rem; }
        }

        /* ============================
           SWEETALERT VIP
           ============================ */
        div:where(.swal2-container) div:where(.swal2-popup) { border: 1px solid rgba(250,211,112,0.2); border-radius: 12px; box-shadow: 0 20px 50px rgba(0,0,0,0.9); font-family: 'Poppins', sans-serif; background: #1a1a1a; color: #fff;}
        div:where(.swal2-container) h2:where(.swal2-title) { color: #fad370 !important; font-weight: 700; letter-spacing: 0.05em; }
        div:where(.swal2-container) input:where(.swal2-input) { background: rgba(255,255,255,0.03) !important; border: 1px solid rgba(255,255,255,0.1) !important; color: #ffffff !important; border-radius: 6px !important; box-shadow: none !important; }
        div:where(.swal2-container) input:where(.swal2-input):focus { border: 1px solid #fad370 !important; box-shadow: 0 0 15px rgba(250,211,112,0.15) !important; }
        div:where(.swal2-container) button:where(.swal2-styled).swal2-confirm { background: #fad370 !important; color: #000 !important; font-weight: 600; border-radius: 6px; }
    </style>

    <div class="login-wrapper">
        <div class="container-animated">
            <div class="split-layout">
                
                <!-- LADO IZQUIERDO -->
                <div class="left-side">
                    <img src="https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=500" alt="Ciberseguridad" class="floating-image">
                </div>

                <!-- LADO DERECHO: Formulario -->
                <div class="right-side">
                    
                    <div class="logo-header">
                        <i class="fas fa-shield-alt"></i>
                    </div>

                    <h1 class="form-title">Inicio de Sesión</h1>
                    <p class="form-subtitle">Sistema VIP · Protocolos Activados</p>

                    <!-- Campo: Correo / Usuario -->
                    <div class="form-group">
                        <label>Credencial de Usuario</label>
                        <div class="input-wrapper" id="wrapIdentifier">
                            <asp:TextBox ID="txtIdentifier" runat="server" 
                                         placeholder="Ingresa tu correo o usuario" 
                                         autocomplete="off"
                                         ClientIDMode="Static"></asp:TextBox>
                        </div>
                        <span id="msgIdentifier" class="validation-msg"></span>
                    </div>

                    <!-- Campo: Contraseña -->
                    <div class="form-group">
                        <label>Clave de Acceso</label>
                        <div class="input-wrapper" id="wrapPassword">
                            <asp:TextBox ID="txtPassword" runat="server" 
                                         TextMode="Password" 
                                         placeholder="• • • • • • • •" 
                                         autocomplete="new-password"
                                         ClientIDMode="Static"></asp:TextBox>
                            <i class="fas fa-eye-slash eye-icon" onclick="togglePassword()" id="eyeIcon"></i>
                        </div>
                        <span id="msgPassword" class="validation-msg"></span>
                    </div>

                    <!-- Recordar / Olvidé -->
                    <div class="remember-forgot">
                        <div class="checkbox-wrapper">
                            <asp:CheckBox ID="chkRemember" runat="server" ClientIDMode="Static" />
                            <label for="chkRemember">Recordar dispositivo</label>
                        </div>
                        <a href="#" class="forgot-link" onclick="solicitarRecuperacion(); return false;">¿Extraviaste tu clave?</a>
                    </div>

                    <!-- Campos Ocultos -->
                    <asp:HiddenField ID="hfEmailRecuperar" runat="server" ClientIDMode="Static" />
                    <asp:Button ID="btnOcultoRecuperar" runat="server" OnClick="btnOcultoRecuperar_Click" style="display:none;" CausesValidation="false" formnovalidate="formnovalidate" ClientIDMode="Static" />

                    <!-- Grupo de Botones: Ingresar y Registrarse -->
                    <div class="button-group">
                        <!-- Botón Ingresar (Inicia Bloqueado por Validación Extrema) -->
                        <asp:Button ID="btnLogin" runat="server" Text="Ingresar al Sistema" CssClass="btn-submit btn-disabled" Enabled="false" OnClick="btnLogin_Click" ClientIDMode="Static" />

                        <!-- Botón de Registro Visible y Adaptable -->
                        <a href="Registro.aspx" class="btn-register">Registrar Nueva Cuenta</a>
                    </div>

                </div>
            </div>
        </div>
    </div>

    <script>
        /* =============================
           LÓGICA: OJO DE CONTRASEÑA
           ============================= */
        function togglePassword() {
            var input = document.getElementById('txtPassword');
            var icon = document.getElementById('eyeIcon');
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.replace('fa-eye-slash', 'fa-eye');
                icon.style.color = '#FAD370';
            } else {
                input.type = 'password';
                icon.classList.replace('fa-eye', 'fa-eye-slash');
                icon.style.color = 'rgba(255, 255, 255, 0.4)';
            }
        }

        /* =============================
           VALIDACIÓN EXTREMA EN VIVO
           ============================= */
        document.addEventListener('DOMContentLoaded', function () {
            const txtId = document.getElementById('txtIdentifier');
            const txtPwd = document.getElementById('txtPassword');
            const wrapId = document.getElementById('wrapIdentifier');
            const wrapPwd = document.getElementById('wrapPassword');
            const msgId = document.getElementById('msgIdentifier');
            const msgPwd = document.getElementById('msgPassword');
            const btnLogin = document.getElementById('btnLogin');

            // Regex de seguridad (Previene inyección SQL básica)
            const forbiddenChars = /['"=\\;]/;

            // Bloquear pegado en contraseña (Seguridad Extrema)
            txtPwd.addEventListener('paste', function (e) {
                e.preventDefault();
                Swal.fire({
                    icon: 'warning', title: 'Operación Denegada',
                    text: 'Por protocolos de seguridad, debes teclear tu contraseña manualmente.',
                    background: '#1a1a1a', color: '#fff', confirmButtonColor: '#fad370'
                });
            });

            function validateAll() {
                let isIdValid = false;
                let isPwdValid = false;
                let valId = txtId.value.trim();
                let valPwd = txtPwd.value;

                // Validar Usuario/Correo
                if (valId.length === 0) {
                    wrapId.className = 'input-wrapper';
                    msgId.innerHTML = '';
                } else if (forbiddenChars.test(valId)) {
                    wrapId.className = 'input-wrapper is-invalid';
                    msgId.className = 'validation-msg invalid';
                    msgId.innerHTML = '<i class="fas fa-times-circle"></i> Caracteres no permitidos.';
                } else {
                    wrapId.className = 'input-wrapper is-valid';
                    msgId.className = 'validation-msg valid';
                    msgId.innerHTML = '<i class="fas fa-check-circle"></i> Sintaxis segura.';
                    isIdValid = true;
                }

                // Validar Contraseña
                if (valPwd.length === 0) {
                    wrapPwd.className = 'input-wrapper';
                    msgPwd.innerHTML = '';
                } else if (valPwd.length < 6) {
                    wrapPwd.className = 'input-wrapper is-invalid';
                    msgPwd.className = 'validation-msg invalid';
                    msgPwd.innerHTML = '<i class="fas fa-shield-alt"></i> La clave requiere mínimo 6 caracteres.';
                } else {
                    wrapPwd.className = 'input-wrapper is-valid';
                    msgPwd.className = 'validation-msg valid';
                    msgPwd.innerHTML = '<i class="fas fa-lock"></i> Cifrado correcto.';
                    isPwdValid = true;
                }

                // Desbloquear o Bloquear Botón
                if (isIdValid && isPwdValid) {
                    btnLogin.classList.remove('btn-disabled');
                    btnLogin.disabled = false;
                } else {
                    btnLogin.classList.add('btn-disabled');
                    btnLogin.disabled = true;
                }
            }

            txtId.addEventListener('input', validateAll);
            txtPwd.addEventListener('input', validateAll);

            // Al hacer clic en enviar, mostramos loader
            btnLogin.addEventListener('click', function () {
                btnLogin.value = 'Verificando Cifrado...';
                // No lo deshabilitamos para que el PostBack se ejecute
                setTimeout(() => { btnLogin.classList.add('btn-disabled'); }, 50);
            });
        });

        /* =============================
           MODAL DE RECUPERACIÓN (SweetAlert)
           ============================= */
        function solicitarRecuperacion() {
            Swal.fire({
                title: '🔐 Recuperar Accesos',
                html: '<p style="color:#aaa;font-size:0.9rem;margin-bottom:10px;">Ingresa tu correo electrónico registrado para solicitar una clave temporal:</p>',
                input: 'email',
                inputPlaceholder: 'operador@sistema.com',
                background: '#1a1a1a', color: '#fff',
                confirmButtonColor: '#FAD370', confirmButtonText: 'Enviar Protocolo',
                showCancelButton: true, cancelButtonText: 'Cancelar', cancelButtonColor: '#444',
                inputValidator: function (value) {
                    if (!value) return 'El correo es obligatorio.';
                }
            }).then(function (result) {
                if (result.value) {
                    document.getElementById('hfEmailRecuperar').value = result.value;
                    document.getElementById('btnOcultoRecuperar').click();
                }
            });
        }

        /* =============================
           ALERTAS DESDE EL SERVIDOR (C#)
           ============================= */
        function showSuccessAlert(title, message, redirectUrl) {
            Swal.fire({
                icon: 'success', title: title, text: message,
                background: '#1a1a1a', color: '#fff', confirmButtonColor: '#28a745',
                timer: 1500, timerProgressBar: true, allowOutsideClick: false
            }).then(function () {
                if (redirectUrl) window.location.href = redirectUrl;
            });
        }

        function showErrorAlert(title, message) {
            Swal.fire({
                icon: 'error', title: title, text: message,
                background: '#1a1a1a', color: '#fff', confirmButtonColor: '#dc3545'
            });
            let btn = document.getElementById('btnLogin');
            if (btn) { btn.value = 'Ingresar al Sistema'; btn.classList.remove('btn-disabled'); btn.disabled = false; }
        }
    </script>
</asp:Content>