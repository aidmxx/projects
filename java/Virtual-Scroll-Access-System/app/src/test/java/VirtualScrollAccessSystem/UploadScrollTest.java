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

public class UploadScrollTest {
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
     *Test if it can exit the current interface by pressing 'q' when entering file name.
     */

    @Test
    void testNAdmin_Exit() {
        String simulatedInput = "1\nadmin\n12345678\n2\n3\nq\n8\n4\n";
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
     *Test if it can exit the current interface by pressing 'q' when entering file path.
     */
    @Test
    void testNAdmin_ExitINStep2() {
        String simulatedInput = "1\nadmin\n12345678\n2\n3\nabc\nq\n8\n4\n";
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
     *Test for invalid file path.
     */
    @Test
    void testPanel_InvalidPath() {
        String simulatedInput = "1\nadmin\n12345678\n2\n3\nabc\nqqw\nsrc/test/resources/testFile/UploadTest.txt\n8\n4";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        App.scan = new Scanner(System.in);

        assertThrows(ExitProgramException.class, () -> {
            App.main(new String[]{RESOURCE_PATH, "true"});
        });

        String output = outputStream.toString();
        System.out.println(output);

        assertTrue(output.contains("The file does not exist. Please check the file path and try again."));
    }


    /**
     *Test for upload directory.
     */
    @Test
    void testPanel_Dirc() {
        String simulatedInput = "1\nadmin\n12345678\n2\n3\nabc\nsrc/test/resources/testFile\nq\n8\n4";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        App.scan = new Scanner(System.in);

        assertThrows(ExitProgramException.class, () -> {
            App.main(new String[]{RESOURCE_PATH, "true"});
        });

        String output = outputStream.toString();
        System.out.println(output);

        assertTrue(output.contains("Invalid file type. Please upload a valid binary file (e.g., .jpg, .png, .pdf, .txt)."));
    }


    /**
     *Test for entering a name that already exists.
     */
    @Test
    void testPanel_RepeatName() {
        String simulatedInput = "1\nadmin\n12345678\n2\n3\nabc\nsrc/test/resources/testFile/UploadTest.txt\n3\nabc\nsrc/test/resources/testFile/UploadTest.txt\n8\n4";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        App.scan = new Scanner(System.in);

        assertThrows(ExitProgramException.class, () -> {
            App.main(new String[]{RESOURCE_PATH, "true"});
        });

        String output = outputStream.toString();
        System.out.println(output);

        assertTrue(output.contains("This name already exists! Please enter a new name."));
    }



    /**
     *Test for upload python file.
     */
    @Test
    void testPanel_PythonFile() {
        String simulatedInput = "1\nadmin\n12345678\n2\n3\ncab\nsrc/test/resources/testFile/UploadTest.py\n8\n4";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        App.scan = new Scanner(System.in);

        assertThrows(ExitProgramException.class, () -> {
            App.main(new String[]{RESOURCE_PATH, "true"});
        });

        String output = outputStream.toString();
        System.out.println(output);

        assertTrue(output.contains("Scroll uploaded successfully!"));
    }


    /**
     *Test for upload rar file.
     */
    @Test
    void testPanel_rarFile() {
        String simulatedInput = "1\nadmin\n12345678\n2\n3\ndac\nsrc/test/resources/testFile/UploadTest.rar\n8\n4";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        App.scan = new Scanner(System.in);

        assertThrows(ExitProgramException.class, () -> {
            App.main(new String[]{RESOURCE_PATH, "true"});
        });

        String output = outputStream.toString();
        System.out.println(output);

        assertTrue(output.contains("Scroll uploaded successfully!"));
    }

    /**
     *Test for illegal character input.
     */
    @Test
    void testPanel_illegal() {
        String simulatedInput = "1\nadmin\n12345678\n2\n3\n?@||@@@\nq\n8\n4";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        App.scan = new Scanner(System.in);

        assertThrows(ExitProgramException.class, () -> {
            App.main(new String[]{RESOURCE_PATH, "true"});
        });

        String output = outputStream.toString();
        System.out.println(output);

        assertTrue(output.contains("Scroll name contains illegal characters. Please try again."));
    }
}