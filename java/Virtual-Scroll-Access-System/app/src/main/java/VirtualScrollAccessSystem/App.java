package VirtualScrollAccessSystem;
import java.util.Scanner;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.io.IOException;

/**
 * The {@code App} class is the main entry point of the Virtual Scroll Access System application.
 * It initializes and starts the application, providing basic setup and interaction logic.
 */
public class App {

    /**
     * The resource path for accessing database files in the app.
     */
    public static String resourcePath;

    /**
     * The {@link Database} object used for the application.
     */
    public static Database db;


    public static Scanner scan = new Scanner(System.in);

    /**
    * The entry point of the application. Initializes the necessary files and resources, and starts the application by prompting the user for the type of action to perform.
    *
    * @param args The command-line arguments. The first argument is used as the resource path for loading files.
    */    
    public static void main(String[] args) {

        String defaultResourcePath = System.getProperty("defaultResourcePath", "src/main/resources/");
        resourcePath = defaultResourcePath;
        boolean isTestMode = false;
    
        // update the resource path and test mode
        if (args.length > 0) {

            if (!args[0].isEmpty()) {
                resourcePath = args[0];
            }
            
            if (args.length > 1) {
                String testArg = args[1].toLowerCase();
                if (testArg.equals("true")) {
                    isTestMode = true;
                } else if (testArg.equals("false")) {
                    isTestMode = false;
                } else {
                    System.out.println("Invalid argument for test mode. Use 'true' or 'false'.");
                    return;
                }
            }
        }
    
        Path path = Paths.get(resourcePath);
    
        try {
            if (!Files.exists(path)) {
                Files.createDirectories(path);
                System.out.println("Resource folder did not exist. Created: " + path.toAbsolutePath());
            } else {
                System.out.println("Using existing resource folder: " + path.toAbsolutePath());
            }
        } catch (IOException e) {
            System.err.println("An error occurred while checking or creating the resource folder: " + e.getMessage());
        }
    
        Setup.loadConfig(resourcePath);
        db = new Database(resourcePath);
    
        Interface ui = new Interface(scan, isTestMode);
        ui.runLoginOrRegister();
    }
    }
