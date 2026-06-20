using System;
using System.IO;
using System.Data;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using Microsoft.VisualBasic.FileIO;
using ExcelDataReader;
using Capa_Datos;
using Capa_Negocio;

namespace monolito
{
    public partial class CargaMasiva : Page
    {
        private N_Producto objNegocioProd = new N_Producto();

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        // =========================================================================
        // FASE 0: SUBIDA FÍSICA DE IMÁGENES AL SERVIDOR ANTES DEL EXCEL
        // =========================================================================
        protected void btnSubirImagenesFisicas_Click(object sender, EventArgs e)
        {
            try
            {
                if (fuImagenesMasivas.HasFiles)
                {
                    string carpeta = Server.MapPath("/Uploads/");
                    if (!Directory.Exists(carpeta)) Directory.CreateDirectory(carpeta);

                    int contadorSubidas = 0;

                    // Recorremos todos los archivos seleccionados
                    foreach (HttpPostedFile archivo in fuImagenesMasivas.PostedFiles)
                    {
                        string ext = Path.GetExtension(archivo.FileName).ToLower();
                        if (ext == ".jpg" || ext == ".jpeg" || ext == ".png" || ext == ".webp")
                        {
                            // REGLA DE ORO: Conservamos el nombre original para que coincida con el Excel
                            string nombreOriginal = Path.GetFileName(archivo.FileName);
                            string rutaFisica = Path.Combine(carpeta, nombreOriginal);

                            archivo.SaveAs(rutaFisica);
                            contadorSubidas++;
                        }
                    }

                    if (contadorSubidas > 0)
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "imgOk", $"showAlert('Imágenes en Servidor', 'Se alojaron {contadorSubidas} imágenes físicamente en el servidor. Ahora ya puede procesar el archivo Excel.', 'success');", true);
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "imgWarn1", "showAlert('Formato no válido', 'No se detectó ningún formato de imagen válido entre los archivos seleccionados.', 'warning');", true);
                    }
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "imgWarn2", "showAlert('Atención', 'Seleccione al menos una imagen antes de subir al servidor.', 'warning');", true);
                }
            }
            catch (Exception ex)
            {
                string errorSeguro = ex.Message.Replace("'", "\\'").Replace("\n", " ");
                ScriptManager.RegisterStartupScript(this, GetType(), "imgErr", $"showAlert('Error de Operación', '{errorSeguro}', 'error');", true);
            }
        }

        // =========================================================================
        // FASE 1: LEER, COMPROBAR FORMATO Y PREVISUALIZAR EXCEL
        // =========================================================================
        protected void btnPrevisualizar_Click(object sender, EventArgs e)
        {
            if (!fuCSV.HasFile)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "err", "showAlert('Aviso', 'Por favor, seleccione un archivo de matriz de inventario.', 'warning');", true);
                return;
            }

            try
            {
                string extension = Path.GetExtension(fuCSV.FileName).ToLower();

                if (extension != ".csv" && extension != ".xls" && extension != ".xlsx")
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "errExt", "showAlert('Formato Inválido', 'Solo se permiten archivos .CSV, .XLS o .XLSX', 'error');", true);
                    return;
                }

                DataTable dt = new DataTable();
                dt.Columns.Add("Nombre");
                dt.Columns.Add("Descripcion");
                dt.Columns.Add("Categoria");
                dt.Columns.Add("Precio");
                dt.Columns.Add("Stock");
                dt.Columns.Add("Proveedor");
                dt.Columns.Add("Imagen");

                // MODO 1: LECTURA CSV
                if (extension == ".csv")
                {
                    using (TextFieldParser parser = new TextFieldParser(fuCSV.PostedFile.InputStream))
                    {
                                //clase de micro
                        parser.TextFieldType = FieldType.Delimited;
                        parser.SetDelimiters(",");

                        if (!parser.EndOfData)
                        {
                            string[] encabezados = parser.ReadFields();
                            if (encabezados == null || encabezados.Length != 7 ||
                                encabezados[0].Trim().ToLower() != "nombre" ||
                                encabezados[5].Trim().ToLower() != "proveedor")
                            {
                                throw new Exception("Estructura inválida. El CSV debe tener los encabezados: Nombre, Descripcion, Categoria, Precio, Stock, Proveedor, Imagen.");
                            }
                        }

                        while (!parser.EndOfData)
                        {
                            string[] campos = parser.ReadFields();
                            if (campos != null && campos.Length == 7) dt.Rows.Add(campos);
                        }
                    }
                }
                // MODO 2: LECTURA DE EXCEL (.XLS, .XLSX) BLINDADA
                else
                {
                    using (var stream = fuCSV.PostedFile.InputStream)
                    {
                        using (var reader = ExcelReaderFactory.CreateReader(stream))
                        {
                            var result = reader.AsDataSet(new ExcelDataSetConfiguration()
                            {
                                ConfigureDataTable = (_) => new ExcelDataTableConfiguration() { UseHeaderRow = true }
                            });

                            DataTable dtExcel = result.Tables[0];

                            // VALIDACIÓN ESTRICTA DE ENCABEZADOS DE EXCEL
                            if (dtExcel.Columns.Count < 7)
                            {
                                throw new Exception("El Excel no tiene las 7 columnas requeridas.");
                            }

                            string col1 = dtExcel.Columns[0].ColumnName.Trim().ToLower();
                            string col6 = dtExcel.Columns[5].ColumnName.Trim().ToLower();

                            if (col1 != "nombre" || col6 != "proveedor")
                            {
                                throw new Exception("Los encabezados del Excel son incorrectos. Debe ser exactamente: Nombre, Descripcion, Categoria, Precio, Stock, Proveedor, Imagen.");
                            }

                            foreach (DataRow row in dtExcel.Rows)
                            {
                                if (!string.IsNullOrWhiteSpace(row[0].ToString()))
                                {
                                    dt.Rows.Add(row[0], row[1], row[2], row[3], row[4], row[5], row[6]);
                                }
                            }
                        }
                    }
                }

                if (dt.Rows.Count == 0) throw new Exception("El archivo está vacío.");

                lblTotal.InnerText = dt.Rows.Count.ToString();
                gvPreview.DataSource = dt;
                gvPreview.DataBind();

                phSummary.Visible = true;
                phPreview.Visible = true;

                Session["DataCSVVIP"] = dt;
            }
            catch (Exception ex)
            {
                string errorSeguro = ex.Message.Replace("'", "\\'").Replace("\n", " ");
                ScriptManager.RegisterStartupScript(this, GetType(), "fatalRead", $"showAlert('Rechazado por Seguridad', '{errorSeguro}', 'error');", true);
            }
        }

        // =========================================================================
        // FASE 2: INYECCIÓN MASIVA
        // =========================================================================
        protected void btnConfirmarSubida_Click(object sender, EventArgs e)
        {
            DataTable dtModel = (DataTable)Session["DataCSVVIP"];
            if (dtModel == null || dtModel.Rows.Count == 0)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "noData", "showAlert('Error', 'No hay datos para procesar.', 'error');", true);
                return;
            }

            // LA SOLUCIÓN DEL INGENIERO: PASO 1 (ELIMINA) Y PASO 2 (REINICIA) ANTES DEL BUCLE
            try
            {
                using (DbMonolitoDataContext dbLimpieza = new DbMonolitoDataContext())
                {
                    dbLimpieza.ExecuteCommand("DELETE FROM tbl_producto;");
                    dbLimpieza.ExecuteCommand("DELETE FROM tbl_proveedor;");
                    dbLimpieza.ExecuteCommand("DBCC CHECKIDENT ('tbl_producto', RESEED, 0);");
                    dbLimpieza.ExecuteCommand("DBCC CHECKIDENT ('tbl_proveedor', RESEED, 0);");
                }
            }
            catch (Exception ex)
            {
                string errLimpieza = ex.Message.Replace("'", "\\'").Replace("\n", " ");
                ScriptManager.RegisterStartupScript(this, GetType(), "errClean", $"showAlert('Error de Inicialización', 'No se pudo vaciar la BD: {errLimpieza}', 'error');", true);
                return;
            }

            // PASO 3: CARGA (Iteración)
            int registrosExitosos = 0;
            int registrosFallidos = 0;
            List<string> reporteErrores = new List<string>();

            int contadorFila = 2;

            foreach (DataRow fila in dtModel.Rows)
            {
                try
                {
                    string nombre = fila["Nombre"].ToString().Trim();
                    string descripcion = fila["Descripcion"].ToString().Trim();
                    string categoria = fila["Categoria"].ToString().Trim();
                    string precioStr = fila["Precio"].ToString().Trim().Replace("$", "");
                    string stockStr = fila["Stock"].ToString().Trim();
                    string proveedor = fila["Proveedor"].ToString().Trim();
                    string imagenPath = fila["Imagen"].ToString().Trim();

                    if (string.IsNullOrEmpty(nombre) || string.IsNullOrEmpty(categoria) || string.IsNullOrEmpty(proveedor))
                    {
                        registrosFallidos++;
                        reporteErrores.Add($"Fila {contadorFila}: Campos obligatorios vacíos.");
                        contadorFila++;
                        continue;
                    }

                    decimal precioDecimal = 0;
                    if (!decimal.TryParse(precioStr, out precioDecimal))
                    {
                        registrosFallidos++;
                        reporteErrores.Add($"Fila {contadorFila}: Formato de precio inválido.");
                        contadorFila++;
                        continue;
                    }

                    int stockEntero = 0;
                    if (!int.TryParse(stockStr, out stockEntero))
                    {
                        registrosFallidos++;
                        reporteErrores.Add($"Fila {contadorFila}: Formato de stock inválido.");
                        contadorFila++;
                        continue;
                    }

                    tbl_producto nuevoProducto = new tbl_producto
                    {
                        pro_nombre = nombre,
                        pro_descripcion = descripcion,
                        pro_precio = precioDecimal,
                        pro_cantidad = stockEntero,
                        pro_foto_path = string.IsNullOrEmpty(imagenPath) ? null : imagenPath
                    };

                    string resultadoSQL = objNegocioProd.EjecutarSPMasivo(nuevoProducto, categoria, proveedor);

                    if (resultadoSQL == "OK") registrosExitosos++;
                    else { registrosFallidos++; reporteErrores.Add($"Fila {contadorFila}: {resultadoSQL}"); }
                }
                catch (Exception ex)
                {
                    registrosFallidos++;
                    reporteErrores.Add($"Fila {contadorFila}: {ex.Message}");
                }
                contadorFila++;
            }

            Session.Remove("DataCSVVIP");
            phPreview.Visible = false;
            phSummary.Visible = false;

            if (registrosFallidos == 0)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "finalOk", $"showAlert('¡Inyección Completa!', 'Se vació el sistema y se registraron exitosamente {registrosExitosos} productos reconstruyendo la sincronización de IDs.', 'success');", true);
            }
            else
            {
                string detalleErrores = string.Join("<br/>", reporteErrores);
                if (detalleErrores.Length > 400) detalleErrores = detalleErrores.Substring(0, 400) + "... (Lista truncada)";
                SwalTemplateHTML(registrosExitosos, registrosFallidos, detalleErrores);
            }
        }

        private void SwalTemplateHTML(int exitos, int fallos, string detalle)
        {
            string detalleSeguro = detalle.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");

            string scriptHtml = $@"
                Swal.fire({{
                    title: 'Auditoría de Inyección',
                    html: '<div style=""text-align:left; font-size:0.95em;"">' +
                          '<p style=""color:#2ed573;""><b>✔ Éxitos:</b> {exitos} productos registrados.</p>' +
                          '<p style=""color:#ff4757; margin-bottom:15px;""><b>❌ Rechazados:</b> {fallos} anomalías detectadas.</p>' +
                          '<div style=""background:#111; padding:12px; border-radius:6px; max-height:150px; overflow-y:auto; font-family:monospace; color:#bbb; border:1px solid #333;"">{detalleSeguro}</div>' +
                          '</div>',
                    icon: 'warning', background: '#1e1e24', color: '#fff', confirmButtonColor: '#FAD370', width: '500px'
                }});";

            ScriptManager.RegisterStartupScript(this, GetType(), "finalWarn", scriptHtml, true);
        }
    }
}