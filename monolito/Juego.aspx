<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Juego.aspx.cs" Inherits="monolito.Juego" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

    <style>
        .game-wrapper {
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            min-height: calc(100vh - 80px); font-family: 'Poppins', sans-serif;
        }

        .game-header { text-align: center; margin-bottom: 20px; animation: slideDown 0.5s ease-out; }
        .game-header h1 { color: #fad370; font-weight: 800; font-size: 2.2em; margin: 0; letter-spacing: 2px; text-transform: uppercase; }
        .game-header p { color: #888; font-size: 0.9em; margin: 5px 0 0 0; }

        /* Panel de Control */
        .control-panel {
            background: #1c1c1c; border: 1px solid rgba(250, 211, 112, 0.2);
            border-radius: 12px; padding: 15px 30px; display: flex; gap: 30px;
            align-items: center; margin-bottom: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.5);
        }

        .stat-box { text-align: center; }
        .stat-label { color: #888; font-size: 0.7em; text-transform: uppercase; letter-spacing: 1px; display: block; }
        .stat-value { color: #fff; font-size: 1.5em; font-weight: 700; font-family: monospace; }
        .stat-value.danger { color: #ff4757; }

        .btn-mode {
            background: rgba(250, 211, 112, 0.1); border: 1px solid #fad370; color: #fad370;
            padding: 8px 20px; border-radius: 8px; font-weight: 600; cursor: pointer;
            transition: 0.3s; width: 180px; text-transform: uppercase; font-size: 0.85em;
        }
        .btn-mode:hover { background: #fad370; color: #1c1c1c; }
        
        .btn-mode.mode-shield { background: rgba(52, 152, 219, 0.1); border-color: #3498db; color: #3498db; }
        .btn-mode.mode-shield:hover { background: #3498db; color: #fff; }

        .btn-restart {
            background: transparent; border: none; color: #888; font-size: 1.5em;
            cursor: pointer; transition: 0.3s;
        }
        .btn-restart:hover { color: #fff; transform: rotate(180deg); }

        /* Cuadrícula del Juego */
        .grid-container {
            background: #111; padding: 10px; border-radius: 12px;
            border: 2px solid rgba(250, 211, 112, 0.1);
            display: grid; grid-template-columns: repeat(8, 1fr); gap: 4px; /* 8x8 Grid */
            box-shadow: inset 0 0 20px rgba(0,0,0,0.8);
        }

        /* Botones de las Celdas */
        .cell {
            width: 45px; height: 45px; border: none; border-radius: 6px;
            font-size: 1.2em; font-weight: bold; cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            transition: background 0.2s; font-family: 'Poppins', sans-serif;
            text-decoration: none; padding: 0; line-height: 45px; text-align: center;
        }

        /* Estados de las Celdas */
        .cell-hidden {
            background: #2a2a2a; color: transparent;
            box-shadow: inset 2px 2px 5px rgba(255,255,255,0.05), inset -2px -2px 5px rgba(0,0,0,0.5);
        }
        .cell-hidden:hover { background: #333; }

        .cell-revealed {
            background: #151515; cursor: default;
            box-shadow: inset 1px 1px 3px rgba(0,0,0,0.8);
        }

        /* Colores de los números */
        .num-1 { color: #3498db; }
        .num-2 { color: #2ecc71; }
        .num-3 { color: #e74c3c; }
        .num-4 { color: #9b59b6; }
        .num-5 { color: #f1c40f; }

        /* Iconos Especiales */
        .cell-shield { background: #2a2a2a; color: #3498db; font-size: 1em; } /* Bandera */
        .cell-virus { background: #ff4757; color: #fff; font-size: 1.2em; animation: pop 0.3s; } /* Mina */
        
        @keyframes pop { 0% { transform: scale(0.5); } 100% { transform: scale(1); } }

        /* Mensaje Final */
        .game-message { margin-top: 20px; font-size: 1.2em; font-weight: 700; height: 30px; }
        .msg-win { color: #2ecc71; }
        .msg-lose { color: #ff4757; }
    </style>

    <div class="game-wrapper">
        <div class="game-header">
            <h1>CYBER-SWEEPER</h1>
            <p>Aísla el malware sin detonarlo.</p>
        </div>

        <div class="control-panel">
            <div class="stat-box">
                <span class="stat-label">Malware</span>
                <asp:Label ID="lblMinas" runat="server" CssClass="stat-value danger">10</asp:Label>
            </div>

            <!-- Botón que cambia entre Escanear (Click) y Proteger (Bandera) -->
            <asp:Button ID="btnToggleMode" runat="server" CssClass="btn-mode" OnClick="btnToggleMode_Click" Text="🔍 MODO: ESCANEAR" />

            <asp:LinkButton ID="btnReiniciar" runat="server" CssClass="btn-restart" OnClick="btnReiniciar_Click" ToolTip="Reiniciar Sistema">
                <i class="fas fa-sync-alt"></i>
            </asp:LinkButton>
        </div>

        <!-- Tablero del Juego generado en Servidor -->
        <div class="grid-container">
            <asp:Repeater ID="rptTablero" runat="server" OnItemCommand="rptTablero_ItemCommand">
                <ItemTemplate>
                    <asp:LinkButton ID="btnCelda" runat="server" 
                        CommandName="ClickCelda" 
                        CommandArgument='<%# Eval("Id") %>' 
                        CssClass='<%# Eval("ClaseCss") %>' 
                        Enabled='<%# !(bool)Eval("Revelada") && !(bool)Eval("JuegoTerminado") %>'>
                        
                        <%-- Usamos HTML para renderizar los iconos de FontAwesome --%>
                        <%# Eval("ContenidoHTML") %>

                    </asp:LinkButton>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <asp:Label ID="lblMensaje" runat="server" CssClass="game-message"></asp:Label>
    </div>
</asp:Content>