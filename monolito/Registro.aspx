<%@ Page Title="Registro" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Registro.aspx.cs" Inherits="monolito.Registro" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Fuentes idénticas a la imagen de referencia -->
    <link href="https://fonts.googleapis.com/css2?family=Abril+Fatface&family=David+Libre:wght@400;500;700&family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

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
           FONDO GENERAL DESENFOCADO
           ============================ */
        .registro-wrapper {
            display: flex; justify-content: center; align-items: center;
            min-height: calc(100vh - 80px);
            background-color: var(--negro);
            font-family: 'David Libre', serif;
            margin: -20px; padding: 40px 15px; position: relative; overflow: hidden;
        }

        .registro-wrapper::before {
            content: ''; position: absolute; top: 0; left: 0; width: 100%; height: 100%;
            background: url('https://images.unsplash.com/photo-1614064641936-732b55b9662b?w=1920') center/cover;
            filter: blur(8px) brightness(0.25); z-index: 0;
        }

        /* ============================
           CONTENEDOR PRINCIPAL ANIMADO (RADAR BORDER)
           ============================ */
        .container-animated {
            position: relative;
            width: 95%; max-width: 1200px; height: 85vh; min-height: 700px; max-height: 850px;
            box-shadow: 0 20px 80px rgba(0, 0, 0, 0.9);
            z-index: 10; overflow: hidden; border-radius: 12px;
            animation: fadeIn 0.8s ease-out; background: #000; 
            padding: 2px; display: flex;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(30px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* Líneas de luz rotatorias */
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

        /* Núcleo interno */
        .split-layout {
            position: relative; width: 100%; height: 100%; z-index: 3;
            display: grid; grid-template-columns: 1fr 1fr;
            background: #050505; border-radius: 10px; overflow: hidden;
        }

        /* ============================
           LADO IZQUIERDO - 2 IMÁGENES APILADAS
           ============================ */
        .left-side {
            position: relative; overflow: hidden;
            background: linear-gradient(135deg, rgba(10, 10, 10, 0.95), rgba(20, 20, 20, 0.9));
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            gap: 30px; padding: 40px;
            border-right: 1px solid rgba(250, 211, 112, 0.15);
        }

        .left-side::before {
            content: ''; position: absolute; top: 0; left: 0; width: 100%; height: 100%;
            background: radial-gradient(circle at center, rgba(250, 211, 112, 0.05) 0%, transparent 70%); z-index: 1;
        }

        .stacked-image {
            position: relative; z-index: 2;
            width: 100%; max-width: 320px; height: 240px; object-fit: cover;
            border: 2px solid var(--dorado); border-radius: 4px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.6);
            transition: transform 0.5s ease;
        }
        .stacked-image:hover { transform: scale(1.02); box-shadow: 0 10px 40px rgba(250, 211, 112, 0.2); }

        /* ============================
           LADO DERECHO - FORMULARIO CON SCROLL
           ============================ */
        .right-side {
            padding: 3rem 4rem; display: flex; flex-direction: column;
            background: transparent; overflow-y: auto; height: 100%;
        }

        /* Scrollbar personalizado VIP */
        .right-side::-webkit-scrollbar { width: 6px; }
        .right-side::-webkit-scrollbar-track { background: rgba(255, 255, 255, 0.02); border-radius: 10px; }
        .right-side::-webkit-scrollbar-thumb { background: rgba(250, 211, 112, 0.3); border-radius: 10px; }
        .right-side::-webkit-scrollbar-thumb:hover { background: rgba(250, 211, 112, 0.6); }

        .logo-header { text-align: center; color: var(--dorado); font-size: 2.2em; margin-bottom: 0.5rem; }
        .form-title { font-family: 'Abril Fatface', cursive; font-size: 2.5rem; color: var(--blanco); text-align: center; margin-bottom: 0.5rem; letter-spacing: 1px; }
        .form-subtitle { color: rgba(255, 255, 255, 0.6); font-size: 0.9rem; text-align: center; margin-bottom: 2.5rem; font-family: 'David Libre', serif; letter-spacing: 1px; text-transform: uppercase; }

        /* ============================
           GRID INTERNO DEL FORMULARIO
           ============================ */
        .form-grid {
            display: grid; grid-template-columns: 1fr 1fr; gap: 15px 20px;
        }
        .full-width { grid-column: 1 / -1; }

        .form-group { text-align: left; position: relative; }
        .form-group label { display: block; color: var(--blanco); font-size: 0.85rem; font-weight: 600; margin-bottom: 0.4rem; font-family: 'David Libre', serif; }
        
        .input-wrapper { position: relative; width: 100%; }

        .form-group input[type="text"], 
        .form-group input[type="password"], 
        .form-group input[type="email"], 
        .form-group input[type="date"] {
            width: 100%; padding: 0.8rem 1rem;
            background: rgba(255, 255, 255, 0.03) !important;
            border: 1px solid rgba(250, 211, 112, 0.2) !important;
            border-left: 3px solid rgba(250, 211, 112, 0.5) !important; 
            color: var(--blanco) !important; font-family: 'David Libre', serif; font-size: 0.95rem;
            transition: all 0.3s ease; border-radius: 4px; box-shadow: none !important;
        }

        .form-group input:focus {
            outline: none; background: rgba(255, 255, 255, 0.06) !important;
            border-color: var(--dorado) !important; border-left: 3px solid var(--dorado) !important;
        }

        .form-group input::placeholder { color: rgba(255, 255, 255, 0.2); }

        /* Bloqueo Autocompletado Chrome */
        .form-group input:-webkit-autofill {
            -webkit-box-shadow: 0 0 0 30px #0a0a0a inset !important;
            -webkit-text-fill-color: #ffffff !important;
        }

        .eye-icon { position: absolute; right: 1rem; top: 50%; transform: translateY(-50%); cursor: pointer; color: rgba(255, 255, 255, 0.4); font-size: 1.1rem; z-index: 5; transition: 0.3s; }
        .eye-icon:hover { color: var(--dorado); }

        /* ============================
           ELEMENTOS ESPECIALES
           ============================ */
        .radio-list { display: flex; gap: 15px; align-items: center; margin-top: 8px; }
        .radio-list label { color: #ccc; cursor: pointer; font-size: 0.85em; font-family: 'Poppins', sans-serif; margin-left: 5px; }
        .radio-list input[type="radio"] { accent-color: var(--dorado); transform: scale(1.2); cursor: pointer; }

        .photo-upload-container {
            display: flex; align-items: center; gap: 15px; margin-top: 5px;
            background: rgba(255, 255, 255, 0.02); padding: 12px; border-radius: 6px; border: 1px dashed rgba(250, 211, 112, 0.3);
        }
        .file-upload-wrapper { width: 100%; overflow: hidden; display: flex; align-items: center; gap: 10px; }
        .file-upload-wrapper input[type="file"] { color: #8f8f8f; font-size: 0.8em; font-family: 'Poppins', sans-serif; }
        .file-upload-wrapper input[type="file"]::file-selector-button {
            background: rgba(250, 211, 112, 0.1); border: 1px solid var(--dorado); color: var(--dorado); 
            padding: 6px 12px; border-radius: 4px; cursor: pointer; font-family: 'Poppins', sans-serif; transition: 0.3s;
        }
        .file-upload-wrapper input[type="file"]::file-selector-button:hover { background: var(--dorado); color: #000; }
        
        .btn-preview { background: var(--dorado); border: none; color: #000; padding: 6px 12px; border-radius: 4px; cursor: pointer; font-weight: 600; font-family: 'Poppins', sans-serif; font-size: 0.8em; }

        /* ============================
           CHECKLIST VIP EN VIVO
           ============================ */
        .checklist-box {
            background: rgba(0, 0, 0, 0.4); border: 1px solid rgba(250, 211, 112, 0.15);
            border-radius: 6px; padding: 15px 20px; margin-top: 15px; margin-bottom: 25px;
        }
        .checklist-box h4 { color: var(--dorado); margin-top: 0; margin-bottom: 12px; font-size: 0.85em; font-family: 'Poppins', sans-serif; text-transform: uppercase; letter-spacing: 1px; }
        .checklist-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
        .check-item { display: flex; align-items: center; gap: 8px; color: #666; font-size: 0.8rem; font-family: 'Poppins', sans-serif; transition: 0.3s; }
        .check-item.valid { color: var(--exito); }
        .check-item.invalid { color: var(--error); }

        /* ============================
           BOTÓN SUBMIT & LINKS
           ============================ */
        .btn-submit {
            width: 100%; padding: 1.1rem;
            background: linear-gradient(135deg, var(--dorado) 0%, #e5c864 100%);
            color: var(--negro); border: none; font-family: 'Poppins', sans-serif;
            font-size: 1rem; font-weight: 700; cursor: pointer; transition: all 0.3s ease;
            text-transform: uppercase; letter-spacing: 1px; border-radius: 4px;
        }
        .btn-submit:hover:not(.btn-disabled) { transform: translateY(-2px); box-shadow: 0 8px 25px rgba(250, 211, 112, 0.4); }
        
        .btn-disabled { 
            background: #2a2a2a !important; color: #555 !important; 
            cursor: not-allowed !important; transform: none !important; box-shadow: none !important; 
        }

        .login-link { text-align: center; margin-top: 1.5rem; color: rgba(255, 255, 255, 0.6); font-size: 0.9rem; font-family: 'Poppins', sans-serif; text-decoration: none; display: block; }
        .login-link span { color: var(--dorado); font-weight: 700; transition: opacity 0.3s ease; }
        .login-link:hover span { text-decoration: underline; }

        /* Ocultar validadores viejos */
        .error-message { display: none !important; }

        /* ============================
           RESPONSIVE
           ============================ */
        @media (max-width: 968px) {
            .split-layout { grid-template-columns: 1fr; }
            .left-side { display: none; }
            .right-side { padding: 2.5rem 2rem; }
        }
        @media (max-width: 600px) {
            .form-grid { grid-template-columns: 1fr; }
            .checklist-grid { grid-template-columns: 1fr; }
            .container-animated { min-height: 90vh; }
        }
    </style>

    <div class="registro-wrapper">
        <div class="container-animated">
            <div class="split-layout">
                
                <!-- LADO IZQUIERDO: 2 Imágenes Apiladas -->
                <div class="left-side">
                    <!-- Imagen 1: Servidores/Hardware -->
                    <img src="https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=500" alt="Hardware VIP" class="stacked-image">
                    
                    <!-- Imagen 2: Código/Software -->
                    <img src="https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=500" alt="Ciberseguridad" class="stacked-image">
                </div>

                <!-- LADO DERECHO: Formulario Scrolleable -->
                <div class="right-side">
                    <div class="logo-header"><i class="fas fa-shield-alt"></i></div>
                    <h1 class="form-title">Registro</h1>
                    <p class="form-subtitle">Por favor, ingrese sus datos</p>

                    <div class="form-grid">
                        <!-- Nombres y Apellidos -->
                        <div class="form-group">
                            <label>Nombres</label>
                            <div class="input-wrapper">
                                <asp:TextBox ID="txtNombres" runat="server" MaxLength="100" autocomplete="off" placeholder="Tus nombres"></asp:TextBox>
                            </div>
                        </div>
                        <div class="form-group">
                            <label>Apellidos</label>
                            <div class="input-wrapper">
                                <asp:TextBox ID="txtLastName" runat="server" MaxLength="100" autocomplete="off" placeholder="Tus apellidos"></asp:TextBox>
                            </div>
                        </div>

                        <!-- Fecha y Cédula -->
                        <div class="form-group">
                            <label>Fecha de Nacimiento</label>
                            <div class="input-wrapper">
                                <asp:TextBox ID="txtBirthDate" runat="server" TextMode="Date" autocomplete="off"></asp:TextBox>
                            </div>
                        </div>
                        <div class="form-group">
                            <label>Cédula (10 dígitos)</label>
                            <div class="input-wrapper">
                                <asp:TextBox ID="txtEcuadorianId" runat="server" MaxLength="10" autocomplete="off" placeholder="Ej: 17xxxxxx42"></asp:TextBox>
                            </div>
                        </div>

                        <!-- Celular y Correo -->
                        <div class="form-group">
                            <label>Número Celular</label>
                            <div class="input-wrapper">
                                <asp:TextBox ID="txtCellphone" runat="server" MaxLength="10" autocomplete="off" placeholder="Ej: 099xxxxxxx"></asp:TextBox>
                            </div>
                        </div>
                        <div class="form-group">
                            <label>Correo Electrónico</label>
                            <div class="input-wrapper">
                                <asp:TextBox ID="txtEmail" runat="server" MaxLength="150" TextMode="Email" autocomplete="off" placeholder="correo@ejemplo.com"></asp:TextBox>
                            </div>
                        </div>

                        <!-- Usuario (Auto) y Género -->
                        <div class="form-group">
                            <label>Nombre de Usuario (Auto)</label>
                            <div class="input-wrapper">
                                <asp:TextBox ID="txtUsername" runat="server" style="pointer-events: none; opacity: 0.7;" placeholder="Generado por el sistema"></asp:TextBox>
                            </div>
                        </div>
                        <div class="form-group">
                            <label>Género</label>
                            <asp:RadioButtonList ID="rblGender" runat="server" CssClass="radio-list" RepeatDirection="Horizontal">
                                <asp:ListItem Value="Femenino" Text="Fem"></asp:ListItem>
                                <asp:ListItem Value="Masculino" Text="Masc"></asp:ListItem>
                                <asp:ListItem Value="Otro" Text="Otro"></asp:ListItem>
                            </asp:RadioButtonList>
                            <asp:RequiredFieldValidator ID="rfvGender" runat="server" ControlToValidate="rblGender" ErrorMessage="Obligatorio" CssClass="error-message" Display="Dynamic"></asp:RequiredFieldValidator>
                        </div>

                        <!-- Dirección (Full width) -->
                        <div class="form-group full-width">
                            <label>Dirección de Domicilio</label>
                            <div class="input-wrapper">
                                <asp:TextBox ID="txtAddress" runat="server" MaxLength="100" autocomplete="off" placeholder="Tu dirección completa"></asp:TextBox>
                            </div>
                        </div>

                        <!-- Foto de Perfil (Full width) -->
                        <div class="form-group full-width">
                            <label>Foto de Perfil (Opcional)</label>
                            <div class="photo-upload-container">
                                <i class="fas fa-camera" style="color: rgba(250, 211, 112, 0.5); font-size: 1.5rem;" id="defaultIcon" runat="server"></i>
                                <asp:Image ID="imgPreview" runat="server" style="display:none; max-width:50px; border-radius:4px; border:1px solid #fad370;" />
                                <div class="file-upload-wrapper">
                                    <asp:FileUpload ID="fuPhoto" runat="server" accept="image/png, image/jpeg, image/jpg" />
                                    <asp:Button ID="btnPreview" runat="server" Text="Cargar" OnClick="btnPreview_Click" CausesValidation="false" formnovalidate="formnovalidate" CssClass="btn-preview" />
                                </div>
                            </div>
                        </div>

                        <!-- Contraseñas -->
                        <div class="form-group">
                            <label>Contraseña</label>
                            <div class="input-wrapper">
                                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" autocomplete="new-password" placeholder="• • • • • • • •"></asp:TextBox>
                                <i class="fas fa-eye-slash eye-icon" onclick="togglePassword('<%= txtPassword.ClientID %>', this)"></i>
                            </div>
                        </div>
                        <div class="form-group">
                            <label>Confirmar Contraseña</label>
                            <div class="input-wrapper">
                                <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" autocomplete="new-password" placeholder="• • • • • • • •"></asp:TextBox>
                                <i class="fas fa-eye-slash eye-icon" onclick="togglePassword('<%= txtConfirmPassword.ClientID %>', this)"></i>
                            </div>
                        </div>

                    </div> <!-- Fin Form Grid -->

                    <!-- CHECKLIST EN VIVO -->
                    <div class="checklist-box full-width">
                        <h4><i class="fas fa-tasks"></i> Verificación de Protocolo</h4>
                        <div class="checklist-grid">
                            <div class="check-item invalid" id="chkNombres"><i class="fas fa-times-circle"></i> 2 Nombres</div>
                            <div class="check-item invalid" id="chkApellidos"><i class="fas fa-times-circle"></i> 2 Apellidos</div>
                            <div class="check-item invalid" id="chkCedula"><i class="fas fa-times-circle"></i> Cédula válida</div>
                            <div class="check-item invalid" id="chkCelular"><i class="fas fa-times-circle"></i> Celular (09...)</div>
                            <div class="check-item invalid" id="chkEmail"><i class="fas fa-times-circle"></i> Correo seguro</div>
                            <div class="check-item invalid" id="chkPassword"><i class="fas fa-times-circle"></i> Claves coinciden</div>
                        </div>
                    </div>

                    <!-- Botón Registro ahora con clase CSS btn-disabled, sin disabled de HTML -->
                    <asp:Button ID="btnRegister" runat="server" Text="REGISTRARSE" CssClass="btn-submit full-width btn-disabled" OnClick="btnRegister_Click" ClientIDMode="Static" />
                    
                    <a href="Login.aspx" class="login-link full-width">¿Ya tiene una cuenta? <span>Inicie sesión</span></a>

                </div> <!-- Fin Lado Derecho -->
            </div>
        </div>
    </div>

   <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
 <script>
     // Ocultar/Mostrar Contraseña
     function togglePassword(inputId, iconElement) {
         var input = document.getElementById(inputId);
         if (input.type === "password") {
             input.type = "text";
             iconElement.classList.replace("fa-eye-slash", "fa-eye");
             iconElement.style.color = "#fad370";
         } else {
             input.type = "password";
             iconElement.classList.replace("fa-eye", "fa-eye-slash");
             iconElement.style.color = "rgba(255,255,255,0.4)";
         }
     }

     document.addEventListener("DOMContentLoaded", function () {
         var txtFirst = document.getElementById('<%= txtNombres.ClientID %>');
         var txtLast = document.getElementById('<%= txtLastName.ClientID %>');
         var txtCedula = document.getElementById('<%= txtEcuadorianId.ClientID %>');
         var txtCelular = document.getElementById('<%= txtCellphone.ClientID %>');
         var txtEmail = document.getElementById('<%= txtEmail.ClientID %>');
         var txtPwd = document.getElementById('<%= txtPassword.ClientID %>');
         var txtConfirmPwd = document.getElementById('<%= txtConfirmPassword.ClientID %>');
         var txtUser = document.getElementById('<%= txtUsername.ClientID %>');
         var btnSubmit = document.getElementById('<%= btnRegister.ClientID %>');

         // 1. VALORES ALEATORIOS FIJOS
         var randomNum = Math.floor(Math.random() * 901) + 100; 
         var specialChars = "@#$%&*.!?";
         var randomChar = specialChars[Math.floor(Math.random() * specialChars.length)];
         var idx1 = Math.floor(Math.random() * 10);
         var idx2 = Math.floor(Math.random() * 10);
         while (idx1 === idx2) { idx2 = Math.floor(Math.random() * 10); }

         // 2. FILTROS EN TIEMPO REAL
         txtCedula.addEventListener('input', function () { this.value = this.value.replace(/[^0-9]/g, ''); });
         txtCelular.addEventListener('input', function () { this.value = this.value.replace(/[^0-9]/g, ''); });
         txtFirst.addEventListener('input', function () { this.value = this.value.replace(/[0-9]/g, ''); });
         txtLast.addEventListener('input', function () { this.value = this.value.replace(/[0-9]/g, ''); });

         // 3. GENERAR USERNAME
         function updateUsername() {
             var nombres = txtFirst.value.trim().split(/\s+/);
             var apellidos = txtLast.value.trim().split(/\s+/);
             var cedula = txtCedula.value.trim();
             var iniciales = "";

             nombres.forEach(function (n) { if (n.length > 0) iniciales += n[0]; });
             apellidos.forEach(function (a) { if (a.length > 0) iniciales += a[0]; });

             var inicialesMixtas = "";
             for (var i = 0; i < iniciales.length; i++) {
                 if (i % 2 === 0) inicialesMixtas += iniciales[i].toUpperCase();
                 else inicialesMixtas += iniciales[i].toLowerCase();
             }

             var digitosCedula = "00";
             if (cedula.length > 0) {
                 var d1 = cedula[idx1 % cedula.length] || cedula[0];
                 var d2 = cedula[idx2 % cedula.length] || cedula[0];
                 digitosCedula = d1 + d2;
             }

             if (inicialesMixtas.length > 0) txtUser.value = inicialesMixtas + randomNum + randomChar + digitosCedula;
             else txtUser.value = "";
         }

         // 4. CHECKLIST VIP EN VIVO
         function updateCheck(id, isValid) {
             var el = document.getElementById(id);
             var icon = el.querySelector('i');
             if (isValid) {
                 el.classList.replace('invalid', 'valid');
                 icon.className = 'fas fa-check-circle';
             } else {
                 el.classList.replace('valid', 'invalid');
                 icon.className = 'fas fa-times-circle';
             }
             return isValid;
         }

         function validateForm() {
             updateUsername();

             var valNombres = txtFirst.value.trim();
             var isValidNombres = valNombres.split(/\s+/).length >= 2 && valNombres.length > 4;
             var chk1 = updateCheck('chkNombres', isValidNombres);

             var valApellidos = txtLast.value.trim();
             var isValidApellidos = valApellidos.split(/\s+/).length >= 2 && valApellidos.length > 4;
             var chk2 = updateCheck('chkApellidos', isValidApellidos);

             var valCedula = txtCedula.value.trim();
             var isValidCedula = valCedula.length === 10 && !/(.)\1{7,}/.test(valCedula);
             var chk3 = updateCheck('chkCedula', isValidCedula);

             var valCelular = txtCelular.value.trim();
             var isValidCelular = /^09\d{8}$/.test(valCelular);
             var chk4 = updateCheck('chkCelular', isValidCelular);

             var valEmail = txtEmail.value.trim();
             var isValidEmail = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(valEmail);
             var chk5 = updateCheck('chkEmail', isValidEmail);

             var valPwd = txtPwd.value;
             var valConfirm = txtConfirmPwd.value;
             var isSecure = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d@$!%*?&]{8,}$/.test(valPwd);
             var isValidPwd = isSecure && valPwd === valConfirm && valPwd !== '';
             var chk6 = updateCheck('chkPassword', isValidPwd);

             if (chk1 && chk2 && chk3 && chk4 && chk5 && chk6) {
                 btnSubmit.classList.remove('btn-disabled');
             } else {
                 btnSubmit.classList.add('btn-disabled');
             }
         }

         // Interceptor de clic para bloquear manualmente si faltan datos
         btnSubmit.addEventListener('click', function(e) {
             if (this.classList.contains('btn-disabled')) {
                 e.preventDefault();
                 Swal.fire({
                     title: 'Datos Incompletos',
                     text: 'Verifique que todos los protocolos estén en verde antes de continuar.',
                     icon: 'warning', background: '#1e1e24', color: '#fff', confirmButtonColor: '#fad370'
                 });
                 return false;
             }
             this.value = 'Procesando...';
         });

         var allInputs = document.querySelectorAll('.form-group input');
         allInputs.forEach(input => { input.addEventListener('input', validateForm); });

         validateForm(); 
     });

     // Alertas Backend con Integración de WhatsApp
     function showSuccessAlert(title, message, redirectUrl) {
         // El enlace mágico de WhatsApp (Asegúrate de que el número y la frase sean los correctos de tu Twilio)
         var linkWhatsApp = "https://wa.me/14155238886?text=join%20each-particular";

         Swal.fire({
             title: title,
             html: `
                <p style="color: #ccc; margin-bottom: 20px;">${message}</p>
                <div style="background: rgba(37, 211, 102, 0.1); border: 1px dashed #25D366; padding: 15px; border-radius: 8px;">
                    <p style="color: #25D366; font-size: 0.9em; margin-bottom: 15px;"><strong>Paso Final:</strong> Para recibir tus códigos 2FA y recuperar tu clave, debes vincular tu WhatsApp.</p>
                    <a href="${linkWhatsApp}" target="_blank" style="display: inline-block; background: #25D366; color: #fff; text-decoration: none; padding: 10px 20px; border-radius: 5px; font-weight: bold; font-family: 'Poppins', sans-serif;">
                        <i class="fab fa-whatsapp" style="font-size: 1.2em; margin-right: 5px;"></i> Vincular WhatsApp
                    </a>
                </div>
             `,
             icon: 'success',
             background: '#1e1e24',
             color: '#fff',
             confirmButtonText: 'Ir al Login',
             confirmButtonColor: '#fad370',
             allowOutsideClick: false // Obliga al usuario a interactuar con la alerta
         }).then((result) => {
             if (result.isConfirmed) {
                 window.location.href = redirectUrl;
             }
         });
     }

     function showErrorAlert(title, message) {
         Swal.fire({ title: title, text: message, icon: 'error', background: '#1e1e24', color: '#fff', confirmButtonColor: '#ff4757' });
         var btn = document.getElementById('<%= btnRegister.ClientID %>');
         if (btn) btn.value = 'REGISTRARSE';
     }
 </script>
</asp:Content>