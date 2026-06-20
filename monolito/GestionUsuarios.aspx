<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GestionUsuarios.aspx.cs" Inherits="monolito.GestionUsuarios" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

    <style>
        /* ── ANIMACIONES ── */
        @keyframes slideDown  { from { opacity:0; transform:translateY(-18px); } to { opacity:1; transform:translateY(0); } }
        @keyframes fadeUp     { from { opacity:0; transform:translateY(28px);  } to { opacity:1; transform:translateY(0); } }

        /* ── ENCABEZADO ── */
        .dash-header {
            margin-bottom: 36px; animation: slideDown 0.55s ease-out;
            display: flex; align-items: flex-end; justify-content: space-between; flex-wrap: wrap; gap: 16px;
        }
        .dash-header-text h1 {
            font-size: 2em; font-weight: 800; margin: 0 0 4px; line-height: 1.1;
            background: linear-gradient(90deg, #fff 60%, #fad370 100%);
            -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;
        }
        .dash-header-text p { color: #555; font-size: 0.875em; margin: 0; }
        .dash-header-text p span { color: #fad370; }

        /* ── TABLA DE USUARIOS ── */
        .activity-table-wrap {
            background: rgba(10,10,10,0.9); border: 1px solid rgba(255,255,255,0.05);
            border-radius: 14px; overflow: hidden; animation: fadeUp 0.6s 0.2s ease-out both;
            padding: 20px; box-shadow: 0 15px 35px rgba(0, 0, 0, 0.5);
        }
        
        .activity-table { width: 100%; border-collapse: collapse; font-size: 0.9em; }
        .activity-table th {
            padding: 15px 18px; text-align: left; color: #888; font-weight: 600;
            font-size: 0.75em; text-transform: uppercase; letter-spacing: 1.5px;
            border-bottom: 1px solid rgba(250,211,112,0.15);
        }
        .activity-table td {
            padding: 15px 18px; border-bottom: 1px solid rgba(255,255,255,0.03);
            color: #ddd; vertical-align: middle;
        }
        .activity-table tr:last-child td { border-bottom: none; }
        .activity-table tr:hover td { background: rgba(250,211,112,0.03); color: #fff; }

        /* ── ETIQUETAS DE ESTADO ── */
        .status-badge {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 4px 12px; border-radius: 20px; font-size: 0.75em; font-weight: 600;
            text-transform: uppercase; letter-spacing: 1px;
        }
        .status-badge.ok     { background:rgba(76,209,55,0.1); color:#4cd137; border: 1px solid rgba(76,209,55,0.2); }
        .status-badge.warn   { background:rgba(255,71,87,0.1); color:#ff4757; border: 1px solid rgba(255,71,87,0.2); }
        .status-badge.admin  { background:rgba(250,211,112,0.1); color:#fad370; border: 1px solid rgba(250,211,112,0.2); }

        /* ── BOTONES DE ACCIÓN EN LA TABLA ── */
        .btn-grid {
            border: none; padding: 6px 14px; border-radius: 6px; font-weight: 600;
            font-size: 0.8em; cursor: pointer; transition: all 0.3s ease; font-family: 'Poppins', sans-serif;
        }
        .btn-unlock { background: rgba(76,209,55,0.15); color: #4cd137; }
        .btn-unlock:hover { background: #4cd137; color: #1a1a1a; box-shadow: 0 0 10px rgba(76,209,55,0.4); }
        
        .btn-lock { background: rgba(255,71,87,0.15); color: #ff4757; }
        .btn-lock:hover { background: #ff4757; color: #fff; box-shadow: 0 0 10px rgba(255,71,87,0.4); }
        
        .btn-disabled { background: transparent; color: #555; cursor: not-allowed; border: 1px dashed #555; }
    </style>

    <div class="dash-header">
        <div class="dash-header-text">
            <h1>Gestión de Usuarios</h1>
            <p>Centro de Control · <span>Auditoría de Cuentas</span></p>
        </div>
    </div>

    <div class="activity-table-wrap">
        <!-- El UseAccessibleHeader permite que ASP.NET renderice las etiquetas <th> correctamente -->
        <asp:GridView ID="gvUsuarios" runat="server" AutoGenerateColumns="False" 
            CssClass="activity-table" GridLines="None" UseAccessibleHeader="true" 
            OnRowCommand="gvUsuarios_RowCommand" DataKeyNames="IdUser">
            
            <Columns>
                <asp:TemplateField HeaderText="Usuario">
                    <ItemTemplate>
                        <div style="display:flex; align-items:center; gap:10px;">
                            <i class="fas fa-user-circle" style="font-size:1.5em; color:#555;"></i>
                            <div>
                                <strong style="display:block; color:#fff; font-size:1.05em;">
                                    <%# Eval("tbl_nombre") %> <%# Eval("tbl_apellido") %>
                                </strong>
                                <span style="font-size:0.85em; color:#888;"><%# Eval("tbl_email") %></span>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:BoundField DataField="tbl_cedula" HeaderText="Cédula" />
                <asp:BoundField DataField="tbl_celular" HeaderText="Celular" />

                <asp:TemplateField HeaderText="Rol">
                    <ItemTemplate>
                        <%# Convert.ToInt32(Eval("tbl_UsertypeID")) == 1 
                            ? "<span class='status-badge admin'><i class='fas fa-crown'></i> Admin</span>" 
                            : "<span class='status-badge'><i class='fas fa-user'></i> VIP</span>" %>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Estado">
                    <ItemTemplate>
                        <%# Convert.ToBoolean(Eval("tbl_activo")) 
                            ? "<span class='status-badge ok'><i class='fas fa-check-circle'></i> Activo</span>" 
                            : "<span class='status-badge warn'><i class='fas fa-lock'></i> Bloqueado</span>" %>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Acciones">
                    <ItemTemplate>
                        <%-- Si es Admin (Rol 1), no mostramos botones para no auto-bloquearse --%>
                        <asp:PlaceHolder runat="server" Visible='<%# Convert.ToInt32(Eval("tbl_UsertypeID")) != 1 %>'>
                            
                            <%-- Si está bloqueado, mostramos el botón de Desbloquear --%>
                            <asp:Button ID="btnDesbloquear" runat="server" Text="Desbloquear" 
                                CommandName="Desbloquear" CommandArgument='<%# Eval("IdUser") %>' 
                                CssClass="btn-grid btn-unlock" 
                                Visible='<%# !Convert.ToBoolean(Eval("tbl_activo")) %>' />
                                
                            <%-- Si está activo, mostramos el botón de Bloquear --%>
                            <asp:Button ID="btnBloquear" runat="server" Text="Bloquear" 
                                CommandName="Bloquear" CommandArgument='<%# Eval("IdUser") %>' 
                                CssClass="btn-grid btn-lock" 
                                Visible='<%# Convert.ToBoolean(Eval("tbl_activo")) %>' 
                                OnClientClick="return confirm('¿Estás seguro de que deseas bloquear a este usuario manualmente?');" />
                                
                        </asp:PlaceHolder>

                        <%-- Etiqueta para administradores --%>
                        <asp:Label runat="server" CssClass="btn-grid btn-disabled" 
                            Visible='<%# Convert.ToInt32(Eval("tbl_UsertypeID")) == 1 %>'>
                            Protegido
                        </asp:Label>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
            
            <EmptyDataTemplate>
                <div style="text-align:center; padding:30px; color:#888;">
                    <i class="fas fa-users-slash" style="font-size:3em; margin-bottom:15px; color:#555;"></i>
                    <p>No se encontraron usuarios registrados en el sistema.</p>
                </div>
            </EmptyDataTemplate>
            
        </asp:GridView>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        function showSuccessAlert(title, message) {
            Swal.fire({
                title: title, text: message, icon: 'success',
                background: '#1e1e24', color: '#fff', confirmButtonColor: '#fad370'
            });
        }
        function showErrorAlert(title, message) {
            Swal.fire({
                title: title, text: message, icon: 'error',
                background: '#1e1e24', color: '#fff', confirmButtonColor: '#ff4757'
            });
        }
    </script>
</asp:Content>