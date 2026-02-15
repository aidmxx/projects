package VirtualScrollAccessSystem;

import VirtualScrollAccessSystem.util.DBUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import org.mindrot.jbcrypt.BCrypt;
import org.json.JSONObject;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;

/**
 * The {@code Setup} class is responsible for initializing the Virtual Scroll Access System application. This includes configuring resources, setting up database and loading initial data.
 */
public class Setup {

    /**
     * A utility instance for managing database operations
     */
    private static DBUtil db = new DBUtil();

    private static int inactivityLimit;



    public static void loadConfig(String path) {
        String configPath = path + "config.json";  // Use the provided path
        Path filePath = Paths.get(configPath);

        try {
            if (Files.exists(filePath)) {
                String content = new String(Files.readAllBytes(filePath));
                JSONObject config = new JSONObject(content);
                inactivityLimit = config.getInt("inactivityLimit");
                System.out.println("Inactivity limit loaded: " + inactivityLimit);
            } else {
                // Create default config if file does not exist
                JSONObject defaultConfig = new JSONObject();
                defaultConfig.put("inactivityLimit", 10);
                Files.write(filePath, defaultConfig.toString().getBytes(), StandardOpenOption.CREATE_NEW);
                inactivityLimit = defaultConfig.getInt("inactivityLimit");
                System.out.println("Config file created with default inactivity limit: " + inactivityLimit);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    public static int getInactivityLimit() {
        return inactivityLimit;
    }

    public static void setInactivityLimit(int newLimit) {
        inactivityLimit = newLimit;
        saveConfig();
    }

    private static void saveConfig() {
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("inactivityLimit", inactivityLimit);
            Files.write(Paths.get("src/main/resources/config.json"), jsonObject.toString().getBytes());
        } catch (Exception e) {
            System.out.println("Failed to save config: " + e.getMessage());
        }
    }



    /**
     * Initializes a connection to the SQLite database for the Virtual Scroll Access System.
     * The method specifies the file path for the database and uses the {@link DBUtil} to establish the connection.
     *
     * @param path The file path where the database is located or will be created.
     * @return A {@link Connection} object representing the connection to the SQLite database.
     */
    public static Connection initDatabase(String path) {
        Connection conn = null;
        String dbPath = path + "data.db";
        conn = db.connect(dbPath);
        return conn;
    }


    /**
     * Creates the 'User' table in the SQLite database if it does not already exist.
     * The 'User' table stores information about system users, including user ID, username, password, role, phone number, and email.
     *
     * @param conn The {@link Connection} object representing the database connection.
     */
    public static void createUserTable(Connection conn) {
        String tableName = "User";
        String query = "CREATE TABLE IF NOT EXISTS User (" +
                "user_id TEXT PRIMARY KEY," +
                "username TEXT," +
                "password TEXT," +
                "role TEXT CHECK(role IN ('admin', 'user'))," +
                "phone_num TEXT," +
                "email TEXT);";

        try {
            PreparedStatement stmt = conn.prepareStatement(query);
            db.createTable(conn, stmt, tableName);
        } catch (Exception e) {
            e.printStackTrace();
        }

        insertDefaultAdminUser(conn);
    }

    /**
     * Inserts a default admin user into the "User" table if it does not already exist.
     *
     * <p>
     * This method first checks whether a user with the user ID "admin" exists in the database.
     * If the admin user is not found, a new admin user with the following details is inserted:
     * <ul>
     * <li>user_id: "admin"
     * <li>username: "admin"
     * <li>password: A hashed version of "12345678"
     * <li>role: "admin"
     * <li>phone_num: (empty)
     * <li>email: (empty)
     * </ul>
     *
     * The password is hashed before being stored in the database.
     *
     * @param conn The {@link Connection} object representing the database connection.
     */
    private static void insertDefaultAdminUser(Connection conn) {
        String checkQuery = "SELECT user_id FROM User WHERE user_id = ?;";
        String insertQuery = "INSERT INTO User (user_id, username, password, role, phone_num, email) VALUES (?, ?, ?, ?, ?, ?);";

        try {
            // check if admin user already exists
            PreparedStatement checkStmt = conn.prepareStatement(checkQuery);
            checkStmt.setString(1, "admin");
            ResultSet rs = checkStmt.executeQuery();

            if (rs.next()) {
                // admin user already exists
                System.out.println("Admin user already exists. No action taken.");
            } else {
                PreparedStatement insertStmt = conn.prepareStatement(insertQuery);

                // set the values for the admin user
                insertStmt.setString(1, "admin");
                insertStmt.setString(2, "admin");
                insertStmt.setString(3, BCrypt.hashpw("12345678", BCrypt.gensalt()));
                insertStmt.setString(4, "admin");
                insertStmt.setString(5, "");
                insertStmt.setString(6, "");

                db.update(conn, insertStmt);
                System.out.println("Default admin user inserted successfully.");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    /**
     * Creates the 'Scroll' table in the SQLite database if it does not already exist.
     * The 'Scroll' table stores information about uploaded scrolls, including the scroll ID, name, content, uploader, and timestamp.
     *
     * @param conn The {@link Connection} object representing the database connection.
     */
    public static void createScrollTable(Connection conn) {
        String tableName = "Scroll";
        String query = "CREATE TABLE IF NOT EXISTS Scroll (" +
                "scroll_id INTEGER PRIMARY KEY AUTOINCREMENT," +
                "filename TEXT," +
                "name TEXT UNIQUE," +
                "content BLOB," +
                "uploader TEXT REFERENCES User(user_id)," +
                "timestamp DATETIME," +
                "file_type INTEGER CHECK(file_type IN (0, 1))," + // CHECK constraint to limit the file_type only be 0 or 1
                "download_counter INTEGER," +
                "upload_counter INTEGER);";

        try {
            PreparedStatement stmt = conn.prepareStatement(query);
            db.createTable(conn, stmt, tableName);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    /**
     * Creates the 'Scroll_Category' linking table in the SQLite database if it does not already exist.
     * This table establishes a many-to-many relationship between scrolls and categories, associating each scroll with one or more categories.
     *
     * @param conn The {@link Connection} object representing the database connection.
     */
    public static void createScrollCategoryTable(Connection conn) {
        String tableName = "Scroll_Category";
        String query = "CREATE TABLE IF NOT EXISTS Scroll_Category (" +
                "scroll_id INTEGER REFERENCES Scroll(scroll_id)," +
                "category_id INTEGER REFERENCES Scroll(category_id)," +
                "PRIMARY KEY (scroll_id, category_id));";

        try {
            PreparedStatement stmt = conn.prepareStatement(query);
            db.createTable(conn, stmt, tableName);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    /**
     * Creates the 'Category' table in the SQLite database if it does not already exist.
     * The 'Category' table stores information about categories, including category ID and category name.
     * Categories are used to classify scrolls into different groups.
     *
     * @param conn The {@link Connection} object representing the database connection.
     */
    public static void createCategoryTable(Connection conn) {
        String tableName = "Category";
        String query = "CREATE TABLE IF NOT EXISTS Category (" +
                "category_id INTEGER PRIMARY KEY AUTOINCREMENT," +
                "category_name TEXT);";

        try {
            PreparedStatement stmt = conn.prepareStatement(query);
            db.createTable(conn, stmt, tableName);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Creates the 'Daily_Scroll' table in the SQLite database if it does not already exist.
     * The 'Daily_Scroll' table stores information about daily scrolls, including the date and
     * a reference to the scroll ID from the 'Scroll' table.
     * This table is used to track the scrolls that were uploaded on a specific date.
     *
     * @param conn The {@link Connection} object representing the database connection.
     */
    public static void createDailyScrollTable(Connection conn) {
        String tableName = "Daily_Scroll";
        String query = "CREATE TABLE IF NOT EXISTS Daily_Scroll (" +
                "date Date PRIMARY KEY," +
                "scroll_id INTEGER REFERENCES Scroll(scroll_id));";

        try {
            PreparedStatement stmt = conn.prepareStatement(query);
            db.createTable(conn, stmt, tableName);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}