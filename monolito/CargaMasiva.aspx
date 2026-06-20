<%@ Page Title="Subida Masiva VIP" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CargaMasiva.aspx.cs" Inherits="monolito.CargaMasiva" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
        :root { --dorado: #FAD370; --negro: #0a0a0a; --gris-oscuro: #1c1c1c; --blanco: #fff; --error: #ff4757; --exito: #2ed573; }
        
        .masivo-wrapper { font-family: 'Poppins', sans-serif; background-color: var(--negro); color: var(--blanco); min-height: calc(100vh - 80px); padding: 30px; margin: -20px; }
        .masivo-header { margin-bottom: 30px; border-bottom: 1px solid rgba(250, 211, 112, 0.2); padding-bottom: 15px; }
        .masivo-header h2 { color: var(--dorado); font-weight: 700; margin: 0; font-size: 1.8em; text-transform: uppercase; letter-spacing: 1px; }
        
        /* Layout de dos columnas para los pasos */
        .steps-container { display: grid; grid-template-columns: 1fr 1fr; gap: 30px; margin-bottom: 30px; }
        @media (max-width: 992px) { .steps-container { grid-template-columns: 1fr; } }

        .upload-container { background: var(--gris-oscuro); border: 2px dashed rgba(250, 211, 112, 0.4); padding: 40px 30px; border-radius: 12px; text-align: center; transition: all 0.3s ease; height: 100%; display: flex; flex-direction: column; justify-content: space-between; }
        .upload-container:hover { border-color: var(--dorado); background: rgba(250, 211, 112, 0.03); }
        .upload-container h3 { color: var(--blanco); margin-bottom: 10px; font-size: 1.3em; }
        .upload-container h3 span { color: var(--dorado); font-weight: bold; }
        .upload-container i.icon-main { font-size: 3.5em; color: var(--dorado); margin-bottom: 15px; transition: transform 0.3s; }
        .upload-container:hover i.icon-main { transform: translateY(-5px); }
        .upload-container p { color: #aaa; font-size: 0.95em; margin-bottom: 25px; font-weight: 500; }
        .upload-container p.file-selected { color: var(--dorado); font-weight: 700; }
        
        .action-buttons { display: flex; justify-content: center; align-items: center; gap: 10px; flex-wrap: wrap; margin-top: auto; }

        .file-input-wrapper { display: inline-block; position: relative; overflow: hidden; cursor: pointer; }
        .file-input-wrapper input[type="file"] { position: absolute; left: 0; top: 0; width: 100%; height: 100%; opacity: 0; cursor: pointer; z-index: 10; }
        
        .btn-vip { padding: 10px 20px; background: var(--dorado); color: #000; border: none; border-radius: 6px; font-weight: 700; cursor: pointer; transition: all 0.3s ease; text-transform: uppercase; letter-spacing: 1px; font-family: 'Poppins', sans-serif; display: inline-flex; align-items: center; justify-content: center; gap: 8px; font-size: 0.9em; }
        .btn-vip:hover { background: #fff; box-shadow: 0 5px 15px rgba(250, 211, 112, 0.4); transform: translateY(-2px); }
        
        .btn-secondary-vip { background: rgba(255,255,255,0.05); color: #fff; border: 1px solid #555; }
        .btn-secondary-vip:hover { background: #222; border-color: var(--dorado); color: var(--dorado); }

        .summary-box { background: rgba(250, 211, 112, 0.05); border: 1px solid rgba(250, 211, 112, 0.2); padding: 20px; border-radius: 8px; margin-bottom: 30px; display: flex; justify-content: space-around; text-align: center; }
        .summary-item h4 { font-size: 0.85em; color: #aaa; text-transform: uppercase; margin-bottom: 5px; letter-spacing: 1px; }
        .summary-item p { font-size: 2em; font-weight: 800; color: #fff; margin: 0; }
        .summary-item .txt-exito { color: var(--exito); font-size: 1.2em; }

        .preview-box { background: var(--gris-oscuro); padding: 25px; border-radius: 12px; border: 1px solid rgba(255, 255, 255, 0.05); box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
        .preview-box h3 { color: var(--dorado); font-size: 1.1em; margin-bottom: 20px; text-transform: uppercase; letter-spacing: 0.5px; }
        
        .grid-container { overflow-x: auto; max-height: 400px; border-radius: 6px; border: 1px solid #333; }
        .grid-vip { width: 100%; border-collapse: collapse; text-align: left; }
        .grid-vip th { background-color: #111; color: var(--dorado); padding: 15px; font-size: 0.85em; text-transform: uppercase; border-bottom: 2px solid var(--dorado); position: sticky; top: 0; z-index: 10; letter-spacing: 1px; }
        .grid-vip td { padding: 12px 15px; border-bottom: 1px solid #222; color: #ddd; font-size: 0.9em; }
        .grid-vip tr:hover td { background-color: rgba(250,211,112,0.05); }
    </style>

    <div class="masivo-wrapper">
        <div class="masivo-header">
            <h2><i class="fas fa-network-wired"></i> Protocolo de Carga Masiva Empresarial</h2>
        </div>

        <div class="steps-container">
            <div class="upload-container">
                <div>
                    <h3><span>Paso 1:</span> Sincronizar Imágenes</h3>
                    <i class="fas fa-images icon-main" id="imgIcon"></i>
                    <p id="imgNameDisplay">Seleccione todas las imágenes de los productos. Mantenga el nombre exacto referenciado en su Excel.</p>
                </div>
                
                <div class="action-buttons">
                    <div class="file-input-wrapper">
                        <asp:FileUpload ID="fuImagenesMasivas" runat="server" AllowMultiple="true" accept=".jpg, .jpeg, .png, .webp" onchange="updateImgCount(this)" />
                        <span class="btn-vip btn-secondary-vip"><i class="fas fa-folder-plus"></i> Elegir Archivos</span>
                    </div>
                    <asp:Button ID="btnSubirImagenesFisicas" runat="server" Text="↑ Subir al Servidor" CssClass="btn-vip" OnClick="btnSubirImagenesFisicas_Click" />
                </div>
            </div>

            <div class="upload-container">
                <div>
                    <h3><span>Paso 2:</span> Cargar Matriz de Datos</h3>
                    <i class="fas fa-file-excel icon-main" id="uploadIcon"></i>
                    <p id="fileNameDisplay">Seleccione su matriz de inventario (.CSV, .XLS, .XLSX)</p>
                </div>
                
                <div class="action-buttons">
                    <div class="file-input-wrapper">
                        <asp:FileUpload ID="fuCSV" runat="server" accept=".csv, .xls, .xlsx" onchange="updateFileName(this)" />
                        <span class="btn-vip btn-secondary-vip"><i class="fas fa-folder-open"></i> Elegir Archivo</span>
                    </div>
                    <asp:Button ID="btnPrevisualizar" runat="server" Text="🔍 Previsualizar" CssClass="btn-vip" OnClick="btnPrevisualizar_Click" />
                </div>
            </div>
        </div>

        <asp:PlaceHolder ID="phSummary" runat="server" Visible="false">
            <div class="summary-box">
                <div class="summary-item">
                    <h4>Filas Detectadas</h4>
                    <p id="lblTotal" runat="server">0</p>
                </div>
                <div class="summary-item">
                    <h4>Estructura de Tabla</h4>
                    <p class="txt-exito"><i class="fas fa-check-circle"></i> Íntegra y Válida</p>
                </div>
            </div>
        </asp:PlaceHolder>

        <asp:PlaceHolder ID="phPreview" runat="server" Visible="false">
            <div class="preview-box">
                <h3><i class="fas fa-eye"></i> Datos listos en memoria del servidor</h3>
                
                <div class="grid-container">
                    <asp:GridView ID="gvPreview" runat="server" CssClass="grid-vip" GridLines="None" AutoGenerateColumns="true">
                    </asp:GridView>
                </div>

                <div style="margin-top: 25px; display: flex; justify-content: flex-end;">
                    <asp:Button ID="btnConfirmarSubida" runat="server" Text="🔥 Inyectar a Base de Datos" CssClass="btn-vip" OnClick="btnConfirmarSubida_Click" OnClientClick="return confirm('¿Confirma la inyección de estos registros al inventario?');" />
                </div>
            </div>
        </asp:PlaceHolder>
    </div>

    <script>
        function updateFileName(input) {
            var display = document.getElementById('fileNameDisplay');
            var icon = document.getElementById('uploadIcon');
            if (input.files && input.files.length > 0) {
                var fileName = input.files[0].name;
                display.innerText = "Matriz cargada: " + fileName;
                display.className = "file-selected";

                if (fileName.toLowerCase().endsWith('.csv')) {
                    icon.className = "fas fa-file-csv icon-main";
                } else {
                    icon.className = "fas fa-file-excel icon-main";
                }
            } else {
                display.innerText = "Seleccione su matriz de inventario (.CSV, .XLS, .XLSX)";
                display.className = "";
                icon.className = "fas fa-file-excel icon-main";
            }
        }

        // Script para mostrar cuántas imágenes se seleccionaron
        function updateImgCount(input) {
            var display = document.getElementById('imgNameDisplay');
            var icon = document.getElementById('imgIcon');
            if (input.files && input.files.length > 0) {
                display.innerText = input.files.length + " imagen(es) preparadas para subir.";
                display.className = "file-selected";
                icon.className = "fas fa-images icon-main";
            } else {
                display.innerText = "Seleccione todas las imágenes de los productos. Mantenga el nombre exacto referenciado en su Excel.";
                display.className = "";
                icon.className = "fas fa-images icon-main";
            }
        }

        function showAlert(title, text, type) {
            Swal.fire({
                title: title, text: text, icon: type,
                background: '#1e1e24', color: '#fff', confirmButtonColor: '#FAD370'
            });
        }
    </script>
</asp:Content>