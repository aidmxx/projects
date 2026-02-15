package VirtualScrollAccessSystem;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Scanner;

import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

public class EditScrollTest {

    private static final String RESOURCE_PATH = "src/test/resources/";
    private static ByteArrayOutputStream outputStream;
    private static PrintStream originalOut;
    private static PrintStream printStream;

    @BeforeAll
    static void setup() {

    }

    @BeforeEach
    void init() {

        originalOut = System.out;
        outputStream = new ByteArrayOutputStream();
        printStream = new PrintStream(outputStream);
        System.setOut(printStream);

        new Database(RESOURCE_PATH);
        new App();
    }

    @AfterEach
    void tear() {
        System.setOut(originalOut); // Restore the original output stream
        try {
            Files.deleteIfExists(Paths.get(RESOURCE_PATH + "data.db"));
            Files.deleteIfExists(Paths.get(RESOURCE_PATH + "config.json"));
        } catch (IOException e) {
            System.err.println("Error while deleting test files: " + e.getMessage());
        }
    }

    @AfterAll
    static void clean() {
    }


    /**
     * Test for whether or not the edit panel can be properly exited.
     */
    @Test
    void testPanel_Exit() {
        String simulatedInput = "1\nadmin\n12345678\n2\n7\n3\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        App.scan = new Scanner(System.in);

        assertThrows(ExitProgramException.class, () -> {
            App.main(new String[]{RESOURCE_PATH, "true"});
        });

        String output = outputStream.toString();
        System.out.println(output);

        assertTrue(output.contains("Have a good day!"));
    }


    /**
     * Test for user typing invalid input in the edit panel.
     */
    @Test
    void testPanel_InvalidInput() {
        String simulatedInput = "1\nadmin\n12345678\n2\n7\n4\n0\nabc\n3\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        App.scan = new Scanner(System.in);

        assertThrows(ExitProgramException.class, () -> {
            App.main(new String[]{RESOURCE_PATH, "true"});
        });

        String output = outputStream.toString();
        System.out.println(output);

        assertTrue(output.contains("Invalid input. Please try again."));
        assertTrue(output.contains("Invalid format. Please try again."));
    }


    /**
     * Test for user typing invalid input (negative number, string or blank) when editing scrolls.
     */
    @Test
    void testEdit_InvalidInput() {

        File file = new File("src/test/resources/testFile/pray.txt");
        Database.addScroll("pray", file, "admin");

        String simulatedInput = "1\nadmin\n12345678\n2\n7\n1\n-1\nabc\n\n1\nQ\n3\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        App.scan = new Scanner(System.in);

        assertThrows(ExitProgramException.class, () -> {
            App.main(new String[]{RESOURCE_PATH, "true"});
        });

        String output = outputStream.toString();
        System.out.println(output);

        assertTrue(output.contains("Invalid scroll ID format. Please try again."));
        assertTrue(output.contains("No Scroll found. Please try again."));
    }


    /**
     * Test for uploading an invalid file (file that does not exist or give an invalid path)
     */
    @Test
    void testEdit_InvalidFile() {
        File file = new File("src/test/resources/testFile/pray.txt");
        Database.addScroll("pray", file, "admin");

        String simulatedInput = "1\nadmin\n12345678\n2\n7\n1\n1\nsrc/someVeryGoodFile.hihihi\n1\nsrc\nQ\n3\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        App.scan = new Scanner(System.in);

        assertThrows(ExitProgramException.class, () -> {
            App.main(new String[]{RESOURCE_PATH, "true"});
        });

        String output = outputStream.toString();
        System.out.println(output);

        assertTrue(output.contains("invalid path, please upload a file."));
        assertTrue(output.contains("Invalid path. File does not exist."));

    }

    /**
     * Update a existed scroll and then delete it.
     */
    @Test
    void testEdit_Normal() {
        File file = new File("src/test/resources/testFile/pray.txt");
        Database.addScroll("pray", file, "user");

        String simulatedInput = "1\nadmin\n12345678\n2\n7\n1\n1\nsrc/test/resources/testFile/testLongFile.txt\nQ\n3\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        App.scan = new Scanner(System.in);
        assertThrows(ExitProgramException.class, () -> {
            App.main(new String[]{RESOURCE_PATH, "true"});
        });

        String output = outputStream.toString();
        System.out.println(output);

        assertTrue(output.contains("Scroll content updated successfully! Press [Enter] to continue or [Q] to go back."));
    }



    /**
     * Update a scroll that is not owned by the user.
     */
    @Test
    void testEdit_NoPermission() {

        Database.addUser("user", "user", "user", "user", "", "");

        File file = new File("src/test/resources/testFile/pray.txt");
        Database.addScroll("pray", file, "admin");


        String simulatedInput = "1\nuser\nuser\n7\n1\n1\nQ\n3\n\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);


        App.scan = new Scanner(System.in);
        assertThrows(ExitProgramException.class, () -> {
            App.main(new String[]{RESOURCE_PATH, "true"});
        });

        String output = outputStream.toString();
        System.out.println(output);

        assertTrue(output.contains("You do not have permission to edit this scroll."));
    }

    /**
     * Edge Case: Multiple database connection, force to create a database connection lock.
     */
    @Test
    void testEdit_DatabaseConnectionError() {
        File file = new File("src/test/resources/testFile/pray.txt");
        Database.addScroll("pray", file, "admin");

        try {
            PreparedStatement stmt = Database.conn.prepareStatement("SELECT MAX(scroll_id) FROM Scroll;");
            stmt.executeQuery();
        } catch (IllegalArgumentException e) {
            throw e;
        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.");
        }

        String simulatedInput = "1\nadmin\n12345678\n2\n7\n1\n1\nsrc/test/resources/testFile/testLongFile.txt\nQ\n3\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        App.scan = new Scanner(System.in);
        assertThrows(ExitProgramException.class, () -> {
            App.main(new String[]{RESOURCE_PATH, "true"});
        });

        String output = outputStream.toString();
        System.out.println(output);

        assertTrue(output.contains("Failed to update scroll content"));
    }


    /**
     * Test for deleting a scroll normally.
     */
    @Test
    void testDelete_Normal() {
        Database.addUser("user", "user", "user", "user", "", "");

        File file = new File("src/test/resources/testFile/pray.txt");
        Database.addScroll("pray", file, "admin");

        String simulatedInput = "1\nadmin\n12345678\n2\n7\n2\n1\nQ\n3\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        App.scan = new Scanner(System.in);
        assertThrows(ExitProgramException.class, () -> {
            App.main(new String[]{RESOURCE_PATH, "true"});
        });

        String output = outputStream.toString();
        System.out.println(output);

        assertTrue(output.contains("Scroll deleted successfully!"));
    }


    /**
     * Test for invalid inputs when deleting an scroll.
     */
    @Test
    void testDelete_InvalidInput() {
        File file = new File("src/test/resources/testFile/pray.txt");
        Database.addScroll("pray", file, "admin");

        String simulatedInput = "1\nadmin\n12345678\n2\n7\n2\n0\n3\nabc\n\n1\n2\nQ\n3\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        App.scan = new Scanner(System.in);
        assertThrows(ExitProgramException.class, () -> {
            App.main(new String[]{RESOURCE_PATH, "true"});
        });

        String output = outputStream.toString();
        System.out.println(output);

        assertTrue(output.contains("Error: No scroll found with the provided scroll_id."));
        assertTrue(output.contains("Invalid input. Please enter a valid scroll_id."));
        assertTrue(output.contains("Invalid input. Please press [Q] to go back."));
    }


    /**
     * Delete a scroll that is not owned by the user.
     */
    @Test
    void testDelete_NoPermission() {
        Database.addUser("user", "user", "user", "user", "", "");

        File file = new File("src/test/resources/testFile/pray.txt");
        Database.addScroll("pray", file, "admin");

        String simulatedInput = "1\nuser\nuser\n7\n2\n1\nQ\n3\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        App.scan = new Scanner(System.in);
        assertThrows(ExitProgramException.class, () -> {
            App.main(new String[]{RESOURCE_PATH, "true"});
        });

        String output = outputStream.toString();
        System.out.println(output);

        assertTrue(output.contains("You do not have permission to delete this scroll."));

    }

    /**
     * Edge Case: Multiple database connection, force to create a database connection lock.
     */
    @Test
    void testDelete_DatabaseConnectionError() {
        File file = new File("src/test/resources/testFile/pray.txt");
        Database.addScroll("pray", file, "admin");

        try {
            PreparedStatement stmt = Database.conn.prepareStatement("SELECT MAX(scroll_id) FROM Scroll;");
            stmt.executeQuery();
        } catch (IllegalArgumentException e) {
            throw e;
        } catch (Exception e) {
            throw new IllegalStateException("Unexpected error occurred.");
        }

        String simulatedInput = "1\nadmin\n12345678\n2\n7\n2\n1\nQ\n3\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        App.scan = new Scanner(System.in);
        assertThrows(ExitProgramException.class, () -> {
            App.main(new String[]{RESOURCE_PATH, "true"});
        });

        String output = outputStream.toString();
        System.out.println(output);

        assertTrue(output.contains("Error: Database access error occurred."));
    }
}
