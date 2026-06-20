using MongoDB.Bson.Serialization.Attributes;
using System;

namespace Capa_Datos
{
    public class ProductoMongo
    {
        [BsonId]
        public int pro_id { get; set; }
        public string pro_nombre { get; set; }
        public string pro_descripcion { get; set; }
        public int? pro_cantidad { get; set; }
        public decimal? pro_precio { get; set; }
        public string pro_foto_path { get; set; }
        public bool? pro_estado { get; set; }

        // Llaves foráneas (En Mongo las guardamos como simples números)
        public int? prov_id { get; set; }
        public int? cat_id { get; set; }

        public DateTime? pro_fecha_registro { get; set; }
    }
}