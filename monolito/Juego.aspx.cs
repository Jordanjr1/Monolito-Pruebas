using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace monolito
{
    public partial class Juego : Page
    {
        // Configuraciones de dificultad
        private const int FILAS = 8;
        private const int COLUMNAS = 8;
        private const int TOTAL_MINAS = 10;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Seguridad básica
            if (Session["UserTypeId"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                IniciarNuevoJuego();
            }
        }

        private void IniciarNuevoJuego()
        {
            List<Celda> tablero = GenerarTablero();
            Session["TableroBuscaminas"] = tablero;
            Session["ModoEscanear"] = true; // true = Abrir, false = Poner Bandera
            Session["JuegoTerminado"] = false;

            ActualizarInterfaz();
        }

        // ==========================================
        // LÓGICA DE CREACIÓN (Manejo de Arreglos en C#)
        // ==========================================
        private List<Celda> GenerarTablero()
        {
            List<Celda> tablero = new List<Celda>();
            int totalCeldas = FILAS * COLUMNAS;

            // 1. Crear las celdas vacías
            for (int i = 0; i < totalCeldas; i++)
            {
                tablero.Add(new Celda { Id = i, Fila = i / COLUMNAS, Columna = i % COLUMNAS });
            }

            // 2. Colocar las minas (Malware) de forma aleatoria
            Random rnd = new Random();
            int minasColocadas = 0;
            while (minasColocadas < TOTAL_MINAS)
            {
                int indiceAleatorio = rnd.Next(totalCeldas);
                if (!tablero[indiceAleatorio].EsMina)
                {
                    tablero[indiceAleatorio].EsMina = true;
                    minasColocadas++;
                }
            }

            // 3. Calcular los números (cuántas minas hay alrededor de cada celda)
            foreach (var celda in tablero)
            {
                if (!celda.EsMina)
                {
                    celda.MinasCercanas = tablero.Count(c => c.EsMina &&
                                          Math.Abs(c.Fila - celda.Fila) <= 1 &&
                                          Math.Abs(c.Columna - celda.Columna) <= 1);
                }
            }

            return tablero;
        }

        // ==========================================
        // EVENTOS DE LOS BOTONES
        // ==========================================
        protected void btnToggleMode_Click(object sender, EventArgs e)
        {
            if ((bool)Session["JuegoTerminado"]) return;

            bool modoActual = (bool)Session["ModoEscanear"];
            Session["ModoEscanear"] = !modoActual;

            ActualizarInterfaz();
        }

        protected void btnReiniciar_Click(object sender, EventArgs e)
        {
            IniciarNuevoJuego();
        }

        // Cuando el usuario hace clic en un cuadrito
        protected void rptTablero_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "ClickCelda")
            {
                if ((bool)Session["JuegoTerminado"]) return;

                int idCelda = Convert.ToInt32(e.CommandArgument);
                List<Celda> tablero = (List<Celda>)Session["TableroBuscaminas"];
                Celda celdaClickeada = tablero.First(c => c.Id == idCelda);
                bool esModoEscanear = (bool)Session["ModoEscanear"];

                // ACCIÓN 1: Poner/Quitar Escudo (Bandera)
                if (!esModoEscanear)
                {
                    if (!celdaClickeada.Revelada)
                    {
                        celdaClickeada.Protegida = !celdaClickeada.Protegida;
                    }
                }
                // ACCIÓN 2: Escanear (Abrir Celda)
                else
                {
                    // Si tiene escudo, no dejamos abrirla por accidente
                    if (celdaClickeada.Protegida) return;

                    // ¡BOOM! Pisó un virus
                    if (celdaClickeada.EsMina)
                    {
                        PerderJuego(tablero);
                        return;
                    }

                    // Celda segura: La abrimos
                    AbrirCeldaRecursiva(tablero, celdaClickeada);
                    ComprobarVictoria(tablero);
                }

                Session["TableroBuscaminas"] = tablero;
                ActualizarInterfaz();
            }
        }

        // ==========================================
        // RECURSIVIDAD: El truco para abrir bloques vacíos
        // ==========================================
        private void AbrirCeldaRecursiva(List<Celda> tablero, Celda celda)
        {
            if (celda.Revelada || celda.Protegida || celda.EsMina) return;

            celda.Revelada = true;

            // Si es un cero (no hay virus cerca), abrimos automáticamente a sus 8 vecinos
            if (celda.MinasCercanas == 0)
            {
                var vecinos = tablero.Where(c => Math.Abs(c.Fila - celda.Fila) <= 1 &&
                                                 Math.Abs(c.Columna - celda.Columna) <= 1).ToList();
                foreach (var vecino in vecinos)
                {
                    AbrirCeldaRecursiva(tablero, vecino);
                }
            }
        }

        // ==========================================
        // CONDICIONES DE VICTORIA O DERROTA
        // ==========================================
        private void PerderJuego(List<Celda> tablero)
        {
            Session["JuegoTerminado"] = true;
            lblMensaje.Text = "¡SISTEMA INFECTADO! Malware detonado.";
            lblMensaje.CssClass = "game-message msg-lose";

            // Revelamos todas las minas
            foreach (var celda in tablero.Where(c => c.EsMina))
            {
                celda.Revelada = true;
            }
            Session["TableroBuscaminas"] = tablero;
            ActualizarInterfaz();
        }

        private void ComprobarVictoria(List<Celda> tablero)
        {
            // Ganas si la cantidad de celdas NO reveladas es igual a la cantidad de minas
            int celdasCerradas = tablero.Count(c => !c.Revelada);
            if (celdasCerradas == TOTAL_MINAS)
            {
                Session["JuegoTerminado"] = true;
                lblMensaje.Text = "¡AMENAZA NEUTRALIZADA! Servidor seguro.";
                lblMensaje.CssClass = "game-message msg-win";
            }
        }

        // ==========================================
        // RENDERIZADO VISUAL
        // ==========================================
        private void ActualizarInterfaz()
        {
            List<Celda> tablero = (List<Celda>)Session["TableroBuscaminas"];
            bool modoEscanear = (bool)Session["ModoEscanear"];
            bool juegoTerminado = (bool)Session["JuegoTerminado"];

            // Actualizar botón de modo
            if (modoEscanear)
            {
                btnToggleMode.Text = "🔍 MODO: ESCANEAR";
                btnToggleMode.CssClass = "btn-mode";
            }
            else
            {
                btnToggleMode.Text = "🛡️ MODO: PROTEGER";
                btnToggleMode.CssClass = "btn-mode mode-shield";
            }

            // Contador de minas restantes (Total - Banderas puestas)
            int escudosPuestos = tablero.Count(c => c.Protegida);
            lblMinas.Text = (TOTAL_MINAS - escudosPuestos).ToString();

            // Preparar datos para el Frontend
            foreach (var c in tablero)
            {
                c.JuegoTerminado = juegoTerminado; // Para deshabilitar botones si se acabó
            }

            rptTablero.DataSource = tablero;
            rptTablero.DataBind();

            if (!juegoTerminado)
            {
                lblMensaje.Text = "";
            }
        }

        // ==========================================
        // CLASE DEL MODELO DE DATOS
        // ==========================================
        [Serializable]
        public class Celda
        {
            public int Id { get; set; }
            public int Fila { get; set; }
            public int Columna { get; set; }
            public bool EsMina { get; set; }
            public int MinasCercanas { get; set; }
            public bool Revelada { get; set; }
            public bool Protegida { get; set; }
            public bool JuegoTerminado { get; set; }

            // Propiedad que lee el HTML para decidir qué color pintarle
            public string ClaseCss
            {
                get
                {
                    if (!Revelada)
                    {
                        if (Protegida) return "cell cell-shield";
                        return "cell cell-hidden";
                    }
                    else
                    {
                        if (EsMina) return "cell cell-virus";

                        string clase = "cell cell-revealed";
                        if (MinasCercanas > 0) clase += $" num-{MinasCercanas}";
                        return clase;
                    }
                }
            }

            // Propiedad que decide qué texto/icono mostrar
            public string ContenidoHTML
            {
                get
                {
                    if (!Revelada)
                    {
                        if (Protegida) return "<i class='fas fa-shield-alt'></i>";
                        return "";
                    }
                    else
                    {
                        if (EsMina) return "<i class='fas fa-bug'></i>";
                        if (MinasCercanas > 0) return MinasCercanas.ToString();
                        return "";
                    }
                }
            }
        }
    }
}