using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using Capa_Negocio;

namespace monolito
{
    public partial class _Default : Page
    {
        public int TotalUsuarios = 0;
        public int UsuariosBloqueados = 0;
        public int TotalValidaciones2FA = 0;

        // Instancia global para poder leer los productos del inventario
        private N_Producto objNegocioProd = new N_Producto();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["UserTypeId"] != null)
                {
                    string roleId = Session["UserTypeId"].ToString();

                    if (roleId == "1")
                    {
                        phDashboardAdmin.Visible = true;
                        phDashboardUser.Visible = false;

                        CargarDatosRealesAdmin();

                        // Llenar el Carrusel y la Gráfica de BI
                        CargarCarruselBI();
                        CargarGraficoBI();
                    }
                    else if (roleId == "2")
                    {
                        phDashboardAdmin.Visible = false;
                        phDashboardUser.Visible = true;
                    }
                }
            }
        }

        private void CargarDatosRealesAdmin()
        {
            try
            {
                N_Usuario objNegocio = new N_Usuario();

                var listaBloqueados = objNegocio.ObtenerUsuariosBloqueados();
                if (listaBloqueados != null) UsuariosBloqueados = listaBloqueados.Count;

                var listaTodos = objNegocio.ObtenerTodosLosUsuarios();
                if (listaTodos != null) TotalUsuarios = listaTodos.Count;

                TotalValidaciones2FA = objNegocio.ObtenerTotalValidaciones2FA();

                if (listaTodos != null)
                {
                    var ultimosUsuarios = listaTodos
                        .OrderByDescending(u => u.tbl_fecha_de_registro)
                        .Take(5)
                        .Select(u => new
                        {
                            Usuario = u.tbl_email,
                            Accion = u.tbl_activo == true ? "Registro nuevo" : "Bloqueado por intentos",
                            IP = "192.168.1." + new Random().Next(10, 255),
                            Estado = u.tbl_activo == true ? "Nuevo" : "Alerta",
                            Fecha = u.tbl_fecha_de_registro
                        }).ToList();

                    rptActividad.DataSource = ultimosUsuarios;
                    rptActividad.DataBind();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error al cargar stats: " + ex.Message);
            }
        }

        // ==========================================
        // MÉTODOS DEL MÓDULO BI (Inventario)
        // ==========================================
        private void CargarCarruselBI()
        {
            try
            {
                // OPTIMIZACIÓN VIP: Traemos solo los últimos 15 productos, sin filtro de foto, 
                // para que el carrusel se mueva rápido y no asfixie el servidor.
                var listaParaCarrusel = objNegocioProd.ListarProductosActivos()
                                                      .OrderByDescending(p => p.pro_id)
                                                      .Take(15)
                                                      .ToList();

                repCarruselDefault.DataSource = listaParaCarrusel;
                repCarruselDefault.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error al cargar carrusel: " + ex.Message);
            }
        }

        // REEMPLAZA EL MÉTODO DEL GRÁFICO
        private void CargarGraficoBI()
        {
            try
            {
                var listaTotal = objNegocioProd.ListarProductosActivos();
                if (listaTotal == null || listaTotal.Count == 0) return;

                // NAVEGACIÓN RELACIONAL: Usamos p.tbl_categoria.cat_nombre
                var datosAgrupados = listaTotal.GroupBy(p => p.tbl_categoria != null ? p.tbl_categoria.cat_nombre : "Sin Categoría")
                                               .Select(g => new
                                               {
                                                   Categoria = g.Key,
                                                   TotalStock = g.Sum(x => x.pro_cantidad)
                                               }).ToList();

                string etiquetas = string.Join(",", datosAgrupados.Select(d => $"'{d.Categoria}'"));
                string valores = string.Join(",", datosAgrupados.Select(d => d.TotalStock));

                string scriptJS = $@"
                    function initGraficoVIP() {{
                        if (typeof Chart === 'undefined') {{ setTimeout(initGraficoVIP, 100); return; }}
                        var canvas = document.getElementById('graficoStockDefault');
                        if(!canvas) return;
                        var ctx = canvas.getContext('2d');
                        var gradient = ctx.createLinearGradient(0, 0, 0, 300);
                        gradient.addColorStop(0, 'rgba(250, 211, 112, 0.8)');
                        gradient.addColorStop(1, 'rgba(250, 211, 112, 0.05)');
                        new Chart(ctx, {{
                            type: 'bar',
                            data: {{ labels: [{etiquetas}], datasets: [{{ label: 'Unidades', data: [{valores}], backgroundColor: gradient, borderColor: '#FAD370', borderWidth: 1, borderRadius: 6, barPercentage: 0.5 }}] }},
                            options: {{ responsive: true, maintainAspectRatio: false, animation: {{ y: {{ duration: 1500, easing: 'easeOutQuart' }} }}, plugins: {{ legend: {{ display: false }} }}, scales: {{ y: {{ beginAtZero: true, grid: {{ color: 'rgba(255,255,255,0.05)' }}, ticks: {{ color: '#888' }} }}, x: {{ grid: {{ display: false }}, ticks: {{ color: '#aaa', font: {{ weight: '600' }} }} }} }} }}
                        }});
                    }}
                    setTimeout(initGraficoVIP, 200);
                ";
                ScriptManager.RegisterStartupScript(this, GetType(), "GenerarGraficoBI", scriptJS, true);
            }
            catch (Exception ex) { System.Diagnostics.Debug.WriteLine("Error gráfico: " + ex.Message); }
        }

        // ==========================================
        // FUNCIONES DE SOPORTE (UI)
        // ==========================================
        protected string ObtenerBadgeEstado(string estado)
        {
            if (estado.ToLower() == "ok")
                return "<span class='status-badge ok'><i class='fas fa-check-circle'></i> OK</span>";
            if (estado.ToLower() == "alerta")
                return "<span class='status-badge warn'><i class='fas fa-exclamation-triangle'></i> Alerta</span>";

            return "<span class='status-badge info'><i class='fas fa-info-circle'></i> Nuevo</span>";
        }

        protected string ObtenerTiempoTranscurrido(DateTime fecha)
        {
            TimeSpan tiempoPasado = DateTime.Now - fecha;

            if (tiempoPasado.TotalMinutes < 1) return "hace unos segundos";
            if (tiempoPasado.TotalMinutes < 60) return $"hace {(int)tiempoPasado.TotalMinutes} min";
            if (tiempoPasado.TotalHours < 24) return $"hace {(int)tiempoPasado.TotalHours} horas";
            if (tiempoPasado.TotalDays < 30) return $"hace {(int)tiempoPasado.TotalDays} días";

            return fecha.ToString("dd MMM yyyy");
        }
    }
}