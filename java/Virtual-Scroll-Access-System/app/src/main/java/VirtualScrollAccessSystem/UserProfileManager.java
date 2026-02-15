package VirtualScrollAccessSystem;

import java.util.Scanner;

public class UserProfileManager {

    private RegisteredUser user;
    private Interface userInterface;

    public UserProfileManager(RegisteredUser user, Interface userInterface) {
        this.user = user;
        this.userInterface = userInterface;
    }

    public void showUpdateOptions() {
        Scanner scanner = new Scanner(System.in);
        ClearTerminal.clearTerminal();
        while (true) {
            user.displayCurrentUserInfo();
            System.out.println("Which field would you like to update?");
            System.out.println("[1] Email");
            System.out.println("[2] Phone Number");
            System.out.println("[3] User name");
            System.out.println("[4] Password");
            System.out.println("[5] Back to main menu");
            System.out.println("Please Select an operation:");
            String input = scanner.nextLine();

            int choice;

            try {
                choice = Integer.parseInt(input);
            } catch (NumberFormatException e) {
                ClearTerminal.clearTerminal();
                System.out.println("Invalid input. Please try again!\n");
                continue;
            }

            switch (choice) {
                case 1 -> {
                    ClearTerminal.clearTerminal();
                    System.out.println("Enter new email or press [Q] to cancel:");
                    String newEmail = scanner.nextLine();
                    if (newEmail.equalsIgnoreCase("Q")) {
                        System.out.println("Email update canceled.\n");
                        continue;
                    }
                    user.updateEmail(newEmail);
                }
                case 2 -> {
                    ClearTerminal.clearTerminal();
                    System.out.println("Enter new phone number or press [Q] to cancel:");
                    String newPhone = scanner.nextLine();
                    if (newPhone.equalsIgnoreCase("Q")) {
                        System.out.println("Phone number update canceled.\n");
                        continue;
                    }
                    user.updatePhoneNumber(newPhone);
                }
                case 3 -> {
                    ClearTerminal.clearTerminal();
                    System.out.println("Enter new user name or press [Q] to cancel:");
                    String newFullName = scanner.nextLine();
                    if (newFullName.equalsIgnoreCase("Q")) {
                        System.out.println("User name update canceled.\n");
                        continue;
                    }
                    boolean updateSuccess = user.updateFullName(newFullName);
                    if (updateSuccess) {
                        userInterface.currentUsername = newFullName;
                        System.out.println("User name updated successfully!\n");
                    }
                }
                case 4 -> {
                    ClearTerminal.clearTerminal();
                    boolean oldPasswordVerified = false;
                    boolean exitPasswordChange = false;
                    while (!oldPasswordVerified) {
                        System.out.println("Please enter your old password or press [Q] to cancel:");
                        String oldPassword = scanner.nextLine();
                        if (oldPassword.equalsIgnoreCase("Q")) {
                            System.out.println("Password update canceled.\n");
                            exitPasswordChange = true;
                            break;
                        }
                        oldPasswordVerified = user.verifyOldPassword(oldPassword);

                        if (!oldPasswordVerified) {
                            System.out.println("Old password is incorrect. Please try again or Enter [Q] to cancel.\n");
                        }
                    }

                    if (oldPasswordVerified && !exitPasswordChange) {
                        boolean passwordUpdated = false;
                        while (!passwordUpdated) {
                            System.out.println("Please enter your new password or press [Q] to cancel:");
                            String newPassword = scanner.nextLine();
                            if (newPassword.equalsIgnoreCase("Q")) {
                                System.out.println("Password update canceled.\n");
                                break;
                            }
                            passwordUpdated = user.setNewPassword(newPassword);

                            if (!passwordUpdated) {
                                System.out.println("Please try a different password.\n");
                            }
                        }
                    }
                }
                case 5 -> {
                    ClearTerminal.clearTerminal();
                    userInterface.userPanel();
                    return;
                }
                default -> {
                    ClearTerminal.clearTerminal();
                    System.out.println("Invalid input. Please try again!\n");
                }
            }
        }
    }
}
