package VirtualScrollAccessSystem;

import org.junit.jupiter.api.*;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.PrintStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Scanner;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertTrue;

public class AdminTest {

    private static Connection conn;
    private RegisteredUser registeredUser;
    private Interface userInterface;

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
        String createScrollTable = "CREATE TABLE Scroll (" +
                "scroll_id INTEGER PRIMARY KEY AUTOINCREMENT," +
                "filename TEXT," +
                "name TEXT," +
                "content BLOB," +
                "uploader TEXT," +
                "timestamp TEXT," +
                "file_type INTEGER," +
                "download_counter INTEGER," +
                "upload_counter INTEGER" +
                ");";
        stmt.execute(createScrollTable);
    }

    @BeforeEach
    public void resetDatabase() throws SQLException {
        Statement stmt = conn.createStatement();
        stmt.execute("DELETE FROM User;");
        stmt.execute("DELETE FROM Scroll;");
        registeredUser = new RegisteredUser("testUserID");
    }

    @BeforeEach
    public void disableClearScreenForTests() {
        System.setProperty("disable.clear", "true");
    }

    @AfterEach
    public void resetClearScreenProperty() {
        System.clearProperty("disable.clear");
    }

    @AfterAll
    public static void teardownDatabase() throws SQLException {
        if (conn != null) {
            conn.close();
        }
    }


    /**
     * Test for if enter password is true and role is admin.
     */
    @Test
    void testLoginPartTrueForAdmin(){
        Database.addUser("admin1", "username", "12345678", "admin", "123456789", "test@example.com");

        Scanner scanner = new Scanner("1\nadmin1\n12345678\n3\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }
        String output = outContent.toString();
        assertTrue(output.contains("Welcome to Admin Panel"), "The output should Admin Panel.");
    }


    /**
     * Test the SPECIAL Button is exist.
     */
    @Test
    void testUserPanelForAdmin(){
        Database.addUser("admin1", "username", "12345678", "admin", "123456789", "test@example.com");

        Scanner scanner = new Scanner("1\nadmin1\n12345678\n2\n8\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }
        String output = outContent.toString();
        assertTrue(output.contains("Welcome to Admin Panel"), "The output should Admin Panel.");
    }

    /**
     * Test in user panel but valid input.
     */
    @Test
    void testValidInput1_UserPanelForAdmin(){
        Database.addUser("admin1", "username", "12345678", "admin", "123456789", "test@example.com");

        Scanner scanner = new Scanner("1\nadmin1\n12345678\n2\n9\n3\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }
        String output = outContent.toString();
    }

    /**
     * Test in user panel but no valid input.
     */
    @Test
    void testInvalidInput1_UserPanelForAdmin(){
        Database.addUser("admin1", "username", "12345678", "admin", "123456789", "test@example.com");

        Scanner scanner = new Scanner("1\nadmin1\n12345678\n2\na\n8\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }
        String output = outContent.toString();
        assertTrue(output.contains("Invalid input"), "The output contain Invalid input.");
    }


    /**
     * Test in user panel but no valid input.
     */
    @Test
    void testInvalidInput2_UserPanelForAdmin(){
        Database.addUser("admin1", "username", "12345678", "admin", "123456789", "test@example.com");

        Scanner scanner = new Scanner("1\nadmin1\n12345678\n2\n12\n8\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }
        String output = outContent.toString();
        assertTrue(output.contains("Invalid input"), "The output should contain Invalid input.");
    }
    /**
     * Test for adminPanel for Invalid input
     */
    @Test
    void TestAdminFunctionInvalidInput(){
        Database.addUser("admin1", "username", "12345678", "admin", "123456789", "test@example.com");
        Scanner scanner = new Scanner("1\nadmin1\n12345678\n1\n8\n5\n3\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }

    }
    /**
     * Test for view all user profile
     */
    @Test
    void TestAdminFunction1(){
        Database.addUser("admin1", "username", "12345678", "admin", "123456789", "test@example.com");
        Scanner scanner = new Scanner("1\nadmin1\n12345678\n1\n1\nQ\n5\n3\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }
        String output = outContent.toString();
        assertTrue(output.contains("user_id"), "The output should contain user_id");
        assertTrue(output.contains("username"), "The output should contain username");
    }

    /**
     * Test for admin panel input invalid
     */
    @Test
    void TestAdminFunction1InvalidInput1(){
        Database.addUser("admin1", "username", "12345678", "admin", "123456789", "test@example.com");
        Scanner scanner = new Scanner("1\nadmin1\n12345678\n4\n3\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }
        String output = outContent.toString();
        assertTrue(output.contains("Invalid"), "The output should contain invalid input");
    }

    /**
     * Test for view all user profile which input is invalid
     */
    @Test
    void TestAdminFunction1InvalidInput2(){
        Database.addUser("admin1", "username", "12345678", "admin", "123456789", "test@example.com");
        Scanner scanner = new Scanner("1\nadmin1\n12345678\n1\n1\na\nQ\n5\n3\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }
        String output = outContent.toString();
        assertTrue(output.contains("Invalid"), "The output should contain invalid input");
    }
    /**
     * Test for adminpanel which input is not a num
     */
    @Test
    void TestAdminFunction1InvalidInput3(){
        Database.addUser("admin1", "username", "12345678", "admin", "123456789", "test@example.com");
        Scanner scanner = new Scanner("1\nadmin1\n12345678\na\n3\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }
        String output = outContent.toString();
        assertTrue(output.contains("format"), "The output should contain invalid input");
    }
    /**
     * Test for add a user is success
     */
    @Test
    void TestAdminFunction2(){
        Database.addUser("admin1", "username", "12345678", "admin", "123456789", "test@example.com");
        Scanner scanner = new Scanner("1\nadmin1\n12345678\n1\n2\nuser1,user1,1234,user,1234,1234@qq.com\n5\n3\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }
        String output = outContent.toString();
        assertTrue(output.contains("successfully"), "The output should contain User added successfully");

    }
    /**
     * Test for add a user is not success because of role wrong and input less than 6
     */
    @Test
    void TestAdminFunction2invalid(){
        Database.addUser("admin1", "username", "12345678", "admin", "123456789", "test@example.com");
        Scanner scanner = new Scanner("1\nadmin1\n12345678\n1\n2\nuser1,user1,1234,user1,1234,1234@qq.com\na\nQ\n5\n3\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }
        String output = outContent.toString();
        assertTrue(output.contains("either"), "The output should contain role distinction");
        assertTrue(output.contains("fields"), "The output should contain Please enter all 6 required fields or enter [Q] to quit");
    }
    /**
     * Test for delete user successfully
     */
    @Test
    void TestAdminFunction3(){
        Database.addUser("admin1", "username", "12345678", "admin", "123456789", "test@example.com");
        Database.addUser("admin2", "username", "12345678", "admin", "123456789", "test@example.com");
        Scanner scanner = new Scanner("1\nadmin1\n12345678\n1\n3\nadmin2\nQ\n5\n3\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }
        String output = outContent.toString();
        assertTrue(output.contains("deleted"), "The output should contain User deleted successfully");

    }
    /**
     * Test for delete user with no ID in db
     */
    @Test
    void TestAdminFunction3withInvalidID(){
        Database.addUser("admin1", "username", "12345678", "admin", "123456789", "test@example.com");
        Database.addUser("admin2", "username", "12345678", "admin", "123456789", "test@example.com");
        Scanner scanner = new Scanner("1\nadmin1\n12345678\n1\n3\nadmin3\nQ\n5\n3\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }
        String output = outContent.toString();
        assertTrue(output.contains("No user found"), "The output should contain User Not found");

    }

    /**
     * Test for statistic scroll and test invalid return
     */
    @Test
    void TestAdminFunction4withInValidInput(){
        Database.addUser("admin1", "username", "12345678", "admin", "123456789", "test@example.com");
        Scanner scanner = new Scanner("1\nadmin1\n12345678\n1\n4\na\nQ\n5\n3\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }
        String output = outContent.toString();
        assertTrue(output.contains("No scroll statistics available"), "The output should contain No scroll statistics available at the moment.");

    }

    /**
     * Test for statistic scroll
     */

    @Test
    void TestAdminFunction4(){
        Database.addUser("admin1", "username", "12345678", "admin", "123456789", "test@example.com");
        File file = new File("src/test/resources/testFile/testAddScrollSuccess.txt");
        assertDoesNotThrow(() -> {
            Database.addScroll("123", file, "001");
        });
        Scanner scanner = new Scanner("1\nadmin1\n12345678\n1\n4\nQ\n5\n3\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }
        String output = outContent.toString();
        assertTrue(output.contains("Download times"), "The output should contain Download times");
        assertTrue(output.contains("Upload/Update"), "The output should contain Upload/Update times");
    }


    /**
     * Test for set Timer with invalid num and alphabet
     */
    @Test
    void TestAdminFunction5withInvalidNumAndAlphabet(){
        Database.addUser("admin1", "username", "12345678", "admin", "123456789", "test@example.com");
        Scanner scanner = new Scanner("1\nadmin1\n12345678\n1\n6\na\n-1\nQ\n3\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }
        String output = outContent.toString();
        assertTrue(output.contains("Invalid input"), "The output should contain Invalid input");
        assertTrue(output.contains("Invalid number"), "The output should contain Invalid input");
    }

    /**
     * Test for set Timer with invalid num and alphabet
     */
    @Test
    void TestAdminFunction5(){
        Database.addUser("admin1", "username", "12345678", "admin", "123456789", "test@example.com");
        Scanner scanner = new Scanner("1\nadmin1\n12345678\n1\n6\n20\n3\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }
        String output = outContent.toString();
        assertTrue(output.contains("set to"), "The output should contain set to X seconds");
    }
}
