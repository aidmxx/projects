package VirtualScrollAccessSystem;

import java.sql.*;
import java.util.Date;
import java.util.HashMap;
import java.util.ArrayList;
import java.nio.file.*;
import java.io.File;
import org.mindrot.jbcrypt.BCrypt;
import java.io.IOException;

import VirtualScrollAccessSystem.util.DBUtil;

/**
 * The {@code Database} class handles all communication between the application and the SQLite database.
 *
 * <p>
 * It provides methods for adding new entries to the database, such as adding users and scrolls, as well as querying the database for retrieving information, such as fetching all users, scrolls, or categories.
 *
 * <p>
 * This class is responsible for managing interactions with the database by executing SQL statements for inserting, updating, deleting, and retrieving data.
 * It ensures that the database is correctly accessed and handles potential exceptions during database operations.
 */
public class Database {

    /**
     * A utility instance for managing database operations
     */
    private static DBUtil db = new DBUtil();

    /**
     * The {@link Connection} object representing the database connection.
     */
    public static Connection conn;
    /**
     * A String list contains 5 readable file types
     */
    private final static String[] readable_lst = {".txt", ".py", ".java", ".json", ".csv"};
    private static boolean isReadable = false;
    /**
     * Constructor of the database.
     * This will be run when the application is lauched.
     * @param path The path to the database file
     */
    public Database (String path) {
        conn = Setup.initDatabase(path);
        Setup.createUserTable(conn);
        Setup.createScrollTable(conn);
        Setup.createScrollCategoryTable(conn);
        Setup.createCategoryTable(conn);
        Setup.createDailyScrollTable(conn);
    }

    /**
     * Adds a new user to the database with the provided details.
     * The password will be hashed using BCrypt before storage.
     *
     * @param user_id The unique identifier for the user.
     * @param username The user's name to be stored in the database.
     * @param password The plain-text password of the user, which will be hashed before saving.
     * @param role The role of the user (e.g., "admin", "user").
     * @param phone_num The phone number of the user.
     * @param email The email address of the user.
     * @throws IllegalArgumentException If the provided argument is empty, or user_id already exists in the database.
     * @throws IllegalStateException If there is a problem with the database connection or if any other SQL-related error occurs during the insertion.
     */
    public static void addUser(String user_id, String username, String password, String role, String phone_num, String email) {

        if (user_id == null || user_id.isEmpty() ||
                username == null || username.isEmpty() ||
                password == null || password.isEmpty() ||
                role == null || role.isEmpty())
        {
            throw new IllegalArgumentException("None of user_id, username, password and role can be null.");
        }

        String query = "INSERT INTO User (user_id, username, password, role, phone_num, email) VALUES (?, ?, ?, ?, ?, ?);";

        try {
            PreparedStatement stmt = conn.prepareStatement(query);

            stmt.setString(1, user_id);
            stmt.setString(2, username);
            stmt.setString(3, BCrypt.hashpw(password, BCrypt.gensalt()));
            stmt.setString(4, role);
            stmt.setString(5, phone_num);
            stmt.setString(6, email);

            db.update(conn, stmt);

        } catch (SQLException e) {

            // primary key violation (duplicate user_id)
            if (e.getErrorCode() == 19) {
                throw new IllegalArgumentException("This user_id already exists! Please enter a new user_id.");

            } else {
                throw new IllegalStateException("An unexpected database error occurred: " + e.getMessage(), e);
            }

        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.");
        }
    }


    /**
     * Retrieves all information for a user based on the provided {@code user_id}.
     *
     * @param user_id The unique identifier for the user whose information is to be fetched. Must not be null or empty.
     * @return Hashmap containing user information
     * @throws IllegalArgumentException If the {@code user_id} is null, empty, or if no user is found with the provided {@code user_id}.
     * @throws IllegalStateException If there is an error accessing the database or an unexpected error occurs.
     */
    public static HashMap<String, String> getUserInfoByUserID(String user_id) {

        if (user_id == null || user_id.trim().isEmpty()) {
            throw new IllegalArgumentException("user_id cannot be null or empty.");
        }

        String query = "SELECT * FROM User WHERE user_id = ?;";

        try {
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setString(1, user_id);
            ResultSet rs = db.query(conn, stmt);

            if (rs.next()) {
                String id = rs.getString("user_id");
                String username = rs.getString("username");
                String password = rs.getString("password");
                String role = rs.getString("role");
                String phone_num = rs.getString("phone_num");
                String email = rs.getString("email");

                HashMap<String, String> res = new HashMap<>();
                res.put("user_id", id);
                res.put("username", username);
                res.put("password", password);
                res.put("role", role);
                res.put("phone_num", phone_num);
                res.put("email", email);

                return res;

            } else {
                throw new IllegalArgumentException("No user found with the provided user_id.");
            }

        } catch (IllegalArgumentException e) {
            throw e;

        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.");
        }
    }


    /**
     * Retrieves information for all users in the database.
     *
     * @return An ArrayList of HashMaps, where each HashMap contains the user information (e.g., user_id, username, role, phone, email, etc.).
     * @throws IllegalStateException If there is an error accessing the database or an unexpected error occurs.
     */
    public static ArrayList<HashMap<String, String>> getAllUserInfo() {
        ArrayList<HashMap<String, String>> allUsersInfo = new ArrayList<>();

        String query = "SELECT user_id, username, role, phone_num, email FROM User;";

        try {
            PreparedStatement stmt = conn.prepareStatement(query);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                HashMap<String, String> userInfo = new HashMap<>();
                userInfo.put("user_id", rs.getString("user_id"));
                userInfo.put("username", rs.getString("username"));
                userInfo.put("role", rs.getString("role"));
                userInfo.put("phone_num", rs.getString("phone_num"));
                userInfo.put("email", rs.getString("email"));

                allUsersInfo.add(userInfo);
            }

            rs.close();
            stmt.close();

        } catch (SQLException e) {
            throw new IllegalStateException("Database access error occurred.", e);

        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.", e);
        }

        return allUsersInfo;
    }


    /**
     * Delete information for a user based on the provided {@code user_id}.
     *
     * @param user_id The unique identifier for the user who will be deleted. Must not be null or empty.
     * @throws IllegalArgumentException If the {@code user_id} is null, empty, or if no user is found with the provided {@code user_id}.
     * @throws IllegalStateException If there is an error accessing the database or an unexpected error occurs.
     */
    public static void deleteUserByUserID(String user_id) {

        if (user_id == null || user_id.trim().isEmpty()) {
            throw new IllegalArgumentException("user_id cannot be null or empty.");
        }

        String query = "DELETE FROM User WHERE user_id = ?;";

        try {
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setString(1, user_id);
            int rowsAffected = db.update(conn, stmt);

            if (rowsAffected == 0) {
                throw new IllegalArgumentException("No user found with the provided user_id.");
            }

        } catch (IllegalArgumentException e) {
            throw e;

        } catch (SQLException e) {
            throw new IllegalStateException("Database access error occurred.", e);

        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.", e);
        }
    }


    /**
     * Updates the username for a user based on the provided {@code user_id}.
     *
     * @param user_id The unique identifier for the user whose username will be updated. Must not be null or empty.
     * @param username The new username to be set for the user. Must not be null or empty.
     * @throws IllegalArgumentException If the {@code user_id} or {@code username} is null or empty, or if no user is found with the provided {@code user_id}.
     * @throws IllegalStateException If there is an error accessing the database or an unexpected error occurs.
     */
    public static void updateUserName(String user_id, String username) {

        if (user_id == null || user_id.trim().isEmpty()) {
            throw new IllegalArgumentException("user_id cannot be null or empty.");
        }

        if (username == null || username.trim().isEmpty()) {
            throw new IllegalArgumentException("username cannot be null or empty.");
        }

        String query = "UPDATE User SET username = ? WHERE user_id = ?;";

        try {
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setString(1, username);
            stmt.setString(2, user_id);
            int rowsAffected = db.update(conn, stmt);

            if (rowsAffected == 0) {
                throw new IllegalArgumentException("No user found with the provided user_id.");
            }

        } catch (IllegalArgumentException e) {
            throw e;

        } catch (SQLException e) {
            throw new IllegalStateException("Database access error occurred.", e);

        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.", e);
        }
    }


    /**
     * Updates the password for a user based on the provided {@code user_id}.
     * The password will be hashed using BCrypt before being stored in the database.
     *
     * @param user_id The unique identifier for the user whose password will be updated. Must not be null or empty.
     * @param newPassword The new plain-text password to be set for the user. Must not be null or empty.
     * @throws IllegalArgumentException If the {@code user_id} or {@code newPassword} is null or empty, or if no user is found with the provided {@code user_id}.
     * @throws IllegalStateException If there is an error accessing the database or an unexpected error occurs.
     */
    public static void updatePassword(String user_id, String newPassword) {

        if (user_id == null || user_id.trim().isEmpty()) {
            throw new IllegalArgumentException("user_id cannot be null or empty.");
        }

        if (newPassword == null || newPassword.trim().isEmpty()) {
            throw new IllegalArgumentException("Password cannot be null or empty.");
        }

        String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
        String query = "UPDATE User SET password = ? WHERE user_id = ?;";

        try {
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setString(1, hashedPassword);
            stmt.setString(2, user_id);
            int rowsAffected = db.update(conn, stmt);

            if (rowsAffected == 0) {
                throw new IllegalArgumentException("No user found with the provided user_id.");
            }

        } catch (IllegalArgumentException e) {
            throw e;

        } catch (SQLException e) {
            throw new IllegalStateException("Database access error occurred.", e);

        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.", e);
        }
    }


    /**
     * Updates the phone number for a user based on the provided {@code user_id}.
     *
     * @param user_id The unique identifier for the user whose phone number will be updated. Must not be null or empty.
     * @param phoneNumber The new phone number to be set for the user. Must not be null or empty.
     * @throws IllegalArgumentException If the {@code user_id} or {@code phoneNumber} is null or empty, or if no user is found with the provided {@code user_id}.
     * @throws IllegalStateException If there is an error accessing the database or an unexpected error occurs.
     */
    public static void updatePhoneNumber(String user_id, String phoneNumber) {

        if (user_id == null || user_id.trim().isEmpty()) {
            throw new IllegalArgumentException("user_id cannot be null or empty.");
        }

        if (phoneNumber == null || phoneNumber.trim().isEmpty()) {
            throw new IllegalArgumentException("Phone number cannot be null or empty.");
        }

        String query = "UPDATE User SET phone_num = ? WHERE user_id = ?;";

        try {
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setString(1, phoneNumber);
            stmt.setString(2, user_id);
            int rowsAffected = db.update(conn, stmt);

            if (rowsAffected == 0) {
                throw new IllegalArgumentException("No user found with the provided user_id.");
            }

        } catch (IllegalArgumentException e) {
            throw e;

        } catch (SQLException e) {
            throw new IllegalStateException("Database access error occurred.", e);

        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.", e);
        }
    }


    /**
     * Updates the email address for a user based on the provided {@code user_id}.
     *
     * @param user_id The unique identifier for the user whose email will be updated. Must not be null or empty.
     * @param email The new email address to be set for the user. Must not be null or empty.
     * @throws IllegalArgumentException If the {@code user_id} or {@code email} is null or empty, or if no user is found with the provided {@code user_id}.
     * @throws IllegalStateException If there is an error accessing the database or an unexpected error occurs.
     */
    public static void updateEmail(String user_id, String email) {

        if (user_id == null || user_id.trim().isEmpty()) {
            throw new IllegalArgumentException("user_id cannot be null or empty.");
        }

        if (email == null || email.trim().isEmpty()) {
            throw new IllegalArgumentException("Email cannot be null or empty.");
        }

        String query = "UPDATE User SET email = ? WHERE user_id = ?;";

        try {
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setString(1, email);
            stmt.setString(2, user_id);
            int rowsAffected = db.update(conn, stmt);

            if (rowsAffected == 0) {
                throw new IllegalArgumentException("No user found with the provided user_id.");
            }

        } catch (IllegalArgumentException e) {
            throw e;

        } catch (SQLException e) {
            throw new IllegalStateException("Database access error occurred.", e);

        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.", e);
        }
    }






    // start Scroll database build

    /**
     * Adds a new scroll to the database with the provided details.
     * The scroll_id is auto incremented in Database
     * @param name The name of each scroll, this must be unique
     * @param file The file used to store scroll content (where needs to convert as binary file in following)
     * @param uploader_id The uploader_id who uploads the scroll (as user_id in User)
     * @throws IllegalArgumentException If the provided argument is empty, or name already exists in the database.
     * @throws IllegalStateException If there is a problem with the database connection or if any other SQL-related error occurs during the insertion.
     */
    public static void addScroll(String name, File file, String uploader_id) {
        if (name == null || name.trim().isEmpty() ||
                file == null ||
                uploader_id == null || uploader_id.trim().isEmpty()) {
            throw new IllegalArgumentException("None of name, file, category and uploader_id can be null.");
        }

        int file_type = 0;
        // detect if the file is a .txt file
        if (file != null && file.isFile() && checkReadable(file.getName().toLowerCase())) {
            file_type = 1;
            isReadable = false;
        }


        // convert file to binary file format byte[]
        byte[] binary_file = null;
        try {
            binary_file = Files.readAllBytes(file.toPath());
        } catch (IOException e) {
            e.printStackTrace();
        }

        String filename = file.getName();

        // get current timeStamp
        Timestamp timestamp = new Timestamp(System.currentTimeMillis());

        String query = "INSERT INTO Scroll (filename, name, content, uploader, timestamp, file_type, download_counter, upload_counter) VALUES (?, ?, ?, ?, ?, ?, ?, ?);";

        try {
            PreparedStatement stmt = conn.prepareStatement(query);

            stmt.setString(1, filename);
            stmt.setString(2, name);
            stmt.setBytes(3, binary_file);
            stmt.setString(4, uploader_id);
            stmt.setTimestamp(5, timestamp);
            stmt.setInt(6, file_type);
            stmt.setInt(7, 0);
            stmt.setInt(8, 1);
            db.update(conn, stmt);

        } catch (SQLException e) {

            // SQLITE_CONSTRAINT_UNIQUE (duplicate name)
            if (e.getErrorCode() == 19) {
                throw new IllegalArgumentException("This name already exists! Please enter a new name.");

            } else {
                throw new IllegalStateException("An unexpected database error occurred: " + e.getMessage(), e);
            }

        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.");
        }
    }

    /**
     * Retrieves the content for a scroll based on the provided {@code scroll_id}.
     * @param scroll_id The id of each scroll used to get the scroll content.
     * @return byte[] The binary file stored in Scroll found by the given scroll_id
     * @throws IllegalArgumentException If the no scroll is found with the provided {@code scroll_id}.
     * @throws IllegalStateException If there is an error accessing the database or an unexpected error occurs.
     */
    public static byte[] getScrollContent(int scroll_id){
        String query = "SELECT content FROM Scroll WHERE scroll_id = ?;";

        try {
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setInt(1, scroll_id);
            ResultSet rs = db.query(conn, stmt);

            if (rs.next()) {
                byte[] content = rs.getBytes("content");
                return content;

            } else {
                throw new IllegalArgumentException("No scroll found with the provided scroll_id.");
            }

        } catch (IllegalArgumentException e) {
            throw e;

        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.");
        }
    }

    /**
     * Retrieves information for all scrolls in the database.
     * @return ArrayList<HashMap<String, Object>> An ArrayList of HashMaps, where each HashMap contains the scroll information (e.g., scroll_id, name, content, uploader, timestamp).
     * {@code scroll_id: int; name: String; content: File; uploader: String; timestamp: Timestamp}
     * @throws IllegalStateException If there is an error accessing the database or an unexpected error occurs.
     */
    public static ArrayList<HashMap<String, Object>> getAllScrollInfo() {
        ArrayList<HashMap<String, Object>> allScrollInfo = new ArrayList<>();

        String query = "SELECT scroll_id, name, uploader, timestamp, file_type, download_counter, upload_counter FROM Scroll;";

        try {
            PreparedStatement stmt = conn.prepareStatement(query);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                HashMap<String, Object> scrollInfo = new HashMap<>();
                scrollInfo.put("scroll_id", rs.getInt("scroll_id"));
                scrollInfo.put("name", rs.getString("name"));
                scrollInfo.put("uploader", rs.getString("uploader"));
                scrollInfo.put("timestamp", rs.getTimestamp("timestamp"));
                scrollInfo.put("file_type", rs.getInt("file_type"));
                scrollInfo.put("download_counter", rs.getInt("download_counter"));
                scrollInfo.put("upload_counter", rs.getInt("upload_counter"));

                allScrollInfo.add(scrollInfo);
            }

            rs.close();
            stmt.close();

        } catch (SQLException e) {
            throw new IllegalStateException("Database access error occurred.", e);

        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.", e);
        }

        return allScrollInfo;
    }


    /**
     * Retrieves information for all scrolls in the database by given user_id.
     * @param user_id The uploader id of the scroll used to get info.
     * @return ArrayList<HashMap<String, Object>> An ArrayList of HashMaps, where each HashMap contains the scroll information (e.g., scroll_id, name, content, uploader, timestamp).
     * @throws IllegalStateException If there is an error accessing the database or an unexpected error occurs.
     */
    public static ArrayList<HashMap<String, Object>> getAllScrollByID(String user_id){
        if (user_id == null || user_id.trim().isEmpty()){
            throw new IllegalArgumentException("user_id cannot be null or empty.");
        }
        ArrayList<HashMap<String, Object>> allScrollInfo = new ArrayList<>();

        String query = "SELECT scroll_id, name, content, uploader, timestamp FROM Scroll WHERE uploader = ?;";

        try {
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setString(1, user_id);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                HashMap<String, Object> scrollInfo = new HashMap<>();
                scrollInfo.put("scroll_id", rs.getInt("scroll_id"));
                scrollInfo.put("name", rs.getString("name"));
                scrollInfo.put("content", rs.getBytes("content"));
                scrollInfo.put("uploader", rs.getString("uploader"));
                scrollInfo.put("timestamp", rs.getTimestamp("timestamp"));

                allScrollInfo.add(scrollInfo);
            }

            rs.close();
            stmt.close();

        } catch (SQLException e) {
            throw new IllegalStateException("Database access error occurred.", e);

        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.", e);
        }

        return allScrollInfo;
    }

    /**
     * Delete information for a scroll based on the provided {@code scroll_id}.
     * @param scroll_id The id of each scroll used to delete data.
     * @throws IllegalArgumentException If the {@code scroll_id} is null, empty, or if no scroll is found with the provided {@code scroll_id}.
     * @throws IllegalStateException If there is an error accessing the database or an unexpected error occurs.
     */
    public static boolean deleteScroll(int scroll_id) {
        String query = "DELETE FROM Scroll WHERE scroll_id = ?;";
        String dailyQuery = "DELETE FROM Daily_Scroll WHERE scroll_id = ?;";

        boolean isDailyScrollDeleted = false;

        try {
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setInt(1, scroll_id);
            int rowsAffected = db.update(conn, stmt);

            if (rowsAffected == 0) {
                throw new IllegalArgumentException("No scroll found with the provided scroll_id.");
            }
            PreparedStatement stmt_daily = conn.prepareStatement(dailyQuery);
            stmt_daily.setInt(1, scroll_id);
            int rowsAffected_daily = db.update(conn, stmt_daily);
            if (rowsAffected_daily > 0) {
                isDailyScrollDeleted = true;
            }

        } catch (IllegalArgumentException e) {
            throw e;

        } catch (SQLException e) {
            throw new IllegalStateException("Database access error occurred.", e);

        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.", e);
        }

        return isDailyScrollDeleted;
    }


    /**
     * Update scroll content based on the scroll id
     * @param file The path for the scroll content
     * @param scroll_id The id for the scroll used to update content
     * @throws IllegalArgumentException If the {@code scroll_id} is null, empty, or if no scroll is found with the provided {@code scroll_id}.
     * @throws IllegalStateException If there is an error accessing the database or an unexpected error occurs.
     */
    public static void updateScroll(File file, int scroll_id) {
        String query = "UPDATE Scroll SET filename = ?, content = ?, file_type = ? WHERE scroll_id = ?;";

        int file_type = 0;

        // detect if the file is a readable file
        if (file != null && file.isFile() && checkReadable(file.getName().toLowerCase())) {
            file_type = 1;
            isReadable = false;
        }
        // convert file to binary file format byte[]
        byte[] binary_file = null;
        try {
            binary_file = Files.readAllBytes(file.toPath());
        } catch (IOException e) {
            e.printStackTrace();
        }

        String filename = file.getName();

        try {
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setString(1, filename);
            stmt.setBytes(2, binary_file);
            stmt.setInt(3, file_type);
            stmt.setInt(4, scroll_id);
            int rowsAffected = db.update(conn, stmt);

            if (rowsAffected == 0) {
                throw new IllegalArgumentException("No scroll found with the provided scroll_id.");
            }

        } catch (IllegalArgumentException e) {
            throw e;

        } catch (SQLException e) {
            throw new IllegalStateException("Database access error occurred.", e);

        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.", e);
        }
    }

    /**
     * Retrieve the scroll information except the content
     * @param scroll_id The id for the scroll used to query
     * @return HashMap<String, Object> A HashMap contains the scroll information (e.g., scroll_id, name, content, uploader, timestamp).
     * @throws IllegalArgumentException If the {@code scroll_id} is null, empty, or if no scroll is found with the provided {@code scroll_id}.
     * @throws IllegalStateException If there is an error accessing the database or an unexpected error occurs.
     */
    public static HashMap<String, Object> getScrollInfoExceptContentByScrollID(int scroll_id) {
        String query = "SELECT scroll_id, filename, name, uploader, timestamp, file_type FROM Scroll WHERE scroll_id = ?;";

        try {
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setInt(1, scroll_id);
            ResultSet rs = db.query(conn, stmt);

            if (rs.next()) {
                int id = rs.getInt("scroll_id");
                String filename = rs.getString("filename");
                String name = rs.getString("name");
                String uploader = rs.getString("uploader");
                Timestamp timestamp = rs.getTimestamp("timestamp");
                int fileType = rs.getInt("file_type");

                HashMap<String, Object> res = new HashMap<>();
                res.put("scroll_id", id);
                res.put("filename", filename);
                res.put("name", name);
                res.put("uploader", uploader);
                res.put("timestamp", timestamp);
                res.put("file_type", fileType);

                return res;

            } else {
                throw new IllegalArgumentException("No scroll found with the provided scroll_id.");
            }

        } catch (IllegalArgumentException e) {
            throw e;

        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.");
        }
    }

    /**
     * Retrieves a preview of the scroll content based on the scroll ID.
     * <p>
     * If the scroll is a text file (file_type = 1), it returns the first 30 words (max) of the scroll content.
     * If the scroll is of a different type (file_type = 0), it returns a message indicating that the preview is unavailable.
     *
     * @param scrollID The ID of the scroll to retrieve the preview for.
     * @return A string containing the preview of the scroll content if the file is a .txt file. Otherwise, returns a message indicating that the preview is unavailable.
     * @throws IllegalArgumentException If no scroll is found with the given scroll ID.
     * @throws IllegalStateException If there is an issue accessing the database or an unexpected error occurs.
     */
    public static String getScrollPreview(int scrollID) {
        String query = "SELECT file_type, content FROM Scroll WHERE scroll_id = ?;";
    
        try {
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setInt(1, scrollID);
            ResultSet rs = stmt.executeQuery();
    
            if (rs.next()) {
                int fileType = rs.getInt("file_type");
                byte[] contentBlob = rs.getBytes("content");
    
                if (fileType == 1) {
                    // Convert BLOB to String
                    String content = new String(contentBlob);
                    // Extract the first 30 words
                    String[] words = content.split("\\s+");
                    StringBuilder preview = new StringBuilder();
    
                    int previewLength = Math.min(words.length, 30);
                    for (int i = 0; i < previewLength; i++) {
                        preview.append(words[i]).append(" ");
                    }
    
                    String previewText = preview.toString().trim();
    
                    if (words.length > 30) {
                        previewText += "...";
                    }
    
                    return previewText;
    
                } else {
                    return "The preview of this document is unavailable, please download the scroll to view it.";
                }
    
            } else {
                throw new IllegalArgumentException("No scroll found with the provided scroll_id.");
            }
    
        } catch (IllegalArgumentException e) {
            throw e;
    
        } catch (SQLException e) {
            throw new IllegalStateException("Database access error occurred.", e);
        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.", e);
        }
    }



    //tempory use
    public static boolean isUserScroll(String user_id, int scroll_id) {
        String query = "SELECT scroll_id FROM Scroll WHERE uploader = ? AND scroll_id = ?;";

        try {
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setString(1, user_id);
            stmt.setInt(2, scroll_id);
            ResultSet rs = stmt.executeQuery();

            boolean scrollExists = rs.next();
            rs.close();
            stmt.close();

            return scrollExists;

        } catch (SQLException e) {
            throw new IllegalStateException("Database access error occurred.", e);
        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.", e);
        }
    }

    /**
     * Retrieve the scroll information by given scroll name
     * @param name The name for the scroll used to query
     * @return HashMap<String, Object> A HashMap contains the scroll information (e.g., scroll_id, name, content, uploader, timestamp).
     * @throws IllegalArgumentException If the {@code name} is null, empty, or if no scroll is found with the provided {@code name}.
     * @throws IllegalStateException If there is an error accessing the database or an unexpected error occurs.
     */
    public static HashMap<String, Object> getScrollInfoByName(String name){
        String query = "SELECT scroll_id, name, uploader, timestamp FROM Scroll WHERE name = ?;";
        try {
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setString(1, name);
            ResultSet rs = db.query(conn, stmt);

            if (rs.next()) {
                int id = rs.getInt("scroll_id");
                String scrollName = rs.getString("name");
                String uploader = rs.getString("uploader");
                Timestamp timestamp = rs.getTimestamp("timestamp");

                HashMap<String, Object> res = new HashMap<>();
                res.put("scroll_id", id);
                res.put("name", scrollName);
                res.put("uploader", uploader);
                res.put("timestamp", timestamp);

                return res;

            } else {
                throw new IllegalArgumentException("No scroll found with the provided name.");
            }

        } catch (IllegalArgumentException e) {
            throw e;

        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.");
        }
    }

    /**
     * Retrieve the scroll information by given scroll time range
     * This method searches for scrolls where the timestamp of the scroll falls between the provided
     * start date (`startTime`) and end date (`startTime`).
     * @param startTime The start date time for the scroll used to query
     * @param endTime The end date time for the scroll used to query
     * @return HashMap<String, Object> A HashMap contains the scroll information (e.g., scroll_id, name, content, uploader, timestamp).
     * @throws IllegalArgumentException If the {@code date} is null, empty, or if no scroll is found with the provided {@code date}.
     * @throws IllegalStateException If there is an error accessing the database or an unexpected error occurs.
     */
    public static ArrayList<HashMap<String, Object>> searchScrollByTimeRange(Date startTime, Date endTime) {
        long startMillis = startTime.getTime();
        long endMillis = endTime.getTime();

        String query = "SELECT * FROM Scroll WHERE timestamp BETWEEN ? AND ?";
        ArrayList<HashMap<String, Object>> allScroll = new ArrayList<>();

        try {
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setLong(1, startMillis);
            stmt.setLong(2, endMillis);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                HashMap<String, Object> scrollInfo = new HashMap<>();
                scrollInfo.put("scroll_id", rs.getInt("scroll_id"));
                scrollInfo.put("name", rs.getString("name"));
                scrollInfo.put("content", rs.getBytes("content"));
                scrollInfo.put("uploader", rs.getString("uploader"));
                scrollInfo.put("timestamp", rs.getTimestamp("timestamp"));

                allScroll.add(scrollInfo);
            }

            rs.close();
            stmt.close();

        } catch (IllegalArgumentException e) {
            throw e;

        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.");
        }
        return allScroll;
    }

    /**
     * Increment upload counter by 1 based on the scroll id
     * @param scroll_id The id for the scroll used to update upload_counter
     * @throws IllegalArgumentException If the {@code scroll_id} is null, empty, or if no upload_counter is found with the provided {@code scroll_id}.
     * @throws IllegalStateException If there is an error accessing the database or an unexpected error occurs.
     */
    public static void updateUploadCounter(int scroll_id){
        String query = "UPDATE Scroll SET upload_counter = upload_counter + 1 WHERE scroll_id = ?;";

        try (PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, scroll_id);
            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("No upload_counter found with the provided ID, or no update made.");
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error updating upload_counter for the provided ID");
        }
    }

    /**
     * Increment download counter by 1 based on the scroll id
     * @param scroll_id The id for the scroll used to update download_counter
     * @throws IllegalArgumentException If the {@code scroll_id} is null, empty, or if no download_counter is found with the provided {@code scroll_id}.
     * @throws IllegalStateException If there is an error accessing the database or an unexpected error occurs.
     */
    public static void updateDownloadCounter(int scroll_id){
        String query = "UPDATE Scroll SET download_counter = download_counter + 1 WHERE scroll_id = ?;";

        try (PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, scroll_id);
            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("No download_counter found with the provided ID, or no update made.");
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error updating download_counter for the provided ID");
        }
    }

    /**
     * Retrieve the scroll info by given uploader.
     * This method searches for scrolls where the uploader's name (either in lower or original case) matches the provided search term.
     * @param uploader The user id or username for the scroll used to query
     * @return ArrayList<HashMap<String, Object>> A group of Hashmaps contains the scroll information (e.g., scroll_id, name, content, uploader, timestamp).
     * @throws IllegalStateException If there is an error accessing the database or an unexpected error occurs.
     */
    // uploader in here can be user_id or username, notice that in here user can query by either valid input
    public static ArrayList<HashMap<String, Object>> searchScrollByUploader(String uploader){
        if (uploader == null || uploader.trim().isEmpty()){
            throw new IllegalArgumentException("uploader cannot be null or empty.");
        }
        ArrayList<HashMap<String, Object>> allScrollInfo = new ArrayList<>();

        String query = "SELECT scroll_id, name, content, uploader, timestamp \n" +
                "FROM Scroll INNER JOIN USER ON (uploader = user_id)\n" +
                "WHERE LOWER(uploader) LIKE ? OR username LIKE ?;";

        try {
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setString(1, "%" + uploader.toLowerCase() + "%");
            stmt.setString(2, "%" + uploader.toLowerCase() + "%");
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                HashMap<String, Object> scrollInfo = new HashMap<>();
                scrollInfo.put("scroll_id", rs.getInt("scroll_id"));
                scrollInfo.put("name", rs.getString("name"));
                scrollInfo.put("content", rs.getBytes("content"));
                scrollInfo.put("uploader", rs.getString("uploader"));
                scrollInfo.put("timestamp", rs.getTimestamp("timestamp"));

                allScrollInfo.add(scrollInfo);
            }

            rs.close();
            stmt.close();

        } catch (SQLException e) {
            throw new IllegalStateException("Database access error occurred.", e);

        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.", e);
        }

        return allScrollInfo;
    }

    /**
     * Retrieve the scroll info by given scroll name.
     * This method searches for scrolls where the scroll name matches the provided search term.
     * @param scroll_name The scroll name for the scroll used to query
     * @return ArrayList<HashMap<String, Object>> A group of Hashmaps contains the scroll information (e.g., scroll_id, name, content, uploader, timestamp).
     * @throws IllegalStateException If there is an error accessing the database or an unexpected error occurs.
     */
    public static ArrayList<HashMap<String, Object>> searchScrollByName(String scroll_name){
        if (scroll_name == null || scroll_name.trim().isEmpty()){
            throw new IllegalArgumentException("scroll_name cannot be null or empty.");
        }
        ArrayList<HashMap<String, Object>> allScrollInfo = new ArrayList<>();

        String query = "SELECT scroll_id, name, content, uploader, timestamp \n" +
                "FROM Scroll \n" +
                "WHERE LOWER(name) LIKE ?;";

        try {
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setString(1, "%" + scroll_name.toLowerCase() + "%");
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                HashMap<String, Object> scrollInfo = new HashMap<>();
                scrollInfo.put("scroll_id", rs.getInt("scroll_id"));
                scrollInfo.put("name", rs.getString("name"));
                scrollInfo.put("content", rs.getBytes("content"));
                scrollInfo.put("uploader", rs.getString("uploader"));
                scrollInfo.put("timestamp", rs.getTimestamp("timestamp"));

                allScrollInfo.add(scrollInfo);
            }

            rs.close();
            stmt.close();

        } catch (SQLException e) {
            throw new IllegalStateException("Database access error occurred.", e);

        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.", e);
        }

        return allScrollInfo;
    }

    /**
     * Retrieve all scroll statistics (scroll_id, download_counter, upload_counter)
     * @return ArrayList<HashMap<String, Object>> An arrayList contains each scroll's statistics.
     * @throws IllegalStateException If there is an error accessing the database or an unexpected error occurs.
     */
    public static ArrayList<HashMap<String, Object>> getScrollStatistics() {
        ArrayList<HashMap<String, Object>> statistics = new ArrayList<>();
        String query = "SELECT scroll_id, download_counter, upload_counter FROM Scroll ORDER BY download_counter DESC;";

        try {
            PreparedStatement stmt = conn.prepareStatement(query);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                HashMap<String, Object> stat = new HashMap<>();
                stat.put("scroll_id", rs.getInt("scroll_id"));
                stat.put("download_counter", rs.getInt("download_counter"));
                stat.put("upload_counter", rs.getInt("upload_counter"));

                statistics.add(stat);
            }
            rs.close();
            stmt.close();
        } catch (SQLException e) {
            throw new IllegalStateException("Database access error occurred.", e);
        }
        return statistics;
    }





    // start Daily_Scroll database build
    /**
     * Adds a new daily scroll to the database with the provided details.
     * @param date The date of the random scroll should show
     * @param scroll_id The scroll id linked to scrolls in Scroll database to get information
     * @throws IllegalArgumentException If the provided argument is empty, or name already exists in the database.
     * @throws IllegalStateException If there is a problem with the database connection or if any other SQL-related error occurs during the insertion.
     */
    public static void addDailyScroll(Date date, int scroll_id){
        String query = "INSERT INTO Daily_Scroll (date, scroll_id) VALUES (?, ?);";

        try {
            // Convert the Date to an integer format YYYYMMDD
            java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("yyyyMMdd");
            int formattedDate = Integer.parseInt(formatter.format(date));

            PreparedStatement stmt = conn.prepareStatement(query);

            stmt.setInt(1, formattedDate);
            stmt.setInt(2, scroll_id);
            db.update(conn, stmt);

        } catch (SQLException e) {

            // SQLITE_CONSTRAINT_UNIQUE (duplicate date)
            if (e.getErrorCode() == 19) {
                throw new IllegalArgumentException("This date already exists! Please enter a new date.");

            } else {
                throw new IllegalStateException("An unexpected database error occurred: " + e.getMessage(), e);
            }

        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.");
        }
    }

    /**
     * Retrieve the daily scroll id by given current date
     * @param current_date The current date for the Daily_scroll used to query
     * @return int An integer contains the scroll download counter (the number of download scroll method be called).
     * @throws IllegalArgumentException If the {@code scroll_id} is null, empty, or if no download_counter is found with the provided {@code scroll_id}.
     * @throws IllegalStateException If there is an error accessing the database or an unexpected error occurs.
     */
    public static int getScrollIDOfTheDay(Date current_date){
        String query = "SELECT scroll_id FROM Daily_Scroll WHERE date = ?;";
        try {
            // Convert the current date to an integer format YYYYMMDD
            java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("yyyyMMdd");
            int formattedDate = Integer.parseInt(formatter.format(current_date));

            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setInt(1, formattedDate);
            ResultSet rs = db.query(conn, stmt);

            if (rs.next()) {
                int scroll_id = rs.getInt("scroll_id");
                return scroll_id;

            } else {
                throw new IllegalArgumentException("No daily_scroll found with the provided date.");
            }

        } catch (IllegalArgumentException e) {
            throw e;

        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.");
        }
    }


    //temporary use
    public static ArrayList<HashMap<String, Object>> getAllTextScrolls() throws SQLException {
        String query = "SELECT scroll_id, name FROM Scroll WHERE file_type = 1;";
        Connection conn = Database.conn;
        PreparedStatement stmt = conn.prepareStatement(query);
        ResultSet rs = stmt.executeQuery();

        ArrayList<HashMap<String, Object>> scrolls = new ArrayList<>();
        while (rs.next()) {
            HashMap<String, Object> scroll = new HashMap<>();
            scroll.put("scroll_id", rs.getInt("scroll_id"));
            scroll.put("name", rs.getString("name"));
            scrolls.add(scroll);
        }
        return scrolls;
    }

    /**
     * A method to checkout the readable for a file
     * @param item The file path
     * @return A boolean value to tell the file whether is readable or not
     */
    public static boolean checkReadable(String item){
        int dotIndex = item.lastIndexOf('.');
        String endType = null;
        if (dotIndex > 0 && dotIndex < item.length() - 1) {
            endType = item.substring(dotIndex).toLowerCase();
        }
        for (String end : readable_lst){
            if (endType.equals(end)){
                isReadable = true;
                return isReadable;
            }
        }
        return isReadable;
    }
}

