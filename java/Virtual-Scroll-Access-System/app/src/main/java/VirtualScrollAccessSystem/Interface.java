package VirtualScrollAccessSystem;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

import org.sqlite.date.ExceptionUtils;

import java.sql.SQLException;

public class Interface {
    private Scanner scan;
    private Timer timer;
    private String currentUserID;
    private String currentUserRole;
    protected String currentUsername;
    private boolean clearOnSuccess = true;
    private AdminUser adminUser = null;
    private User user;
    private boolean test = false;

    private static final char[] ILLEGAL_CHARACTERS = {'/', '\n', '\r', '\t', '\0', '\f', '`', '?', '*', '\\', '<', '>', '|', '\"', ':', '^', '{', '}'};

    public Interface(Scanner scan, boolean test) {
        this.scan = scan;
        this.user = null;
        this.test = test;
    }


    /**************************************************************************
     * 
     * Application Navigation
     * 
     **************************************************************************/


    public void runLoginOrRegister() {
        if (clearOnSuccess) {
            ClearTerminal.clearTerminal();
        }
        clearOnSuccess = true;
        System.out.println("Welcome to the library!");

        int UserOrGuest = -1;
        while (UserOrGuest == -1) {
            System.out.println("Do you want to log in to an existing account[1], register new account[2], visit as a guest[3], or exit[4]?");
            try {
                String userInput = scan.nextLine();
                UserOrGuest = Integer.parseInt(userInput);
                if (UserOrGuest < 1 || UserOrGuest > 4) {
                    ClearTerminal.clearTerminal();
                    System.out.println("Invalid input. Please try again.\n");
                    UserOrGuest = -1;
                }
            } catch (NumberFormatException e) {
                ClearTerminal.clearTerminal();
                System.out.println("Invalid input. Please try again.\n");
            }
        }
        if (UserOrGuest == 1) {
            loginProcess();
        } else if (UserOrGuest == 2) {
            registerProcess();
        } else if (UserOrGuest == 3) {
            guestMode();
        } else {
            exitProgram();
        }
    }

    private void loginProcess() {
        ClearTerminal.clearTerminal();
        LoginPart(true);
    }

    private void registerProcess() {
        ClearTerminal.clearTerminal();
        boolean isRegistered = RegisteredUser.registration();
        if (isRegistered) {
            LoginPart(false);
        } else {
            clearOnSuccess = false;
            ClearTerminal.clearTerminal();
            System.out.println("Registration cancelled.");
            runLoginOrRegister();
        }
    }

    private void exitProgram() {
        ClearTerminal.clearTerminal();
        scan.close();
        System.out.println("Have a good day!");

        if (test) {
            throw new ExitProgramException("Exit");
        } else {
            System.exit(0);
        }
    }

    public void LoginPart(boolean clearScreen) {
        if (clearScreen) {
            ClearTerminal.clearTerminal();
        }
        System.out.println("Please Enter your UserID. [Q] to exit");
        String userID = scan.nextLine();
        if (userID.equalsIgnoreCase("Q")) {
            ClearTerminal.clearTerminal();
            clearOnSuccess = false;
            System.out.println("Login cancelled.\n");
            runLoginOrRegister();
            return;
        }
        ClearTerminal.clearTerminal();
        System.out.println("Please Enter your password. [Q] to exit");
        String userPassword = scan.nextLine();
        if (userPassword.equalsIgnoreCase("Q")) {
            ClearTerminal.clearTerminal();
            clearOnSuccess = false;
            System.out.println("Login cancelled.");
            runLoginOrRegister();
            return;
        }
        boolean loginSuccess = User.verifyUserLogin(userID, userPassword);
        if (loginSuccess) {
            HashMap<String, String> userInfo = Database.getUserInfoByUserID(userID);
            currentUserID = userInfo.get("user_id");
            currentUserRole = userInfo.get("role");
            currentUsername = userInfo.get("username");
            SuccessTerminal();
        } else {
            ClearTerminal.clearTerminal();
            System.out.println("Login failed. Please check your User ID or password.\n");
            clearOnSuccess = false;
            runLoginOrRegister();
        }
    }

    public void showHeader() {
        System.out.println("--------------------------");
        System.out.println("Welcome " + currentUsername);
        System.out.println("You are login as a " + currentUserRole + "!");
        System.out.println("--------------------------");
    }

    public void SuccessTerminal() {
        if (clearOnSuccess) {
            ClearTerminal.clearTerminal();
        }
        clearOnSuccess = true;
        if (currentUserRole.equals("guest")) {
            int choice = -1;
            while (choice == -1) {
                showHeader();
                System.out.println("[1] View Scrolls");
                System.out.println("[2] Exit");
                System.out.println("Please select an operation:");
                String userInput = scan.nextLine();
                try {
                    choice = Integer.parseInt(userInput);
                    if (choice < 1 || choice > 2) {
                        ClearTerminal.clearTerminal();
                        System.out.println("Invalid input. Please try again.\n");
                        choice = -1;
                    } else if (choice == 2) {
                        Scroll_seeker(choice + 6);
                    } else {
                        Scroll_seeker(choice);
                    }
                } catch (NumberFormatException e) {
                    ClearTerminal.clearTerminal();
                    System.out.println("Invalid format. Please try again.\n");
                    choice = -1;
                }
            }
        } else if (currentUserRole.equals("user")) {
            userPanel();
        } else if (currentUserRole.equals("admin")) {
            if (adminUser == null) {
                adminUser = new AdminUser(scan, this);
            }
            adminUser.adminPanel();
        }
    }

    public void userPanel() {
        int choice = -1;
        while (choice == -1) {
            showHeader();
            System.out.println("VirtualScrollAccessSystem provides the following functions:");
            System.out.println("[0] Pick a lucky Scroll for Today");
            System.out.println("[1] View Scrolls");
            System.out.println("[2] Download Scrolls");
            System.out.println("[3] Upload Scrolls");
            System.out.println("[4] Search Scrolls");
            System.out.println("[5] Preview Scrolls");
            System.out.println("[6] Update Profile");
            System.out.println("[7] Edit Scroll");
            if (currentUserRole.equals("admin")) {
                System.out.println("[8] Log Out");
                System.out.println("[9] Return to Admin Panel");
            } else {
                System.out.println("[8] Log Out");
            }

            System.out.println("Please select an operation:");
            String userInput = scan.nextLine();
            try {
                choice = Integer.parseInt(userInput);

                if (currentUserRole.equals("admin")) {
                    if (choice >= 0 && choice <= 9) {
                        Scroll_seeker(choice);
                    } else {
                        ClearTerminal.clearTerminal();
                        System.out.println("Invalid input. Please try again.\n");
                        choice = -1;
                    }
                } else {
                    if (choice >= 0 && choice <= 8) {
                        Scroll_seeker(choice);
                    } else {
                        ClearTerminal.clearTerminal();
                        System.out.println("Invalid input. Please try again.\n");
                        choice = -1;
                    }
                }
            } catch (NumberFormatException e) {
                ClearTerminal.clearTerminal();
                System.out.println("Invalid input. Please try again.\n");
            }
        }
    }

    public void Scroll_seeker(int choice) {
        if (choice == 0) {
            pickLuckyScrollForToday();
        } else if (choice == 1) {
            ClearTerminal.clearTerminal();
            viewScrolls();
            exitCurrentPage();
        } else if (choice == 2) {
            ClearTerminal.clearTerminal();
            downloadScroll();
        } else if (choice == 3) {
            boolean uploadSuccess = uploadScroll();
            if (uploadSuccess) {

                userPanel();
            } else {
                userPanel();
            }
        } else if (choice == 4) {
            searchScrolls();
        } else if (choice == 5) {
            previewScroll();
        } else if (choice == 6) {
            updateProfile();
        } else if (choice == 7) {
            editScrollSelect();
        } else if (choice == 8) {
            runLoginOrRegister();
        } else if (choice == 9 && currentUserRole.equals("admin")) {
            ClearTerminal.clearTerminal();
            adminUser.adminPanel();
        }
    }



    /**************************************************************************
     * 
     * Utility Functions
     * 
     **************************************************************************/


    public void guestMode() {
        ClearTerminal.clearTerminal();
        currentUserID = "Guest";
        currentUserRole = "guest";
        currentUsername = "Guest";
        SuccessTerminal();
    }

    public boolean containsIllegalCharacters(String fileName) {
        for (char c : fileName.toCharArray()) {
            for (char illegalChar : ILLEGAL_CHARACTERS) {
                if (c == illegalChar) {
                    return true;
                }
            }
        }
        return false;
    }

    public void updateProfile() {
        RegisteredUser currentUser = new RegisteredUser(currentUserID);
        UserProfileManager profileManager = new UserProfileManager(currentUser, this);
        profileManager.showUpdateOptions();
    }

    public String getCurrentUserID() {
        return currentUserID;
    }


    /**************************************************************************
     * 
     * Preview Timer
     * 
     **************************************************************************/


    public void forceReturnToUserPanel() {
        ClearTerminal.clearTerminal();
        stopInactivityTimer();
        System.out.println("Due to inactivity, you have been blocked. Press [Enter] to reactivated current viewing, Press [Q] for being back to main panel.");
    }

    public void startInactivityTimer() {
        stopInactivityTimer();
        timer = new Timer();
        timer.schedule(new TimerTask() {
            @Override
            public void run() {
                forceReturnToUserPanel();
            }
        }, Setup.getInactivityLimit() * 1000L);
    }


    public void stopInactivityTimer() {
        if (timer != null) {
            timer.cancel();
            timer = null;
        }
    }


    /**************************************************************************
     * 
     * Scroll of the Day
     * 
     **************************************************************************/


    public void pickLuckyScrollForToday() {
        ClearTerminal.clearTerminal();
        showHeader();
        String userInput = "";

        try {
            Date currentDate = new Date(System.currentTimeMillis());
            int scrollID;

            try {
                scrollID = Database.getScrollIDOfTheDay(currentDate);
            } catch (IllegalArgumentException e) {
                scrollID = pickRandomTextScroll();
                Database.addDailyScroll(currentDate, scrollID);
            }
            HashMap<String, Object> scrollInfo = Database.getScrollInfoExceptContentByScrollID(scrollID);
            int fileType = (int) scrollInfo.get("file_type");
            String scrollName = (String) scrollInfo.get("name");

            do {
                ClearTerminal.clearTerminal();
                showHeader();
                if (fileType == 1) {
                    String scrollContent = new String(Database.getScrollContent(scrollID));
                    String truncatedContent = scrollContent.length() > 20 ? scrollContent.substring(0, 20) + "..." : scrollContent;
                    System.out.println("Today's lucky scroll: " + scrollName);
                    System.out.println("-----------------------------");
                    System.out.println("Content:\n");
                    System.out.println(truncatedContent);
                    System.out.println("-----------------------------");
                }
                System.out.println("Press [Q] to go back to the previous page.");

                userInput = scan.nextLine();

                if (!userInput.equalsIgnoreCase("Q")) {
                    System.out.println("Invalid input. Please try again.");
                }
            } while (!userInput.equalsIgnoreCase("Q"));

            ClearTerminal.clearTerminal();
            userPanel();

        } catch (IllegalStateException e) {
            ClearTerminal.clearTerminal();
            System.out.println(e.getMessage());
            userPanel();
        }
    }


    private int pickRandomTextScroll() throws IllegalStateException {
        try {
            ArrayList<HashMap<String, Object>> textScrolls = Database.getAllTextScrolls();

            if (textScrolls.isEmpty()) {
                throw new IllegalStateException("No text scrolls available.");
            }
            int randomIndex = (int) (Math.random() * textScrolls.size());
            HashMap<String, Object> selectedScroll = textScrolls.get(randomIndex);
            return (int) selectedScroll.get("scroll_id");
        } catch (SQLException e) {
            throw new IllegalStateException("Error occurred while retrieving text scrolls.", e);
        }
    }



    /**************************************************************************
     * 
     * View All Scroll
     * 
     **************************************************************************/


     public void viewScrolls() {
        ArrayList<HashMap<String, Object>> scrolls = Database.getAllScrollInfo();
        if (scrolls.isEmpty()) {
            showHeader();
            System.out.println("No available Scrolls at the moment.\n");
        } else {
            showHeader();
            System.out.println(String.format(
                    "%-17s %-13s %-15s %-15s %-12s",
                    "scrollName", "scrollID", "uploadTime", "uploader", "File Type"
            ));
            System.out.println("------------------------------------------------------------------------------------");

            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            for (HashMap<String, Object> scroll : scrolls) {
                String scrollName = (String) scroll.get("name");
                String scrollID = String.valueOf(scroll.get("scroll_id"));
                Date timestamp = (Date) scroll.get("timestamp");
                String uploadTime = dateFormat.format(timestamp);
                String uploader = (String) scroll.get("uploader");
                int fileType = (int) scroll.get("file_type");

                String fileTypeDescription = (fileType == 1) ? "readable" : "unreadable";

                System.out.println(String.format(
                        "%-20s %-10s %-15s %-15s %-12s",
                        scrollName, scrollID, uploadTime, uploader, fileTypeDescription
                ));
            }
            System.out.println("------------------------------------------------------------------------------------");
        }
    }


    /**************************************************************************
     * 
     * Preview Scroll Related
     * 
     **************************************************************************/

    public void previewScroll() {
        ClearTerminal.clearTerminal();
        while (true) {
            startInactivityTimer();
            viewScrolls();
            ArrayList<HashMap<String, Object>> scrolls = Database.getAllScrollInfo();
            if (scrolls.isEmpty()) {
                ClearTerminal.clearTerminal();
                System.out.println("No available scrolls at the moment. Press [Q] to go back.\n");
                String exitInput = scan.nextLine();
                if (exitInput.equalsIgnoreCase("Q")) {
                    ClearTerminal.clearTerminal();
                    stopInactivityTimer();
                    userPanel();
                    return;
                } else {
                    ClearTerminal.clearTerminal();
                    stopInactivityTimer();
                    System.out.println("Invalid input. Please press [Q] to go back.");
                    continue;
                }
            }
            System.out.println("Enter the scroll ID to preview or [Q] to go back:");
            String scroll_input = scan.nextLine();
            if (scroll_input.equalsIgnoreCase("Q")) {
                ClearTerminal.clearTerminal();
                stopInactivityTimer();
                userPanel();
                return;
            }

            int scrollID;
            try {
                scrollID = Integer.parseInt(scroll_input);
            } catch (NumberFormatException e) {
                ClearTerminal.clearTerminal();
                stopInactivityTimer();
                System.out.println("Invalid scroll ID format. Please try again.\n");
                continue;
            }
            HashMap<String, Object> scrollInfo = null;
            try {
                scrollInfo = Database.getScrollInfoExceptContentByScrollID(scrollID);
            } catch (IllegalArgumentException e) {
                ClearTerminal.clearTerminal();
                stopInactivityTimer();
                System.out.println("No scroll found with the provided scroll ID. Please try again.\n");
                continue;
            }

            ClearTerminal.clearTerminal();
            previewScrollContent(scrollInfo, scrollID);

            System.out.println("Press [Q] to go back or [Enter] to preview another scroll.");
            String nextInput = scan.nextLine();
            if (nextInput.equalsIgnoreCase("Q")) {
                ClearTerminal.clearTerminal();
                stopInactivityTimer();
                userPanel();
                return;
            } else {
                ClearTerminal.clearTerminal();
                stopInactivityTimer();
            }
        }
    }


    public void previewScrollContent(HashMap<String, Object> scrollInfo, int scrollID) {
        startInactivityTimer();
        String scrollName = (String) scrollInfo.get("name");
        int fileType = (int) scrollInfo.get("file_type");

        ClearTerminal.clearTerminal();
        System.out.println("Previewing Scroll: " + scrollName);
        System.out.println("-----------------------------");
        if (fileType == 1) {
            String scrollContent = Database.getScrollPreview(scrollID);
            System.out.println("Content:\n");
            System.out.println(scrollContent);
        } else {
            ClearTerminal.clearTerminal();
            System.out.println("This scroll is not a text file and cannot be previewed.\n");
            stopInactivityTimer();
        }
        System.out.println("-----------------------------");
    }




    /**************************************************************************
     * 
     * Edit Scroll Related
     * 
     **************************************************************************/



     
    public void editScrollSelect() {
        ClearTerminal.clearTerminal();
        int choice = -1;
        while (choice == -1) {
            showHeader();
            System.out.println("You want to edit your Scroll or want to delete?");
            System.out.println("[1] Edit Scroll");
            System.out.println("[2] Delete Scroll");
            System.out.println("[3] Exit Current Page");
            System.out.println("Please select an operation: ");
            String user_input = scan.nextLine();
            try {
                choice = Integer.parseInt(user_input);
                if (choice < 1 || choice > 3) {
                    ClearTerminal.clearTerminal();
                    System.out.println("Invalid input. Please try again.\n");
                    choice = -1;
                } else if (choice == 1) {
                    ClearTerminal.clearTerminal();
                    editScroll();
                } else if (choice == 2) {
                    ClearTerminal.clearTerminal();
                    deleteScroll();
                } else {
                    ClearTerminal.clearTerminal();
                    userPanel();
                }
            } catch (NumberFormatException e) {
                ClearTerminal.clearTerminal();
                System.out.println("Invalid format. Please try again.\n");
                choice = -1;
            }
        }
    }

    public void editScroll() {
        String errorMessage = null;
        while (true) {
            ClearTerminal.clearTerminal();
            if (errorMessage != null) {
                System.out.println(errorMessage);
                System.out.println();
                errorMessage = null;
            }
            viewScrolls();

            System.out.println("Enter the scroll ID you want to edit or press [Q] to go back:");
            String scroll_input = scan.nextLine();
            if (scroll_input.equalsIgnoreCase("Q")) {
                ClearTerminal.clearTerminal();
                editScrollSelect();
                return;
            }

            int scrollID;
            try {
                scrollID = Integer.parseInt(scroll_input);
            } catch (NumberFormatException e) {
                errorMessage = "Invalid scroll ID format. Please try again.";
                continue;
            }

            HashMap<String, Object> scrollInfo;
            try {
                scrollInfo = Database.getScrollInfoExceptContentByScrollID(scrollID);
            } catch (IllegalArgumentException e) {
                errorMessage = "No Scroll found. Please try again.";
                continue;
            } catch (Exception e) {
                errorMessage = "Unexcepted Error.";
                continue;
            }

            String uploader = (String) scrollInfo.get("uploader");
            if (!(currentUserID.equals(uploader) || currentUserRole.equals("admin"))) {
                errorMessage = "You do not have permission to edit this scroll.";
                continue;
            }
            
            ClearTerminal.clearTerminal();
            System.out.println("Enter the file path for the new scroll or press [Q] to go back:");
            String filePath = scan.nextLine();
            if (filePath.equalsIgnoreCase("Q")) {
                ClearTerminal.clearTerminal();
                editScrollSelect();
                return;
            }

            File file = new File(filePath);

            if (!file.exists()) {
                errorMessage = "Invalid path. File does not exist.";
                continue;
            }

            if (!file.isFile()) {
                errorMessage = "invalid path, please upload a file.";
                continue;
            }

            try {
                Database.updateScroll(file, scrollID);
                Database.updateUploadCounter(scrollID);
                System.out.println("Scroll content updated successfully! Press [Enter] to continue or [Q] to go back.");
                String retryInput = scan.nextLine();
                if (retryInput.equalsIgnoreCase("Q")) {
                    ClearTerminal.clearTerminal();
                    editScrollSelect();
                    return;
                }
            } catch (IllegalStateException e) {
                errorMessage = "Failed to update scroll content: " + e.getMessage();
            }
        }
    }




    /**************************************************************************
     * 
     * Delete Scroll Related
     * 
     **************************************************************************/

    
    public void deleteScroll() {
        while (true) {
            List<HashMap<String, Object>> scrolls;
            
            scrolls = Database.getAllScrollInfo();
            if (scrolls == null || scrolls.isEmpty()) {
                while (true) {
                    System.out.println("No scrolls available to delete. Press [Q] to go back: ");
                    String exitInput = scan.nextLine();
                    if (exitInput.equalsIgnoreCase("Q")) {
                        ClearTerminal.clearTerminal();
                        editScrollSelect();
                        return;
                    } else {
                        System.out.println("Invalid input. Please press [Q] to go back.\n");
                    }
                }
            }
            System.out.println(String.format("%-10s %-20s %-20s", "scroll_id", "scroll_name", "uploader"));
            System.out.println("----------------------------------------------------------");
            for (HashMap<String, Object> scroll : scrolls) {
                int scroll_id = (int) scroll.get("scroll_id");
                String scroll_name = (String) scroll.get("name");
                String uploaded_by = (String) scroll.get("uploader");
                System.out.println(String.format("%-10d %-20s %-20s", scroll_id, scroll_name, uploaded_by));
            }
            System.out.println("----------------------------------------------------------");
            System.out.print("Enter the scroll_id to delete or [Q] to quit: ");
            String userInput = scan.nextLine();
            if (userInput.equalsIgnoreCase("Q")) {
                ClearTerminal.clearTerminal();
                editScrollSelect();
                break;
            }
            try {
                int scroll_id = Integer.parseInt(userInput);

                if (currentUserRole.equals("user") && !Database.isUserScroll(currentUserID, scroll_id)) {
                    ClearTerminal.clearTerminal();
                    System.out.println("You do not have permission to delete this scroll.\n");
                    continue;
                }
                Database.deleteScroll(scroll_id);
                ClearTerminal.clearTerminal();
                System.out.println("Scroll deleted successfully!\n");
            } catch (NumberFormatException e) {
                ClearTerminal.clearTerminal();
                System.out.println("Invalid input. Please enter a valid scroll_id.\n");
                continue;
            } catch (IllegalArgumentException e) {
                ClearTerminal.clearTerminal();
                System.out.println("Error: " + e.getMessage() + "\n");
                continue;
            } catch (IllegalStateException e) {
                System.out.println("Error: " + e.getMessage() + "\n");
                continue;
            }
        }
    }

    public void exitCurrentPage() {
        System.out.println("Enter [Q] to exit current page");
        String userInput;
        do {
            userInput = scan.nextLine();
            if (!userInput.equalsIgnoreCase("Q")) {
                ClearTerminal.clearTerminal();
                viewScrolls();
                System.out.println("Invalid input. Enter [Q] to exit current page.\n");
            }
        } while (!userInput.equalsIgnoreCase("Q"));

        ClearTerminal.clearTerminal();
        stopInactivityTimer();

        if (currentUserRole.equals("guest")) {
            SuccessTerminal();
        } else {
            userPanel();
        }
    }





    /**************************************************************************
     * 
     * Upload Scroll Related
     * 
     **************************************************************************/

    

    public boolean uploadScroll() {
        ClearTerminal.clearTerminal();
        showHeader();
        String scrollName;

        do {
            System.out.println("Please provide the scroll name, [Q] to abort");
            scrollName = scan.nextLine();
            if (scrollName.equalsIgnoreCase("Q")) {
                ClearTerminal.clearTerminal();
                System.out.println("Upload cancelled.\n");
                return false;
            }
            if (containsIllegalCharacters(scrollName)) {
                ClearTerminal.clearTerminal();
                showHeader();
                System.out.println("Scroll name contains illegal characters. Please try again.\n");
            }
        } while (containsIllegalCharacters(scrollName));

        ClearTerminal.clearTerminal();
        showHeader();
        String filePath;
        File file;
        do {
            System.out.println("Please provide the file path for the scroll content, [Q] to abort");
            filePath = scan.nextLine();
            if (filePath.equalsIgnoreCase("Q")) {
                ClearTerminal.clearTerminal();
                System.out.println("Upload cancelled.\n");
                return false;
            }
            file = new File(filePath);
            if (!file.exists()) {
                ClearTerminal.clearTerminal();
                showHeader();
                System.out.println("The file does not exist. Please check the file path and try again.\n");
                continue;
            }
            if (!isBinaryFile(file)) {
                ClearTerminal.clearTerminal();
                showHeader();
                System.out.println("Invalid file type. Please upload a valid binary file (e.g., .jpg, .png, .pdf, .txt).\n");
            }
        } while (!file.exists() || !isBinaryFile(file));

        try {
            Database.addScroll(scrollName, file, currentUserID);
            ClearTerminal.clearTerminal();
            System.out.println("Scroll uploaded successfully!\n");
            return true;
        } catch (IllegalArgumentException e) {
            ClearTerminal.clearTerminal();
            System.out.println(e.getMessage());
            return false;
        } catch (IllegalStateException e) {
            ClearTerminal.clearTerminal();
            System.out.println("An unexpected error occurred: " + e.getMessage() + "\n");
            return false;
        }
    }

    private boolean isBinaryFile(File file) {
        String fileName = file.getName().toLowerCase();
        String[] allowedExtensions = {".jpg", ".png", ".pdf", ".docx", ".xlsx", ".zip", ".rar", ".txt", ".py", ".java", ".json", ".csv"};
        for (String extension : allowedExtensions) {
            if (fileName.endsWith(extension)) {
                return true;
            }
        }
        return false;
    }



    /**************************************************************************
     * 
     * Download Scroll Related
     * 
     **************************************************************************/


    public void downloadScroll() {
        ClearTerminal.clearTerminal();
        while (true) {
            viewScrolls();
            System.out.println("Enter the scroll ID to download or press [Q] to go back:");
            String d_input = scan.nextLine();
            if (d_input.equalsIgnoreCase("Q")) {
                ClearTerminal.clearTerminal();
                userPanel();
                return;
            }
            try {
                int d_scrollID = Integer.parseInt(d_input);
                HashMap<String, Object> scrollInfo = Database.getScrollInfoExceptContentByScrollID(d_scrollID);
                if (scrollInfo == null || scrollInfo.isEmpty()) {
                    ClearTerminal.clearTerminal();
                    System.out.println("Scroll not found. Please try again.");
                    continue;
                }
                String filename = (String) scrollInfo.get("filename");
                String d_scrollName = (String) scrollInfo.get("name");
                String uploader = (String) scrollInfo.get("uploader");
                int fileType = (int) scrollInfo.get("file_type");

                ClearTerminal.clearTerminal();
                System.out.println("\nScroll Preview:");
                System.out.println("Name: " + d_scrollName);
                System.out.println("Uploader: " + uploader);
                System.out.println("File Type: " + (fileType == 1 ? "Text" : "Binary"));
                System.out.println("\nPreview: " + Database.getScrollPreview(d_scrollID));

                System.out.println("\nDo you want to download this scroll? (Y/N)");
                String downloadChoice = scan.nextLine().trim();
                if (!downloadChoice.equalsIgnoreCase("Y") && !downloadChoice.equalsIgnoreCase("N")) {
                    ClearTerminal.clearTerminal();
                    System.out.println("Invalid input. Please try again.");
                    continue;
                }
                if (downloadChoice.equalsIgnoreCase("N")) {
                    ClearTerminal.clearTerminal();
                    System.out.println("Download aborted.");
                    continue;
                }
                if (!currentUserRole.equals("admin") && !currentUserID.equals(uploader)) {
                    ClearTerminal.clearTerminal();
                    System.out.println("Download failed: You do not have permission to download this file.");
                    continue;
                }
                String downloadPath;
                ClearTerminal.clearTerminal();
                while (true) {
                    showHeader();
                    System.out.println("Enter the target directory or press [Q] to abort:");
                    downloadPath = scan.nextLine();
                    if (downloadPath.equalsIgnoreCase("Q")) {
                        ClearTerminal.clearTerminal();
                        System.out.println("Download aborted.");
                        break;
                    }

                    try {
                        Path path = Paths.get(downloadPath, filename);
                        Files.write(path, Database.getScrollContent(d_scrollID));
                        System.out.println("Download successful to: " + path.toAbsolutePath());
                        Database.updateDownloadCounter(d_scrollID);
                        break;
                    } catch (IOException e) {
                        ClearTerminal.clearTerminal();
                        System.out.println("Invalid path. Please try again.");
                    }
                }

                System.out.println("Press [Enter] to download another scroll or [Q] to quit:");
                String choice = scan.nextLine();
                if (choice.equalsIgnoreCase("Q")) {
                    ClearTerminal.clearTerminal();
                    userPanel();
                    return;
                }

            } catch (NumberFormatException e) {
                ClearTerminal.clearTerminal();
                System.out.println("Invalid scroll ID format. Please try again.");
            } catch (IllegalArgumentException e) {
                ClearTerminal.clearTerminal();
                System.out.println("Error: " + e.getMessage());
            } catch (Exception e) {
                ClearTerminal.clearTerminal();
                System.out.println("Unexpected error: " + e.getMessage());
            }
        }
    }





    /**************************************************************************
     * 
     * Search Scroll Related
     * 
     **************************************************************************/


    public void searchScrolls() {
        ClearTerminal.clearTerminal();
        while (true) {
            showHeader();
            System.out.println("Search scrolls:");
            System.out.println("[1] Search by scroll ID");
            System.out.println("[2] Search by uploader");
            System.out.println("[3] Search by date range");
            System.out.println("[4] Return to previous menu");
            System.out.println();
            System.out.print("Select search method: ");
            
            String choice = scan.nextLine().trim();
            
            if (choice.equalsIgnoreCase("Q")) {
                ClearTerminal.clearTerminal();
                userPanel();
                return;
            }
            
            if (!choice.equals("1") && !choice.equals("2") && !choice.equals("3") && !choice.equals("4")) {
                System.out.println("\nInvalid input. Please enter a number between 1 and 4.");
                scan.nextLine();
                ClearTerminal.clearTerminal();
                continue;
            }
            
            int newChoice = Integer.parseInt(choice);
            
            ArrayList<HashMap<String, Object>> res = new ArrayList<>();
            
            if (newChoice == 1) {
                ClearTerminal.clearTerminal();
                res = searchByScrollID();
            } else if (newChoice == 2) {
                ClearTerminal.clearTerminal();
                res = searchByUploader();
            } else if (newChoice == 3) {
                ClearTerminal.clearTerminal();
                res = searchByDateRange();
            } else if (newChoice == 4) {
                ClearTerminal.clearTerminal();
                userPanel();
                return;
            }

            ClearTerminal.clearTerminal();
            if (res != null && !res.isEmpty()) {
                displaySearchResults(res);
            } else {
                System.out.println("No scrolls found.");
            }
            
            System.out.println();
            System.out.println("Press [Enter] to continue searching, or enter [Q] to abort.");
            String continueChoice = scan.nextLine().trim();
            if (continueChoice.equalsIgnoreCase("Q")) {
                ClearTerminal.clearTerminal();
                userPanel();
                return;
            }
            ClearTerminal.clearTerminal();
        }
    }

    private ArrayList<HashMap<String, Object>> searchByScrollID() {

        System.out.print("Enter scroll ID or Press [Q] to go back: \n");
        String scroll_Input = scan.nextLine().trim();
        if (scroll_Input.equalsIgnoreCase("Q")) {
            ClearTerminal.clearTerminal();
            return new ArrayList<>();
        }
        try {
            int scrollID = Integer.parseInt(scroll_Input);
            HashMap<String, Object> scroll = Database.getScrollInfoExceptContentByScrollID(scrollID);
            ArrayList<HashMap<String, Object>> result = new ArrayList<>();
            result.add(scroll);
            return result;
        } catch (NumberFormatException e) {
            ClearTerminal.clearTerminal();
            System.out.println("Invalid scroll ID format. Please try again");
        } catch (IllegalArgumentException e) {
            ClearTerminal.clearTerminal();
            System.out.println(e.getMessage());
        }
        return new ArrayList<>();
    }

    private ArrayList<HashMap<String, Object>> searchByUploader() {
        ClearTerminal.clearTerminal();
        System.out.print("Enter uploader ID or Press [Q] to go back: \n");
        String uploader = scan.nextLine().trim();
        if (uploader.equalsIgnoreCase("Q")) {
            ClearTerminal.clearTerminal();
            return new ArrayList<>();
        }
        ArrayList<HashMap<String, Object>> res = Database.searchScrollByUploader(uploader);
        return res;
    }

    private ArrayList<HashMap<String, Object>> searchByDateRange() {
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        Date startDate = null;
        Date endDate = null;
        ClearTerminal.clearTerminal();
        while (startDate == null) {
            System.out.print("\nEnter start date (YYYY-MM-DD) or Press [Q] to go back: \n");
            String startDateStr = scan.nextLine().trim();
            if (startDateStr.equalsIgnoreCase("Q")) {
                ClearTerminal.clearTerminal();
                return new ArrayList<>();
            }
            if (isValidDate(startDateStr)) {
                try {
                    startDate = dateFormat.parse(startDateStr);
                } catch (ParseException e) {
                    ClearTerminal.clearTerminal();
                    System.out.println("\nError parsing date. Please try again.");
                }
            } else {
                ClearTerminal.clearTerminal();
                System.out.println("\nInvalid date. Please enter a valid date in YYYY-MM-DD format.");
            }
        }
        ClearTerminal.clearTerminal();
        while (endDate == null) {
            System.out.print("\nEnter end date (YYYY-MM-DD) or Press [Q] to go back: \n");
            String endDateStr = scan.nextLine().trim();
            if (endDateStr.equalsIgnoreCase("Q")) {
                ClearTerminal.clearTerminal();
                return new ArrayList<>();
            }
            if (isValidDate(endDateStr)) {
                try {
                    endDate = dateFormat.parse(endDateStr);
                    if (endDate.before(startDate)) {
                        ClearTerminal.clearTerminal();
                        System.out.println("\nEnd date must be after start date.");
                        endDate = null;
                    }
                } catch (ParseException e) {
                    ClearTerminal.clearTerminal();
                    System.out.println("\nError parsing date. Please try again.");
                }
            } else {
                ClearTerminal.clearTerminal();
                System.out.println("\nInvalid date. Please enter a valid date in YYYY-MM-DD format.");
            }
        }
        
        return Database.searchScrollByTimeRange(startDate, endDate);
    }

    private boolean isValidDate(String dateStr) {
        if (!dateStr.matches("\\d{4}-\\d{2}-\\d{2}")) {
            return false;
        }
        String[] parts = dateStr.split("-");
        int year = Integer.parseInt(parts[0]);
        int month = Integer.parseInt(parts[1]);
        int day = Integer.parseInt(parts[2]);
        
        if (year < 1 || month < 1 || month > 12 || day < 1) {
            return false;
        }
        
        int[] daysInMonth = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
        if (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) {
            daysInMonth[1] = 29;
        }
        
        return day <= daysInMonth[month - 1];
    }

    private void displaySearchResults(ArrayList<HashMap<String, Object>> results) {
        if (results.isEmpty()) {
            System.out.println("No matching results found.");
        } else {
            System.out.println();
            System.out.println(String.format("%-15s %-10s %-15s %-15s", "Scroll ID", "Name", "Uploader", "Upload Time"));
            System.out.println("----------------------------------------------------------");
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            for (HashMap<String, Object> result : results) {
                int id = (int) result.get("scroll_id");
                String name = (String) result.get("name");
                String uploader = (String) result.get("uploader");
                Date timestamp = (Date) result.get("timestamp");
                String uploadTime = sdf.format(timestamp);
                System.out.println(String.format("%-15d %-10s %-15s %-15s", id, name, uploader, uploadTime));
            }
            System.out.println("----------------------------------------------------------");
        }
    }
}