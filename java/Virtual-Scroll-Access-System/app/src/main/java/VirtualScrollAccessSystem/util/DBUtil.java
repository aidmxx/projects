package VirtualScrollAccessSystem.util;

import java.sql.*;

/**
 * The {@code DBUtil} class provides utility methods to manage SQLite database connections and operations.
 * It allows for connecting to a database, creating tables, checking for table existence, executing SQL queries (SELECT, INSERT, UPDATE, DELETE), and closing database connections.
 *
 * <p>
 * This class is designed to facilitate database interaction in the Virtual Scroll Access System, but it can be adapted for any system using an SQLite database.
 *
 * <p>Features:
 * <ul>
 *   <li>Establishes a connection to an SQLite database file.
 *   <li>Creates tables in the database if they do not already exist.
 *   <li>Executes SELECT queries and returns the result set.
 *   <li>Executes INSERT, UPDATE, or DELETE queries to modify the database.
 *   <li>Checks whether a specified table exists in the database.
 *   <li>Closes database connections.
 * </ul>
 * 
 * @author Junrui Kang
 * @version 1.0
 */
public class DBUtil {
    
    /**
     * The default file path for the SQLite database .db file.
     * This constant can be used to specify the location where the database file will be created or accessed.
     */
    private String path = "";


    /**
     * Retrieves the file path of the SQLite database (.db) file.
     * This method provides access to the current file path being used for the database, which can be useful for configuration or logging purposes.
     *
     * @return The file path of the .db file as a {@link String}.
     */
    public String getDbFilePath() {
        return this.path;
    };


    /**
     * Initializes a connection to an SQLite database. 
     * If the database file specified by the file path exists, 
     * it initializes a connection to the existing database.
     * If the database file does not exist, it creates a new database file and initializes the connection.
     *
     * @param filePath The path to the SQLite database file. If the file does not exist, it will be created.
     * @return A {@link Connection} object that represents the connection to the SQLite database.
     */
    public Connection connect(String filePath) {
        this.path = filePath;
        Connection conn = null;

        try {
            Class.forName("org.sqlite.JDBC");
            conn = DriverManager.getConnection("jdbc:sqlite:" + filePath); 
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return conn;
    };
 

    /**
     * Closes the connection to the SQLite database.
     *
     * @param conn The {@link Connection} object to close.
     */
    public void closeConnection(Connection conn) {
        try {
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    };


    /**
     * Creates a table in the SQLite database using the provided SQL query.
     * This method executes the given SQL statement to create a table with the specified name if the connection is valid.
     *
     * @param conn The {@link Connection} object representing the database connection. 
     * @param query The {@link PreparedStatement} object containing the SQL query that defines the table structure.
     * @param tableName The name of the table to be created. This is used to check whether the table exist.
     * @throws SQLException Throw error when the SQL query is invalid.
     */
    public void createTable(Connection conn, PreparedStatement query, String tableName) throws SQLException {

        // check whether the connection is valid
        if (conn == null || conn.isClosed()) {
            throw new SQLException("Database connection is invalid.");
        }

        // check if the table already exists
        if (tableExists(conn, tableName)) {
            System.out.println("Table '" + tableName + "' already exists.");
            return;
        }

        // execute the query to create the table
        query.executeUpdate();
        System.out.println("Table '" + tableName + "' created successfully.");
    }


    /**
     * Checks whether a table with the given name exists in the database.
     *
     * @param conn The {@link Connection} object representing the database connection.
     * @param tableName The name of the table to check.
     * @return True if the table exists, otherwise false.
     * @throws SQLException If any database error occurs.
     */
    private boolean tableExists(Connection conn, String tableName) throws SQLException {
        boolean exists = false;

        String query = "SELECT name FROM sqlite_master WHERE type='table' AND name=?;";
        try (PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setString(1, tableName);
            try (ResultSet rs = stmt.executeQuery()) {
                exists = rs.next(); // Table exists if the result set has any rows
            }
        }
        
        return exists;
    } 


    /**
     * Executes a SELECT SQL query and returns the ResultSet.
     * This method sends a prepared SELECT statement to the database for execution.
     *
     * @param conn The {@link Connection} object representing the database connection.
     * @param query The {@link PreparedStatement} object containing the SQL SELECT query.
     * @return The {@link ResultSet} object containing the results of the query.
     * @throws SQLException Throw error when the SQL query is invalid or connection is not valid.
     */
    public ResultSet query(Connection conn, PreparedStatement query) throws SQLException {

        // check whether the connection is valid
        if (conn == null || conn.isClosed()) {
            throw new SQLException("Database connection is invalid.");
        }

        // execute the SELECT query and return the ResultSet
        return query.executeQuery();
    }

    /**
     * Executes an INSERT, UPDATE, or DELETE SQL statement.
     * This method sends a prepared statement to the database for execution.
     *
     * @param conn The {@link Connection} object representing the database connection.
     * @param query The {@link PreparedStatement} object containing the SQL query (INSERT, UPDATE, DELETE).
     * @return An integer indicating the number of rows affected by the query.
     * @throws SQLException Throw error when the SQL statement is invalid or connection is not valid.
     */
    public int update(Connection conn, PreparedStatement query) throws SQLException {
        // check whether the connection is valid
        if (conn == null || conn.isClosed()) {
            throw new SQLException("Database connection is invalid.");
        }

        // execute INSERT, UPDATE or DELETE SQL query
        return query.executeUpdate();
    }
}
