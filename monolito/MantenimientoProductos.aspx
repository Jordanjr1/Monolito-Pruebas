<%@ Page Title="Gestión de Productos VIP" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MantenimientoProductos.aspx.cs" Inherits="monolito.MantenimientoProductos" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
        :root { --dorado: #FAD370; --negro: #0a0a0a; --gris-oscuro: #1c1c1c; --blanco: #fff; }
        
        .erp-wrapper { font-family: 'Poppins', sans-serif; background-color: var(--negro); color: var(--blanco); min-height: calc(100vh - 80px); padding: 30px; margin: -20px; }
        .erp-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; border-bottom: 1px solid rgba(250, 211, 112, 0.2); padding-bottom: 15px; }
        .erp-header h2 { color: var(--dorado); font-weight: 700; margin: 0; font-size: 1.8em; letter-spacing: 1px; text-transform: uppercase; }

        .erp-body { display: grid; grid-template-columns: 380px 1fr; gap: 30px; }

        /* PANEL FORMULARIO */
        .panel-form { background: var(--gris-oscuro); padding: 25px; border-radius: 12px; border: 1px solid rgba(255, 255, 255, 0.05); box-shadow: 0 10px 30px rgba(0,0,0,0.5); align-self: start; }
        .panel-form h3 { color: var(--dorado); font-size: 1.2em; margin-bottom: 20px; border-bottom: 1px dashed rgba(250, 211, 112, 0.3); padding-bottom: 10px; }
        
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; font-size: 0.85em; color: #aaa; margin-bottom: 5px; }
        .form-group input, .form-group select, .form-group textarea { width: 100%; padding: 10px; background: rgba(0,0,0,0.3); border: 1px solid #333; color: #fff; border-radius: 6px; font-family: 'Poppins', sans-serif; transition: 0.3s; }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus { border-color: var(--dorado); outline: none; }
        .form-group select option { background-color: var(--gris-oscuro); color: #fff; }
        
        .btn-vip { width: 100%; padding: 12px; background: var(--dorado); color: #000; border: none; border-radius: 6px; font-weight: 700; cursor: pointer; transition: 0.3s; text-transform: uppercase; letter-spacing: 1px; margin-top: 10px; }
        .btn-vip:hover { background: #fff; box-shadow: 0 5px 15px rgba(250, 211, 112, 0.4); transform: translateY(-2px); }
        .btn-clear { background: transparent; color: #aaa; border: 1px solid #555; margin-top: 10px; }
        .btn-clear:hover { background: #333; color: #fff; }

        /* ========================================= */
        /* BARRA DE FILTROS PROFESIONAL (NUEVO)      */
        /* ========================================= */
        .filter-bar { display: flex; gap: 15px; background: var(--gris-oscuro); padding: 15px 20px; border-radius: 12px; margin-bottom: 20px; border: 1px solid rgba(255, 255, 255, 0.05); align-items: center; flex-wrap: wrap; box-shadow: 0 5px 15px rgba(0,0,0,0.3); }
        .search-container { flex-grow: 1; position: relative; min-width: 250px; }
        .search-container input { width: 100%; padding: 10px 40px 10px 15px; background: rgba(0,0,0,0.4); border: 1px solid #444; color: #fff; border-radius: 20px; font-family: 'Poppins', sans-serif; transition: 0.3s; }
        .search-container input:focus { border-color: var(--dorado); outline: none; box-shadow: 0 0 10px rgba(250, 211, 112, 0.2); }
        .search-container i.fa-search { position: absolute; right: 15px; top: 12px; color: #888; }
        .ajax-loading { position: absolute; right: 40px; top: 12px; color: var(--dorado); }
        
        .filter-select { padding: 10px 15px; background: rgba(0,0,0,0.4); border: 1px solid #444; color: #ccc; border-radius: 20px; font-family: 'Poppins', sans-serif; outline: none; cursor: pointer; transition: 0.3s; }
        .filter-select:focus, .filter-select:hover { border-color: var(--dorado); color: #fff; }
        .filter-select option { background-color: var(--gris-oscuro); color: #fff; }

        /* PANEL TABLA */
        .panel-data { background: var(--gris-oscuro); padding: 25px; border-radius: 12px; border: 1px solid rgba(255, 255, 255, 0.05); overflow-x: auto; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
        .grid-vip { width: 100%; border-collapse: collapse; text-align: left; margin-bottom: 20px; }
        .grid-vip th { background-color: #0a0a0a; color: var(--dorado); padding: 15px; font-size: 0.85em; text-transform: uppercase; letter-spacing: 1px; border-bottom: 2px solid var(--dorado); }
        .grid-vip td { padding: 12px 15px; border-bottom: 1px solid #222; color: #ddd; font-size: 0.9em; vertical-align: middle; }
        .grid-vip tr:hover td { background-color: rgba(250, 211, 112, 0.03); }

        /* IMÁGENES REDONDAS VIP */
        .img-grid { width: 45px; height: 45px; object-fit: cover; border-radius: 8px; border: 1px solid rgba(250, 211, 112, 0.3); box-shadow: 0 4px 8px rgba(0,0,0,0.3); }

        /* BOTONES ACCION */
        .btn-icon { background: transparent; border: none; cursor: pointer; padding: 6px; border-radius: 4px; transition: 0.3s; margin-right: 5px; font-size: 1.1em; }
        .btn-edit { color: #3498db; } .btn-edit:hover { background: rgba(52, 152, 219, 0.1); }
        .btn-delete { color: #e74c3c; } .btn-delete:hover { background: rgba(231, 76, 60, 0.1); }

        /* PAGINACIÓN */
        .pager-vip table { margin: 0 auto; }
        .pager-vip td { padding: 0 4px; border: none; }
        .pager-vip a, .pager-vip span { display: block; padding: 6px 12px; border-radius: 4px; text-decoration: none; font-weight: 600; font-size: 0.85em; }
        .pager-vip a { background: #111; color: #aaa; border: 1px solid #333; }
        .pager-vip a:hover { background: var(--dorado); color: #000; }
        .pager-vip span { background: var(--dorado); color: #000; border: 1px solid var(--dorado); }

        @media (max-width: 1200px) { .erp-body { grid-template-columns: 1fr; } }
    </style>

    <div class="erp-wrapper">
        

        <div class="erp-header">
            <h2><i class="fas fa-boxes"></i> Maestro de Inventarios VIP</h2>
        </div>

        <div class="erp-body">
            <div class="panel-form">
                <h3 id="lblTituloFormulario" runat="server"><i class="fas fa-plus-circle"></i> Registrar Ítem</h3>
                <asp:HiddenField ID="hfIdProducto" runat="server" Value="0" />

                <div class="form-group">
                    <label>Nombre del Producto *</label>
                    <asp:TextBox ID="txtNombre" runat="server" MaxLength="150" autocomplete="off" placeholder="Ej: Laptop Asus Tuf"></asp:TextBox>
                </div>

                <div class="form-group">
                    <label>Estructura de Categoría *</label>
                    <asp:DropDownList ID="ddlCategoria" runat="server"></asp:DropDownList>
                </div>

                <div class="form-group">
                    <label>Asignación de Proveedor *</label>
                    <asp:DropDownList ID="ddlProveedor" runat="server"></asp:DropDownList>
                </div>

                <div class="form-group">
                    <label>Precio Unitario ($) *</label>
                    <asp:TextBox ID="txtPrecio" runat="server" autocomplete="off" placeholder="0.00"></asp:TextBox>
                </div>

                <div class="form-group">
                    <label>Existencias Iniciales (Stock) *</label>
                    <asp:TextBox ID="txtStock" runat="server" TextMode="Number" placeholder="0"></asp:TextBox>
                </div>

                <div class="form-group">
                    <label>Descripción Técnica</label>
                    <asp:TextBox ID="txtDescripcion" runat="server" TextMode="MultiLine" Rows="3" MaxLength="500" placeholder="Detalles de hardware, garantía..."></asp:TextBox>
                </div>

                <div class="form-group">
                    <label>Imagen del Producto</label>
                    <asp:FileUpload ID="fuFoto" runat="server" accept=".jpg,.jpeg,.png,.webp" AllowMultiple="true" />
                </div>

                <asp:Button ID="btnGuardar" runat="server" Text="Inyectar a Inventario" CssClass="btn-vip" OnClick="btnGuardar_Click" />
                <asp:Button ID="btnLimpiar" runat="server" Text="Cancelar" CssClass="btn-vip btn-clear" OnClick="btnLimpiar_Click" CausesValidation="false" />
            </div>

            <div class="panel-right">
                <asp:UpdatePanel ID="upGrid" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        
                        <div class="filter-bar">
                            <div class="search-container">
                                <asp:TextBox ID="txtBuscar" runat="server" placeholder="Buscar por nombre o descripción..." AutoPostBack="true" OnTextChanged="Filtros_Changed"></asp:TextBox>
                                <i class="fas fa-search"></i>
                                <asp:UpdateProgress ID="UpdateProgress1" runat="server" AssociatedUpdatePanelID="upGrid">
                                    <ProgressTemplate>
                                        <i class="fas fa-spinner fa-spin ajax-loading"></i>
                                    </ProgressTemplate>
                                </asp:UpdateProgress>
                            </div>
                            
                            <asp:DropDownList ID="ddlFiltroCategoria" runat="server" CssClass="filter-select" AutoPostBack="true" OnSelectedIndexChanged="Filtros_Changed">
                            </asp:DropDownList>
                            
                            <asp:DropDownList ID="ddlFiltroProveedor" runat="server" CssClass="filter-select" AutoPostBack="true" OnSelectedIndexChanged="Filtros_Changed">
                            </asp:DropDownList>
                        </div>

                        <div class="panel-data">
                            <asp:GridView ID="gvProductos" runat="server" AutoGenerateColumns="False" 
                                CssClass="grid-vip" GridLines="None" DataKeyNames="pro_id"
                                AllowPaging="True" PageSize="8" OnPageIndexChanging="gvProductos_PageIndexChanging"
                                OnRowCommand="gvProductos_RowCommand">
                                <Columns>
                                    <asp:TemplateField HeaderText="Img">
                                        <ItemTemplate>
                                            <img src='<%# string.IsNullOrEmpty(Eval("pro_foto_path")?.ToString()) ? "https://placehold.co/100/111/fad370?text=VIP" : Eval("pro_foto_path") %>' class="img-grid" />
                                        </ItemTemplate>
                                        <ItemStyle Width="60px" HorizontalAlign="Center" />
                                    </asp:TemplateField>

                                    <asp:BoundField DataField="pro_nombre" HeaderText="Producto" />
                                    <asp:BoundField DataField="tbl_categoria.cat_nombre" HeaderText="Categoría" />
                                    <asp:BoundField DataField="pro_precio" HeaderText="Precio" DataFormatString="${0:N2}" />
                                    <asp:BoundField DataField="pro_cantidad" HeaderText="Stock" ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField DataField="tbl_proveedor.prov_nombre" HeaderText="Proveedor" />
                                    
                                    <asp:TemplateField HeaderText="Acciones">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="btnEditar" runat="server" CommandName="Editar" CommandArgument="<%# ((GridViewRow) Container).RowIndex %>" CssClass="btn-icon btn-edit" ToolTip="Editar">
                                                <i class="fas fa-pen"></i>
                                            </asp:LinkButton>
                                            <asp:LinkButton ID="btnEliminar" runat="server" CommandName="Eliminar" CommandArgument='<%# Eval("pro_id") %>' CssClass="btn-icon btn-delete" ToolTip="Desactivar" OnClientClick="return confirm('¿Seguro que desea dar de baja este producto del almacén?');">
                                                <i class="fas fa-trash-alt"></i>
                                            </asp:LinkButton>
                                        </ItemTemplate>
                                        <ItemStyle Width="100px" HorizontalAlign="Center" />
                                    </asp:TemplateField>
                                </Columns>
                                <PagerStyle CssClass="pager-vip" />
                                <EmptyDataTemplate>
                                    <div style="text-align: center; padding: 40px; color: #666;">
                                        <i class="fas fa-box-open" style="font-size: 3em; margin-bottom: 15px;"></i>
                                        <p>No se encontraron productos con los filtros aplicados.</p>
                                    </div>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
                    </ContentTemplate>
                </asp:UpdatePanel>
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