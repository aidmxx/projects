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

public class SearchScrollTest {
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
     *Test for exit the search interface by entering 4..
     */
    @Test
    void testNAdmin_Exit() {
        String simulatedInput = "1\nadmin\n12345678\n2\n4\n4\n8\n4\n";
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
     *Test for exit the search interface by entering q.
     */
    @Test
    void testNAdmin_ExitByQ() {
        String simulatedInput = "1\nadmin\n12345678\n2\n4\nq\n8\n4\n";
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
    * Test for search a non-existent file by ID.
     */
    @Test
    void testNAdmin_SearchByID_NoFile() {
        String simulatedInput = "1\nadmin\n12345678\n2\n4\n1\n1\nq\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        App.scan = new Scanner(System.in);

        assertThrows(ExitProgramException.class, () -> {
            App.main(new String[]{RESOURCE_PATH, "true"});
        });

        String output = outputStream.toString();
        System.out.println(output);

        assertTrue(output.contains("No scroll found with the provided scroll_id."));
        assertTrue(output.contains("No scrolls found."));
    }


    /**
     * Test for search a non-existent file by uploader.
     */
    @Test
    void testNAdmin_SearchByName_NoFile() {
        String simulatedInput = "1\nadmin\n12345678\n2\n4\n2\n001\nq\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        App.scan = new Scanner(System.in);

        assertThrows(ExitProgramException.class, () -> {
            App.main(new String[]{RESOURCE_PATH, "true"});
        });

        String output = outputStream.toString();
        System.out.println(output);

        assertTrue(output.contains("No scrolls found."));
    }


    /**
     * Test for search a non-existent file by date.
     */
    @Test
    void testNAdmin_SearchByDate_NoFile() {
        String simulatedInput = "1\nadmin\n12345678\n2\n4\n3\n2024-01-01\n2024-12-30\nq\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        App.scan = new Scanner(System.in);

        assertThrows(ExitProgramException.class, () -> {
            App.main(new String[]{RESOURCE_PATH, "true"});
        });

        String output = outputStream.toString();
        System.out.println(output);

        assertTrue(output.contains("No scrolls found."));
    }

    /**
     * Test for search a file by ID.
     */
    @Test
    void testNAdmin_SearchByID_File() {
        File file = new File("src/test/resources/testFile/UploadTest.txt");
        Database.addScroll("Test", file, "admin");

        String simulatedInput = "1\nadmin\n12345678\n2\n4\n1\n1\nq\n8\n4\n";
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
     * Test for search a file by uploader.
     */
    @Test
    void testNAdmin_SearchByUploader_File() {
        File file = new File("src/test/resources/testFile/UploadTest.txt");
        Database.addScroll("Test", file, "admin");

        String simulatedInput = "1\nadmin\n12345678\n2\n4\n2\nadmin\nq\n8\n4\n";
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
     * Test for search a file by date.
     */
    @Test
    void testNAdmin_SearchByDate_File() {
        File file = new File("src/test/resources/testFile/UploadTest.txt");
        Database.addScroll("Test", file, "admin");

        String simulatedInput = "1\nadmin\n12345678\n2\n4\n3\n2024-01-01\n2024-12-30\nq\n8\n4\n";
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
     * Test for search a file by invalid date.
     */
    @Test
    void testNAdmin_SearchByInvalidDate_File() {
        File file = new File("src/test/resources/testFile/UploadTest.txt");
        Database.addScroll("Test", file, "admin");

        String simulatedInput = "1\nadmin\n12345678\n2\n4\n3\n2024-13-30\nq\nq\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        App.scan = new Scanner(System.in);

        assertThrows(ExitProgramException.class, () -> {
            App.main(new String[]{RESOURCE_PATH, "true"});
        });

        String output = outputStream.toString();
        System.out.println(output);

        assertTrue(output.contains("Invalid date. Please enter a valid date in YYYY-MM-DD format."));
    }


    /**
     * Test for search a file by reverse date.
     */
    @Test
    void testNAdmin_SearchByReverseDate_File() {
        File file = new File("src/test/resources/testFile/UploadTest.txt");
        Database.addScroll("Test", file, "admin");

        String simulatedInput = "1\nadmin\n12345678\n2\n4\n3\n2024-12-30\n2024-01-01\nq\nq\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        App.scan = new Scanner(System.in);

        assertThrows(ExitProgramException.class, () -> {
            App.main(new String[]{RESOURCE_PATH, "true"});
        });

        String output = outputStream.toString();
        System.out.println(output);

        assertTrue(output.contains("End date must be after start date."));
    }


    /**
     * Test for enter a value or letter that is not between 1 and 4.
     */
    @Test
    void testNAdmin_Invalid() {
        String simulatedInput = "1\nadmin\n12345678\n2\n4\n5\n4\n4\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        App.scan = new Scanner(System.in);

        assertThrows(ExitProgramException.class, () -> {
            App.main(new String[]{RESOURCE_PATH, "true"});
        });

        String output = outputStream.toString();
        System.out.println(output);

        assertTrue(output.contains("Invalid input. Please enter a number between 1 and 4."));
    }

    /**
     * Attempt to enter illegal characters when inputting an ID.
     */
    @Test
    void testNAdmin_SearchByNFEID_File() {
        File file = new File("src/test/resources/testFile/UploadTest.txt");
        Database.addScroll("Test", file, "admin");

        String simulatedInput = "1\nadmin\n12345678\n2\n4\n1\n@@@@@@\nq\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        App.scan = new Scanner(System.in);

        assertThrows(ExitProgramException.class, () -> {
            App.main(new String[]{RESOURCE_PATH, "true"});
        });

        String output = outputStream.toString();
        System.out.println(output);

        assertTrue(output.contains("Invalid scroll ID format. Please try again"));
        assertTrue(output.contains("No scrolls found."));
    }

    /**
     * Attempt to enter illegal characters when inputting an uploader.
     */
    @Test
    void testNAdmin_SearchByNFEUploader_File() {
        File file = new File("src/test/resources/testFile/UploadTest.txt");
        Database.addScroll("Test", file, "admin");

        String simulatedInput = "1\nadmin\n12345678\n2\n4\n2\n@@@@@@\nq\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        App.scan = new Scanner(System.in);

        assertThrows(ExitProgramException.class, () -> {
            App.main(new String[]{RESOURCE_PATH, "true"});
        });

        String output = outputStream.toString();
        System.out.println(output);

        assertTrue(output.contains("No scrolls found."));
    }

    /**
     * Attempt to enter illegal characters when inputting date.
     */
    @Test
    void testNAdmin_SearchByNFEDate_File() {
        File file = new File("src/test/resources/testFile/UploadTest.txt");
        Database.addScroll("Test", file, "admin");

        String simulatedInput = "1\nadmin\n12345678\n2\n4\n3\n@@@@@\nq\nq\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        App.scan = new Scanner(System.in);

        assertThrows(ExitProgramException.class, () -> {
            App.main(new String[]{RESOURCE_PATH, "true"});
        });

        String output = outputStream.toString();
        System.out.println(output);

        assertTrue(output.contains("Invalid date. Please enter a valid date in YYYY-MM-DD format."));
    }

    /**
     * Test for search a file by date.
     */
    @Test
    void testNAdmin_SearchByErrorDateFormat_File() {
        File file = new File("src/test/resources/testFile/UploadTest.txt");
        Database.addScroll("Test", file, "admin");

        String simulatedInput = "1\nadmin\n12345678\n2\n4\n3\n2222\nq\nq\n8\n4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        App.scan = new Scanner(System.in);

        assertThrows(ExitProgramException.class, () -> {
            App.main(new String[]{RESOURCE_PATH, "true"});
        });

        String output = outputStream.toString();
        System.out.println(output);

        assertTrue(output.contains("Invalid date. Please enter a valid date in YYYY-MM-DD format."));
    }
}
