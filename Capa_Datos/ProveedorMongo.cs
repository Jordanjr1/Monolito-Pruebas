using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System;

namespace Capa_Datos
{
    public class ProveedorMongo
    {
        [BsonId]
        public int prov_id { get; set; }
        public string prov_nombre { get; set; }
        public string prov_contacto { get; set; }
        public string prov_email { get; set; }
        public bool? prov_estado { get; set; }
        public DateTime? prov_fecha_registro { get; set; }
    }
}