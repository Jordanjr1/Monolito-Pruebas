using System;
using System.Collections.Generic;
using System.Text;
using System.Web.UI;

namespace monolito
{
    public partial class Rombo : Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        protected void btnGenerar_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtAlto.Text)) return;

            int input = int.Parse(txtAlto.Text);

            // VALIDACIÓN BACKEND: Evita números menores o iguales a cero
            if (input <= 0)
            {
                litFigura.Text = "<p style='color:red;'>Por favor, ingrese un número mayor a 0.</p>";
                return;
            }
            // Lógica de normalización y generación
            int mitad = (input % 4 == 0) ? input : (input + (4 - (input % 4)));
            int margen = 2;
            int alto = mitad * 2 + 1 + margen * 2;
            int ancho = mitad * 2 + 1 + margen * 2;
            int fc = alto / 2;
            int cc = ancho / 2;

            char[,] lienzo = InicializarLienzo(alto, ancho);
            DibujarRombo(lienzo, alto, ancho, fc, cc, mitad);
            litFigura.Text = RenderizarConMarco(lienzo, alto, ancho);
        }

        private static char[,] InicializarLienzo(int alto, int ancho)
        {
            var lienzo = new char[alto, ancho];
            for (int i = 0; i < alto; i++)
                for (int j = 0; j < ancho; j++)
                    lienzo[i, j] = ' ';
            return lienzo;
        }

        private static void DibujarRombo(char[,] lienzo, int alto, int ancho, int fc, int cc, int mitad)
        {
            int paso = 4;
            for (int i = 0; i < alto; i++)
            {
                if (i == fc - 1) continue;
                for (int j = 0; j < ancho; j++)
                {
                    int dist = Math.Abs(i - fc) + Math.Abs(j - cc);
                    if (dist == mitad || (dist < mitad && dist % paso == 0))
                        lienzo[i, j] = '*';
                }
            }
            DibujarFilaEspecial(lienzo, fc, cc, ancho);
        }

        private static void DibujarFilaEspecial(char[,] lienzo, int fc, int cc, int ancho)
        {
            int filaEspejo = fc + 1;
            int filaEspecial = fc - 1;
            var pos = new List<int>();

            for (int j = 0; j < ancho; j++)
                if (lienzo[filaEspejo, j] == '*') pos.Add(j);

            for (int k = 0; k < pos.Count; k++)
            {
                if (pos[k] > cc)
                    pos[k] = Math.Max(pos[k] - 2, cc + 1);
            }

            foreach (int j in pos)
            {
                if (j >= 0 && j < ancho)
                    lienzo[filaEspecial, j] = '*';
            }
        }

        private static string RenderizarConMarco(char[,] lienzo, int alto, int ancho)
        {
            var sb = new StringBuilder();

            // CAMBIO: Ajusté el background a un tono oscuro y el color de texto a blanco/gris claro
            sb.Append("<pre style='font-family:\"Courier New\",monospace; " +
                      "line-height:1.15; font-size:14px; display:inline-block; " +
                      "background:#212529; color:#f8f9fa; padding:15px; " +
                      "border:1px solid #495057; border-radius: 5px;'>");

            sb.Append('╔');
            for (int j = 0; j < ancho; j++) sb.Append('═');
            sb.AppendLine("╗");

            for (int i = 0; i < alto; i++)
            {
                sb.Append('║');
                for (int j = 0; j < ancho; j++) sb.Append(lienzo[i, j]);
                sb.AppendLine("║");
            }

            sb.Append('╚');
            for (int j = 0; j < ancho; j++) sb.Append('═');
            sb.Append('╝');
            sb.Append("</pre>");
            return sb.ToString();
        }
        
    }
}