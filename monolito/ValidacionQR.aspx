<%@ Page Title="Validación 2FA" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ValidacionQR.aspx.cs" Inherits="monolito.ValidacionQR" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ═══════════════════════════════════════════════════
         DEPENDENCIAS EXTERNAS
    ═══════════════════════════════════════════════════ --%>
    <link href="https://fonts.googleapis.com/css2?family=Share+Tech+Mono&family=Rajdhani:wght@400;500;600;700&family=Orbitron:wght@400;700;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <script src="https://unpkg.com/html5-qrcode" type="text/javascript"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <%-- ════════════════════════════
         FIX CRÍTICO: showErrorAlert
    ════════════════════════════ --%>
    <script>
        function showErrorAlert(titulo, mensaje) {
            Swal.fire({
                icon: 'error',
                title: titulo,
                text: mensaje,
                background: '#0a0a0a',
                color: '#d4c49a',
                confirmButtonText: 'REINTENTAR',
                confirmButtonColor: '#fad370',
                iconColor: '#ff3860',
                customClass: {
                    popup: 'swal-cyber-popup',
                    title: 'swal-cyber-title',
                    confirmButton: 'swal-cyber-btn'
                }
            });
        }
    </script>

    <%-- ═══════════════
         ESTILOS
    ═══════════════ --%>
    <style>
        /* ── RESET & BASE ── */
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --cyan:      #fad370;
            --cyan-dim:  rgba(250, 211, 112, 0.15);
            --cyan-glow: rgba(250, 211, 112, 0.5);
            --red:       #ff3860;
            --green:     #fad370;
            --bg:        #0a0a0a;
            --bg2:       #111111;
            --bg3:       #181818;
            --border:    rgba(250, 211, 112, 0.2);
            --text:      #d4c49a;
            --text-dim:  #5a4e35;
            --font-mono: 'Share Tech Mono', monospace;
            --font-hud:  'Orbitron', sans-serif;
            --font-body: 'Rajdhani', sans-serif;
        }

        /* ── LOADER ── */
        #vip-loader {
            position: fixed; inset: 0;
            background: var(--bg);
            z-index: 9999;
            display: flex; flex-direction: column;
            justify-content: center; align-items: center;
            gap: 24px;
            font-family: var(--font-mono);
            transition: opacity 0.8s ease, visibility 0.8s ease;
        }
        #vip-loader.hidden { opacity: 0; visibility: hidden; pointer-events: none; }

        .loader-hex {
            position: relative;
            width: 100px; height: 115px;
        }
        .loader-hex svg { width: 100%; height: 100%; animation: hex-spin 4s linear infinite; }
        .loader-hex-inner {
            position: absolute; inset: 0;
            display: flex; justify-content: center; align-items: center;
        }
        .loader-hex-inner i { font-size: 2.2rem; color: var(--cyan); animation: pulse-icon 1.2s ease-in-out infinite; }
        @keyframes hex-spin { to { transform: rotate(360deg); } }
        @keyframes pulse-icon { 0%,100%{opacity:.4;transform:scale(.9)} 50%{opacity:1;transform:scale(1.05)} }

        .loader-lines {
            display: flex; flex-direction: column; align-items: flex-start;
            gap: 6px; width: 280px;
        }
        .loader-line {
            font-size: .72rem; color: var(--text-dim);
            letter-spacing: .08em; opacity: 0;
            animation: line-in .4s ease forwards;
        }
        .loader-line span { color: var(--cyan); }
        .loader-line:nth-child(1){animation-delay:.3s}
        .loader-line:nth-child(2){animation-delay:.8s}
        .loader-line:nth-child(3){animation-delay:1.3s}
        .loader-line:nth-child(4){animation-delay:1.8s}
        @keyframes line-in { to { opacity: 1; } }

        .loader-bar-wrap {
            width: 280px; height: 3px;
            background: rgba(0,212,255,.1);
            border-radius: 2px; overflow: hidden;
            margin-top: 4px;
        }
        .loader-bar {
            height: 100%; width: 0;
            background: linear-gradient(90deg, transparent, var(--cyan));
            animation: bar-fill 2.4s ease forwards 0.3s;
            box-shadow: 0 0 12px var(--cyan);
        }
        @keyframes bar-fill { to { width: 100%; } }

        /* ── CANVAS DE FONDO ── */
        #bg-canvas {
            position: fixed; inset: 0;
            width: 100%; height: 100%;
            pointer-events: none; z-index: 0;
            opacity: .35;
        }

        /* ── LAYOUT PRINCIPAL ── */
        .auth-wrapper {
            position: relative; z-index: 1;
            min-height: calc(100vh - 80px);
            display: flex; align-items: center; justify-content: center;
            padding: 30px 16px;
            font-family: var(--font-body);
        }

        /* ── PANEL CENTRAL ── */
        .auth-panel {
            width: 100%; max-width: 640px;
            background: var(--bg2);
            border: 1px solid var(--border);
            border-radius: 4px;
            position: relative;
            overflow: hidden;
            animation: panel-in .9s cubic-bezier(.16,1,.3,1) forwards;
            opacity: 0;
        }
        @keyframes panel-in {
            from { opacity:0; transform:translateY(30px) scale(.97); }
            to   { opacity:1; transform:translateY(0) scale(1); }
        }

        /* bordes luminosos de las esquinas */
        .auth-panel::before,
        .auth-panel::after {
            content:''; position:absolute;
            width:60px; height:60px;
            border-color: var(--cyan);
            border-style: solid;
            z-index: 2;
        }
        .auth-panel::before { top:0; left:0;   border-width:2px 0 0 2px; }
        .auth-panel::after  { bottom:0; right:0; border-width:0 2px 2px 0; }

        /* ── CABECERA DEL PANEL ── */
        .panel-header {
            padding: 20px 28px 16px;
            border-bottom: 1px solid var(--border);
            display: flex; align-items: center; gap: 16px;
            background: linear-gradient(90deg, rgba(0,212,255,.06) 0%, transparent 100%);
        }
        .header-icon-wrap {
            width: 52px; height: 52px; flex-shrink: 0;
            border: 1px solid rgba(0,212,255,.3);
            border-radius: 3px;
            display: flex; align-items: center; justify-content: center;
            background: rgba(0,212,255,.07);
            position: relative;
        }
        .header-icon-wrap i { font-size: 1.5rem; color: var(--cyan); }
        .header-icon-wrap::after {
            content:''; position:absolute; inset:0;
            border-radius:3px;
            box-shadow: 0 0 20px var(--cyan-glow), inset 0 0 10px rgba(0,212,255,.1);
        }

        .header-text { flex:1; }
        .header-text .sys-label {
            font-family: var(--font-mono);
            font-size: .62rem; color: var(--cyan);
            letter-spacing: .2em; text-transform:uppercase;
            margin-bottom: 4px; opacity:.7;
        }
        .header-text h1 {
            font-family: var(--font-hud);
            font-size: 1.15rem; font-weight: 700;
            color: #fff; letter-spacing: .1em;
            text-transform: uppercase;
            line-height: 1.1;
        }

        .header-status {
            display: flex; flex-direction: column; align-items: flex-end; gap: 4px;
        }
        .status-badge {
            font-family: var(--font-mono);
            font-size: .6rem; letter-spacing: .12em;
            padding: 3px 8px; border-radius: 2px;
            text-transform: uppercase;
        }
        .status-badge.armed {
            background: rgba(0,255,136,.1);
            border: 1px solid rgba(0,255,136,.3);
            color: var(--green);
        }
        .status-badge.scanning {
            background: rgba(0,212,255,.1);
            border: 1px solid rgba(0,212,255,.3);
            color: var(--cyan);
            animation: blink-badge 1.4s ease infinite;
        }
        @keyframes blink-badge { 0%,100%{opacity:.6} 50%{opacity:1} }

        /* ── CUERPO DEL PANEL ── */
        .panel-body { padding: 28px; }

        .instruction-row {
            display: flex; gap: 10px; align-items: flex-start;
            margin-bottom: 24px;
            padding: 12px 14px;
            background: rgba(0,212,255,.04);
            border-left: 2px solid rgba(0,212,255,.3);
            border-radius: 0 3px 3px 0;
        }
        .instruction-row i { color: var(--cyan); margin-top:2px; flex-shrink:0; font-size:.85rem; }
        .instruction-row p {
            font-size: .9rem; color: var(--text);
            line-height: 1.55; letter-spacing:.02em;
        }

        /* ── ESCÁNER ── */
        .scanner-wrap {
            position: relative;
            width: 100%; max-width: 420px;
            margin: 0 auto;
            aspect-ratio: 1 / 1;
        }

        /* fondo con cuadrícula tipo HUD */
        .scanner-grid-bg {
            position: absolute; inset: 0;
            background-image:
                linear-gradient(rgba(0,212,255,.05) 1px, transparent 1px),
                linear-gradient(90deg, rgba(0,212,255,.05) 1px, transparent 1px);
            background-size: 28px 28px;
            border-radius: 3px;
            pointer-events: none; z-index: 1;
        }

        .scanner-frame {
            position: absolute; inset: 0;
            border: 1px solid rgba(0,212,255,.18);
            border-radius: 3px;
            overflow: hidden;
            background: #000;
            z-index: 2;
        }

        #reader { width:100%; height:100%; border:none; }
        #reader video {
            object-fit: cover !important;
            width: 100%  !important;
            height: 100% !important;
        }
        /* oculta los controles nativos de html5-qrcode */
        #reader__scan_region img,
        #reader__dashboard { display: none !important; }

        /* láser */
        .scan-laser {
            position: absolute; left: 0; width: 100%; height: 3px;
            background: linear-gradient(90deg, transparent 0%, var(--cyan) 30%, #fff 50%, var(--cyan) 70%, transparent 100%);
            box-shadow: 0 0 18px var(--cyan), 0 0 40px var(--cyan-glow);
            animation: laser-sweep 2s ease-in-out infinite;
            z-index: 10; pointer-events: none;
        }
        @keyframes laser-sweep {
            0%   { top:-2px; opacity:0; }
            5%   { opacity:1; }
            95%  { opacity:1; }
            100% { top:100%; opacity:0; }
        }

        /* esquinas HUD */
        .hud-corner {
            position:absolute; width:28px; height:28px;
            border-color: var(--cyan); border-style:solid;
            z-index: 12; pointer-events:none;
        }
        .hud-corner.tl { top:14px; left:14px;  border-width:3px 0 0 3px; }
        .hud-corner.tr { top:14px; right:14px;  border-width:3px 3px 0 0; }
        .hud-corner.bl { bottom:14px; left:14px; border-width:0 0 3px 3px; }
        .hud-corner.br { bottom:14px; right:14px; border-width:0 3px 3px 0; }

        /* mira central */
        .crosshair {
            position: absolute; inset:0;
            display: flex; align-items: center; justify-content: center;
            z-index: 11; pointer-events:none;
            opacity: .25;
        }
        .crosshair::before, .crosshair::after {
            content:''; position:absolute;
            background: var(--cyan);
        }
        .crosshair::before { width:1px; height:40%; }
        .crosshair::after  { height:1px; width:40%; }

        /* ── BARRA DE ESTADO ── */
        .status-bar {
            margin-top: 20px;
            padding: 10px 14px;
            background: var(--bg3);
            border: 1px solid var(--border);
            border-radius: 3px;
            display: flex; align-items: center; gap: 10px;
        }
        .status-dot {
            width: 7px; height: 7px; border-radius: 50%;
            background: var(--cyan); flex-shrink:0;
            animation: dot-pulse 1.4s ease infinite;
            box-shadow: 0 0 8px var(--cyan);
        }
        @keyframes dot-pulse { 0%,100%{opacity:.4} 50%{opacity:1} }

        #status-text {
            font-family: var(--font-mono);
            font-size: .75rem; color: var(--text);
            letter-spacing: .06em;
            flex:1;
        }
        #status-text.success { color: var(--green); }
        #status-text.error   { color: var(--red); }

        /* ── MÉTRICAS INFERIORES ── */
        .metrics-row {
            display: grid; grid-template-columns: repeat(3,1fr);
            gap: 10px; margin-top: 16px;
        }
        .metric-cell {
            padding: 10px;
            border: 1px solid var(--border);
            border-radius: 3px;
            background: rgba(0,212,255,.03);
            text-align: center;
        }
        .metric-cell .m-label {
            font-family: var(--font-mono);
            font-size: .55rem; color: var(--text-dim);
            letter-spacing: .12em; text-transform: uppercase;
            margin-bottom: 4px;
        }
        .metric-cell .m-value {
            font-family: var(--font-hud);
            font-size: .9rem; font-weight: 700;
            color: var(--cyan);
        }

        /* ── FOOTER DEL PANEL ── */
        .panel-footer {
            padding: 14px 28px;
            border-top: 1px solid var(--border);
            display: flex; align-items: center; justify-content: space-between;
            background: rgba(0,0,0,.2);
        }
        .footer-code {
            font-family: var(--font-mono);
            font-size: .6rem; color: var(--text-dim);
            letter-spacing: .1em;
        }
        .enc-badge {
            display: flex; align-items: center; gap: 6px;
            font-family: var(--font-mono);
            font-size: .6rem; color: var(--green);
            letter-spacing: .1em;
        }
        .enc-badge i { font-size: .65rem; }

        /* ── SWEETALERT PERSONALIZADO ── */
        .swal-cyber-popup {
            border: 1px solid rgba(255,56,96,.35) !important;
            border-radius: 4px !important;
        }
        .swal-cyber-title {
            font-family: var(--font-hud) !important;
            letter-spacing: .08em !important;
        }
        .swal-cyber-btn {
            font-family: var(--font-hud) !important;
            letter-spacing: .1em !important;
            border-radius: 2px !important;
        }

        /* ── RESPONSIVE ── */
        @media (max-width: 480px) {
            .panel-body    { padding: 18px; }
            .panel-header  { padding: 16px 18px 14px; }
            .panel-footer  { padding: 12px 18px; }
            .header-text h1 { font-size: 1rem; }
            .metrics-row   { grid-template-columns: repeat(3,1fr); gap:6px; }
        }
    </style>

    <%-- ════════════════════
         LOADER VIP
    ════════════════════ --%>
    <div id="vip-loader">
        <div class="loader-hex">
            <svg viewBox="0 0 100 115" fill="none" xmlns="http://www.w3.org/2000/svg">
                <polygon points="50,3 97,27.5 97,87.5 50,112 3,87.5 3,27.5"
                    stroke="rgba(250,211,112,0.4)" stroke-width="1.5" fill="none"
                    stroke-dasharray="6 3"/>
                <polygon points="50,15 85,33 85,82 50,100 15,82 15,33"
                    stroke="rgba(250,211,112,0.15)" stroke-width="1" fill="none"/>
            </svg>
            <div class="loader-hex-inner"><i class="fas fa-fingerprint"></i></div>
        </div>
        <div class="loader-lines">
            <div class="loader-line">[ <span>SYS</span> ] Inicializando protocolo 2FA...</div>
            <div class="loader-line">[ <span>NET</span> ] Canal seguro establecido...</div>
            <div class="loader-line">[ <span>CAM</span> ] Calibrando módulo óptico...</div>
            <div class="loader-line">[ <span>OK</span>  ] Sistema listo.</div>
        </div>
        <div class="loader-bar-wrap"><div class="loader-bar"></div></div>
    </div>

    <%-- ════════════════════
         CANVAS DE FONDO
    ════════════════════ --%>
    <canvas id="bg-canvas"></canvas>

    <%-- ════════════════════
         PANEL PRINCIPAL
    ════════════════════ --%>
    <div class="auth-wrapper">
        <div class="auth-panel">

            <%-- CABECERA --%>
            <div class="panel-header">
                <div class="header-icon-wrap">
                    <i class="fas fa-shield-halved"></i>
                </div>
                <div class="header-text">
                    <div class="sys-label">Módulo de Seguridad · AUTH-2FA</div>
                    <h1>Verificación de Identidad</h1>
                </div>
                <div class="header-status">
                    <span class="status-badge armed">ARMADO</span>
                    <span class="status-badge scanning" id="badge-scanning">ESCANEANDO</span>
                </div>
            </div>

            <%-- CUERPO --%>
            <div class="panel-body">

                <div class="instruction-row">
                    <i class="fas fa-circle-info"></i>
                    <p>Apunta tu código QR hacia la cámara. El sistema lo detectará y validará automáticamente sin necesidad de confirmar.</p>
                </div>

                <%-- ESCÁNER --%>
                <div class="scanner-wrap">
                    <div class="scanner-grid-bg"></div>
                    <div class="scanner-frame">
                        <div id="reader"></div>
                    </div>
                    <div class="scan-laser"></div>
                    <div class="hud-corner tl"></div>
                    <div class="hud-corner tr"></div>
                    <div class="hud-corner bl"></div>
                    <div class="hud-corner br"></div>
                    <div class="crosshair"></div>
                </div>

                <%-- ESTADO --%>
                <div class="status-bar">
                    <div class="status-dot" id="status-dot"></div>
                    <span id="status-text">Conectando cámara segura...</span>
                </div>

                <%-- MÉTRICAS --%>
                <div class="metrics-row">
                    <div class="metric-cell">
                        <div class="m-label">Protocolo</div>
                        <div class="m-value">TOTP</div>
                    </div>
                    <div class="metric-cell">
                        <div class="m-label">Cifrado</div>
                        <div class="m-value">AES-256</div>
                    </div>
                    <div class="metric-cell">
                        <div class="m-label">Estado</div>
                        <div class="m-value" id="metric-state">ACTIVO</div>
                    </div>
                </div>

            </div>

            <%-- FOOTER --%>
            <div class="panel-footer">
                <span class="footer-code">SESS · <span id="session-id-display">——</span></span>
                <span class="enc-badge"><i class="fas fa-lock"></i> CONEXIÓN CIFRADA</span>
            </div>

        </div><%-- /auth-panel --%>
    </div>

    <%-- CAMPOS OCULTOS ASP.NET --%>
    <asp:HiddenField ID="hfCodigoQR" runat="server" />
    <asp:Button   ID="btnValidar"   runat="server" OnClick="btnValidar_Click" style="display:none;" />

    <%-- ════════════════════
         SCRIPTS
    ════════════════════ --%>
    <script>
        // ── CANVAS PARTÍCULAS ──────────────────────────────────────────
        (function () {
            const canvas = document.getElementById('bg-canvas');
            const ctx = canvas.getContext('2d');
            let W, H, particles = [];

            function resize() {
                W = canvas.width = window.innerWidth;
                H = canvas.height = window.innerHeight;
            }
            resize();
            window.addEventListener('resize', resize);

            function randBetween(a, b) { return a + Math.random() * (b - a); }

            for (let i = 0; i < 60; i++) {
                particles.push({
                    x: randBetween(0, 1),
                    y: randBetween(0, 1),
                    vx: randBetween(-.0002, .0002),
                    vy: randBetween(-.0002, .0002),
                    r: randBetween(.8, 2.5),
                    a: randBetween(.2, .7)
                });
            }

            function draw() {
                ctx.clearRect(0, 0, W, H);

                // grid lines
                ctx.strokeStyle = 'rgba(250,211,112,0.04)';
                ctx.lineWidth = 1;
                const step = 60;
                for (let x = 0; x < W; x += step) {
                    ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, H); ctx.stroke();
                }
                for (let y = 0; y < H; y += step) {
                    ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(W, y); ctx.stroke();
                }

                // particles + connections
                particles.forEach(p => {
                    p.x = (p.x + p.vx + 1) % 1;
                    p.y = (p.y + p.vy + 1) % 1;
                });

                for (let i = 0; i < particles.length; i++) {
                    const a = particles[i];
                    for (let j = i + 1; j < particles.length; j++) {
                        const b = particles[j];
                        const dx = (a.x - b.x) * W;
                        const dy = (a.y - b.y) * H;
                        const dist = Math.sqrt(dx * dx + dy * dy);
                        if (dist < 140) {
                            ctx.strokeStyle = `rgba(250,211,112,${.08 * (1 - dist / 140)})`;
                            ctx.lineWidth = .5;
                            ctx.beginPath();
                            ctx.moveTo(a.x * W, a.y * H);
                            ctx.lineTo(b.x * W, b.y * H);
                            ctx.stroke();
                        }
                    }
                    ctx.beginPath();
                    ctx.arc(a.x * W, a.y * H, a.r, 0, Math.PI * 2);
                    ctx.fillStyle = `rgba(250,211,112,${a.a})`;
                    ctx.fill();
                }
                requestAnimationFrame(draw);
            }
            draw();
        })();

        // ── HUD DINÁMICO ────────────────────────────────────────────────
        document.getElementById('session-id-display').textContent =
            Math.random().toString(36).substring(2, 8).toUpperCase();

        // ── LOADER ──────────────────────────────────────────────────────
        window.addEventListener('load', function () {
            setTimeout(function () {
                var loader = document.getElementById('vip-loader');
                if (loader) {
                    loader.classList.add('hidden');
                    setTimeout(function () { loader.style.display = 'none'; }, 900);
                }
            }, 2800);
        });

        // ── ESCÁNER QR ──────────────────────────────────────────────────
        document.addEventListener("DOMContentLoaded", function () {
            const html5QrCode = new Html5Qrcode("reader");
            const statusEl = document.getElementById('status-text');
            const statusDot = document.getElementById('status-dot');
            const metricState = document.getElementById('metric-state');
            const badgeScan = document.getElementById('badge-scanning');

            function setStatus(msg, type) {
                statusEl.textContent = msg;
                statusEl.className = type || '';
                if (type === 'success') {
                    statusDot.style.background = '#fad370';
                    statusDot.style.boxShadow = '0 0 8px rgba(250,211,112,.6)';
                    metricState.textContent = 'DETECTADO';
                    metricState.style.color = '#fad370';
                    badgeScan.textContent = 'DETECTADO';
                } else if (type === 'error') {
                    statusDot.style.background = 'var(--red)';
                    statusDot.style.boxShadow = '0 0 8px var(--red)';
                }
            }

            const config = {
                fps: 30,
                qrbox: (vw, vh) => {
                    const s = Math.floor(Math.min(vw, vh) * 0.72);
                    return { width: s, height: s };
                },
                aspectRatio: 1.0,
                formatsToSupport: [Html5QrcodeSupportedFormats.QR_CODE]
            };

            const onScanSuccess = (decodedText) => {
                if (!html5QrCode.isScanning) return;
                html5QrCode.stop().then(() => {
                    setStatus('Código detectado · Validando identidad...', 'success');

                    Swal.fire({
                        title: 'Código Detectado',
                        html: '<span style="font-family:\'Share Tech Mono\',monospace;font-size:.85rem;letter-spacing:.05em;color:#fad370">Validando credenciales...</span>',
                        timer: 1800,
                        showConfirmButton: false,
                        didOpen: () => Swal.showLoading(),
                        background: '#0a0a0a',
                        color: '#d4c49a',
                        customClass: { popup: 'swal-cyber-popup' }
                    });

                    document.getElementById('<%= hfCodigoQR.ClientID %>').value = decodedText;
                document.getElementById('<%= btnValidar.ClientID %>').click();

            }).catch(err => console.warn('Stop error:', err));
        };

        // intenta cámara trasera primero (móvil), luego webcam (escritorio)
        html5QrCode.start({ facingMode: "environment" }, config, onScanSuccess)
            .then(() => setStatus('Cámara activa · Muestra tu código QR'))
            .catch(() => {
                Html5Qrcode.getCameras().then(devices => {
                    if (devices && devices.length > 0) {
                        html5QrCode.start(devices[0].id, config, onScanSuccess)
                            .then(() => setStatus('Cámara activa · Muestra tu código QR'))
                            .catch(() => setStatus('Error al activar la cámara', 'error'));
                    } else {
                        setStatus('No se detectó ninguna cámara', 'error');
                    }
                }).catch(() => setStatus('Permite el acceso a la cámara en tu navegador', 'error'));
            });
    });
    </script>

</asp:Content>
