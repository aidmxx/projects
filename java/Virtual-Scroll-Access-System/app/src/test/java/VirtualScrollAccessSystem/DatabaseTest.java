package VirtualScrollAccessSystem;

import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mindrot.jbcrypt.BCrypt;
import java.nio.file.*;
import java.io.File;
import java.util.HashMap;
import java.util.ArrayList;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Date;
import java.text.ParseException;


public class DatabaseTest {

    // set up the environment and testing database
    @BeforeEach
    public void setup() {
        new Database("src/test/resources/");
    }

    @AfterEach
    public void teardown() throws SQLException {
        if (Database.conn != null && !Database.conn.isClosed()) {
            Database.conn.createStatement().executeUpdate("DELETE FROM User;");
            Database.conn.createStatement().executeUpdate("DELETE FROM Scroll;");
            Database.conn.createStatement().executeUpdate("DELETE FROM Daily_Scroll;");
            // method to reset auto-increment
            Database.conn.createStatement().executeUpdate("DELETE FROM sqlite_sequence WHERE name='Scroll';");
            Database.conn.close();
        }
    }

    /**
     * Tests the functionality of adding a new user into database.
     * Simulates user input to add a user and checks if the insertion is successful.
     */
    @Test
    public void testAddUserSuccessfully() {
        assertDoesNotThrow(() -> {
            Database.addUser("001", "John Doe", "password123", "user", "1234567890", "john@example.com");
        });

        HashMap<String, String> userInfo = Database.getUserInfoByUserID("001");

        assertEquals("John Doe", userInfo.get("username"));
        assertEquals("user", userInfo.get("role"));
        assertEquals("john@example.com", userInfo.get("email"));
    }

    /**
     * Tests the functionality of adding a user with duplicate ID into database.
     * Simulates user input to add a user with duplicate ID and checks if the insertion is failed with an IllegalArgumentException.
     */
    @Test
    public void testAddUserWithDuplicateUserID() {
        Database.addUser("001", "John Doe", "password123", "user", "1234567890", "john@example.com");

        // try to add a user with the same user_id, expecting an IllegalArgumentException
        assertThrows(IllegalArgumentException.class, () -> {
            Database.addUser("001", "Jane Smith", "password456", "admin", "0987654321", "jane@example.com");
        });
    }

    /**
     * Tests the functionality of adding a user with an empty user ID into database.
     * Simulates user input to add a user with an empty user ID and checks if the insertion is failed with an IllegalArgumentException.
     */
    @Test
    public void testAddUserWithEmptyUserID() {
        assertThrows(IllegalArgumentException.class, () -> {
            Database.addUser("", "Jane Smith", "password456", "admin", "0987654321", "jane@example.com");
        });
    }

    /**
     * Tests the functionality of adding a user with a null user ID into database.
     * Simulates user input to add a user with a null user ID and checks if the insertion is failed with an IllegalArgumentException.
     */
    @Test
    public void testAddUserWithNullUserID() {
        assertThrows(IllegalArgumentException.class, () -> {
            Database.addUser(null, "Jane Smith", "password456", "admin", "0987654321", "jane@example.com");
        });
    }

    /**
     * Tests the functionality of adding a user with an empty username into database.
     * Simulates user input to add a user with an empty username and checks if the insertion is failed with an IllegalArgumentException.
     */
    @Test
    public void testAddUserWithEmptyUsername() {
        assertThrows(IllegalArgumentException.class, () -> {
            Database.addUser("001", "", "password456", "admin", "0987654321", "jane@example.com");
        });
    }

    /**
     * Tests the functionality of adding a user with a null username into database.
     * Simulates user input to add a user with a null username and checks if the insertion is failed with an IllegalArgumentException.
     */
    @Test
    public void testAddUserWithNullUsername() {
        assertThrows(IllegalArgumentException.class, () -> {
            Database.addUser("001", null, "password456", "admin", "0987654321", "jane@example.com");
        });
    }

    /**
     * Tests the functionality of adding a user with an empty password into database.
     * Simulates user input to add a user with an empty password and checks if the insertion is failed with an IllegalArgumentException.
     */
    @Test
    public void testAddUserWithEmptyPassword() {
        assertThrows(IllegalArgumentException.class, () -> {
            Database.addUser("001", "Jane Smith", "", "admin", "0987654321", "jane@example.com");
        });
    }

    /**
     * Tests the functionality of adding a user with a null password into database.
     * Simulates user input to add a user with a null password and checks if the insertion is failed with an IllegalArgumentException.
     */
    @Test
    public void testAddUserWithNullPassword() {
        assertThrows(IllegalArgumentException.class, () -> {
            Database.addUser("001", "Jane Smith", null, "admin", "0987654321", "jane@example.com");
        });
    }

    /**
     * Tests the functionality of adding a user with an empty role into database.
     * Simulates user input to add a user with an empty role and checks if the insertion is failed with an IllegalArgumentException.
     */
    @Test
    public void testAddUserWithEmptyRole() {
        assertThrows(IllegalArgumentException.class, () -> {
            Database.addUser("001", "Jane Smith", "password456", "", "0987654321", "jane@example.com");
        });
    }

    /**
     * Tests the functionality of adding a user with a null role into database.
     * Simulates user input to add a user with a null role and checks if the insertion is failed with an IllegalArgumentException.
     */
    @Test
    public void testAddUserWithNullRole() {
        assertThrows(IllegalArgumentException.class, () -> {
            Database.addUser("001", "Jane Smith", "password456", null, "0987654321", "jane@example.com");
        });
    }

    /**
     * Tests the functionality of adding a user with ID into database.
     * Simulates user input to add a user with ID and checks if the insertion is successful.
     */
    @Test
    public void testGetUserInfoByUserIDSuccessfully() {
        Database.addUser("002", "Alice Smith", "securePass", "admin", "1122334455", "alice@example.com");

        // retrieve the user info
        HashMap<String, String> userInfo = Database.getUserInfoByUserID("002");

        assertEquals("Alice Smith", userInfo.get("username"));
        assertEquals("admin", userInfo.get("role"));
        assertEquals("alice@example.com", userInfo.get("email"));
    }

    /**
     * Tests the functionality of getting user information from database with an invalid ID.
     * Simulates user input to get user info with an invalid ID and checks if the retrieval is failed with an IllegalArgumentException.
     */
    @Test
    public void testGetUserInfoByInvalidUserID() {

        // attempt to retrieve user info for a non-existent user
        assertThrows(IllegalArgumentException.class, () -> {
            Database.getUserInfoByUserID("999");
        });
    }

    /**
     * Tests the functionality of getting user information from database with an empty ID.
     * Simulates user input to get user info with an empty ID and checks if the retrieval is failed with an IllegalArgumentException.
     */
    @Test
    public void testGetUserInfoByEmptyUserID() {

        // attempt to retrieve user info for a non-existent user
        assertThrows(IllegalArgumentException.class, () -> {
            Database.getUserInfoByUserID("");
        });
    }

    /**
     * Tests the functionality of getting user information from database with a null ID.
     * Simulates user input to get user info with a null ID and checks if the retrieval is failed with an IllegalArgumentException.
     */
    @Test
    public void testGetUserInfoByNullUserID() {

        // attempt to retrieve user info for a non-existent user
        assertThrows(IllegalArgumentException.class, () -> {
            Database.getUserInfoByUserID(null);
        });
    }

    /**
     * Tests the functionality of getting user information from database.
     * Simulates user input to get user info and checks if the retrieval is successful.
     */
    @Test
    public void testGetAllUserInfo() {
        Database.addUser("001", "John Doe", "password123", "user", "1234567890", "john@example.com");
        Database.addUser("002", "Jane Smith", "password456", "user", "0987654321", "jane@example.com");

        ArrayList<HashMap<String, String>> allUsers = Database.getAllUserInfo();

        // verify that the admin user is included
        boolean adminUserFound = false;
        for (HashMap<String, String> userInfo : allUsers) {
            if (userInfo.get("user_id").equals("admin")) {
                adminUserFound = true;
                assertEquals("admin", userInfo.get("username"));
                assertEquals("admin", userInfo.get("role"));
                assertEquals("", userInfo.get("phone_num"));
                assertEquals("", userInfo.get("email"));
            }
        }
        assertTrue(adminUserFound, "Admin user should be present in the database.");

        // verify the total number of users retrieved
        assertEquals(3, allUsers.size(), "There should be 3 users in total.");
    }

    /**
     * Tests the functionality of deleting a user information from database.
     * Simulates user input to delete a user and checks if the deletion is successful.
     */
    @Test
    public void testDeleteUserSuccessfully() {
        Database.addUser("003", "Bob Builder", "constructIt", "user", "9988776655", "bob@example.com");

        // ensure the user was added
        assertDoesNotThrow(() -> Database.getUserInfoByUserID("003"));

        // delete the user
        assertDoesNotThrow(() -> Database.deleteUserByUserID("003"));

        // verify the user no longer exists
        assertThrows(IllegalArgumentException.class, () -> {
            Database.getUserInfoByUserID("003");
        });
    }

    /**
     * Tests the functionality of deleting a user information with an invalid user ID from database.
     * Simulates user input to delete a user with an invalid user ID and checks if the deletion is failed with an IllegalArgumentException.
     */
    @Test
    public void testDeleteUserWithInvalidUserID() {

        // attempt to delete a user that doesn't exist
        assertThrows(IllegalArgumentException.class, () -> {
            Database.deleteUserByUserID("999");
        });
    }

    /**
     * Tests the functionality of updating a username into database.
     * Simulates user input to update a username and checks if the edition is successful.
     */
    @Test
    public void testUpdateUserNameSuccessfully() {
        Database.addUser("004", "Charlie Brown", "peanuts", "user", "1212121212", "charlie@example.com");

        // update the username
        assertDoesNotThrow(() -> {
            Database.updateUserName("004", "Charlie Updated");
        });

        // verify the updated username
        HashMap<String, String> userInfo = Database.getUserInfoByUserID("004");
        assertEquals("Charlie Updated", userInfo.get("username"));
    }

    /**
     * Tests the functionality of updating a username with an invalid user ID into database.
     * Simulates user input to update a username with an invalid user ID and checks if the edition is failed with an IllegalArgumentException.
     */
    @Test
    public void testUpdateUserNameWithInvalidUserID() {
        // attempt to update username for a non-existent user
        assertThrows(IllegalArgumentException.class, () -> {
            Database.updateUserName("999", "No User");
        });
    }

    /**
     * Tests the functionality of updating a username with an empty user ID into database.
     * Simulates user input to update a username with an empty user ID and checks if the edition is failed with an IllegalArgumentException.
     */
    @Test
    public void testUpdateUserNameWithEmptyUserID() {
        // attempt to update username for a non-existent user
        assertThrows(IllegalArgumentException.class, () -> {
            Database.updateUserName("", "No User");
        });
    }

    /**
     * Tests the functionality of updating a username with a null user ID into database.
     * Simulates user input to update a username with a null user ID and checks if the edition is failed with an IllegalArgumentException.
     */
    @Test
    public void testUpdateUserNameWithNullUserID() {
        // attempt to update username for a non-existent user
        assertThrows(IllegalArgumentException.class, () -> {
            Database.updateUserName(null, "No User");
        });
    }

    /**
     * Tests the functionality of updating a username with an empty username into database.
     * Simulates user input to update a username with an empty username and checks if the edition is failed with an IllegalArgumentException.
     */
    @Test
    public void testUpdateUserNameWithEmptyUsername() {
        // attempt to update username for a non-existent user
        Database.addUser("004", "Charlie Brown", "peanuts", "user", "1212121212", "charlie@example.com");

        assertThrows(IllegalArgumentException.class, () -> {
            Database.updateUserName("004", "");
        });
    }

    /**
     * Tests the functionality of updating a username with a null username into database.
     * Simulates user input to update a username with a null username and checks if the edition is failed with an IllegalArgumentException.
     */
    @Test
    public void testUpdateUserNameWithNullUsername() {
        // attempt to update username for a non-existent user
        Database.addUser("004", "Charlie Brown", "peanuts", "user", "1212121212", "charlie@example.com");

        assertThrows(IllegalArgumentException.class, () -> {
            Database.updateUserName("004", null);
        });
    }

    /**
     * Tests the functionality of updating a password into database.
     * Simulates user input to update a password and checks if the edition is successful.
     */
    @Test
    public void testUpdatePasswordSuccessfully() {
        Database.addUser("005", "Daisy Duck", "quack123", "admin", "1313131313", "daisy@example.com");

        // update the password
        assertDoesNotThrow(() -> {
            Database.updatePassword("005", "newQuack456");
        });

        HashMap<String, String> userInfo = Database.getUserInfoByUserID("005");
        assertTrue(BCrypt.checkpw("newQuack456", userInfo.get("password")));
    }

    /**
     * Tests the functionality of updating a password with an invalid user ID into database.
     * Simulates user input to update a password with an invalid user ID and checks if the edition is failed with an IllegalArgumentException.
     */
    @Test
    public void testUpdatePasswordWithInvalidUserID() {
        // attempt to update password for a non-existent user
        assertThrows(IllegalArgumentException.class, () -> {
            Database.updatePassword("999", "noPass");
        });
    }
    
    /**
     * Tests the functionality of updating a password with an empty user ID into database.
     * Simulates user input to update a password with an empty user ID and checks if the edition is failed with an IllegalArgumentException.
     */
    @Test
    public void testUpdatePasswordWithEmptyUserID() {
        // attempt to update password for a non-existent user
        assertThrows(IllegalArgumentException.class, () -> {
            Database.updatePassword("", "noPass");
        });
    }

     /**
     * Tests the functionality of updating a password with a null user ID into database.
     * Simulates user input to update a password with a null user ID and checks if the edition is failed with an IllegalArgumentException.
     */
    @Test
    public void testUpdatePasswordWithNullUserID() {
        // attempt to update password for a non-existent user
        assertThrows(IllegalArgumentException.class, () -> {
            Database.updatePassword(null, "noPass");
        });
    }

    /**
     * Tests the functionality of updating a password with an empty password into database.
     * Simulates user input to update a password with an empty password and checks if the edition is failed with an IllegalArgumentException.
     */
    @Test
    public void testUpdatePasswordWithEmptyPassword() {
        // attempt to update password for a non-existent user
        Database.addUser("005", "Daisy Duck", "quack123", "admin", "1313131313", "daisy@example.com");
        assertThrows(IllegalArgumentException.class, () -> {
            Database.updatePassword("005", "");
        });
    }

    /**
     * Tests the functionality of updating a password with a null password into database.
     * Simulates user input to update a password with a null password and checks if the edition is failed with an IllegalArgumentException.
     */
    @Test
    public void testUpdatePasswordWithNullPassword() {
        // attempt to update password for a non-existent user
        Database.addUser("005", "Daisy Duck", "quack123", "admin", "1313131313", "daisy@example.com");
        assertThrows(IllegalArgumentException.class, () -> {
            Database.updatePassword("005", null);
        });
    }

    /**
     * Tests the functionality of updating a phone number into database.
     * Simulates user input to update a phone number and checks if the edition is successful.
     */
    @Test
    public void testUpdatePhoneNumberSuccessfully() {
        Database.addUser("006", "Minnie Mouse", "minnie123", "user", "1414141414", "minnie@example.com");

        // update the phone number
        assertDoesNotThrow(() -> {
            Database.updatePhoneNumber("006", "5556667777");
        });

        // verify the updated phone number
        HashMap<String, String> userInfo = Database.getUserInfoByUserID("006");
        assertEquals("5556667777", userInfo.get("phone_num"));
    }

    /**
     * Tests the functionality of updating a phone number with an invalid user ID into database.
     * Simulates user input to update a phone number with an invalid user ID and checks if the edition is failed with an IllegalArgumentException.
     */
    @Test
    public void testUpdatePhoneNumberWithInvalidUserID() {
        // attempt to update email for a non-existent user
        assertThrows(IllegalArgumentException.class, () -> {
            Database.updatePhoneNumber("999", "5556667777");
        });
    }

    /**
     * Tests the functionality of updating a phone number with an empty user ID into database.
     * Simulates user input to update a phone number with an empty user ID and checks if the edition is failed with an IllegalArgumentException.
     */
    @Test
    public void testUpdatePhoneNumberWithEmptyUserID() {
        // attempt to update email for a non-existent user
        assertThrows(IllegalArgumentException.class, () -> {
            Database.updatePhoneNumber("", "5556667777");
        });
    }

    /**
     * Tests the functionality of updating a phone number with a null user ID into database.
     * Simulates user input to update a phone number with a null user ID and checks if the edition is failed with an IllegalArgumentException.
     */
    @Test
    public void testUpdatePhoneNumberWithNullUserID() {
        // attempt to update email for a non-existent user
        assertThrows(IllegalArgumentException.class, () -> {
            Database.updatePhoneNumber(null, "5556667777");
        });
    }

    /**
     * Tests the functionality of updating a phone number with an empty phone number into database.
     * Simulates user input to update a phone number with an empty phone number and checks if the edition is failed with an IllegalArgumentException.
     */
    @Test
    public void testUpdatePhoneNumberWithEmptyPhoneNumber() {
        Database.addUser("006", "Minnie Mouse", "minnie123", "user", "1414141414", "minnie@example.com");
        // attempt to update email for a non-existent user
        assertThrows(IllegalArgumentException.class, () -> {
            Database.updatePhoneNumber("006", "");
        });
    }

    /**
     * Tests the functionality of updating a phone number with a null phone number into database.
     * Simulates user input to update a phone number with a null phone number and checks if the edition is failed with an IllegalArgumentException.
     */
    @Test
    public void testUpdatePhoneNumberWithNullPhoneNumber() {
        Database.addUser("006", "Minnie Mouse", "minnie123", "user", "1414141414", "minnie@example.com");
        // attempt to update email for a non-existent user
        assertThrows(IllegalArgumentException.class, () -> {
            Database.updatePhoneNumber("006", null);
        });
    }

    /**
     * Tests the functionality of updating an email into database.
     * Simulates user input to update an email and checks if the edition is successful.
     */
    @Test
    public void testUpdateEmailSuccessfully() {
        Database.addUser("007", "Goofy", "goofy123", "user", "1515151515", "goofy@example.com");

        // update the email address
        assertDoesNotThrow(() -> {
            Database.updateEmail("007", "newgoofy@example.com");
        });

        // verify the updated email address
        HashMap<String, String> userInfo = Database.getUserInfoByUserID("007");
        assertEquals("newgoofy@example.com", userInfo.get("email"));
    }

    /**
     * Tests the functionality of updating an email with an invalid user ID into database.
     * Simulates user input to update an email with an invalid user ID and checks if the edition is failed with an IllegalArgumentException.
     */
    @Test
    public void testUpdateEmailWithInvalidUserID() {
        // attempt to update email for a non-existent user
        assertThrows(IllegalArgumentException.class, () -> {
            Database.updateEmail("999", "noemail@example.com");
        });
    }

    /**
     * Tests the functionality of updating an email with an empty user ID into database.
     * Simulates user input to update an email with an empty user ID and checks if the edition is failed with an IllegalArgumentException.
     */
    @Test
    public void testUpdateEmailWithEmptyUserID() {
        // attempt to update email for a non-existent user
        assertThrows(IllegalArgumentException.class, () -> {
            Database.updateEmail("", "noemail@example.com");
        });
    }

    /**
     * Tests the functionality of updating an email with a null user ID into database.
     * Simulates user input to update an email with a null user ID and checks if the edition is failed with an IllegalArgumentException.
     */
    @Test
    public void testUpdateEmailWithNullUserID() {
        // attempt to update email for a non-existent user
        assertThrows(IllegalArgumentException.class, () -> {
            Database.updateEmail(null, "noemail@example.com");
        });
    }

    /**
     * Tests the functionality of updating an email with an empty email into database.
     * Simulates user input to update an email with an empty email and checks if the edition is failed with an IllegalArgumentException.
     */
    @Test
    public void testUpdateEmailWithEmptyEmail() {
        // attempt to update email for a non-existent user
        Database.addUser("007", "Goofy", "goofy123", "user", "1515151515", "goofy@example.com");
        assertThrows(IllegalArgumentException.class, () -> {
            Database.updateEmail("007", "");
        });
    }

    
    /**
     * Tests the functionality of updating an email with a null email into database.
     * Simulates user input to update an email with a null email and checks if the edition is failed with an IllegalArgumentException.
     */
    @Test
    public void testUpdateEmailWithNullEmail() {
        // attempt to update email for a non-existent user
        Database.addUser("007", "Goofy", "goofy123", "user", "1515151515", "goofy@example.com");
        assertThrows(IllegalArgumentException.class, () -> {
            Database.updateEmail("007", null);
        });
    }

    /**
     * Tests the functionality of adding a scroll into database.
     * Simulates user and scroll input to add a scroll and checks if the insertion is successful.
     */
    @Test
    public void testAddScrollSuccessfully() {
        File file = new File("src/test/resources/testFile/testAddScrollSuccess.txt");
        byte[] binary_file = null;
        try {
            binary_file = Files.readAllBytes(file.toPath());
        } catch (IOException e) {
            e.printStackTrace();
        }
        Database.addUser("001", "John Doe", "password123", "user", "1234567890", "john@example.com");

        assertDoesNotThrow(() -> {
            Database.addScroll("123", file, "001");
        });

        // Dynamically find the latest scroll ID (assuming it's the highest ID after the insert)
        try {
            PreparedStatement stmt = Database.conn.prepareStatement("SELECT MAX(scroll_id) FROM Scroll;");
            ResultSet rs = stmt.executeQuery();
            rs.next();
            int latestScrollID = rs.getInt(1);
        } catch (IllegalArgumentException e) {
            throw e;

        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.");
        }

        HashMap<String, Object> scrollInfo = Database.getScrollInfoExceptContentByScrollID(1);

        assertEquals(1, scrollInfo.get("scroll_id"));
        assertEquals("123", scrollInfo.get("name"));
        assertEquals("001", scrollInfo.get("uploader"));
    }

    /**
     * Tests the functionality of adding a scroll with an empty name into database.
     * Simulates user and scroll input to add a scroll with an empty name and checks if the insertion is failed with IllegalArgumentException.
     */
    @Test
    public void testAddScrollWithEmptyName() {
        File file = new File("src/test/resources/testFile/testAddScrollSuccess.txt");
        assertThrows(IllegalArgumentException.class, () -> {
            Database.addScroll("", file, "001");
        });
    }

    /**
     * Tests the functionality of adding a scroll with a null name into database.
     * Simulates user and scroll input to add a scroll with a null name and checks if the insertion is failed with IllegalArgumentException.
     */
    @Test
    public void testAddScrollWithNullName() {
        File file = new File("src/test/resources/testFile/testAddScrollSuccess.txt");
        assertThrows(IllegalArgumentException.class, () -> {
            Database.addScroll(null, file, "001");
        });
    }

    /**
     * Tests the functionality of adding a scroll with a null file into database.
     * Simulates user and scroll input to add a scroll with a null file and checks if the insertion is failed with IllegalArgumentException.
     */
    @Test
    public void testAddScrollWithNullFile() {
        assertThrows(IllegalArgumentException.class, () -> {
            Database.addScroll("123", null, "001");
        });
    }

    /**
     * Tests the functionality of adding a scroll with a null uploader into database.
     * Simulates user and scroll input to add a scroll with a null uploader and checks if the insertion is failed with IllegalArgumentException.
     */
    @Test
    public void testAddScrollWithNullUploader() {
        File file = new File("src/test/resources/testFile/testAddScrollSuccess.txt");
        assertThrows(IllegalArgumentException.class, () -> {
            Database.addScroll("123", file, null);
        });
    }

    /**
     * Tests the functionality of adding a scroll with an empty uploader into database.
     * Simulates user and scroll input to add a scroll with an empty uploader and checks if the insertion is failed with IllegalArgumentException.
     */
    @Test
    public void testAddScrollWithEmptyUploader() {
        File file = new File("src/test/resources/testFile/testAddScrollSuccess.txt");
        assertThrows(IllegalArgumentException.class, () -> {
            Database.addScroll("123", file, "");
        });
    }

    /**
     * Tests the functionality of adding a scroll with a duplicate name into database.
     * Simulates user and scroll input to add a scroll with a duplicate name and checks if the insertion is failed with an IllegalArgumentException.
     */
    @Test
    public void testAddScrollWithDuplicateName(){
        File file = new File("src/test/resources/testFile/testSQLException.txt");
        Database.addUser("001", "John Doe", "password123", "user", "1234567890", "john@example.com");
        Database.addScroll("ABC", file, "001");

        assertThrows(IllegalArgumentException.class, () -> {
            Database.addScroll("ABC", file, "001");
        });
    }

    /**
     * Tests the functionality of previewing a scroll content from database.
     * Simulates user and scroll input to preview a scroll content and checks if the previewing is successful.
     */
    @Test
    public void testPreviewScrollTxtSuccessfully() {
        File file = new File("src/test/resources/testFile/testAddScrollSuccess.txt");

        byte[] binary_file = null;
        try {
            binary_file = Files.readAllBytes(file.toPath());
        } catch (IOException e) {
            e.printStackTrace();
            fail("Failed to read the test file.");
        }

        // Add a user to the database for the uploader reference
        Database.addUser("001", "John Doe", "password123", "user", "1234567890", "john@example.com");

        // Ensure the scroll is added without any exceptions
        assertDoesNotThrow(() -> {
            Database.addScroll("123", file, "001");
        });

        // Test retrieving the preview for the added scroll
        String preview = assertDoesNotThrow(() -> Database.getScrollPreview(1));

        String expectedPreview = "ABCDEFG";

        assertEquals(expectedPreview, preview);
    }

    /**
     * Tests the functionality of previewing a scroll content not existed from database.
     * Simulates user and scroll input to preview a scroll content not existed and checks if the previewing is successful.
     */
    @Test
    public void testPreviewScrollNotFound() {
        assertThrows(IllegalArgumentException.class, () -> {
            Database.getScrollPreview(1);
        });
    }

    /**
     * Tests the functionality of previewing a scroll content with a long text file from database.
     * Simulates user and scroll input to preview a scroll content with a long text file and checks if the previewing is successful.
     */
    @Test
    public void testPreviewScrollTxtLongFile() {
        File file = new File("src/test/resources/testFile/testLongFile.txt");

        byte[] binary_file = null;
        try {
            binary_file = Files.readAllBytes(file.toPath());
        } catch (IOException e) {
            e.printStackTrace();
            fail("Failed to read the test file.");
        }

        // Add a user to the database for the uploader reference
        Database.addUser("001", "John Doe", "password123", "user", "1234567890", "john@example.com");

        // Ensure the scroll is added without any exceptions
        assertDoesNotThrow(() -> {
            Database.addScroll("123", file, "001");
        });

        // Test retrieving the preview for the added scroll
        String preview = assertDoesNotThrow(() -> Database.getScrollPreview(1));

        String expectedPreview = "This is a very very very very very very very very very very very very very very very very very very very very very very very very very very very...";

        assertEquals(expectedPreview, preview);
    }

    /**
     * Tests the functionality of previewing a scroll content with a pdf file from database.
     * Simulates user and scroll input to preview a scroll content with a pdf file and checks if the previewing is failed with error message.
     */
    // @Test
    // public void testPreviewScrollPdf() {
    //     File file = new File("src/test/resources/testFile/testPdfFile.pdf");

    //     byte[] binary_file = null;
    //     try {
    //         binary_file = Files.readAllBytes(file.toPath());
    //     } catch (IOException e) {
    //         e.printStackTrace();
    //         fail("Failed to read the test file.");
    //     }

    //     // Add a user to the database for the uploader reference
    //     Database.addUser("001", "John Doe", "password123", "user", "1234567890", "john@example.com");

    //     // Ensure the scroll is added without any exceptions
    //     assertDoesNotThrow(() -> {
    //         Database.addScroll("123", file, "001");
    //     });

    //     // Test retrieving the preview for the added scroll
    //     String preview = assertDoesNotThrow(() -> Database.getScrollPreview(1));

    //     String expectedPreview = "The preview of this document is unavailable, please download the scroll to view it.";

    //     assertEquals(expectedPreview, preview);
    // }

    /**
     * Tests the functionality of getting a scroll content with given scroll ID from database.
     * Simulates user and scroll input to preview a scroll content with given scroll ID and checks if the retrieval is successful.
     */
    @Test
    public void testGetScrollContentSuccessfully(){
        File file = new File("src/test/resources/testFile/testAddScrollSuccess.txt");
        // convert file to binary file format byte[]
        byte[] binary_file = null;
        try {
            binary_file = Files.readAllBytes(file.toPath());
        } catch (IOException e) {
            e.printStackTrace();
        }

        Database.addUser("001", "John Doe", "password123", "user", "1234567890", "john@example.com");
        assertDoesNotThrow(() -> {
            Database.addScroll("123", file, "001");
        });

        // Dynamically find the latest scroll ID (assuming it's the highest ID after the insert)
        try {
            PreparedStatement stmt = Database.conn.prepareStatement("SELECT MAX(scroll_id) FROM Scroll;");
            ResultSet rs = stmt.executeQuery();
            rs.next();
            int latestScrollID = rs.getInt(1);
        } catch (IllegalArgumentException e) {
            throw e;
        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.");
        }

        // Use assertArrayEquals to compare byte arrays
        assertArrayEquals(binary_file, Database.getScrollContent(1));
    }

    /**
     * Tests the functionality of getting all scroll information from database.
     * Simulates user and scroll input to get all scroll information and checks if the retrieval is successful.
     */
    @Test
    public void testGetAllScrollInfoSuccessfully(){
        File file = new File("src/test/resources/testFile/testAddScrollSuccess.txt");

        Database.addUser("001", "John Doe", "password123", "user", "1234567890", "john@example.com");
        assertDoesNotThrow(() -> {
            Database.addScroll("123", file, "001");
            Database.addScroll("456", file, "001");
        });

        // start to retrieve scroll info
        ArrayList<HashMap<String, Object>> allScrolls = Database.getAllScrollInfo();
        HashMap<String, Object> firstScroll = allScrolls.get(0);
        assertEquals(firstScroll.get("name"), "123");
        assertEquals(firstScroll.get("uploader"), "001");
        assertEquals(firstScroll.get("file_type"), 1);
        assertEquals(firstScroll.get("download_counter"), 0);
        assertEquals(firstScroll.get("upload_counter"), 1);

        HashMap<String, Object> secondScroll = allScrolls.get(1);
        assertEquals(secondScroll.get("name"), "456");
        assertEquals(secondScroll.get("uploader"), "001");
        assertEquals(firstScroll.get("file_type"), 1);
        assertEquals(firstScroll.get("download_counter"), 0);
        assertEquals(firstScroll.get("upload_counter"), 1);

    }

    /**
     * Tests the functionality of deleting a scroll from database.
     * Simulates user and scroll input to delete a scroll and checks if the deletion is successful.
     */
    @Test
    public void testDeleteScrollSuccessfully(){
        File file = new File("src/test/resources/testFile/testAddScrollSuccess.txt");
        // convert file to binary file format byte[]
        byte[] binary_file = null;
        try {
            binary_file = Files.readAllBytes(file.toPath());
        } catch (IOException e) {
            e.printStackTrace();
        }

        Database.addUser("001", "John Doe", "password123", "user", "1234567890", "john@example.com");
        assertDoesNotThrow(() -> {
            Database.addScroll("123", file, "001");
        });

        Database.deleteScroll(1);

        // Check that the Scroll table is empty
        int scrollCount = 0;

        // Dynamically find the latest scroll ID (assuming it's the highest ID after the insert)
        try {
            PreparedStatement stmt = Database.conn.prepareStatement("SELECT MAX(scroll_id) FROM Scroll;");
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                scrollCount = rs.getInt(1); // get the count of rows in the Scroll table
            }
        } catch (IllegalArgumentException e) {
            throw e;
        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.");
        }
        // assert that the scroll count is 0
        assertTrue(scrollCount == 0);
    }

    /**
     * Tests the functionality of deleting a scroll not existed from database.
     * Simulates user and scroll input to delete a scroll not existed and checks if the deletion is failed with IllegalArgumentException.
     */
    @Test
    public void testDeleteScrollNoFound(){
        assertThrows(IllegalArgumentException.class, () -> {
            Database.deleteScroll(1);
        });
    }

    /**
     * Tests the functionality of updating a scroll with the new content file from database.
     * Simulates user and scroll input to update a scroll with the new content file and checks if the edition is successful.
     */
    @Test
    public void testUpdateScrollSuccessfully(){
        File file = new File("src/test/resources/testFile/testAddScrollSuccess.txt");

        Database.addUser("001", "John Doe", "password123", "user", "1234567890", "john@example.com");
        assertDoesNotThrow(() -> {
            Database.addScroll("123", file, "001");
        });

        File new_file = new File("src/test/resources/testFile/testUpdateScrollSuccess.txt");

        // Dynamically find the latest scroll ID (assuming it's the highest ID after the insert)
        try {
            PreparedStatement stmt = Database.conn.prepareStatement("SELECT MAX(scroll_id) FROM Scroll;");
            ResultSet rs = stmt.executeQuery();
            rs.next();
            int latestScrollID = rs.getInt(1);
        } catch (IllegalArgumentException e) {
            throw e;
        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.");
        }

        // new file update
        Database.updateScroll(new_file, 1);

        // convert file to binary file format byte[]
        byte[] binary_file = null;
        try {
            binary_file = Files.readAllBytes(new_file.toPath());
        } catch (IOException e) {
            e.printStackTrace();
        }

        assertArrayEquals(binary_file, Database.getScrollContent(1));
    }

    /**
     * Tests the functionality of updating a scroll with a none readable file from database.
     * Simulates user and scroll input to update a scroll with a none readable file and checks if the edition is successful.
     * Edge testcase for updateScroll
     */
    // @Test
    // public void testUpdateScrollFileNotReadable() {
    //     File file = new File("src/test/resources/testFile/testAddScrollSuccess.txt");

    //     Database.addUser("001", "John Doe", "password123", "user", "1234567890", "john@example.com");
    //     assertDoesNotThrow(() -> {
    //         Database.addScroll("123", file, "001");
    //     });

    //     File new_file = new File("src/test/resources/testFile/testPdfFile.pdf");

    //     // Dynamically find the latest scroll ID (assuming it's the highest ID after the insert)
    //     try {
    //         PreparedStatement stmt = Database.conn.prepareStatement("SELECT MAX(scroll_id) FROM Scroll;");
    //         ResultSet rs = stmt.executeQuery();
    //         rs.next();
    //         int latestScrollID = rs.getInt(1);
    //     } catch (IllegalArgumentException e) {
    //         throw e;
    //     } catch (Exception e) {
    //         throw new IllegalStateException("Unexpected error occurred.");
    //     }
    //     new_file.setReadable(false);
    //     // new file update
    //     Database.updateScroll(new_file, 1);
    //     HashMap<String, Object> scrollInfo = Database.getScrollInfoExceptContentByScrollID(1);
    //     assertEquals(scrollInfo.get("file_type"), 0);
    //     assertFalse(Database.checkReadable(new_file.getName().toLowerCase()));
    // }

    /**
     * Tests the functionality of getting a scroll information with the given scroll ID from database.
     * Simulates user and scroll input to get a scroll information with the given scroll ID and checks if the retrieval is successful.
     */
    @Test
    public void testGetScrollInfoExceptContentByScrollIDSuccessfully(){
        File file = new File("src/test/resources/testFile/testAddScrollSuccess.txt");

        Database.addUser("001", "John Doe", "password123", "user", "1234567890", "john@example.com");
        assertDoesNotThrow(() -> {
            Database.addScroll("123", file, "001");
        });

        // Dynamically find the latest scroll ID (assuming it's the highest ID after the insert)
        try {
            PreparedStatement stmt = Database.conn.prepareStatement("SELECT MAX(scroll_id) FROM Scroll;");
            ResultSet rs = stmt.executeQuery();
            rs.next();
            int latestScrollID = rs.getInt(1);
        } catch (IllegalArgumentException e) {
            throw e;
        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.");
        }

        HashMap<String, Object> scrollInfo = Database.getScrollInfoExceptContentByScrollID(1);
        assertEquals(scrollInfo.get("scroll_id"), 1);
        assertEquals(scrollInfo.get("name"), "123");
        assertEquals(scrollInfo.get("uploader"), "001");
    }

    /**
     * Tests the functionality of getting all scroll information with the given user ID from database.
     * Simulates user and scroll input to get all scroll information with the given user ID and checks if the retrieval is successful.
     */
    @Test
    public void testGetAllScrollByIDSuccessfully(){
        File file = new File("src/test/resources/testFile/testAddScrollSuccess.txt");

        // convert file to binary file format byte[]
        byte[] binary_file = null;
        try {
            binary_file = Files.readAllBytes(file.toPath());
        } catch (IOException e) {
            e.printStackTrace();
        }

        Database.addUser("001", "John Doe", "password123", "user", "1234567890", "john@example.com");
        assertDoesNotThrow(() -> {
            Database.addScroll("123", file, "001");
            Database.addScroll("456", file, "001");
        });

        ArrayList<HashMap<String, Object>> allScrollByID = Database.getAllScrollByID("001");
        HashMap<String, Object> firstScroll = allScrollByID.get(0);
        assertEquals(firstScroll.get("name"), "123");
        // Cast to byte[]
        assertArrayEquals((byte[])firstScroll.get("content"), binary_file);
        assertEquals(firstScroll.get("uploader"), "001");

        HashMap<String, Object> secondScroll = allScrollByID.get(1);
        assertEquals(secondScroll.get("name"), "456");
        // Cast to byte[]
        assertArrayEquals((byte[])secondScroll.get("content"), binary_file);
        assertEquals(secondScroll.get("uploader"), "001");
    }

    /**
     * Tests the functionality of getting the scroll information with the given scroll name from database.
     * Simulates user and scroll input to get the scroll information with the given scroll name and checks if the retrieval is successful.
     */
    @Test
    public void testGetScrollInfoByNameSuccessfully(){
        File file = new File("src/test/resources/testFile/testAddScrollSuccess.txt");

        Database.addUser("001", "John Doe", "password123", "user", "1234567890", "john@example.com");
        assertDoesNotThrow(() -> {
            Database.addScroll("123", file, "001");
        });

        // Dynamically find the latest scroll ID (assuming it's the highest ID after the insert)
        try {
            PreparedStatement stmt = Database.conn.prepareStatement("SELECT MAX(scroll_id) FROM Scroll;");
            ResultSet rs = stmt.executeQuery();
            rs.next();
            int latestScrollID = rs.getInt(1);
        } catch (IllegalArgumentException e) {
            throw e;
        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.");
        }

        HashMap<String, Object> scrollInfo = Database.getScrollInfoByName("123");
        assertEquals(scrollInfo.get("scroll_id"), 1);
        assertEquals(scrollInfo.get("name"), "123");
        assertEquals(scrollInfo.get("uploader"), "001");
    }

    /**
     * Tests the functionality of searching the scroll information with the given time range from database.
     * Simulates user and scroll input to search the scroll information with the given time range and checks if the retrieval is successful.
     */
    @Test
    public void testGetScrollInfoByTimeRangeSuccessfully() {
        File file = new File("src/test/resources/testFile/testAddScrollSuccess.txt");
        Database.addUser("001", "John Doe", "password123", "user", "1234567890", "john@example.com");

        // Add the scroll and get its exact timestamp
        assertDoesNotThrow(() -> {
            Database.addScroll("123", file, "001");
        });

        // Dynamically find the latest scroll ID
        int latestScrollID = -1;
        try {
            PreparedStatement stmt = Database.conn.prepareStatement("SELECT MAX(scroll_id) FROM Scroll;");
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                latestScrollID = rs.getInt(1);
            }
            rs.close();
            stmt.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }

        Date endTime = new Date(System.currentTimeMillis());
        Date startTime = new Date(endTime.getTime() - 24 * 60 * 60 * 1000);

        ArrayList<HashMap<String, Object>> allScrolls = Database.searchScrollByTimeRange(startTime, endTime);
        HashMap<String, Object> scrollInfo = allScrolls.get(0);
        assertNotNull(scrollInfo);
        assertEquals(latestScrollID, scrollInfo.get("scroll_id"));
        assertEquals("123", scrollInfo.get("name"));
        assertEquals("001", scrollInfo.get("uploader"));
    }

    /**
     * Tests the functionality of updating the Upload Counter of the scroll from database.
     * Simulates user and scroll input to update the Upload Counter of the scroll and checks if the increment is successful.
     */
    @Test
    public void testUpdateUploadCounterSuccessfully(){
        File file = new File("src/test/resources/testFile/testAddScrollSuccess.txt");

        Database.addUser("001", "John Doe", "password123", "user", "1234567890", "john@example.com");
        assertDoesNotThrow(() -> {
            Database.addScroll("123", file, "001");
        });

        // Dynamically find the latest scroll ID (assuming it's the highest ID after the insert)
        try {
            PreparedStatement stmt = Database.conn.prepareStatement("SELECT MAX(scroll_id) FROM Scroll;");
            ResultSet rs = stmt.executeQuery();
            rs.next();
            int latestScrollID = rs.getInt(1);
        } catch (IllegalArgumentException e) {
            throw e;
        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.");
        }
        Database.updateUploadCounter(1);
    }

    /**
     * Tests the functionality of updating the Download Counter of the scroll from database.
     * Simulates user and scroll input to update the Download Counter of the scroll and checks if the increment is successful.
     */
    @Test
    public void testUpdateDownloadCounterSuccessfully(){
        File file = new File("src/test/resources/testFile/testAddScrollSuccess.txt");

        Database.addUser("001", "John Doe", "password123", "user", "1234567890", "john@example.com");
        assertDoesNotThrow(() -> {
            Database.addScroll("123", file, "001");
        });

        // Dynamically find the latest scroll ID (assuming it's the highest ID after the insert)
        try {
            PreparedStatement stmt = Database.conn.prepareStatement("SELECT MAX(scroll_id) FROM Scroll;");
            ResultSet rs = stmt.executeQuery();
            rs.next();
            int latestScrollID = rs.getInt(1);
        } catch (IllegalArgumentException e) {
            throw e;
        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.");
        }
        Database.updateDownloadCounter(1);
    }

    /**
     * Tests the functionality of searching the scroll information with the given uploader from database.
     * Simulates user and scroll input to search the scroll information with the given uploader and checks if the retrieval is successful.
     */
    @Test
    public void testSearchScrollByUploaderSuccessfully(){
        File file = new File("src/test/resources/testFile/testAddScrollSuccess.txt");

        Database.addUser("001", "John Doe", "password123", "user", "1234567890", "john@example.com");
        assertDoesNotThrow(() -> {
            Database.addScroll("123", file, "001");
            Database.addScroll("456", file, "001");
        });

        // Dynamically find the latest scroll ID (assuming it's the highest ID after the insert)
        try {
            PreparedStatement stmt = Database.conn.prepareStatement("SELECT MAX(scroll_id) FROM Scroll;");
            ResultSet rs = stmt.executeQuery();
            rs.next();
            int latestScrollID = rs.getInt(1);
        } catch (IllegalArgumentException e) {
            throw e;
        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.");
        }

        ArrayList<HashMap<String, Object>> allScrolls = Database.searchScrollByUploader("1");
        HashMap<String, Object> firstScroll = allScrolls.get(0);
        assertEquals(firstScroll.get("name"), "123");
        assertEquals(firstScroll.get("uploader"), "001");

        HashMap<String, Object> secondScroll = allScrolls.get(1);
        assertEquals(secondScroll.get("name"), "456");
        assertEquals(secondScroll.get("uploader"), "001");
    }

    /**
     * Tests the functionality of searching the scroll information with the given scroll name from database.
     * Simulates user and scroll input to search the scroll information with the given scroll name and checks if the retrieval is successful.
     */
    @Test
    public void testSearchScrollByNameSuccessfully(){
        File file = new File("src/test/resources/testFile/testAddScrollSuccess.txt");

        Database.addUser("001", "John Doe", "password123", "user", "1234567890", "john@example.com");
        assertDoesNotThrow(() -> {
            Database.addScroll("123", file, "001");
        });

        // Dynamically find the latest scroll ID (assuming it's the highest ID after the insert)
        try {
            PreparedStatement stmt = Database.conn.prepareStatement("SELECT MAX(scroll_id) FROM Scroll;");
            ResultSet rs = stmt.executeQuery();
            rs.next();
            int latestScrollID = rs.getInt(1);
        } catch (IllegalArgumentException e) {
            throw e;
        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.");
        }

        ArrayList<HashMap<String, Object>> allScrolls = Database.searchScrollByName("1");
        HashMap<String, Object> firstScroll = allScrolls.get(0);
        assertEquals(firstScroll.get("name"), "123");
        assertEquals(firstScroll.get("uploader"), "001");

    }

    /**
     * Tests the functionality of adding the daily scroll information into database.
     * Simulates user and scroll input to add the daily scroll information and checks if the insertion is successful.
     */
    @Test
    public void testAddDailyScrollAndGetScrollIDOfTheDaySuccessfully(){
        File file = new File("src/test/resources/testFile/testAddScrollSuccess.txt");

        Database.addUser("001", "John Doe", "password123", "user", "1234567890", "john@example.com");
        Database.addScroll("123", file, "001");
        assertDoesNotThrow(() -> {
            Database.addDailyScroll(new Date(System.currentTimeMillis()), 1);
        });

        try {
            PreparedStatement stmt = Database.conn.prepareStatement("SELECT MAX(scroll_id) FROM Scroll;");
            ResultSet rs = stmt.executeQuery();
            rs.next();
            int latestScrollID = rs.getInt(1);
        } catch (IllegalArgumentException e) {
            throw e;
        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.");
        }
        // Get the current date as java.sql.Date for querying (without time component)
        java.sql.Date currentDate = new java.sql.Date(System.currentTimeMillis());

        assertDoesNotThrow(() -> {
            int scroll_id = Database.getScrollIDOfTheDay(new Date(System.currentTimeMillis()));
            assertEquals(scroll_id, 1);
        });
    }

    /**
     * Tests the functionality of adding the duplicate date daily scroll information into database.
     * Simulates user and scroll input to add the duplicate date daily scroll information and checks if the insertion is fail with IllegalArgumentException.
     */
    @Test
    public void testAddDailyScrollWithDuplicateDate(){
        File file = new File("src/test/resources/testFile/testAddScrollSuccess.txt");

        Database.addUser("001", "John Doe", "password123", "user", "1234567890", "john@example.com");
        Database.addScroll("123", file, "001");

        String dateString = "2024-10-22";
        SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
        try{
            Date date = formatter.parse(dateString);
            assertDoesNotThrow(() -> {
                Database.addDailyScroll(date, 1);
            });
            assertThrows(IllegalArgumentException.class, () -> {
                Database.addDailyScroll(date, 1);
            });
        } catch (ParseException e) {
            fail("Date parsing failed: " + e.getMessage());
        }
    }

    /**
     * Tests the functionality of getting the scroll statistics from database.
     * Simulates user and scroll input to get the scroll statistics and checks if the retrieval is successful.
     */
    @Test
    public void testGetScrollStatisticsSuccessfully(){
        File file = new File("src/test/resources/testFile/testAddScrollSuccess.txt");

        Database.addUser("001", "John Doe", "password123", "user", "1234567890", "john@example.com");
        assertDoesNotThrow(() -> {
            Database.addScroll("123", file, "001");
        });

        // Dynamically find the latest scroll ID (assuming it's the highest ID after the insert)
        try {
            PreparedStatement stmt = Database.conn.prepareStatement("SELECT MAX(scroll_id) FROM Scroll;");
            ResultSet rs = stmt.executeQuery();
            rs.next();
            int latestScrollID = rs.getInt(1);
        } catch (IllegalArgumentException e) {
            throw e;
        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.");
        }

        ArrayList<HashMap<String, Object>> allScrolls = Database.getScrollStatistics();
        HashMap<String, Object> firstScroll = allScrolls.get(0);
        assertEquals(firstScroll.get("scroll_id"), 1);
        assertEquals(firstScroll.get("download_counter"), 0);
        assertEquals(firstScroll.get("upload_counter"), 1);
    }

    /**
     * Tests the functionality of getting all text scroll information from database.
     * Simulates user and scroll input to get all text scroll information and checks if the retrieval is successful.
     */
    @Test
    public void testGetAllTextScrollsSuccessfully() throws SQLException {
        File file = new File("src/test/resources/testFile/testAddScrollSuccess.txt");

        Database.addUser("001", "John Doe", "password123", "user", "1234567890", "john@example.com");
        assertDoesNotThrow(() -> {
            Database.addScroll("123", file, "001");
            Database.addScroll("345", file, "001");
        });

        // Dynamically find the latest scroll ID (assuming it's the highest ID after the insert)
        try {
            PreparedStatement stmt = Database.conn.prepareStatement("SELECT MAX(scroll_id) FROM Scroll;");
            ResultSet rs = stmt.executeQuery();
            rs.next();
            int latestScrollID = rs.getInt(1);
        } catch (IllegalArgumentException e) {
            throw e;
        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.");
        }

        ArrayList<HashMap<String, Object>> allTextScrolls = Database.getAllTextScrolls();
        HashMap<String, Object> firstScroll = allTextScrolls.get(0);
        assertEquals(firstScroll.get("scroll_id"), 1);
        assertEquals(firstScroll.get("name"), "123");
        HashMap<String, Object> secondScroll = allTextScrolls.get(1);
        assertEquals(secondScroll.get("scroll_id"), 2);
        assertEquals(secondScroll.get("name"), "345");
    }

    /**
     * Tests the functionality of detecting the scroll is updated by the given user ID from database.
     * Simulates user and scroll input to detect the scroll is updated by the given user ID and checks if the detection is successful.
     */
    @Test
    public void testIsUserScrollSuccessfully() {
        File file = new File("src/test/resources/testFile/testAddScrollSuccess.txt");

        Database.addUser("001", "John Doe", "password123", "user", "1234567890", "john@example.com");
        assertDoesNotThrow(() -> {
            Database.addScroll("123", file, "001");
        });

        // Dynamically find the latest scroll ID (assuming it's the highest ID after the insert)
        try {
            PreparedStatement stmt = Database.conn.prepareStatement("SELECT MAX(scroll_id) FROM Scroll;");
            ResultSet rs = stmt.executeQuery();
            rs.next();
            int latestScrollID = rs.getInt(1);
        } catch (IllegalArgumentException e) {
            throw e;
        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.");
        }

        boolean scrollExists = Database.isUserScroll("001", 1);
        assertTrue(scrollExists);
    }

}
