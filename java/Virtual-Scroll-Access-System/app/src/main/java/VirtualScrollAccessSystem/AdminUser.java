package VirtualScrollAccessSystem;

import java.util.Scanner;
import java.util.*;

/**
 * The {@code AdminUser} class represents an administrator user in the Virtual Scroll Access System.
 * Admin users have the ability to access the admin panel and perform administrative tasks.
 */
public class AdminUser extends RegisteredUser {
    private Scanner scan;
    private Interface userInterface;


    public AdminUser(Scanner scan, Interface userInterface) {
        super(userInterface.getCurrentUserID());
        this.scan = scan;
        this.userInterface = userInterface;
    }






    public void adminPanel() {
        userInterface.showHeader();
        int choice = -1;
        while (choice == -1) {
            System.out.println("Welcome to Admin Panel!");
            System.out.println("[1] Access Admin Functions");
            System.out.println("[2] Normal UserPanel");
            System.out.println("[3] Log Out");
            System.out.println("Please select an operation:");
            String userInput = scan.nextLine();
            try {
                choice = Integer.parseInt(userInput);
                if (choice == 1) {
                    ClearTerminal.clearTerminal();
                    adminFunctions();
                } else if (choice == 2) {
                    ClearTerminal.clearTerminal();
                    userInterface.userPanel();
                } else if (choice == 3) {
                    ClearTerminal.clearTerminal();
                    userInterface.runLoginOrRegister();
                } else {
                    ClearTerminal.clearTerminal();
                    System.out.println("Invalid input. Please try again.\n");
                    choice = -1;
                }
            } catch (NumberFormatException e) {
                ClearTerminal.clearTerminal();
                System.out.println("Invalid input format. Please enter a valid number.\n");
            }
        }
    }

    private void adminFunctions() {
        userInterface.showHeader();
        int adminChoice = -1;
        while (adminChoice == -1) {
            System.out.println("Welcome to Admin Management");
            System.out.println("[1] View all users and their profiles");
            System.out.println("[2] Add a new user");
            System.out.println("[3] Delete a user");
            System.out.println("[4] View statistics (downloads/uploads)");
            System.out.println("[5] Back to Admin Panel");
            System.out.println("[6] Set Inactivity Timer");
            System.out.println("Please select an operation:");
            String userInput = scan.nextLine();
            try {
                adminChoice = Integer.parseInt(userInput);

                if (adminChoice == 1) {
                    ClearTerminal.clearTerminal();
                    viewAllUsers();
                    exitCurrentPage_viewAllUser();
                } else if (adminChoice == 2) {
                    ClearTerminal.clearTerminal();
                    addUser();
                } else if (adminChoice == 3) {
                    ClearTerminal.clearTerminal();
                    deleteUser();
                } else if (adminChoice == 4) {
                    ClearTerminal.clearTerminal();
                    viewStatistics();
                } else if (adminChoice == 5) {
                    ClearTerminal.clearTerminal();
                    adminPanel();
                } else if (adminChoice == 6) {
                    ClearTerminal.clearTerminal();
                    setNewInactivityLimit();
                } else {
                    System.out.println("Invalid input. Please try again.\n");
                    adminChoice = -1;
                }
            } catch (NumberFormatException e) {
                System.out.println("Invalid input format. Please enter a valid number.\n");
                adminChoice = -1;
            }
        }
    }


    public void setNewInactivityLimit() {
        while (true) {
            userInterface.showHeader();
            System.out.print("Currently limit seconds is " + Setup.getInactivityLimit() + "\n");
            System.out.print("--------------------------------------\n");
            System.out.print("Enter new inactivity limit in seconds or press [Q] to go back: \n");
            String userInput = scan.nextLine();
            if (userInput.equalsIgnoreCase("Q")) {
                ClearTerminal.clearTerminal();
                adminPanel();
                return;
            }

            try {
                int newLimit = Integer.parseInt(userInput);
                if (newLimit <= 0){
                    ClearTerminal.clearTerminal();
                    System.out.println("Invalid number. Inactivity limit must be greater than 0.  Please enter a valid number or press [Q] to go back.\n");
                    continue;
                }
                Setup.setInactivityLimit(newLimit);
                ClearTerminal.clearTerminal();
                System.out.println("Inactivity limit set to " + newLimit + " seconds.");
                adminPanel();
                return;
            } catch (NumberFormatException e) {
                ClearTerminal.clearTerminal();
                System.out.println("Invalid input. Please enter a valid number or press [Q] to go back.\n");
            }
        }
    }



    private void viewStatistics() {
        ArrayList<HashMap<String, Object>> statistics = Database.getScrollStatistics();

        if (statistics.isEmpty()) {
            System.out.println("No scroll statistics available at the moment.\n");
        } else {
            System.out.println(String.format("%-10s %-15s %-15s", "Scroll ID", "Download times", "Upload/Update times"));
            System.out.println("--------------------------------------------------");

            for (HashMap<String, Object> stat : statistics) {
                int scrollID = (int) stat.get("scroll_id");
                int downloadCount = (int) stat.get("download_counter");
                int uploadCount = (int) stat.get("upload_counter");

                System.out.println(String.format("%-10d %-15d %-15d", scrollID, downloadCount, uploadCount));
            }

            System.out.println("--------------------------------------------------");
        }

        System.out.println("Enter [Q] to exit current page");
        String userInput;
        do {
            userInput = scan.nextLine();
            if (!userInput.equalsIgnoreCase("Q")) {
                ClearTerminal.clearTerminal();
                viewStatistics();
                System.out.println("Invalid input. Enter [Q] to exit current page.");
            }
        } while (!userInput.equalsIgnoreCase("Q"));
        ClearTerminal.clearTerminal();
        adminFunctions();
    }

    private void viewAllUsers() {
        userInterface.showHeader();
        ArrayList<HashMap<String, String>> allUsersInfo = Database.getAllUserInfo();
        System.out.println(String.format("%-10s %-15s %-15s %-15s %-10s", "user_id", "username", "role", "phone_num", "email"));
        System.out.println("-----------------------------------------------------------------------------");

        for (HashMap<String, String> userInfo : allUsersInfo) {
            String userId = userInfo.get("user_id");
            String username = userInfo.get("username");
            String role = userInfo.get("role");
            String phoneNum = userInfo.get("phone_num");
            String email = userInfo.get("email");

            System.out.println(String.format("%-10s %-15s %-15s %-15s %-10s", userId, username, role, phoneNum, email));
        }

        System.out.println("-----------------------------------------------------------------------------");
    }

    private void addUser() {
        boolean validInput = false;
        userInterface.showHeader();
        while (!validInput) {
            System.out.print("Enter user details as this format (user_id, username, password, role, phone_num, email) or [Q] to quit:\n");
            String userInput = scan.nextLine();
            if (userInput.equalsIgnoreCase("Q")) {
                System.out.println("Adding user operation canceled.\n");
                ClearTerminal.clearTerminal();
                adminFunctions();
                return;
            }
            String[] userDetails = userInput.split(",");
            if (userDetails.length != 6) {
                ClearTerminal.clearTerminal();
                userInterface.showHeader();
                System.out.println("Error: Please enter all 6 required fields or enter [Q] to quit.\n");
                continue;
            }
            String user_id = userDetails[0].trim();
            String username = userDetails[1].trim();
            String password = userDetails[2].trim();
            String role = userDetails[3].trim();
            String phone_num = userDetails[4].trim();
            String email = userDetails[5].trim();
            if (!role.equals("user") && !role.equals("admin")) {
                ClearTerminal.clearTerminal();
                System.out.println("Error: Role must be either 'user' or 'admin'. Please try again or enter [Q] to quit.\n");
                continue;
            }

            try {
                ClearTerminal.clearTerminal();
                Database.addUser(user_id, username, password, role, phone_num, email);
                System.out.println("User added successfully!\n");
                validInput = true;
            } catch (IllegalArgumentException e) {
                ClearTerminal.clearTerminal();
                System.out.println("Error: " + e.getMessage() + " Press [Q] to quit.\n");
            } catch (IllegalStateException e) {
                System.out.println("Error: " + e.getMessage() +"\n");
                return;
            }
        }
        adminFunctions();
    }

    private void deleteUser() {
        boolean continueDeleting = true;

        while (continueDeleting) {
            viewAllUsers();
            System.out.print("Enter the user_id to delete or [Q] to quit: ");
            String userInput = scan.nextLine();
            if (userInput.equalsIgnoreCase("Q")) {
                ClearTerminal.clearTerminal();
                adminFunctions();
                return;
            }
            try {
                Database.deleteUserByUserID(userInput.trim());
                ClearTerminal.clearTerminal();
                System.out.println("User with user_id '" + userInput + "' deleted successfully!\n");
            } catch (IllegalArgumentException e) {
                ClearTerminal.clearTerminal();
                System.out.println("Error: " + e.getMessage() +"\n");
            } catch (IllegalStateException e) {
                ClearTerminal.clearTerminal();
                System.out.println("Error: " + e.getMessage() +"\n");
                return;
            }
        }

        ClearTerminal.clearTerminal();
        adminFunctions();
    }

    private void exitCurrentPage_viewAllUser() {
        System.out.println("Enter [Q] to exit current page");
        String userInput;
        do {
            userInput = scan.nextLine();
            if (!userInput.equalsIgnoreCase("Q")) {
                ClearTerminal.clearTerminal();
                viewAllUsers();
                System.out.println("Invalid input. Enter [Q] to exit current page.\n");
            }
        } while (!userInput.equalsIgnoreCase("Q"));
        ClearTerminal.clearTerminal();
        adminFunctions();
    }
}
