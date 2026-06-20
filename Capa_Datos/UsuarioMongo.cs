using System;
using System.Collections.Generic;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace Capa_Datos
{
    public class UsuarioMongo
    {
        [BsonId]
        public int IdUser { get; set; }
        public string tbl_email { get; set; }
        public string tbl_nickname { get; set; }
        public string tbl_OtpCode { get; set; }
        public bool? tbl_activo { get; set; }
        public int? tbl_numerodeintentos_fallidos { get; set; }
        public List<byte> tbl_PasswordHash { get; set; }

        // CORREGIDO: Agregamos los campos que faltaban en el documento de Mongo
        public string tbl_celular { get; set; }
        public string tbl_cedula { get; set; }
        public int? tbl_UsertypeID { get; set; }
    }
}