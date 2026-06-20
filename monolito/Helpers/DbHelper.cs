using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace monolito.Helpers
{
    public static class DbHelper
    {
        private static string _connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

        public static SqlConnection GetConnection()
        {
            return new SqlConnection(_connectionString);
        }

        // Método genérico para ejecutar procedimientos almacenados que no devuelven datos
        public static void ExecuteNonQuery(string spName, SqlParameter[] parameters)
        {
            using (var connection = GetConnection())
            {
                using (var command = new SqlCommand(spName, connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    if (parameters != null)
                    {
                        command.Parameters.AddRange(parameters);
                    }
                    connection.Open();
                    command.ExecuteNonQuery();
                }
            }
        }

        // Método genérico para ejecutar procedimientos almacenados que devuelven un conjunto de datos (DataTable)
        public static DataTable ExecuteQuery(string spName, SqlParameter[] parameters)
        {
            using (var connection = GetConnection())
            {
                using (var command = new SqlCommand(spName, connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    if (parameters != null)
                    {
                        command.Parameters.AddRange(parameters);
                    }
                    using (var adapter = new SqlDataAdapter(command))
                    {
                        DataTable dataTable = new DataTable();
                        adapter.Fill(dataTable);
                        return dataTable;
                    }
                }
            }
        }
    }
}