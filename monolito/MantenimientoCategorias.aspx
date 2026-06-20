<%@ Page Title="Gestión de Categorías" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MantenimientoCategorias.aspx.cs" Inherits="monolito.MantenimientoCategorias" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
        :root { --dorado: #FAD370; --negro: #0a0a0a; --gris-oscuro: #1c1c1c; --blanco: #fff; }
        .erp-wrapper { font-family: 'Poppins', sans-serif; background-color: var(--negro); color: var(--blanco); min-height: calc(100vh - 80px); padding: 30px; margin: -20px; }
        .erp-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; border-bottom: 1px solid rgba(250, 211, 112, 0.2); padding-bottom: 15px; }
        .erp-header h2 { color: var(--dorado); font-weight: 700; margin: 0; font-size: 1.8em; letter-spacing: 1px; text-transform: uppercase; }
        
        /* ── INTERRUPTOR ESTILO VIP (TOGGLE SWITCH) ── */
        .toggle-vip { display: flex; align-items: center; gap: 12px; background: rgba(255,255,255,0.03); padding: 8px 18px; border-radius: 30px; border: 1px solid rgba(255,255,255,0.08); transition: all 0.3s ease; }
        .toggle-vip:hover { background: rgba(255,255,255,0.06); border-color: rgba(250, 211, 112, 0.4); }
        .toggle-vip input[type="checkbox"] { appearance: none; -webkit-appearance: none; width: 44px; height: 22px; background: #333; border-radius: 22px; position: relative; cursor: pointer; outline: none; transition: background 0.3s; box-shadow: inset 0 0 5px rgba(0,0,0,0.5); margin: 0; }
        .toggle-vip input[type="checkbox"]::after { content: ''; position: absolute; top: 2px; left: 2px; width: 18px; height: 18px; background: #aaa; border-radius: 50%; transition: all 0.3s cubic-bezier(0.4, 0.0, 0.2, 1); box-shadow: 0 2px 4px rgba(0,0,0,0.4); }
        .toggle-vip input[type="checkbox"]:checked { background: var(--dorado); }
        .toggle-vip input[type="checkbox"]:checked::after { left: 24px; background: #000; }
        .toggle-vip label { color: #ccc; font-size: 0.85em; font-weight: 600; cursor: pointer; text-transform: uppercase; letter-spacing: 1px; margin: 0; padding-top: 1px; transition: color 0.3s; }
        .toggle-vip input[type="checkbox"]:checked + label { color: var(--dorado); }

        .erp-body { display: grid; grid-template-columns: 350px 1fr; gap: 30px; }
        .panel-form { background: var(--gris-oscuro); padding: 25px; border-radius: 12px; border: 1px solid rgba(255, 255, 255, 0.05); box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
        .panel-form h3 { color: var(--dorado); font-size: 1.2em; margin-bottom: 20px; border-bottom: 1px dashed rgba(250, 211, 112, 0.3); padding-bottom: 10px; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; font-size: 0.85em; color: #aaa; margin-bottom: 5px; }
        .form-group input, .form-group textarea { width: 100%; padding: 10px; background: rgba(0,0,0,0.3); border: 1px solid #333; color: #fff; border-radius: 6px; font-family: 'Poppins', sans-serif; transition: 0.3s; resize: none; }
        .form-group input:focus, .form-group textarea:focus { border-color: var(--dorado); outline: none; }
        .btn-vip { width: 100%; padding: 12px; background: var(--dorado); color: #000; border: none; border-radius: 6px; font-weight: 700; cursor: pointer; transition: 0.3s; text-transform: uppercase; letter-spacing: 1px; margin-top: 10px; }
        .btn-vip:hover { background: #fff; box-shadow: 0 5px 15px rgba(250, 211, 112, 0.4); transform: translateY(-2px); }
        .btn-clear { background: transparent; color: #aaa; border: 1px solid #555; margin-top: 10px; }
        .btn-clear:hover { background: #333; color: #fff; }
        
        .panel-data { background: var(--gris-oscuro); padding: 25px; border-radius: 12px; border: 1px solid rgba(255, 255, 255, 0.05); overflow-x: auto; }
        .grid-vip { width: 100%; border-collapse: collapse; text-align: left; }
        .grid-vip th { background-color: #0a0a0a; color: var(--dorado); padding: 15px; font-size: 0.9em; text-transform: uppercase; letter-spacing: 1px; border-bottom: 2px solid var(--dorado); }
        .grid-vip td { padding: 15px; border-bottom: 1px solid #333; color: #ddd; font-size: 0.9em; vertical-align: middle; }
        .grid-vip tr:hover td { background-color: rgba(250, 211, 112, 0.05); }
        
        /* ── BOTONES DE ACCIÓN (ALINEADOS Y ESTILIZADOS) ── */
        .action-container { display: flex; justify-content: center; gap: 8px; } /* Contenedor flexible para alinear perfecto */
        .btn-icon { background: transparent; border: none; cursor: pointer; padding: 6px 8px; border-radius: 6px; transition: 0.3s; font-size: 1.1em; display: inline-flex; align-items: center; justify-content: center; }
        .btn-edit { color: #3498db; } .btn-edit:hover { background: rgba(52, 152, 219, 0.15); }
        .btn-delete { color: #e67e22; } .btn-delete:hover { background: rgba(230, 126, 34, 0.15); color: #f39c12; } /* Naranja para baja lógica */
        .btn-restore { color: #4cd137; } .btn-restore:hover { background: rgba(76, 209, 55, 0.15); }
        .btn-hard-delete { color: #ff4757; } .btn-hard-delete:hover { background: rgba(255, 71, 87, 0.15); box-shadow: 0 0 10px rgba(255, 71, 87, 0.4); } /* Rojo agresivo para destrucción */
        
        @media (max-width: 992px) { .erp-body { grid-template-columns: 1fr; } }
    </style>

    <div class="erp-wrapper">
        <div class="erp-header">
            <h2><i class="fas fa-tags"></i> Catálogo de Categorías Autorizadas</h2>
            
            <div class="toggle-vip">
                <asp:CheckBox ID="chkVerEliminados" runat="server" Text="Auditar Bajas" AutoPostBack="true" OnCheckedChanged="chkVerEliminados_CheckedChanged" />
            </div>
        </div>

        <div class="erp-body">
            <div class="panel-form">
                <h3 id="lblTituloFormulario" runat="server"><i class="fas fa-folder-plus"></i> Nueva Categoría</h3>
                <asp:HiddenField ID="hfIdCategoria" runat="server" Value="0" />

                <div class="form-group">
                    <label>Nombre de la Categoría *</label>
                    <asp:TextBox ID="txtNombreCat" runat="server" MaxLength="100" autocomplete="off" placeholder="Ej: ELECTRÓNICA"></asp:TextBox>
                </div>

                <div class="form-group">
                    <label>Descripción / Alcance</label>
                    <asp:TextBox ID="txtDescripcionCat" runat="server" TextMode="MultiLine" Rows="3" MaxLength="250" placeholder="Descripción..."></asp:TextBox>
                </div>

                <asp:Button ID="btnGuardar" runat="server" Text="Registrar Categoría" CssClass="btn-vip" OnClick="btnGuardar_Click" />
                <asp:Button ID="btnLimpiar" runat="server" Text="Cancelar" CssClass="btn-vip btn-clear" OnClick="btnLimpiar_Click" CausesValidation="false" />
            </div>

            <div class="panel-data">
                <asp:GridView ID="gvCategorias" runat="server" AutoGenerateColumns="False" 
                    CssClass="grid-vip" GridLines="None" DataKeyNames="cat_id"
                    OnRowCommand="gvCategorias_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="cat_id" HeaderText="ID" ItemStyle-Width="50px" />
                        <asp:BoundField DataField="cat_nombre" HeaderText="Categoría" HeaderStyle-HorizontalAlign="Left" />
                        <asp:BoundField DataField="cat_descripcion" HeaderText="Descripción" HeaderStyle-HorizontalAlign="Left" />
                        
                        <asp:TemplateField HeaderText="Acciones">
                            <ItemTemplate>
                                <div class="action-container">
                                    <asp:LinkButton ID="btnEditar" runat="server" CommandName="Editar" CommandArgument="<%# ((GridViewRow) Container).RowIndex %>" CssClass="btn-icon btn-edit" ToolTip="Editar">
                                        <i class="fas fa-pen"></i>
                                    </asp:LinkButton>
                                    
                                    <asp:LinkButton ID="btnRestaurar" runat="server" CommandName="Restaurar" CommandArgument='<%# Eval("cat_id") %>' CssClass="btn-icon btn-restore" ToolTip="Restaurar" Visible='<%# !(bool)Eval("cat_estado") %>'>
                                        <i class="fas fa-trash-restore"></i>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="btnEliminarDefinitivo" runat="server" CommandName="EliminarDefinitivo" CommandArgument='<%# Eval("cat_id") %>' CssClass="btn-icon btn-hard-delete" ToolTip="Destruir Permanente de BD" Visible='<%# !(bool)Eval("cat_estado") %>' OnClientClick="return confirm('¡PELIGRO EXTREMO! ¿Destruir DEFINITIVAMENTE esta categoría? Esta acción borrará el registro de la base de datos y NO se puede deshacer.');">
                                        <i class="fas fa-skull-crossbones"></i>
                                    </asp:LinkButton>
                                    
                                    <asp:LinkButton ID="btnEliminar" runat="server" CommandName="Eliminar" CommandArgument='<%# Eval("cat_id") %>' CssClass="btn-icon btn-delete" ToolTip="Baja Lógica (Ocultar)" Visible='<%# (bool)Eval("cat_estado") %>' OnClientClick="return confirm('¿Desea ocultar esta categoría? Los productos vinculados seguirán existiendo.');">
                                        <i class="fas fa-trash-alt"></i>
                                    </asp:LinkButton>
                                </div>
                            </ItemTemplate>
                            <ItemStyle Width="160px" HorizontalAlign="Center" />
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div style="text-align: center; padding: 40px; color: #777;">
                            <i class="fas fa-folder-open" style="font-size: 3em; margin-bottom: 15px;"></i>
                            <p>No hay categorías registradas en el diccionario del sistema.</p>
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
                background: '#1e1e24', color: '#fff', confirmButtonColor: '#FAD370'
            });
        }
    </script>
</asp:Content>