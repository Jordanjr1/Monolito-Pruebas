<%@ Page Title="Generador de Rombo" 
    Language="C#" 
    MasterPageFile="~/Site.Master" 
    AutoEventWireup="true" 
    CodeBehind="Rombo.aspx.cs" 
    Inherits="monolito.Rombo" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid mt-4">
        <div class="card" style="max-width: 600px; margin: 0 auto;">
            <div class="card-header bg-primary text-white">
                <h4 class="mb-0">Generador de Rombo</h4>
            </div>
            <div class="card-body text-center">
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label>Tamaño (Alto):</label>
                        <asp:TextBox ID="txtAlto" runat="server" CssClass="form-control" TextMode="Number" min="1" Text="10"></asp:TextBox>
                    </div>
                </div>

                <asp:Button ID="btnGenerar" runat="server" Text="Generar Rombo" CssClass="btn btn-primary" OnClick="btnGenerar_Click" />

                <div class="mt-4" style="overflow-x: auto;">
                    <asp:Literal ID="litFigura" runat="server"></asp:Literal>
                </div>
            </div>
        </div>
    </div>
</asp:Content>