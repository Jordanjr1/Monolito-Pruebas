<%@ Page Title="Gestión de Proveedores VIP" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MantenimientoProveedores.aspx.cs" Inherits="monolito.MantenimientoProveedores" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
        :root { --dorado: #FAD370; --negro: #0a0a0a; --gris-oscuro: #1c1c1c; --blanco: #fff; }
        
        .erp-wrapper { font-family: 'Poppins', sans-serif; background-color: var(--negro); color: var(--blanco); min-height: calc(100vh - 80px); padding: 30px; margin: -20px; }
        .erp-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; border-bottom: 1px solid rgba(250, 211, 112, 0.2); padding-bottom: 15px; }
        .erp-header h2 { color: var(--dorado); font-weight: 700; margin: 0; font-size: 1.8em; letter-spacing: 1px; text-transform: uppercase; }

        .erp-body { display: grid; grid-template-columns: 350px 1fr; gap: 30px; }

        /* PANEL LATERAL (FORMULARIO) */
        .panel-form { background: var(--gris-oscuro); padding: 25px; border-radius: 12px; border: 1px solid rgba(255, 255, 255, 0.05); box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
        .panel-form h3 { color: var(--dorado); font-size: 1.2em; margin-bottom: 20px; border-bottom: 1px dashed rgba(250, 211, 112, 0.3); padding-bottom: 10px; }
        
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; font-size: 0.85em; color: #aaa; margin-bottom: 5px; }
        .form-group input { width: 100%; padding: 10px; background: rgba(0,0,0,0.3); border: 1px solid #333; color: #fff; border-radius: 6px; font-family: 'Poppins', sans-serif; transition: 0.3s; }
        .form-group input:focus { border-color: var(--dorado); outline: none; }
        
        .btn-vip { width: 100%; padding: 12px; background: var(--dorado); color: #000; border: none; border-radius: 6px; font-weight: 700; cursor: pointer; transition: 0.3s; text-transform: uppercase; letter-spacing: 1px; margin-top: 10px; }
        .btn-vip:hover { background: #fff; box-shadow: 0 5px 15px rgba(250, 211, 112, 0.4); transform: translateY(-2px); }

        .btn-clear { background: transparent; color: #aaa; border: 1px solid #555; margin-top: 10px; }
        .btn-clear:hover { background: #333; color: #fff; }

        /* GRIDVIEW VIP (TABLA DE DATOS) */
        .panel-data { background: var(--gris-oscuro); padding: 25px; border-radius: 12px; border: 1px solid rgba(255, 255, 255, 0.05); overflow-x: auto; }
        .grid-vip { width: 100%; border-collapse: collapse; text-align: left; }
        .grid-vip th { background-color: #0a0a0a; color: var(--dorado); padding: 15px; font-size: 0.9em; text-transform: uppercase; letter-spacing: 1px; border-bottom: 2px solid var(--dorado); }
        .grid-vip td { padding: 15px; border-bottom: 1px solid #333; color: #ddd; font-size: 0.9em; vertical-align: middle; }
        .grid-vip tr:hover td { background-color: rgba(250, 211, 112, 0.05); }

        /* BOTONES DE ACCIÓN EN EL GRID */
        .btn-icon { background: transparent; border: none; cursor: pointer; padding: 8px; border-radius: 4px; transition: 0.3s; margin-right: 5px; font-size: 1.1em; }
        .btn-edit { color: #3498db; } .btn-edit:hover { background: rgba(52, 152, 219, 0.1); }
        .btn-delete { color: #e74c3c; } .btn-delete:hover { background: rgba(231, 76, 60, 0.1); }

        @media (max-width: 992px) {
            .erp-body { grid-template-columns: 1fr; }
        }
    </style>

    <div class="erp-wrapper">
        <div class="erp-header">
            <h2><i class="fas fa-truck"></i> Gestión de Proveedores</h2>
        </div>

        <div class="erp-body">
            <div class="panel-form">
                <h3 id="lblTituloFormulario" runat="server"><i class="fas fa-building"></i> Nuevo Proveedor</h3>
                
                <asp:HiddenField ID="hfIdProveedor" runat="server" Value="0" />

                <div class="form-group">
                    <label>Nombre de la Empresa *</label>
                    <asp:TextBox ID="txtNombreProv" runat="server" MaxLength="150" autocomplete="off" placeholder="Ej: Microsoft Corp."></asp:TextBox>
                </div>

                <div class="form-group">
                    <label>Nombre del Contacto</label>
                    <asp:TextBox ID="txtContactoProv" runat="server" MaxLength="100" autocomplete="off" placeholder="Ej: Juan Pérez"></asp:TextBox>
                </div>

                <div class="form-group">
                    <label>Correo de Facturación</label>
                    <asp:TextBox ID="txtEmailProv" runat="server" MaxLength="150" TextMode="Email" autocomplete="off" placeholder="ventas@empresa.com"></asp:TextBox>
                </div>

                <asp:Button ID="btnGuardar" runat="server" Text="Guardar Proveedor" CssClass="btn-vip" OnClick="btnGuardar_Click" />
                <asp:Button ID="btnLimpiar" runat="server" Text="Cancelar" CssClass="btn-vip btn-clear" OnClick="btnLimpiar_Click" CausesValidation="false" />
            </div>

            <div class="panel-data">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
        <span style="color: var(--dorado); font-weight: 500; text-transform: uppercase; font-size: 0.9em; letter-spacing: 1px;">Listado de Registros</span>
        <asp:CheckBox ID="chkVerInactivos" runat="server" Text=" &nbsp;Ver Proveedores Inactivos" AutoPostBack="true" OnCheckedChanged="chkVerInactivos_CheckedChanged" style="color: #aaa; font-size: 0.9em; cursor: pointer;" />
    </div>

    <asp:GridView ID="gvProveedores" runat="server" AutoGenerateColumns="False" 
        CssClass="grid-vip" GridLines="None" DataKeyNames="prov_id"
        OnRowCommand="gvProveedores_RowCommand">
        <Columns>
            <asp:BoundField DataField="prov_id" HeaderText="ID" Visible="false" />
            <asp:BoundField DataField="prov_nombre" HeaderText="Empresa" />
            <asp:BoundField DataField="prov_contacto" HeaderText="Contacto" />
            <asp:BoundField DataField="prov_email" HeaderText="Correo Electrónico" />
            
            <asp:TemplateField HeaderText="Acciones">
                <ItemTemplate>
                    <asp:LinkButton ID="btnEditar" runat="server" CommandName="Editar" CommandArgument="<%# ((GridViewRow) Container).RowIndex %>" CssClass="btn-icon btn-edit" ToolTip="Editar">
                        <i class="fas fa-pen"></i>
                    </asp:LinkButton>
                    
                    <asp:LinkButton ID="btnEliminar" runat="server" CommandName="Eliminar" CommandArgument='<%# Eval("prov_id") %>' CssClass="btn-icon btn-delete" ToolTip="Desactivar" Visible='<%# Convert.ToBoolean(Eval("prov_estado")) %>' OnClientClick="return confirm('¿Confirma que desea dar de baja a este proveedor? Se ocultarán sus productos vinculados automáticamente.');">
                        <i class="fas fa-trash-alt"></i>
                    </asp:LinkButton>

                    <asp:LinkButton ID="btnReactivar" runat="server" CommandName="Reactivar" CommandArgument='<%# Eval("prov_id") %>' CssClass="btn-icon" ToolTip="Reactivar Proveedor" Visible='<%# !Convert.ToBoolean(Eval("prov_estado")) %>' style="color: #2ecc71;" OnClientClick="return confirm('¿Desea reactivar este proveedor? El sistema restaurará de forma automática todos sus productos con sus IDs originales.');">
                        <i class="fas fa-check-circle"></i>
                    </asp:LinkButton>
                </ItemTemplate>
                <ItemStyle Width="120px" HorizontalAlign="Center" />
            </asp:TemplateField>
        </Columns>
        <EmptyDataTemplate>
            <div style="text-align: center; padding: 40px; color: #777;">
                <i class="fas fa-truck-loading" style="font-size: 3em; margin-bottom: 15px; color: #444;"></i>
                <p>No se encontraron proveedores en este estado.</p>
            </div>
        </EmptyDataTemplate>
    </asp:GridView>
</div>
        </div>
    </div>

    <script>
        function showAlert(title, text, type) {
            Swal.fire({
                title: title, text: text, icon: type,
                background: '#1e1e24', color: '#fff',
                confirmButtonColor: '#FAD370'
            });
        }
    </script>
</asp:Content>