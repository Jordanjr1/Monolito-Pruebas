using System;
using System.Collections.Generic;
using System.Linq;
using MongoDB.Driver;
using MongoDB.Bson.Serialization.Attributes;
using MongoDB.Bson;

namespace Capa_Datos
{
    public class LogAcceso
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }
        public string UsuarioId { get; set; }
        public DateTime FechaAcceso { get; set; }
    }

    public class D_Usuario
    {
        private IMongoCollection<UsuarioMongo> _coleccionUsuarios;
        private IMongoCollection<LogAcceso> _coleccionLogs;

        public D_Usuario()
        {
            var conexion = new ConexionMongo();
            _coleccionUsuarios = conexion.database.GetCollection<UsuarioMongo>("Users");
            _coleccionLogs = conexion.database.GetCollection<LogAcceso>("LogAcceso");
        }

        // Firmas originales con mapeo interno automático:

        public Users Login(string identificador)
        {
            try
            {
                var mongoUser = _coleccionUsuarios.Find(u =>
                    u.tbl_email == identificador || u.tbl_nickname == identificador
                ).FirstOrDefault();

                return MapToUsers(mongoUser); // Traduce y retorna Users

            }
            catch (Exception) { return null; }
        }

        public bool ActualizarOtp(string email, string hashOtp)
        {
            try
            {
                var filter = Builders<UsuarioMongo>.Filter.Eq(u => u.tbl_email, email);
                var update = Builders<UsuarioMongo>.Update.Set(u => u.tbl_OtpCode, hashOtp);
                var result = _coleccionUsuarios.UpdateOne(filter, update);
                return result.MatchedCount > 0;
            }
            catch (Exception) { return false; }
        }

        public List<Users> ObtenerTodosLosUsuarios()
        {
            try
            {
                var listaMongo = _coleccionUsuarios.Find(_ => true).ToList();
                return listaMongo.Select(MapToUsers).ToList(); // Traduce la lista completa
            }
            catch (Exception) { return new List<Users>(); }
        }

        public bool RegistrarUsuario(Users nuevoUsuario)
        {
            try
            {
                var mongoUser = MapToMongo(nuevoUsuario); // Traduce de Users a Mongo
                _coleccionUsuarios.InsertOne(mongoUser);
                return true;
            }
            catch (Exception) { return false; }
        }

        public bool BloquearUsuarioManual(int idUser)
        {
            try
            {
                // Ya no se necesita int.Parse, usamos directamente idUser
                var filter = Builders<UsuarioMongo>.Filter.Eq(u => u.IdUser, idUser);
                var update = Builders<UsuarioMongo>.Update.Set(u => u.tbl_activo, false);
                var result = _coleccionUsuarios.UpdateOne(filter, update);
                return result.MatchedCount > 0;
            }
            catch (Exception) { return false; }
        }

        public int ObtenerTotalValidaciones2FA()
        {
            try
            {
                return (int)_coleccionLogs.CountDocuments(_ => true);
            }
            catch (Exception) { return 0; }
        }

        public List<Users> ObtenerUsuariosBloqueados()
        {
            try
            {
                var listaMongo = _coleccionUsuarios.Find(u => u.tbl_activo == false).ToList();
                return listaMongo.Select(MapToUsers).ToList();
            }
            catch (Exception) { return new List<Users>(); }
        }

        public bool DesbloquearUsuario(int idUser)
        {
            try
            {
                // Ya no se necesita int.Parse, usamos directamente idUser
                var filter = Builders<UsuarioMongo>.Filter.Eq(u => u.IdUser, idUser);
                var update = Builders<UsuarioMongo>.Update
                    .Set(u => u.tbl_activo, true)
                    .Set(u => u.tbl_numerodeintentos_fallidos, 0);
                var result = _coleccionUsuarios.UpdateOne(filter, update);
                return result.MatchedCount > 0;
            }
            catch (Exception) { return false; }
        }

        public Users ObtenerUsuarioPorEmail(string email)
        {
            try
            {
                var mongoUser = _coleccionUsuarios.Find(u => u.tbl_email == email).FirstOrDefault();
                return MapToUsers(mongoUser);
            }
            catch (Exception) { return null; }
        }

        public bool ActualizarPassword(string email, byte[] hashBytes, string status)
        {
            try
            {
                var filter = Builders<UsuarioMongo>.Filter.Eq(u => u.tbl_email, email);
                var update = Builders<UsuarioMongo>.Update.Set(u => u.tbl_PasswordHash, hashBytes.ToList());

                if (status == "TEMP")
                {
                    update = update.Set(u => u.tbl_OtpCode, "TEMP");
                }
                else if (status == null)
                {
                    update = update.Set(u => u.tbl_OtpCode, (string)null);
                }

                var result = _coleccionUsuarios.UpdateOne(filter, update);
                return result.MatchedCount > 0;
            }
            catch (Exception) { return false; }
        }

        public bool ActualizarEntidad(Users usuario)
        {
            try
            {
                var mongoUser = MapToMongo(usuario);
                var result = _coleccionUsuarios.ReplaceOne(u => u.IdUser == mongoUser.IdUser, mongoUser);
                return result.MatchedCount > 0;
            }
            catch (Exception) { return false; }
        }

        public void RegistrarLogAcceso(int idUser)
        {
            try
            {
                var nuevoLog = new LogAcceso
                {
                    // Convertimos a string para que encaje con la propiedad de tu clase LogAcceso
                    UsuarioId = idUser.ToString(),
                    FechaAcceso = DateTime.Now
                };
                _coleccionLogs.InsertOne(nuevoLog);
            }
            catch (Exception) { }
        }

        // ==========================================
        // MÉTODOS DE TRADUCCIÓN (MAPPING MÁGICO)
        // ==========================================

        private Users MapToUsers(UsuarioMongo m)
        {
            if (m == null) return null;
            return new Users
            {
                IdUser = m.IdUser,
                tbl_email = m.tbl_email,
                tbl_nickame = m.tbl_nickname,
                tbl_OtpCode = m.tbl_OtpCode,
                tbl_activo = m.tbl_activo,
                tbl_numerodeintentos_fallidos = m.tbl_numerodeintentos_fallidos,
                tbl_celular = m.tbl_celular,
                tbl_cedula = m.tbl_cedula,
                tbl_PasswordHash = m.tbl_PasswordHash != null ? new System.Data.Linq.Binary(m.tbl_PasswordHash.ToArray()) : null,
                tbl_UsertypeID = m.tbl_UsertypeID
            };
        }

        private UsuarioMongo MapToMongo(Users u)
        {
            if (u == null) return null;
            return new UsuarioMongo
            {
                IdUser = u.IdUser,
                tbl_email = u.tbl_email,
                tbl_nickname = u.tbl_nickame,
                tbl_OtpCode = u.tbl_OtpCode,
                tbl_activo = u.tbl_activo,
                tbl_numerodeintentos_fallidos = u.tbl_numerodeintentos_fallidos,
                tbl_celular = u.tbl_celular,
                tbl_cedula = u.tbl_cedula,
                tbl_PasswordHash = u.tbl_PasswordHash != null ? u.tbl_PasswordHash.ToArray().ToList() : null,
                tbl_UsertypeID = u.tbl_UsertypeID
            };
        }
    }
}