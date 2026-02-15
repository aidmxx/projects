package VirtualScrollAccessSystem;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Scanner;

import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

public class SampleTest {

    private static final String RESOURCE_PATH = "src/test/resources/";
    private static ByteArrayOutputStream outputStream;
    private static PrintStream originalOut;


    @BeforeAll
    static void setup() {
        originalOut = System.out;
        outputStream = new ByteArrayOutputStream();
        PrintStream printStream = new PrintStream(outputStream);
        System.setOut(printStream);
    }

    @BeforeEach
    void init() {
        try {
            Files.deleteIfExists(Paths.get(RESOURCE_PATH + "data.db"));
            Files.deleteIfExists(Paths.get(RESOURCE_PATH + "config.json"));
        } catch (IOException e) {
            System.err.println("Error while deleting test files: " + e.getMessage());
        }
    }

    @AfterAll
    static void tear() {

    }

    @Test
    void testExit() {
        // type your input here
        String simulatedInput = "4\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);
    
        App.scan = new Scanner(System.in);
    
        assertThrows(ExitProgramException.class, () -> {

            // please call the main method with two parameters:
            // - resource path
            // - "true"
            App.main(new String[]{RESOURCE_PATH, "true"});
        });
    
        System.setOut(originalOut);
        String output = outputStream.toString();
    
        // match the output here
        assertTrue(output.contains("Have a good day!"), "The output preview should be avalible.");
    }


    // @Test
    // void testGuestViewScroll() {
    //     String simulatedInput = "3\n1\nQ\n2\n4\n";
    //     ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
    //     System.setIn(inputStream);
    
    //     App.scan = new Scanner(System.in);
    
    //     assertThrows(ExitProgramException.class, () -> {
    //         App.main(new String[]{RESOURCE_PATH, "true"});
    //     });
    
    //     System.setOut(originalOut);
    //     String output = outputStream.toString();
    //     System.out.println(output);
    
    //     assertTrue(output.contains("No available Scrolls at the moment."), "The output preview should be avalible.");
    // }

}
