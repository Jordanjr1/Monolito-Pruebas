using Capa_Datos;
using Capa_Negocio;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace monolito
{
    public partial class MantenimientoProductos : Page
    {
        private N_Producto objNegocioProd = new N_Producto();
        private N_Proveedor objNegocioProv = new N_Proveedor();
        private N_Categoria objNegocioCat = new N_Categoria(); // INSTANCIA AÑADIDA PARA LEER DE MONGO

        // ELIMINADO: private DbMonolitoDataContext db = new DbMonolitoDataContext(); 
        // Regla estricta: La vista no debe acceder directo al contexto de datos.

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CargarDesplegablesCentrales();
                CargarGrid();
            }
        }

        private void CargarDesplegablesCentrales()
        {
            try
            {
                // 1. Llenar Catálogo de Categorías usando la Capa de Negocio (Conectada a Mongo)
                // Usamos ListarCategorias() y filtramos las activas. Ajusta el nombre del método si en tu N_Categoria se llama distinto.
                var listasCat = objNegocioCat.Listar().Where(c => c.cat_estado == true).OrderBy(c => c.cat_nombre).ToList();

                ddlCategoria.DataSource = listasCat;
                ddlCategoria.DataValueField = "cat_id";
                ddlCategoria.DataTextField = "cat_nombre";
                ddlCategoria.DataBind();
                ddlCategoria.Items.Insert(0, new ListItem("Seleccione Categoría...", ""));

                // Llenar Filtro de Categorías
                ddlFiltroCategoria.DataSource = listasCat;
                ddlFiltroCategoria.DataValueField = "cat_id";
                ddlFiltroCategoria.DataTextField = "cat_nombre";
                ddlFiltroCategoria.DataBind();
                ddlFiltroCategoria.Items.Insert(0, new ListItem("Todas las Categorías", ""));

                // 2. Llenar Almacén de Proveedores
                var listasProv = objNegocioProv.ListarProveedoresActivos();
                ddlProveedor.DataSource = listasProv;
                ddlProveedor.DataValueField = "prov_id";
                ddlProveedor.DataTextField = "prov_nombre";
                ddlProveedor.DataBind();
                ddlProveedor.Items.Insert(0, new ListItem("Seleccione Proveedor...", ""));

                // Llenar Filtro de Proveedores
                ddlFiltroProveedor.DataSource = listasProv;
                ddlFiltroProveedor.DataValueField = "prov_id";
                ddlFiltroProveedor.DataTextField = "prov_nombre";
                ddlFiltroProveedor.DataBind();
                ddlFiltroProveedor.Items.Insert(0, new ListItem("Todos los Proveedores", ""));
            }
            catch (Exception ex)
            {
                Alertar("Error de Inicialización", ex.Message, "error");
            }
        }

        // ========================================================
        // MOTOR DE BÚSQUEDA INTELIGENTE CON FILTROS CRUZADOS
        // ========================================================
        private void CargarGrid()
        {
            try
            {
                string textoBusqueda = txtBuscar.Text.Trim().ToLower();
                string idCatFiltro = ddlFiltroCategoria.SelectedValue;
                string idProvFiltro = ddlFiltroProveedor.SelectedValue;

                var query = objNegocioProd.ListarProductosActivos().AsQueryable();

                if (!string.IsNullOrEmpty(textoBusqueda))
                {
                    query = query.Where(p =>
                        (p.pro_nombre != null && p.pro_nombre.ToLower().Contains(textoBusqueda)) ||
                        (p.pro_descripcion != null && p.pro_descripcion.ToLower().Contains(textoBusqueda))
                    );
                }

                if (!string.IsNullOrEmpty(idCatFiltro))
                {
                    int catId = Convert.ToInt32(idCatFiltro);
                    query = query.Where(p => p.cat_id == catId);
                }

                if (!string.IsNullOrEmpty(idProvFiltro))
                {
                    int provId = Convert.ToInt32(idProvFiltro);
                    query = query.Where(p => p.prov_id == provId);
                }

                gvProductos.DataSource = query.ToList();
                gvProductos.DataBind();
            }
            catch (Exception ex)
            {
                Alertar("Error de Búsqueda", ex.Message, "error");
            }
        }

        protected void Filtros_Changed(object sender, EventArgs e)
        {
            gvProductos.PageIndex = 0;
            CargarGrid();
        }

        protected void gvProductos_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvProductos.PageIndex = e.NewPageIndex;
            CargarGrid();
        }

        // ========================================================
        // MÉTODOS CRUD
        // ========================================================
        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            try
            {
                if (ddlCategoria.SelectedIndex == 0 || ddlProveedor.SelectedIndex == 0)
                {
                    Alertar("Campos Incompletos", "Debe seleccionar una Categoría y un Proveedor válidos.", "warning");
                    return;
                }

                tbl_producto objProd = new tbl_producto();
                objProd.pro_nombre = txtNombre.Text.Trim();
                objProd.cat_id = Convert.ToInt32(ddlCategoria.SelectedValue);
                objProd.prov_id = Convert.ToInt32(ddlProveedor.SelectedValue);
                objProd.pro_precio = Convert.ToDecimal(txtPrecio.Text.Trim().Replace("$", ""));
                objProd.pro_cantidad = Convert.ToInt32(txtStock.Text.Trim());
                objProd.pro_descripcion = txtDescripcion.Text.Trim();
                objProd.pro_estado = true;

                List<string> rutasImagenesGuardadas = new List<string>();

                if (fuFoto.HasFiles)
                {
                    foreach (HttpPostedFile archivoSubido in fuFoto.PostedFiles)
                    {
                        string ext = Path.GetExtension(archivoSubido.FileName).ToLower();
                        if (ext != ".jpg" && ext != ".jpeg" && ext != ".png" && ext != ".webp")
                        {
                            Alertar("Formato no válido", $"El archivo '{archivoSubido.FileName}' no es una imagen permitida (JPG, JPEG, PNG, WEBP).", "warning");
                            return;
                        }

                        if (archivoSubido.ContentLength > 10 * 1024 * 1024)
                        {
                            Alertar("Archivo muy pesado", $"La imagen '{archivoSubido.FileName}' supera el límite permitido de 10MB.", "warning");
                            return;
                        }

                        try
                        {
                            using (System.Drawing.Image img = System.Drawing.Image.FromStream(archivoSubido.InputStream))
                            {
                                if (img.Width < 500 || img.Height < 500)
                                {
                                    Alertar("Resolución Insuficiente", $"La imagen '{archivoSubido.FileName}' mide {img.Width}x{img.Height}px. La resolución mínima requerida es de 500x500px.", "warning");
                                    return;
                                }
                            }
                        }
                        catch
                        {
                            Alertar("Archivo corrupto", $"No se pudo leer el archivo '{archivoSubido.FileName}' como una imagen válida.", "error");
                            return;
                        }
                    }

                    string carpeta = Server.MapPath("/Uploads/");
                    if (!Directory.Exists(carpeta)) Directory.CreateDirectory(carpeta);

                    int contador = 0;
                    foreach (HttpPostedFile archivoSubido in fuFoto.PostedFiles)
                    {
                        string extension = Path.GetExtension(archivoSubido.FileName).ToLower();
                        string nuevoNombre = "PROD_" + Guid.NewGuid().ToString().Substring(0, 8) + extension;
                        string rutaVirtual = "/Uploads/" + nuevoNombre;
                        string rutaFisica = Server.MapPath(rutaVirtual);

                        archivoSubido.SaveAs(rutaFisica);
                        rutasImagenesGuardadas.Add(rutaVirtual);

                        if (contador == 0)
                        {
                            objProd.pro_foto_path = rutaVirtual;
                        }
                        contador++;
                    }
                }

                string respuesta = "";
                int id = Convert.ToInt32(hfIdProducto.Value);

                if (id == 0)
                {
                    respuesta = objNegocioProd.InsertarProducto(objProd);
                }
                else
                {
                    objProd.pro_id = id;
                    if (!fuFoto.HasFiles)
                    {
                        // REEMPLAZO: Buscamos el producto anterior usando la Capa de Negocio, no la DB directa
                        var prodAnterior = objNegocioProd.ListarProductosActivos().FirstOrDefault(x => x.pro_id == id);
                        if (prodAnterior != null) objProd.pro_foto_path = prodAnterior.pro_foto_path;
                    }
                    respuesta = objNegocioProd.ActualizarProducto(objProd);
                }

                if (respuesta == "OK")
                {
                    Alertar("Éxito", "Producto inyectado correctamente al inventario central.", "success");
                    LimpiarFormulario();

                    txtBuscar.Text = "";
                    ddlFiltroCategoria.SelectedIndex = 0;
                    ddlFiltroProveedor.SelectedIndex = 0;
                    CargarGrid();

                    upGrid.Update();
                }
                else
                {
                    Alertar("Validación", respuesta, "warning");
                }
            }
            catch (Exception ex)
            {
                Alertar("Error de Operación", ex.Message, "error");
            }
        }

        protected void gvProductos_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Editar")
            {
                int index = Convert.ToInt32(e.CommandArgument);
                int idProd = Convert.ToInt32(gvProductos.DataKeys[index].Value);

                // REEMPLAZO: Buscar el producto para editar usando la Capa de Negocio
                var prod = objNegocioProd.ListarProductosActivos().FirstOrDefault(x => x.pro_id == idProd);

                if (prod != null)
                {
                    hfIdProducto.Value = prod.pro_id.ToString();
                    txtNombre.Text = prod.pro_nombre;

                    if (ddlCategoria.Items.FindByValue(prod.cat_id.ToString()) != null)
                        ddlCategoria.SelectedValue = prod.cat_id.ToString();

                    if (ddlProveedor.Items.FindByValue(prod.prov_id.ToString()) != null)
                        ddlProveedor.SelectedValue = prod.prov_id.ToString();

                    txtPrecio.Text = prod.pro_precio.ToString();
                    txtStock.Text = prod.pro_cantidad.ToString();
                    txtDescripcion.Text = prod.pro_descripcion;

                    lblTituloFormulario.InnerHtml = "<i class='fas fa-pen'></i> Editando Ítem";
                    btnGuardar.Text = "Actualizar Cambios";
                }
            }
            else if (e.CommandName == "Eliminar")
            {
                int idProd = Convert.ToInt32(e.CommandArgument);
                string resp = objNegocioProd.EliminarProducto(idProd);

                if (resp == "OK")
                {
                    Alertar("Almacén Actualizado", "El producto ha sido dado de baja.", "success");
                    CargarGrid();
                }
                else
                {
                    Alertar("Error", resp, "error");
                }
            }
        }

        protected void btnLimpiar_Click(object sender, EventArgs e)
        {
            LimpiarFormulario();
        }

        private void LimpiarFormulario()
        {
            hfIdProducto.Value = "0";
            txtNombre.Text = "";
            ddlCategoria.SelectedIndex = 0;
            ddlProveedor.SelectedIndex = 0;
            txtPrecio.Text = "";
            txtStock.Text = "";
            txtDescripcion.Text = "";
            lblTituloFormulario.InnerHtml = "<i class='fas fa-plus-circle'></i> Registrar Ítem";
            btnGuardar.Text = "Inyectar a Inventario";
        }

        private void Alertar(string t, string m, string icon)
        {
            string cleanMsg = m.Replace("'", "\\'").Replace("\n", " ");
            ScriptManager.RegisterStartupScript(this, GetType(), "alertProdVIP", $"showAlert('{t}', '{cleanMsg}', '{icon}');", true);
        }
    }
}