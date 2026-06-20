using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MongoDB.Driver;

namespace Capa_Datos
{
    public class ConexionMongo
    {
        
        public IMongoDatabase database;

        public ConexionMongo()
        {
            
            var client = new MongoClient("mongodb://localhost:27017");

            
            database = client.GetDatabase("DbMonolitoMongo");
        }
    }
}