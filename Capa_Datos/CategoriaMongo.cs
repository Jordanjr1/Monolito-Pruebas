using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MongoDB.Bson.Serialization.Attributes;

namespace Capa_Datos
{
    public class CategoriaMongo
    {
        [BsonId]
        public int cat_id { get; set; }
        public string cat_nombre { get; set; }
        public string cat_descripcion { get; set; }
        public bool? cat_estado { get; set; }
    }
}