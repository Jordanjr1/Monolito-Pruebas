<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="monolito._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swiper@10/swiper-bundle.min.css" />
    <script src="https://cdn.jsdelivr.net/npm/swiper@10/swiper-bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
    /* ── ANIMATIONS ── */
    @keyframes slideDown  { from { opacity:0; transform:translateY(-18px); } to { opacity:1; transform:translateY(0); } }
    @keyframes fadeUp     { from { opacity:0; transform:translateY(28px);  } to { opacity:1; transform:translateY(0); } }
    @keyframes shimmerMove{ 0% { left:-100%; } 100% { left:200%; } }
    @keyframes numberTick { from { opacity:0; transform:translateY(10px); } to { opacity:1; transform:translateY(0); } }
    @keyframes borderGlow { 0%,100% { border-color:rgba(250,211,112,0.12); } 50% { border-color:rgba(250,211,112,0.35); } }

    /* ── HEADER ── */
    .dash-header {
        margin-bottom: 36px;
        animation: slideDown 0.55s ease-out;
        display: flex; align-items: flex-end; justify-content: space-between;
        flex-wrap: wrap; gap: 16px;
    }
    .dash-header-text h1 {
        font-size: 2em; font-weight: 800; margin: 0 0 4px; line-height: 1.1;
        background: linear-gradient(90deg, #fff 60%, #fad370 100%);
        -webkit-background-clip: text; -webkit-text-fill-color: transparent;
        background-clip: text;
    }
    .dash-header-text p { color: #555; font-size: 0.875em; margin: 0; }
    .dash-header-text p span { color: #fad370; }

    .live-badge {
        display: inline-flex; align-items: center; gap: 7px;
        background: rgba(76,209,55,0.08); border: 1px solid rgba(76,209,55,0.2);
        color: #4cd137; padding: 6px 14px; border-radius: 50px; font-size: 0.75em;
        font-weight: 600; letter-spacing: 1px; text-transform: uppercase;
        animation: fadeUp 0.6s 0.3s ease-out both;
    }
    .live-dot {
        width: 7px; height: 7px; border-radius: 50%; background: #4cd137;
        animation: livePulse 1.5s infinite;
    }
    @keyframes livePulse { 0%,100%{opacity:1;transform:scale(1)} 50%{opacity:0.4;transform:scale(0.8)} }

    /* ── CARDS GRID ── */
    .cards-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(230px, 1fr));
        gap: 20px;
    }

    /* ── CARD ── */
    .dash-card {
        background: rgba(12, 12, 12, 0.85);
        border: 1px solid rgba(255, 255, 255, 0.06);
        border-radius: 16px; padding: 24px;
        display: flex; align-items: center; justify-content: space-between;
        cursor: pointer; position: relative; overflow: hidden;
        transition: transform 0.35s cubic-bezier(0.4,0,0.2,1),
                    box-shadow 0.35s ease,
                    border-color 0.35s ease,
                    background 0.35s ease;
        animation: fadeUp 0.6s ease-out both;
    }
    .dash-card:nth-child(1){animation-delay:0.08s}
    .dash-card:nth-child(2){animation-delay:0.16s}
    .dash-card:nth-child(3){animation-delay:0.24s}
    .dash-card:nth-child(4){animation-delay:0.32s}

    .dash-card::after {
        content: ''; position: absolute;
        top: 0; left: -100%; width: 50%; height: 100%;
        background: linear-gradient(90deg, transparent, rgba(250,211,112,0.04), transparent);
        animation: shimmerMove 4s ease-in-out infinite;
        pointer-events: none;
    }

    .dash-card::before {
        content: ''; position: absolute; top: 0; left: 0; right: 0; height: 2px;
        background: var(--card-accent, transparent);
        opacity: 0; transition: opacity 0.35s ease;
    }
    .dash-card:hover::before { opacity: 1; }

    .dash-card:hover {
        transform: translateY(-7px) scale(1.01);
        background: rgba(18, 18, 18, 0.95);
        border-color: rgba(250, 211, 112, 0.28);
        box-shadow: 0 20px 50px rgba(0,0,0,0.6), 0 0 0 1px rgba(250,211,112,0.1);
    }

    .card-body { flex: 1; }
    .card-label { font-size: 0.72em; color: #555; text-transform: uppercase; letter-spacing: 1.8px; margin: 0 0 10px; font-weight: 500; }
    .card-value { font-size: 2.2em; font-weight: 800; margin: 0; line-height: 1; display: flex; align-items: baseline; gap: 4px; }
    .card-value-unit { font-size: 0.45em; font-weight: 600; color: #555; }
    .card-meta { margin-top: 10px; font-size: 0.72em; color: #444; display: flex; align-items: center; gap: 5px; }
    .card-meta.up   { color: #4cd137; }
    .card-meta.down { color: #ff4757; }

    .card-icon-wrap {
        width: 60px; height: 60px; border-radius: 14px; flex-shrink: 0;
        display: flex; align-items: center; justify-content: center;
        font-size: 1.6em; margin-left: 18px;
        transition: transform 0.35s cubic-bezier(0.4,0,0.2,1), box-shadow 0.35s ease;
        background: var(--icon-bg, rgba(250,211,112,0.08));
        color: var(--icon-color, #fad370);
    }
    .dash-card:hover .card-icon-wrap {
        transform: scale(1.12) rotate(-6deg);
        box-shadow: 0 0 20px var(--icon-glow, rgba(250,211,112,0.2));
    }

    /* ── ESTILOS MÓDULO BI VIP (GALERÍA 3D CORREGIDA) ── */
    .dashboard-grid-bi { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-top: 36px; }
    .panel-vip-bi { background: rgba(12, 12, 12, 0.85); padding: 25px; border-radius: 16px; border: 1px solid rgba(255, 255, 255, 0.06); animation: fadeUp 0.6s 0.4s ease-out both; overflow: hidden; /* EVITA QUE LA GALERÍA ROMPA EL CONTENEDOR */ }
    .panel-vip-bi h3 { color: #fad370; margin-top: 0; margin-bottom: 20px; font-size: 1.05em; text-transform: uppercase; letter-spacing: 1px; border-bottom: 1px dashed rgba(250, 211, 112, 0.15); padding-bottom: 12px; }
    
    /* ── EFECTO 3D SWIPER ── */
    .swiper-container-3d { 
        width: 100%; 
        padding-top: 20px; 
        padding-bottom: 50px; 
        perspective: 1200px; /* CLAVE 1: Profundidad del cajón 3D */
    }
    
    .swiper-slide-3d { 
        width: 250px; /* Fija el ancho estricto para que no colapse */
        height: 330px; 
        background-color: transparent; 
        border-radius: 18px; 
        display: flex; 
        flex-direction: column; 
        overflow: hidden; 
        transform-style: preserve-3d; /* CLAVE 2: Mantiene los elementos hijos en el espacio Z */
        box-shadow: 0 15px 40px rgba(0,0,0,0.7); 
        border: 1px solid rgba(250,211,112,0.3); /* Un toque de borde VIP */
    }
    
    .swiper-slide-3d img { 
        width: 100%; 
        height: 230px; 
        object-fit: cover; /* CLAVE 3: Fuerza a las imágenes a no deformarse */
        object-position: center;
        background-color: #111;
    }
    
    .slide-info-3d { 
        padding: 15px 10px; 
        text-align: center; 
        flex-grow: 1; 
        display: flex; 
        flex-direction: column; 
        justify-content: center; 
        background: linear-gradient(180deg, #181818 0%, #0a0a0a 100%); 
        border-top: 2px solid #fad370; 
    }
    .slide-info-3d h4 { margin: 0; color: #fff; font-size: 0.95em; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; font-weight: 500; letter-spacing: 0.5px; }
    .slide-info-3d p { margin: 6px 0 0 0; color: #fad370; font-weight: 800; font-size: 1.2em; }
    
    .swiper-pagination-bullet { background: #555; opacity: 1; transition: all 0.3s; }
    .swiper-pagination-bullet-active { background: #fad370; box-shadow: 0 0 10px rgba(250,211,112,0.5); transform: scale(1.2); }
    @media (max-width: 992px) { .dashboard-grid-bi { grid-template-columns: 1fr; } }

    /* ── SECTION SPACER ── */
    .section-gap { margin-top: 36px; }

    /* ── ACTIVITY TABLE (Admin) ── */
    .section-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 18px; animation: slideDown 0.5s 0.4s ease-out both; }
    .section-header h2 { font-size: 1em; font-weight: 600; color: #888; text-transform: uppercase; letter-spacing: 1.5px; }
    .section-header a  { color: #fad370; font-size: 0.8em; text-decoration: none; transition: opacity 0.2s; }
    .section-header a:hover { opacity: 0.7; }

    .activity-table-wrap { background: rgba(10,10,10,0.9); border: 1px solid rgba(255,255,255,0.05); border-radius: 14px; overflow: hidden; animation: fadeUp 0.6s 0.45s ease-out both; }
    .activity-table { width: 100%; border-collapse: collapse; font-size: 0.85em; }
    .activity-table th { padding: 12px 18px; text-align: left; color: #444; font-weight: 500; font-size: 0.75em; text-transform: uppercase; letter-spacing: 1.2px; border-bottom: 1px solid rgba(255,255,255,0.04); }
    .activity-table td { padding: 13px 18px; border-bottom: 1px solid rgba(255,255,255,0.03); color: #bbb; vertical-align: middle; }
    .activity-table tr:last-child td { border-bottom: none; }
    .activity-table tr:hover td { background: rgba(250,211,112,0.03); color: #fff; }

    .status-badge { display: inline-flex; align-items: center; gap: 5px; padding: 3px 10px; border-radius: 20px; font-size: 0.75em; font-weight: 600; }
    .status-badge.ok     { background:rgba(76,209,55,0.1); color:#4cd137; }
    .status-badge.warn   { background:rgba(255,71,87,0.1); color:#ff4757; }
    .status-badge.info   { background:rgba(52,152,219,0.1); color:#3498db; }
    .status-badge i { font-size: 0.7em; }

    /* ── USER QUICK ACTIONS ── */
    .quick-actions { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-top: 28px; animation: fadeUp 0.6s 0.4s ease-out both; }
    .action-btn { background: rgba(12,12,12,0.85); border: 1px solid rgba(255,255,255,0.06); border-radius: 12px; padding: 18px; cursor: pointer; display: flex; align-items: center; gap: 14px; text-decoration: none; color: inherit; transition: all 0.25s ease; }
    .action-btn:hover { background: rgba(20,20,20,0.95); border-color: rgba(250,211,112,0.25); transform: translateY(-3px); box-shadow: 0 10px 25px rgba(0,0,0,0.4); color: #fff; }
    .action-btn-icon { width: 46px; height: 46px; border-radius: 10px; flex-shrink: 0; display: flex; align-items: center; justify-content: center; font-size: 1.4em; }
    .action-btn-info span { display: block; font-size: 0.75em; color: #555; }
    .action-btn-info strong { font-size: 0.95em; font-weight: 600; }
</style>

<asp:PlaceHolder ID="phDashboardAdmin" runat="server" Visible="false">

    <div class="dash-header">
        <div class="dash-header-text">
            <h1>Centro de Control</h1>
            <p>Sistema VIP · <span>Administración completa</span></p>
        </div>
        <div class="live-badge"><span class="live-dot"></span>Sistema activo</div>
    </div>

    <div class="cards-grid">
        <div class="dash-card" style="--card-accent:linear-gradient(90deg,#fad370,transparent);">
            <div class="card-body">
                <p class="card-label">Usuarios registrados</p>
                <h2 class="card-value" id="valUsuarios">0</h2>
                <p class="card-meta up"><i class="fas fa-arrow-up"></i> +12 este mes</p>
            </div>
            <div class="card-icon-wrap"><i class="fas fa-users"></i></div>
        </div>

        <div class="dash-card" style="--card-accent:linear-gradient(90deg,#ff4757,transparent);--icon-bg:rgba(255,71,87,0.08);--icon-color:#ff4757;--icon-glow:rgba(255,71,87,0.2);">
            <div class="card-body">
                <p class="card-label">Cuentas bloqueadas</p>
                <h2 class="card-value" style="color:#ff4757" id="valBloqueadas">0</h2>
                <p class="card-meta down"><i class="fas fa-exclamation-triangle"></i> Requieren revisión</p>
            </div>
            <div class="card-icon-wrap"><i class="fas fa-user-lock"></i></div>
        </div>

        <div class="dash-card" style="--card-accent:linear-gradient(90deg,#3498db,transparent);--icon-bg:rgba(52,152,219,0.08);--icon-color:#3498db;--icon-glow:rgba(52,152,219,0.2);">
            <div class="card-body">
                <p class="card-label">Validaciones 2FA</p>
                <h2 class="card-value" style="color:#3498db" id="val2FA">0</h2>
                <p class="card-meta up"><i class="fas fa-arrow-up"></i> +8% vs ayer</p>
            </div>
            <div class="card-icon-wrap"><i class="fas fa-qrcode"></i></div>
        </div>

        <div class="dash-card" style="--card-accent:linear-gradient(90deg,#4cd137,transparent);--icon-bg:rgba(76,209,55,0.08);--icon-color:#4cd137;--icon-glow:rgba(76,209,55,0.2);">
            <div class="card-body">
                <p class="card-label">Estado del servidor</p>
                <h2 class="card-value" style="color:#4cd137">
                    <span id="valServer">0</span>
                    <span class="card-value-unit">%</span>
                </h2>
                <p class="card-meta up"><i class="fas fa-circle" style="font-size:0.6em;"></i> Operativo · Uptime 99.9%</p>
            </div>
            <div class="card-icon-wrap"><i class="fas fa-server"></i></div>
        </div>
    </div>

    <div class="dashboard-grid-bi">
        <div class="panel-vip-bi">
            <h3><i class="fas fa-cube"></i> Galería Destacada 3D</h3>
            <div class="swiper swiper-container-3d mySwiper3D">
                <div class="swiper-wrapper">
                    <asp:Repeater ID="repCarruselDefault" runat="server" EnableViewState="false">
                        <ItemTemplate>
                            <div class="swiper-slide swiper-slide-3d">
                                <img src='<%# string.IsNullOrEmpty(Eval("pro_foto_path")?.ToString()) ? "https://placehold.co/400x300/111/fad370?text=VIP+Producto" : Eval("pro_foto_path") %>' alt='<%# Eval("pro_nombre") %>' onerror="this.src='https://placehold.co/400x300/111/fad370?text=VIP+Producto';" />
                                <div class="slide-info-3d">
                                    <h4><%# Eval("pro_nombre") %></h4>
                                    <p>$<%# Eval("pro_precio", "{0:N2}") %></p>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                <div class="swiper-pagination"></div>
            </div>
        </div>

        <div class="panel-vip-bi">
            <h3><i class="fas fa-chart-area"></i> Densidad de Inventario</h3>
            <div style="position: relative; height: 300px; width: 100%;">
                <canvas id="graficoStockDefault"></canvas>
            </div>
        </div>
    </div>

    <div class="section-gap">
        <div class="section-header">
            <h2><i class="fas fa-history" style="margin-right:8px;font-size:0.9em;"></i>Actividad reciente</h2>
            <a href="#">Ver todo <i class="fas fa-arrow-right"></i></a>
        </div>
        <div class="activity-table-wrap">
            <table class="activity-table">
                <thead>
                    <tr>
                        <th>Usuario</th>
                        <th>Acción</th>
                        <th>IP</th>
                        <th>Estado</th>
                        <th>Hora</th>
                    </tr>
                </thead>
               <tbody>
                    <asp:Repeater ID="rptActividad" runat="server" EnableViewState="false">
                        <ItemTemplate>
                            <tr>
                                <td><i class="fas fa-user-circle" style="margin-right:8px;color:#555;"></i><%# Eval("Usuario") %></td>
                                <td><%# Eval("Accion") %></td>
                                <td><%# Eval("IP") %></td>
                                <td>
                                    <%# ObtenerBadgeEstado(Eval("Estado").ToString()) %>
                                </td>
                                <td><%# ObtenerTiempoTranscurrido(Convert.ToDateTime(Eval("Fecha"))) %></td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </div>

</asp:PlaceHolder>

<asp:PlaceHolder ID="phDashboardUser" runat="server" Visible="false">

    <div class="dash-header">
        <div class="dash-header-text">
            <h1>Mi Panel VIP</h1>
            <p>Tu actividad · <span>Cyber-Sweeper VIP</span></p>
        </div>
        <div class="live-badge"><span class="live-dot"></span>En línea</div>
    </div>

    <div class="cards-grid">
        <div class="dash-card" style="--card-accent:linear-gradient(90deg,#3498db,transparent);--icon-bg:rgba(52,152,219,0.08);--icon-color:#3498db;--icon-glow:rgba(52,152,219,0.2);">
            <div class="card-body">
                <p class="card-label">Sectores seguros</p>
                <h2 class="card-value" style="color:#3498db" id="valSectores">0</h2>
                <p class="card-meta up"><i class="fas fa-arrow-up"></i> Tu récord actual</p>
            </div>
            <div class="card-icon-wrap"><i class="fas fa-shield-alt"></i></div>
        </div>

        <div class="dash-card" style="--card-accent:linear-gradient(90deg,#ff4757,transparent);--icon-bg:rgba(255,71,87,0.08);--icon-color:#ff4757;--icon-glow:rgba(255,71,87,0.2);">
            <div class="card-body">
                <p class="card-label">Malware aislado</p>
                <h2 class="card-value" style="color:#ff4757" id="valMalware">0</h2>
                <p class="card-meta down"><i class="fas fa-exclamation-triangle"></i> Amenazas neutralizadas</p>
            </div>
            <div class="card-icon-wrap"><i class="fas fa-bug"></i></div>
        </div>

        <div class="dash-card" style="--card-accent:linear-gradient(90deg,#fad370,transparent);">
            <div class="card-body">
                <p class="card-label">Nivel de acceso</p>
                <h2 class="card-value">VIP</h2>
                <p class="card-meta up"><i class="fas fa-crown"></i> Acceso premium activo</p>
            </div>
            <div class="card-icon-wrap"><i class="fas fa-crown"></i></div>
        </div>
    </div>

    <div class="quick-actions">
        <a href="Juego.aspx" class="action-btn">
            <div class="action-btn-icon" style="background:rgba(250,211,112,0.08);color:#fad370;">
                <i class="fas fa-gamepad"></i>
            </div>
            <div class="action-btn-info">
                <span>Ir a jugar</span>
                <strong>Cyber-Sweeper VIP</strong>
            </div>
        </a>
        <a href="#" class="action-btn">
            <div class="action-btn-icon" style="background:rgba(52,152,219,0.08);color:#3498db;">
                <i class="fas fa-trophy"></i>
            </div>
            <div class="action-btn-info">
                <span>Ver ranking</span>
                <strong>Tabla de líderes</strong>
            </div>
        </a>
    </div>

</asp:PlaceHolder>

<script>
    // Count-up animation
    function countUp(id, target, duration) {
        var el = document.getElementById(id);
        if (!el) return;
        var start = 0, step = target / (duration / 16);
        var timer = setInterval(function () {
            start = Math.min(start + step, target);
            el.textContent = Math.floor(start);
            if (start >= target) clearInterval(timer);
        }, 16);
    }

    setTimeout(function () {
        // ==========================================
        // ADMIN: DATOS REALES DESDE C#
        // ==========================================
        var totalUsuarios = <%= TotalUsuarios %>;
        var usuariosBloqueados = <%= UsuariosBloqueados %>;
        var total2FA = <%= TotalValidaciones2FA %>;

        countUp('valUsuarios', totalUsuarios, 1400);
        countUp('valBloqueadas', usuariosBloqueados, 800);
        countUp('val2FA', total2FA, 1600);
        countUp('valServer', 100, 1100);

        // ==========================================
        // USER: CYBER-SWEEPER 
        // ==========================================
        if (document.getElementById('valSectores')) {
            countUp('valSectores', 24, 900); // Récord de sectores seguros
            countUp('valMalware', 10, 900);  // Virus aislados
        }
    }, 350);

    // ==========================================
    // INICIALIZACIÓN SWIPER 3D (MÓDULO BI)
    // ==========================================
    function initSwiperVIP() {
        if (typeof Swiper === 'undefined') {
            setTimeout(initSwiperVIP, 100);
            return;
        }
        var swiperContainer = document.querySelector('.mySwiper3D');
        if (swiperContainer && swiperContainer.querySelector('.swiper-slide')) {
            new Swiper(".mySwiper3D", {
                effect: "coverflow",
                grabCursor: true,
                centeredSlides: true,
                slidesPerView: "auto", /* Ahora sí funcionará porque fijamos el width de la tarjeta en CSS */
                speed: 800,
                coverflowEffect: {
                    rotate: 35,      /* Aumentamos el ángulo de rotación para un efecto 3D más agresivo */
                    stretch: -15,    /* Acerca ligeramente las tarjetas laterales al centro */
                    depth: 250,      /* Aumenta la sensación de profundidad hacia atrás */
                    modifier: 1,
                    slideShadows: true, /* Activamos las sombras dinámicas para realismo */
                },
                loop: true,
                autoplay: {
                    delay: 2500,
                    disableOnInteraction: false,
                    pauseOnMouseEnter: true
                },
                pagination: {
                    el: ".swiper-pagination",
                    clickable: true,
                    dynamicBullets: true,
                }
            });
        }
    }
    initSwiperVIP();
</script>
</asp:Content>