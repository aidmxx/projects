package VirtualScrollAccessSystem;

import org.junit.jupiter.api.*;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.PrintStream;
import java.sql.*;
import java.util.Date;
import java.util.Scanner;
import java.text.SimpleDateFormat;
import java.io.ByteArrayInputStream;
import static org.junit.jupiter.api.Assertions.*;

public class InterfaceTest {
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
        String createDailyScrollTable = "CREATE TABLE IF NOT EXISTS Daily_Scroll (" +
                "date DATE PRIMARY KEY," +
                "scroll_id INTEGER REFERENCES Scroll(scroll_id)" +
                ");";
        stmt.execute(createDailyScrollTable);
    }

    @BeforeEach
    public void resetDatabase() throws SQLException {
        Statement stmt = conn.createStatement();
        stmt.execute("DELETE FROM User;");
        stmt.execute("DELETE FROM Scroll;");
        stmt.execute("DELETE FROM Daily_Scroll;");
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
     * Tests the functionality of viewing scrolls as a guest when no scrolls are available.
     * Simulates user input and checks for correct output message.
     */
    @Test
    void testViewScrollsWithEmptyDatabase() {
        Scanner scanner = new Scanner("3\n1\nQ\n2\n4\n");
        Interface userInterface = new Interface(scanner,true);
        try {
            Statement stmt = conn.createStatement();
            stmt.execute("DELETE FROM Scroll;");
        } catch (SQLException e) {
            fail("Failed to clear the Scroll table for testing.");
        }
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));

        userInterface.viewScrolls();
        String output = outContent.toString();
        assertTrue(output.contains("No available Scrolls at the moment"),
                "The output should indicate no scrolls are available.");
    }

    /**
     * Tests the functionality of viewing scrolls as a guest when has some scrolls are available.
     * Simulates user input and checks for correct output message.
     */
    @Test
    void testViewScrollsWithData() throws SQLException {
        String insertScroll = "INSERT INTO Scroll (scroll_id, name, content, uploader, timestamp, file_type, download_counter, upload_counter) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?);";
        PreparedStatement stmt = conn.prepareStatement(insertScroll);
        stmt.setInt(1, 1);
        stmt.setString(2, "Test Scroll");
        stmt.setString(3, "This is a test scroll content");
        stmt.setString(4, "uploader_001");
        SimpleDateFormat isoFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
        String formattedTimestamp = isoFormat.format(new java.util.Date());
        stmt.setString(5, formattedTimestamp);
        stmt.setInt(6, 1);
        stmt.setInt(7, 5);
        stmt.setInt(8, 3);
        stmt.executeUpdate();
        stmt.close();
        Scanner scanner = new Scanner("3\n1\nQ\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));
        userInterface.viewScrolls();
        String output = outContent.toString();
        assertTrue(output.contains("Test Scroll"), "The output should contain the inserted scroll.");
        assertTrue(output.contains("uploader_001"), "The output should show the uploader ID.");
    }

    /**
     * Tests the functionality of viewing scrolls but wrong return when has some scrolls are available.
     */
    @Test
    void testViewScrollsWithDataButWrongReturn() throws SQLException {
        Database.addUser("12", "username", "123", "user", "123456789", "test@example.com");
        String insertScroll = "INSERT INTO Scroll (scroll_id, name, content, uploader, timestamp, file_type, download_counter, upload_counter) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?);";
        PreparedStatement stmt = conn.prepareStatement(insertScroll);
        stmt.setInt(1, 1);
        stmt.setString(2, "Test Scroll");
        stmt.setString(3, "This is a test scroll content");
        stmt.setString(4, "uploader_001");
        SimpleDateFormat isoFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
        String formattedTimestamp = isoFormat.format(new java.util.Date());
        stmt.setString(5, formattedTimestamp);
        stmt.setInt(6, 1);
        stmt.setInt(7, 5);
        stmt.setInt(8, 3);
        stmt.executeUpdate();
        stmt.close();
        Scanner scanner = new Scanner("1\n12\n123\n1\na\nQ\n8\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }

    }
    /**
     * Test for if put invalid input in scanner.
     */
    @Test
    void TestInvalidInputInLoginPanel(){
        Scanner scanner = new Scanner("a\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }
        String output = outContent.toString();
        assertTrue(output.contains("try again"), "The output should contain Invalid input.");
    }

    /**
     * Test for if put invalid input in scanner.
     */
    @Test
    void TestInvalidInputInLoginPanel2(){
        Scanner scanner = new Scanner("9\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }
        String output = outContent.toString();
        assertTrue(output.contains("try again"), "The output should contain Invalid input.");
    }
    /**
     * Test for if enter password is false.
     */
    @Test
    void testLoginPartFalse(){
        Scanner scanner = new Scanner("1\nadmin\n123456\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }
        String output = outContent.toString();
        assertTrue(output.contains("Login failed"), "The output should contain Login failed.");
    }

    /**
     * Test for if enter password is true and role is user.
     */
    @Test
    void testLoginSuccess() {
        Database.addUser("12", "username", "123", "user", "123456789", "test@example.com");
        Scanner scanner = new Scanner("1\n12\n123\n8\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }
        System.setOut(new PrintStream(outContent));
    }


    /**
     * Test for if enter password is true and role is user.
     */
    @Test
    void testLoginSuccessButWrongInputInUserPanel() {
        Database.addUser("12", "username", "123", "user", "123456789", "test@example.com");
        Scanner scanner = new Scanner("1\n12\n123\n12\n8\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }
        System.setOut(new PrintStream(outContent));
    }


    /**
     * Test for Login Cancel If enter Q in Password
     */
    @Test
    void testLoginCancel1() {
        Database.addUser("12", "username", "123", "user", "123456789", "test@example.com");
        Scanner scanner = new Scanner("1\n12\nQ\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }
        System.setOut(new PrintStream(outContent));
    }
    /**
     * Test for Login Cancel If enter Q in User ID
     */
    @Test
    void testLoginCancel2() {
        Database.addUser("12", "username", "123", "user", "123456789", "test@example.com");
        Scanner scanner = new Scanner("1\nQ\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }
        System.setOut(new PrintStream(outContent));
    }

//    /**
//     * Test for Registration Cancel If enter Q
//     */
//    @Test
//    void testRegistration_Cancel() {
//        Database.addUser("12", "username", "123", "user", "123456789", "test@example.com");
//        Scanner scanner = new Scanner("2\nQ\n4\n");
//
//        Interface userInterface = new Interface(scanner,true);
//        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
//        try {
//            userInterface.runLoginOrRegister();
//        } catch (ExitProgramException e) {
//        }
//        System.setOut(new PrintStream(outContent));
//    }



    /**
     * Test for Guest invalid input
     */
    @Test
    void testGuest_invalid() {
        Scanner scanner = new Scanner("3\n3\n2\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }
        System.setOut(new PrintStream(outContent));
    }

    /**
     * Test for Guest invalid input
     */
    @Test
    void testGuest_invalid2() {
        Scanner scanner = new Scanner("3\na\n2\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }
        System.setOut(new PrintStream(outContent));
    }
    /**
     * Test for Guest valid input
     */
    @Test
    void testGuest_valid1() {
        Scanner scanner = new Scanner("3\n1\nQ\n2\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }
        System.setOut(new PrintStream(outContent));
    }

    /**
     * Test for if PickUp lucky scroll is no available
     */
    @Test
    void testUserPanel1PickupScroll() {
        Database.addUser("123", "username", "123", "user", "123456789", "test@example.com");

        Scanner scanner = new Scanner("1\n123\n123\n0\n8\n4\n");
        Interface userInterface = new Interface(scanner,true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }
        System.setOut(new PrintStream(outContent));
    }

    /**
     * Test for if PickUp lucky scroll is available
     */
    @Test
    void testUserPanel1PickupScrollSuccess() throws SQLException {

        Database.addUser("123", "username", "123", "user", "123456789", "test@example.com");
        String insertScroll = "INSERT INTO Scroll (scroll_id, name, content, uploader, timestamp, file_type, download_counter, upload_counter) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?);";
        PreparedStatement stmt = conn.prepareStatement(insertScroll);
        stmt.setInt(1, 9);
        stmt.setString(2, "testScroll");
        stmt.setString(3, "This is a test scroll content");
        stmt.setString(4, "123");
        SimpleDateFormat isoFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
        String formattedTimestamp = isoFormat.format(new java.util.Date());
        stmt.setString(5, formattedTimestamp);
        stmt.setInt(6, 1);
        stmt.setInt(7, 5);
        stmt.setInt(8, 3);
        stmt.executeUpdate();
        stmt.close();
        Date currentDate = new Date(System.currentTimeMillis());
        Database.addDailyScroll(currentDate, 9);
        Scanner scanner = new Scanner("1\n123\n123\n0\nQ\n1\nQ\n8\n4\n");
        Interface userInterface = new Interface(scanner, true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));

        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }

        String output = outContent.toString();
        System.out.println(output);

        assertTrue(output.contains("Today's lucky scroll"), "The output should contain 'Today's lucky scroll'");
        assertTrue(output.contains("testScroll"), "The output should contain the name of the scroll 'testScroll'");
    }



    /**
     * Test for if PickUp lucky scroll is available,yet when user leave enter wrong input
     */

    @Test
    void testUserPanelPickupScrollSuccess_ButWrongReturn() throws SQLException {

        Database.addUser("123", "username", "123", "user", "123456789", "test@example.com");
        String insertScroll = "INSERT INTO Scroll (scroll_id, name, content, uploader, timestamp, file_type, download_counter, upload_counter) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?);";
        PreparedStatement stmt = conn.prepareStatement(insertScroll);
        stmt.setInt(1, 9);
        stmt.setString(2, "testScroll");
        stmt.setString(3, "This is a test scroll content");
        stmt.setString(4, "123");
        SimpleDateFormat isoFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
        String formattedTimestamp = isoFormat.format(new java.util.Date());
        stmt.setString(5, formattedTimestamp);
        stmt.setInt(6, 1);
        stmt.setInt(7, 5);
        stmt.setInt(8, 3);
        stmt.executeUpdate();
        stmt.close();
        Date currentDate = new Date(System.currentTimeMillis());
        Database.addDailyScroll(currentDate, 9);
        Scanner scanner = new Scanner("1\n123\n123\n0\na\nQ\n1\nQ\n8\n4\n");
        Interface userInterface = new Interface(scanner, true);
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));

        try {
            userInterface.runLoginOrRegister();
        } catch (ExitProgramException e) {
        }

        String output = outContent.toString();
        System.out.println(output);

        assertTrue(output.contains("Today's lucky scroll"), "The output should contain 'Today's lucky scroll'");
        assertTrue(output.contains("testScroll"), "The output should contain the name of the scroll 'testScroll'");
    }

    /**
     * Test for DownloadScroll Successfully
     */
    @Test
    void testDownloadScroll_Normal() throws SQLException{
        Database.addUser("123", "user1", "password", "user", "123456789", "user1@example.com");
        String insertScroll = "INSERT INTO Scroll (scroll_id, name, content, uploader, timestamp, file_type, download_counter, upload_counter) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?);";
        PreparedStatement stmt = conn.prepareStatement(insertScroll);
        stmt.setInt(1, 9);
        stmt.setString(2, "testScroll");
        stmt.setString(3, "This is a test scroll content");
        stmt.setString(4, "123");
        SimpleDateFormat isoFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
        String formattedTimestamp = isoFormat.format(new java.util.Date());
        stmt.setString(5, formattedTimestamp);
        stmt.setInt(6, 1);
        stmt.setInt(7, 5);
        stmt.setInt(8, 3);
        stmt.executeUpdate();
        stmt.close();
        String simulatedInput = "1\n123\npassword\n2\n9\nY\nsrc/test/resources/testFile/downloadedScroll.txt\nQ\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outputStream));
        Interface userInterface = new Interface(new Scanner(System.in), true);
        assertThrows(ExitProgramException.class, () -> {
            userInterface.runLoginOrRegister();
        });
        String output = outputStream.toString();
        System.out.println(output);
        File downloadedFile = new File("src/test/resources/testFile/downloadedScroll.txt");

        downloadedFile.delete();
    }


    /**
     * Test for DownloadScroll with aborted
     */
    @Test
    void testDownloadScroll_Aborted1() throws SQLException{
        Database.addUser("123", "user1", "password", "user", "123456789", "user1@example.com");
        String insertScroll = "INSERT INTO Scroll (scroll_id, name, content, uploader, timestamp, file_type, download_counter, upload_counter) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?);";
        PreparedStatement stmt = conn.prepareStatement(insertScroll);
        stmt.setInt(1, 9);
        stmt.setString(2, "testScroll");
        stmt.setString(3, "This is a test scroll content");
        stmt.setString(4, "123");
        SimpleDateFormat isoFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
        String formattedTimestamp = isoFormat.format(new java.util.Date());
        stmt.setString(5, formattedTimestamp);
        stmt.setInt(6, 1);
        stmt.setInt(7, 5);
        stmt.setInt(8, 3);
        stmt.executeUpdate();
        stmt.close();
        String simulatedInput = "1\n123\npassword\n2\n9\na\n9\nN\nQ\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outputStream));
        Interface userInterface = new Interface(new Scanner(System.in), true);
        assertThrows(ExitProgramException.class, () -> {
            userInterface.runLoginOrRegister();
        });
        String output = outputStream.toString();
        System.out.println(output);
    }



    /**
     * Test for DownloadScroll with ScrollNoFound
     */
    @Test
    void testDownloadScroll_ScrollNoFound() throws SQLException{
        Database.addUser("123", "user1", "password", "user", "123456789", "user1@example.com");
        String insertScroll = "INSERT INTO Scroll (scroll_id, name, content, uploader, timestamp, file_type, download_counter, upload_counter) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?);";
        PreparedStatement stmt = conn.prepareStatement(insertScroll);
        stmt.setInt(1, 9);
        stmt.setString(2, "testScroll");
        stmt.setString(3, "This is a test scroll content");
        stmt.setString(4, "123");
        SimpleDateFormat isoFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
        String formattedTimestamp = isoFormat.format(new java.util.Date());
        stmt.setString(5, formattedTimestamp);
        stmt.setInt(6, 1);
        stmt.setInt(7, 5);
        stmt.setInt(8, 3);
        stmt.executeUpdate();
        stmt.close();
        String simulatedInput = "1\n123\npassword\n2\n12\n9\nY\nsrc/test/resources/testFile/downloadedScroll.txt\nQ\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outputStream));
        Interface userInterface = new Interface(new Scanner(System.in), true);
        assertThrows(ExitProgramException.class, () -> {
            userInterface.runLoginOrRegister();
        });
        String output = outputStream.toString();
        System.out.println(output);
        File downloadedFile = new File("src/test/resources/testFile/downloadedScroll.txt");

        downloadedFile.delete();
    }

//    /**
//     * Test for DownloadScroll with download abort
//     */
//    @Test
//    void testDownloadScroll_Abort() throws SQLException{
//        Database.addUser("123", "user1", "password", "user", "123456789", "user1@example.com");
//        String insertScroll = "INSERT INTO Scroll (scroll_id, name, content, uploader, timestamp, file_type, download_counter, upload_counter) " +
//                "VALUES (?, ?, ?, ?, ?, ?, ?, ?);";
//        PreparedStatement stmt = conn.prepareStatement(insertScroll);
//        stmt.setInt(1, 9);
//        stmt.setString(2, "testScroll");
//        stmt.setString(3, "This is a test scroll content");
//        stmt.setString(4, "123");
//        SimpleDateFormat isoFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
//        String formattedTimestamp = isoFormat.format(new java.util.Date());
//        stmt.setString(5, formattedTimestamp);
//        stmt.setInt(6, 1);
//        stmt.setInt(7, 5);
//        stmt.setInt(8, 3);
//        stmt.executeUpdate();
//        stmt.close();
//        String simulatedInput = "1\n123\npassword\n2\n9\nY\nQ\nQ\n8\n4\n";
//        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
//        System.setIn(inputStream);
//        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
//        System.setOut(new PrintStream(outputStream));
//        Interface userInterface = new Interface(new Scanner(System.in), true);
//        assertThrows(ExitProgramException.class, () -> {
//            userInterface.runLoginOrRegister();
//        });
//        String output = outputStream.toString();
//        System.out.println(output);
//        File downloadedFile = new File("src/test/resources/testFile/downloadedScroll.txt");
//
//        downloadedFile.delete();
//    }


    /**
     * Test for DownloadScroll with InvalidPath
     */
    @Test
    void testDownloadScroll_InvalidPath() throws SQLException{
        Database.addUser("123", "user1", "password", "user", "123456789", "user1@example.com");
        String insertScroll = "INSERT INTO Scroll (scroll_id, name, content, uploader, timestamp, file_type, download_counter, upload_counter) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?);";
        PreparedStatement stmt = conn.prepareStatement(insertScroll);
        stmt.setInt(1, 9);
        stmt.setString(2, "testScroll");
        stmt.setString(3, "This is a test scroll content");
        stmt.setString(4, "123");
        SimpleDateFormat isoFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
        String formattedTimestamp = isoFormat.format(new java.util.Date());
        stmt.setString(5, formattedTimestamp);
        stmt.setInt(6, 1);
        stmt.setInt(7, 5);
        stmt.setInt(8, 3);
        stmt.executeUpdate();
        stmt.close();
        String simulatedInput = "1\n123\npassword\n2\n9\na\n9\nY\nabc\nQ\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outputStream));
        Interface userInterface = new Interface(new Scanner(System.in), true);
        assertThrows(ExitProgramException.class, () -> {
            userInterface.runLoginOrRegister();
        });
        String output = outputStream.toString();
        System.out.println(output);
        File downloadedFile = new File("src/test/resources/testFile/downloadedScroll.txt");

        downloadedFile.delete();
    }

    /**
     * Test for DownloadScroll with no permission
     */
    @Test
    void testDownloadScroll_NoPermission() throws SQLException{
        Database.addUser("123", "user1", "password", "user", "123456789", "user1@example.com");
        String insertScroll = "INSERT INTO Scroll (scroll_id, name, content, uploader, timestamp, file_type, download_counter, upload_counter) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?);";
        PreparedStatement stmt = conn.prepareStatement(insertScroll);
        stmt.setInt(1, 10);
        stmt.setString(2, "testScroll2");
        stmt.setString(3, "This is a test scroll content");
        stmt.setString(4, "124");
        SimpleDateFormat isoFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
        String formattedTimestamp = isoFormat.format(new java.util.Date());
        stmt.setString(5, formattedTimestamp);
        stmt.setInt(6, 1);
        stmt.setInt(7, 5);
        stmt.setInt(8, 3);
        stmt.executeUpdate();
        stmt.close();
        String simulatedInput = "1\n123\npassword\n2\n10\nY\nQ\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outputStream));
        Interface userInterface = new Interface(new Scanner(System.in), true);
        assertThrows(ExitProgramException.class, () -> {
            userInterface.runLoginOrRegister();
        });
        String output = outputStream.toString();
        System.out.println(output);
        assertTrue(output.contains("Download failed"), "The output should contain Download failed");

    }

    /**
     * Test for preview Scroll success
     */
    @Test
    void testPreviewScroll_Success1() throws SQLException{
        Database.addUser("123", "user1", "password", "user", "123456789", "user1@example.com");
        String insertScroll = "INSERT INTO Scroll (scroll_id, name, content, uploader, timestamp, file_type, download_counter, upload_counter) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?);";
        PreparedStatement stmt = conn.prepareStatement(insertScroll);
        stmt.setInt(1, 10);
        stmt.setString(2, "testScroll2");
        stmt.setString(3, "This is a test scroll content");
        stmt.setString(4, "124");
        SimpleDateFormat isoFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
        String formattedTimestamp = isoFormat.format(new java.util.Date());
        stmt.setString(5, formattedTimestamp);
        stmt.setInt(6, 1);
        stmt.setInt(7, 5);
        stmt.setInt(8, 3);
        stmt.executeUpdate();
        stmt.close();
        String simulatedInput = "1\n123\npassword\n5\nQ\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outputStream));
        Interface userInterface = new Interface(new Scanner(System.in), true);
        assertThrows(ExitProgramException.class, () -> {
            userInterface.runLoginOrRegister();
        });
        String output = outputStream.toString();
        System.out.println(output);
        assertTrue(output.contains("scrollName"), "The output should contain scrollName");
        assertTrue(output.contains("uploadTime"), "The output should contain uploadTime");
        assertTrue(output.contains("File Type"), "The output should contain File Type");
    }

    /**
     * Test for preview Scroll success
     */
    @Test
    void testPreviewScroll_Success2() throws SQLException{
        Database.addUser("123", "user1", "password", "user", "123456789", "user1@example.com");
        String insertScroll = "INSERT INTO Scroll (scroll_id, name, content, uploader, timestamp, file_type, download_counter, upload_counter) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?);";
        PreparedStatement stmt = conn.prepareStatement(insertScroll);
        stmt.setInt(1, 10);
        stmt.setString(2, "testScroll2");
        stmt.setString(3, "This is a test scroll content");
        stmt.setString(4, "124");
        SimpleDateFormat isoFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
        String formattedTimestamp = isoFormat.format(new java.util.Date());
        stmt.setString(5, formattedTimestamp);
        stmt.setInt(6, 1);
        stmt.setInt(7, 5);
        stmt.setInt(8, 3);
        stmt.executeUpdate();
        stmt.close();
        String simulatedInput = "1\n123\npassword\n5\n10\nQ\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outputStream));
        Interface userInterface = new Interface(new Scanner(System.in), true);
        assertThrows(ExitProgramException.class, () -> {
            userInterface.runLoginOrRegister();
        });
        String output = outputStream.toString();
        System.out.println(output);
        assertTrue(output.contains("Previewing"), "The output should contain Previewing");
    }

    /**
     * Test for preview with No Scroll ID Found
     */
    @Test
    void testPreviewScroll_NoScrollIdFound() throws SQLException{
        Database.addUser("123", "user1", "password", "user", "123456789", "user1@example.com");
        String insertScroll = "INSERT INTO Scroll (scroll_id, name, content, uploader, timestamp, file_type, download_counter, upload_counter) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?);";
        PreparedStatement stmt = conn.prepareStatement(insertScroll);
        stmt.setInt(1, 10);
        stmt.setString(2, "testScroll2");
        stmt.setString(3, "This is a test scroll content");
        stmt.setString(4, "124");
        SimpleDateFormat isoFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
        String formattedTimestamp = isoFormat.format(new java.util.Date());
        stmt.setString(5, formattedTimestamp);
        stmt.setInt(6, 1);
        stmt.setInt(7, 5);
        stmt.setInt(8, 3);
        stmt.executeUpdate();
        stmt.close();
        String simulatedInput = "1\n123\npassword\n5\n12\nQ\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outputStream));
        Interface userInterface = new Interface(new Scanner(System.in), true);
        assertThrows(ExitProgramException.class, () -> {
            userInterface.runLoginOrRegister();
        });
        String output = outputStream.toString();
        System.out.println(output);
        assertTrue(output.contains("No scroll found"), "The output should contain No scroll found");
    }


    /**
     * Test for preview with Invalid Scroll ID
     */
    @Test
    void testPreviewScroll_InvalidScrollId() throws SQLException{
        Database.addUser("123", "user1", "password", "user", "123456789", "user1@example.com");
        String insertScroll = "INSERT INTO Scroll (scroll_id, name, content, uploader, timestamp, file_type, download_counter, upload_counter) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?);";
        PreparedStatement stmt = conn.prepareStatement(insertScroll);
        stmt.setInt(1, 10);
        stmt.setString(2, "testScroll2");
        stmt.setString(3, "This is a test scroll content");
        stmt.setString(4, "124");
        SimpleDateFormat isoFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
        String formattedTimestamp = isoFormat.format(new java.util.Date());
        stmt.setString(5, formattedTimestamp);
        stmt.setInt(6, 1);
        stmt.setInt(7, 5);
        stmt.setInt(8, 3);
        stmt.executeUpdate();
        stmt.close();
        String simulatedInput = "1\n123\npassword\n5\na\nQ\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outputStream));
        Interface userInterface = new Interface(new Scanner(System.in), true);
        assertThrows(ExitProgramException.class, () -> {
            userInterface.runLoginOrRegister();
        });
        String output = outputStream.toString();
        System.out.println(output);
        assertTrue(output.contains("Invalid scroll ID format"), "The output should contain Invalid scroll ID format");
    }

    /**
     * Test for preview Scroll with no scroll
     */
    @Test
    void testPreviewScroll_NoScroll(){
        Database.addUser("123", "user1", "password", "user", "123456789", "user1@example.com");
        String simulatedInput = "1\n123\npassword\n5\nQ\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outputStream));
        Interface userInterface = new Interface(new Scanner(System.in), true);
        assertThrows(ExitProgramException.class, () -> {
            userInterface.runLoginOrRegister();
        });
        String output = outputStream.toString();
        System.out.println(output);
        assertTrue(output.contains("No available scrolls"), "The output should contain No available scrolls");

    }
    /**
     * Test for preview Scroll with InvalidReturn
     */
    @Test
    void testPreviewScroll_InvalidReturn(){
        Database.addUser("123", "user1", "password", "user", "123456789", "user1@example.com");
        String simulatedInput = "1\n123\npassword\n5\na\nQ\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outputStream));
        Interface userInterface = new Interface(new Scanner(System.in), true);
        assertThrows(ExitProgramException.class, () -> {
            userInterface.runLoginOrRegister();
        });
        String output = outputStream.toString();
        System.out.println(output);
    }


}