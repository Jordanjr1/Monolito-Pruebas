<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Desbloqueos.aspx.cs" Inherits="monolito.Desbloqueos" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;800&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
        .admin-container { padding: 40px 20px; font-family: 'Poppins', sans-serif; min-height: 80vh; }
        .admin-title { color: #ff4757; font-weight: 800; text-align: center; letter-spacing: 2px; margin-bottom: 30px; text-transform: uppercase; }
        .admin-subtitle { color: #8f8f8f; text-align: center; margin-bottom: 40px; }
        
        /* Diseño de la Tabla (GridView) */
        .grid-vip { width: 100%; border-collapse: collapse; background-color: #1e1e24; border-radius: 10px; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
        .grid-vip th { background-color: #15151a; color: #fad370; padding: 15px; text-align: left; font-weight: 600; border-bottom: 2px solid #ff4757; }
        .grid-vip td { padding: 15px; border-bottom: 1px solid rgba(255, 255, 255, 0.05); color: #e0e0e0; vertical-align: middle; }
        .grid-vip tr:hover { background-color: rgba(255, 71, 87, 0.05); }

        /* Botón de desbloqueo */
        .btn-unlock { background-color: transparent; color: #4cd137; border: 1px solid #4cd137; padding: 8px 15px; border-radius: 5px; cursor: pointer; font-weight: 600; transition: 0.3s; }
        .btn-unlock:hover { background-color: #4cd137; color: #1e1e24; box-shadow: 0 0 10px rgba(76, 209, 55, 0.4); }
    </style>

    <div class="admin-container">
        <h2 class="admin-title"><i class="fas fa-lock"></i> Panel de Administración</h2>
        <p class="admin-subtitle">Aquí aparecen los usuarios bloqueados por superar el límite de intentos fallidos.</p>

        <asp:GridView ID="gvBloqueados" runat="server" CssClass="grid-vip" AutoGenerateColumns="False" GridLines="None" OnRowCommand="gvBloqueados_RowCommand">
            <Columns>
                <asp:BoundField DataField="IdUser" HeaderText="ID" />
                <asp:BoundField DataField="tbl_nombre" HeaderText="Nombres" />
                <asp:BoundField DataField="tbl_apellido" HeaderText="Apellidos" />
                <asp:BoundField DataField="tbl_email" HeaderText="Correo" />
                <asp:BoundField DataField="tbl_ultimo_intento" HeaderText="Fecha Bloqueo" DataFormatString="{0:dd/MM/yyyy HH:mm}" />
                
                <asp:TemplateField HeaderText="Acción">
                    <ItemTemplate>
                        <asp:Button ID="btnDesbloquear" runat="server" Text="Desbloquear" CommandName="Desbloquear" CommandArgument='<%# Eval("IdUser") %>' CssClass="btn-unlock" />
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
            
            <EmptyDataTemplate>
                <div style="padding: 30px; text-align: center; color: #4cd137;">
                    <i class="fas fa-check-circle" style="font-size: 3em; margin-bottom: 15px;"></i><br />
                    ¡Excelente! No hay usuarios bloqueados en este momento.
                </div>
            </EmptyDataTemplate>
        </asp:GridView>
    </div>
</asp:Content>