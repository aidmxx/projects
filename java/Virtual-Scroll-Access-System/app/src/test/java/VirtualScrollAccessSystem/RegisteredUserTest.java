package VirtualScrollAccessSystem;

import org.junit.jupiter.api.*;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.lang.reflect.Method;
import java.sql.*;
import static org.junit.jupiter.api.Assertions.*;

import java.util.HashMap;
import java.util.Scanner;
import org.junit.jupiter.api.Test;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.sql.SQLException;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import static org.mockito.Mockito.*;

import org.mindrot.jbcrypt.BCrypt;
import org.mockito.Mockito;


import org.junit.jupiter.api.BeforeAll;


public class RegisteredUserTest {
    private static Connection conn;
    private RegisteredUser registeredUser;

    @BeforeAll
    public static void setupDatabase() throws SQLException {
        conn = DriverManager.getConnection("jdbc:sqlite::memory:");
        Database.conn = conn;
        Statement stmt = conn.createStatement();

        String createUserTable = "CREATE TABLE User (" +
                "user_id TEXT PRIMARY KEY," +
                "username TEXT," +
                "password TEXT," +
                "role TEXT," +
                "phone_num TEXT," +
                "email TEXT" +
                ");";
        stmt.execute(createUserTable);
    }

    @BeforeEach
    public void resetDatabase() throws SQLException {
        Statement stmt = conn.createStatement();
        stmt.execute("DELETE FROM User;");
        registeredUser = new RegisteredUser("testUserID");
    }

    @AfterAll
    public static void teardownDatabase() throws SQLException {
        if (conn != null) {
            conn.close();
        }
    }

    /**
     * Tests the functionality of registering a new user.
     * Simulates user input to register a user and checks if the registration is successful.
     */
    @Test
    void testRegistration() {
        Scanner scanner = new Scanner("0412345678\nuser@example.com\nJohn Doe\njohndoe\ntestUserID\npassword\n");
        RegisteredUser.scan = scanner;

        boolean result = RegisteredUser.registration();
        assertTrue(result, "The registration should be successful");
    }

    /**
     * Tests the functionality of canceling the registration.
     * Simulates user input to cancel the registration and checks if the registration is canceled.
     */
    @Test
    void testRegistrationExit() {
        Scanner scanner = new Scanner("Q\n");
        RegisteredUser.scan = scanner;
        boolean result = RegisteredUser.registration();
        assertFalse(result, "The registration should be cancelled by the user");
    }

    /**
     * Tests the functionality of canceling the registration at the phone number stage.
     * Simulates user input to cancel the registration and checks if the registration is canceled.
     */
    @Test
    void testRegistrationExitAtPhoneNumber() {
        Scanner scanner = new Scanner("Q\n");
        RegisteredUser.scan = scanner;

        boolean result = RegisteredUser.registration();
        assertFalse(result, "The registration should be cancelled by the user at phone number stage");
    }

    /**
     * Tests the functionality of canceling the registration at the email stage.
     * Simulates user input to cancel the registration and checks if the registration is canceled.
     */
    @Test
    void testRegistrationExitAtEmail() {
        Scanner scanner = new Scanner("0412345678\nQ\n");
        RegisteredUser.scan = scanner;

        boolean result = RegisteredUser.registration();
        assertFalse(result, "The registration should be cancelled by the user at email stage");
    }

    /**
     * Tests the functionality of canceling the registration at the full name stage.
     * Simulates user input to cancel the registration and checks if the registration is canceled.
     */
    @Test
    void testRegistrationExitAtFullName() {
        Scanner scanner = new Scanner("0412345678\ns@test.com\nQ\n");
        RegisteredUser.scan = scanner;

        boolean result = RegisteredUser.registration();
        assertFalse(result, "The registration should be cancelled by the user at full name stage");
    }

    /**
     * Tests the functionality of entering an invalid email during registration.
     * Simulates user input of an invalid email and checks if the appropriate error message is displayed.
     */
    @Test
    void testRegistrationInvalidEmail() {
        Scanner scanner = new Scanner("0412345678\nsss|@test.com\nQ\n");
        RegisteredUser.scan = scanner;

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outputStream));
        boolean result = RegisteredUser.registration();
        System.setOut(System.out);
        String output = outputStream.toString();
        assertTrue(output.contains("Invalid email address. Please enter a valid email."), "The output should be 'Invalid email address. Please enter a valid email.'");
    }

    /**
     * Tests the functionality of canceling the registration at the username stage.
     * Simulates user input to cancel the registration and checks if the registration is canceled.
     */
    @Test
    void testRegistrationExitAtUserName() {
        Scanner scanner = new Scanner("0412345678\nuser@example.com\nJohn Doe\nQ\n");
        RegisteredUser.scan = scanner;

        boolean result = RegisteredUser.registration();
        assertFalse(result, "The registration should be cancelled by the user at username stage");
    }

    /**
     * Tests the functionality of canceling the registration at the userID stage.
     * Simulates user input to cancel the registration and checks if the registration is canceled.
     */
    @Test
    void testRegistrationExitAtUserID() {
        Scanner scanner = new Scanner("0412345678\nuser@example.com\nJohn Doe\njohndoe\nQ\n");
        RegisteredUser.scan = scanner;

        boolean result = RegisteredUser.registration();
        assertFalse(result, "The registration should be cancelled by the user at userID stage");
    }

    /**
     * Tests the functionality of checking if a userID already exists in the database.
     * Inserts a user with a specific userID and verifies if the checkUserIDExists method correctly identifies it.
     */
    @Test
    public void testCheckUserIDExists() throws Exception {
        Statement stmt = conn.createStatement();
        String insertUserSQL = "INSERT INTO User (user_id, username, password, role, phone_num, email) VALUES (" +
                "'existingUserID', 'user1', 'password', 'user', '12345678', 'user@test.com');";
        stmt.execute(insertUserSQL);

        Method method = RegisteredUser.class.getDeclaredMethod("checkUserIDExists", String.class);
        method.setAccessible(true);

        boolean userExists = (boolean) method.invoke(null, "existingUserID");
        boolean userDoesNotExist = (boolean) method.invoke(null, "nonExistingUserID");

        assertTrue(userExists);
        assertFalse(userDoesNotExist);
    }

    /**
     * Tests the functionality of checking if a userID does not exist in the database.
     * Inserts a user with a specific userID and verifies if the checkUserIDExists method correctly identifies non-existing userIDs.
     */
    @Test
    public void testCheckUserIDNotExists() throws Exception {
        Statement stmt = conn.createStatement();
        String insertUserSQL = "INSERT INTO User (user_id, username, password, role, phone_num, email) VALUES (" +
                "'existingUserID', 'user1', 'password', 'user', '12345678', 'user@test.com');";
        stmt.execute(insertUserSQL);

        Method method = RegisteredUser.class.getDeclaredMethod("checkUserIDExists", String.class);
        method.setAccessible(true);

        boolean userExists = (boolean) method.invoke(null, "existingUserID");
        boolean userDoesNotExist = (boolean) method.invoke(null, "nonExistingUserID");

        assertTrue(userExists, "The user with userID 'existingUserID' should exist in the database");
        assertFalse(userDoesNotExist, "The user with userID 'nonExistingUserID' should not exist in the database");
    }

    /*
    @Test
    public void testRegistrationSuccess(){
        //Database.conn = conn;
        Scanner scanner = new Scanner("123456789\nuser@example.com\nJohn Doe\njohndoe\njohndoe123\npassword\n");
        RegisteredUser.scan = scanner;
        boolean result = RegisteredUser.registration();
        assertTrue(result, "The registration should be successful");
        PreparedStatement stmt = conn.prepareStatement("SELECT * FROM User WHERE user_id = ?");
        stmt.setString(1, "johndoe123");
        ResultSet rs = stmt.executeQuery();

        assertTrue(rs.next());
        assertEquals("johndoe", rs.getString("username"));
    }

    @Test
    public void testUserIDAlreadyExists() throws SQLException {
        PreparedStatement insertStmt = conn.prepareStatement("INSERT INTO User (user_id, username, password, role, phone_num, email) VALUES (?, ?, ?, ?, ?, ?)");
        insertStmt.setString(1, "existingID");
        insertStmt.setString(2, "testuser");
        insertStmt.setString(3, "password");
        insertStmt.setString(4, "user");
        insertStmt.setString(5, "123456789");
        insertStmt.setString(6, "test@example.com");
        insertStmt.executeUpdate();

        Scanner scanner = new Scanner("123456789\nuser@example.com\nJohn Doe\njohndoe\nexistingID\n12BB\npassword\n");
        RegisteredUser.scan = scanner;
        boolean result = RegisteredUser.registration();
        assertTrue(result);
    }

    @Test
    public void testUserIDDoesNotExist() {
        Scanner scanner = new Scanner("123456789\nuser@example.com\nJohn Doe\njohndoe\nnewID\npassword\n");
        RegisteredUser.scan = scanner;
        boolean result = RegisteredUser.registration();
        assertTrue(result);
    }
 */
    // Test for phone number input exit with Q
    @Test
    public void testRegistrationExitPhoneNumber() {
        Scanner scanner = new Scanner("Q\n");
        RegisteredUser.scan = scanner;
        boolean result = RegisteredUser.registration();
        assertFalse(result);
    }

    // Test for email address input exit with Q
    @Test
    public void testRegistrationExitEmail() {
        Scanner scanner = new Scanner("123456789\nQ\n");
        RegisteredUser.scan = scanner;
        boolean result = RegisteredUser.registration();
        assertFalse(result);
    }

    // Test for full name input exit with Q
    @Test
    public void testRegistrationExitFullName() {
        Scanner scanner = new Scanner("123456789\nuser@example.com\nQ\n");
        RegisteredUser.scan = scanner;
        boolean result = RegisteredUser.registration();
        assertFalse(result);
    }

    // Test for username input exit with Q
    @Test
    public void testRegistrationExitUserName() {
        Scanner scanner = new Scanner("123456789\nuser@example.com\nJohn Doe\nQ\n");
        RegisteredUser.scan = scanner;
        boolean result = RegisteredUser.registration();
        assertFalse(result);
    }

    // Test for userID input exit with Q
    @Test
    public void testRegistrationExitUserID() {
        Scanner scanner = new Scanner("123456789\nuser@example.com\nJohn Doe\njohndoe\nQ\n");
        RegisteredUser.scan = scanner;
        boolean result = RegisteredUser.registration();
        assertFalse(result);
    }

    // Test for password input exit with Q
    @Test
    public void testRegistrationExitPassword() {
        Scanner scanner = new Scanner("123456789\nuser@example.com\nJohn Doe\njohndoe\njohndoe123\nQ\n");
        RegisteredUser.scan = scanner;
        boolean result = RegisteredUser.registration();
        assertFalse(result);
    }

    /**
     * Tests the functionality of displaying the current user information.
     * Inserts a user into the database and checks if the output matches the expected user information.
     */
    @Test
    void testDisplayCurrentUserInfo() throws SQLException {

        String insertUserSQL = "INSERT INTO User (user_id, username, password, role, phone_num, email) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(insertUserSQL)) {
            pstmt.setString(1, "s_id");
            pstmt.setString(2, "S S");
            pstmt.setString(3, "s_password");
            pstmt.setString(4, "user");
            pstmt.setString(5, "0412345678");
            pstmt.setString(6, "s@test.com");
            pstmt.executeUpdate();
        }

        RegisteredUser user = new RegisteredUser("s_id");

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outputStream));

        user.displayCurrentUserInfo();

        System.setOut(System.out);
        String output = outputStream.toString();

        assertTrue(output.contains("User ID: s_id"), "The output should include 'User ID: s_id'");
        assertTrue(output.contains("Full Name: S S"), "The output should include 'Full Name: S S'");
        assertTrue(output.contains("Email: s@test.com"), "The output should include 'Email: s@test.com'");
        assertTrue(output.contains("Phone Number: 0412345678"), "The output should include 'Phone Number: 0412345678'");
    }

    /**
     * Tests the functionality of updating the email address of the user.
     * Inserts a user, updates their email, and checks if the updated email is displayed correctly.
     */
    @Test
    void testUpdateEmail() throws SQLException {
        String insertUserSQL = "INSERT INTO User (user_id, username, password, role, phone_num, email) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(insertUserSQL)) {
            pstmt.setString(1, "s_id");
            pstmt.setString(2, "S S");
            pstmt.setString(3, "s_password");
            pstmt.setString(4, "user");
            pstmt.setString(5, "0412345678");
            pstmt.setString(6, "s@test.com");
            pstmt.executeUpdate();
        }

        RegisteredUser user = new RegisteredUser("s_id");

        user.updateEmail("sNew@test.com");

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outputStream));

        user.displayCurrentUserInfo();

        System.setOut(System.out);
        String output = outputStream.toString();

        System.out.println("Captured Output:\n" + output);

        assertTrue(output.contains("User ID: s_id"), "The output should include 'User ID: s_id'");
        assertTrue(output.contains("Full Name: S S"), "The output should include 'Full Name: S S'");
        assertTrue(output.contains("Email: sNew@test.com"), "The output should include updated 'Email: sNew@test.com'");
        assertTrue(output.contains("Phone Number: 0412345678"), "The output should include 'Phone Number: 0412345678'");
    }

    /**
     * Tests the functionality of updating the email address with an invalid value.
     * Ensures that the method returns false when an invalid email is provided.
     */
    @Test
    void testUpdateEmail_illegalArgument() {
        RegisteredUser user = new RegisteredUser("s_id");

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outputStream));

        boolean result = user.updateEmail("invalidEmail");

        System.setOut(System.out);
        String output = outputStream.toString();

        assertFalse(result, "The method should return false for invalid email");
    }

    /**
     * Tests the functionality of updating the phone number of the user.
     * Inserts a user, updates their phone number, and checks if the updated phone number is displayed correctly.
     */
    @Test
    void testUpdatePhoneNumber() throws SQLException {
        String insertUserSQL = "INSERT INTO User (user_id, username, password, role, phone_num, email) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(insertUserSQL)) {
            pstmt.setString(1, "s_id");
            pstmt.setString(2, "S S");
            pstmt.setString(3, "s_password");
            pstmt.setString(4, "user");
            pstmt.setString(5, "0412345678");
            pstmt.setString(6, "s@test.com");
            pstmt.executeUpdate();
        }

        RegisteredUser user = new RegisteredUser("s_id");

        user.updatePhoneNumber("0487654321");

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outputStream));

        user.displayCurrentUserInfo();

        System.setOut(System.out);
        String output = outputStream.toString();

        System.out.println("Captured Output:\n" + output);

        assertTrue(output.contains("User ID: s_id"), "The output should include 'User ID: s_id'");
        assertTrue(output.contains("Full Name: S S"), "The output should include 'Full Name: S S'");
        assertTrue(output.contains("Email: s@test.com"), "The output should include 'Email: s@test.com'");
        assertTrue(output.contains("Phone Number: 0487654321"), "The output should include updated 'Phone Number: 0487654321'");
    }

    /**
     * Tests the functionality of updating the phone number with an invalid value.
     * Ensures that the method returns false when an invalid phone number is provided.
     */
    @Test
    void testUpdatePhoneNumber_illegalArgument() {
        RegisteredUser user = new RegisteredUser("s_id");

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outputStream));

        boolean result = user.updatePhoneNumber("invalidPhoneNumber");

        System.setOut(System.out);
        String output = outputStream.toString();

        assertFalse(result, "The method should return false for invalid input");
    }

    /**
     * Tests the functionality of updating the user's full name.
     * Inserts a user, updates their full name, and checks if the updated full name is displayed correctly.
     */
    @Test
    void testUpdateUserName() throws SQLException {
        String insertUserSQL = "INSERT INTO User (user_id, username, password, role, phone_num, email) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(insertUserSQL)) {
            pstmt.setString(1, "s_id");
            pstmt.setString(2, "S S");
            pstmt.setString(3, "s_password");
            pstmt.setString(4, "user");
            pstmt.setString(5, "0412345678");
            pstmt.setString(6, "s@test.com");
            pstmt.executeUpdate();
        }

        RegisteredUser user = new RegisteredUser("s_id");

        boolean updateSuccess = user.updateFullName("sNew sName");
        assertTrue(updateSuccess, "The operation to update the username should be successful");

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outputStream));

        user.displayCurrentUserInfo();

        System.setOut(System.out);
        String output = outputStream.toString();

        System.out.println("Captured Output:\n" + output);

        assertTrue(output.contains("User ID: s_id"), "The output should include 'User ID: s_id'");
        assertTrue(output.contains("Full Name: sNew sName"), "The output should include updated 'Full Name: sNew sName'");
        assertTrue(output.contains("Email: s@test.com"), "The output should include 'Email: s@test.com'");
        assertTrue(output.contains("Phone Number: 0412345678"), "The output should include 'Phone Number: 0412345678'");
    }

    /**
     * Tests the functionality of updating the user's full name with an invalid value.
     * Ensures that the method returns false when an invalid full name is provided.
     */
    @Test
    void testUpdateUserName_illegalArgument() {
        RegisteredUser user = new RegisteredUser("s_id");

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outputStream));

        boolean result = user.updateFullName("invalidFullName");

        System.setOut(System.out);
        String output = outputStream.toString();

        assertFalse(result, "The method should return false for invalid full name");
    }

    /**
     * Tests the functionality of verifying the old password.
     * Inserts a user, verifies the correct password, and ensures that the method returns true.
     */
    @Test
    void testVerifyOldPassword() throws SQLException {
        String insertUserSQL = "INSERT INTO User (user_id, username, password, role, phone_num, email) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(insertUserSQL)) {
            pstmt.setString(1, "s_id");
            pstmt.setString(2, "S S");
            pstmt.setString(3, BCrypt.hashpw("old_password", BCrypt.gensalt()));
            pstmt.setString(4, "user");
            pstmt.setString(5, "0412345678");
            pstmt.setString(6, "s@test.com");
            pstmt.executeUpdate();
        }

        RegisteredUser user = new RegisteredUser("s_id");

        boolean verifySuccess = user.verifyOldPassword("old_password");
        assertTrue(verifySuccess, "The method should return true when the old password is correct");

        boolean verifyFailure = user.verifyOldPassword("wrong_password");
        assertFalse(verifyFailure, "The method should return false when the old password is incorrect");
    }

    /**
     * Tests the functionality of verifying the old password with an incorrect value.
     * Ensures that the method returns false when the wrong password is provided.
     */
    @Test
    void testVerifyOldPassword_incorrect() throws SQLException {
        String insertUserSQL = "INSERT INTO User (user_id, username, password, role, phone_num, email) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(insertUserSQL)) {
            pstmt.setString(1, "s_id");
            pstmt.setString(2, "S S");
            pstmt.setString(3, BCrypt.hashpw("old_password", BCrypt.gensalt()));
            pstmt.setString(4, "user");
            pstmt.setString(5, "0412345678");
            pstmt.setString(6, "s@test.com");
            pstmt.executeUpdate();
        }

        RegisteredUser user = new RegisteredUser("s_id");

        boolean verifyFailure = user.verifyOldPassword("wrong_password");
        assertFalse(verifyFailure, "The method should return false when the old password is incorrect");
    }

    /**
     * Tests the functionality of setting a new password that is the same as the old password.
     * Inserts a user, attempts to update the password to the same value, and ensures the method returns false.
     */
    @Test
    void testSetNewPassword_sameAsOld() throws SQLException {
        String insertUserSQL = "INSERT INTO User (user_id, username, password, role, phone_num, email) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(insertUserSQL)) {
            pstmt.setString(1, "s_id");
            pstmt.setString(2, "S S");
            pstmt.setString(3, BCrypt.hashpw("old_password", BCrypt.gensalt()));
            pstmt.setString(4, "user");
            pstmt.setString(5, "0412345678");
            pstmt.setString(6, "s@test.com");
            pstmt.executeUpdate();
        }

        RegisteredUser user = new RegisteredUser("s_id");

        boolean updateSuccess = user.setNewPassword("old_password");
        assertFalse(updateSuccess, "The method should return false when the new password is the same as the old password");

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outputStream));

        user.displayCurrentUserInfo();

        System.setOut(System.out);
        String output = outputStream.toString();

        System.out.println("Captured Output:\n" + output);

        assertTrue(output.contains("User ID: s_id"), "The output should include 'User ID: s_id'");
        assertTrue(output.contains("Full Name: S S"), "The output should include 'Full Name: S S'");
        assertTrue(output.contains("Email: s@test.com"), "The output should include 'Email: s@test.com'");
        assertTrue(output.contains("Phone Number: 0412345678"), "The output should include 'Phone Number: 0412345678'");
    }

    /**
     * Tests the functionality of setting a new password that is different from the old password.
     * Inserts a user, updates the password, and ensures that the update is successful.
     */
    @Test
    void testSetNewPassword_success() throws SQLException {
        String insertUserSQL = "INSERT INTO User (user_id, username, password, role, phone_num, email) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(insertUserSQL)) {
            pstmt.setString(1, "s_id");
            pstmt.setString(2, "S S");
            pstmt.setString(3, BCrypt.hashpw("old_password", BCrypt.gensalt()));
            pstmt.setString(4, "user");
            pstmt.setString(5, "0412345678");
            pstmt.setString(6, "s@test.com");
            pstmt.executeUpdate();
        }

        RegisteredUser user = new RegisteredUser("s_id");

        boolean updateSuccess = user.setNewPassword("new_password");
        assertTrue(updateSuccess, "The method should return true when the new password is different from the old password");

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outputStream));

        user.displayCurrentUserInfo();

        System.setOut(System.out);
        String output = outputStream.toString();

        System.out.println("Captured Output:\n" + output);

        assertTrue(output.contains("User ID: s_id"), "The output should include 'User ID: s_id'");
        assertTrue(output.contains("Full Name: S S"), "The output should include 'Full Name: S S'");
        assertTrue(output.contains("Email: s@test.com"), "The output should include 'Email: s@test.com'");
        assertTrue(output.contains("Phone Number: 0412345678"), "The output should include 'Phone Number: 0412345678'");
    }

}