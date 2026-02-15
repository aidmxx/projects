package VirtualScrollAccessSystem;
import org.mindrot.jbcrypt.BCrypt;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Scanner;

public class RegisteredUser extends User {
    protected static Scanner scan = new Scanner(System.in);
    private String userID;

    private static final String EMAIL_REGEX = "^[\\w.-]+@[\\w.-]+\\.[a-zA-Z]{2,}$";
    private static final String AU_PHONE_REGEX = "^0[2-478](\\d{8})$";
    private static final char[] ILLEGAL_CHARACTERS = {'/', '\n', '\r', '\t', '\0', '\f', '`', '?', '*', '\\', '<', '>', '|', '\"', ':', '^', '{', '}'};

    public static boolean registration() {
        ClearTerminal.clearTerminal();
        String phoneNumber;
        while (true) {
            System.out.println("What's your phone number? [Q] for exit");
            phoneNumber = scan.nextLine();
            if (phoneNumber.equalsIgnoreCase("Q")) {
                ClearTerminal.clearTerminal();
                return false;
            }
            if (isValidPhoneNumber(phoneNumber)) {
                break;
            } else {
                ClearTerminal.clearTerminal();
                System.out.println("Invalid phone number. Please enter a valid Australian phone number.");
            }
        }

        String emailAddress;
        ClearTerminal.clearTerminal();
        while (true) {
            System.out.println("What's your email address? [Q] for exit");
            emailAddress = scan.nextLine();
            if (emailAddress.equalsIgnoreCase("Q")) {
                ClearTerminal.clearTerminal();
                return false;
            }
            if (isValidEmail(emailAddress)) {
                break;
            } else {
                ClearTerminal.clearTerminal();
                System.out.println("Invalid email address. Please enter a valid email.");
            }
        }
        ClearTerminal.clearTerminal();
        System.out.println("What's your full name? [Q] for exit");
        String fullName = scan.nextLine();
        if (fullName.equalsIgnoreCase("Q")) {
            ClearTerminal.clearTerminal();
            return false;
        }

        String userName;
        ClearTerminal.clearTerminal();
        while (true) {
            System.out.println("What's your username? [Q] for exit");
            userName = scan.nextLine();
            if (userName.equalsIgnoreCase("Q")) {
                return false;
            }
            if (!containsIllegalCharacters(userName)) {
                break;
            } else {
                ClearTerminal.clearTerminal();
                System.out.println("Username contains illegal characters. Please enter a valid username.");
            }
        }

        String userID;
        ClearTerminal.clearTerminal();
        while (true) {
            System.out.println("What's your userID? [Q] for exit");
            userID = scan.nextLine();
            if (userID.equalsIgnoreCase("Q")) {
                return false;
            }
            if (checkUserIDExists(userID)) {
                ClearTerminal.clearTerminal();
                System.out.println("This user_id already exists! Please enter a new user_id.");
            } else {
                break;
            }
        }
        ClearTerminal.clearTerminal();
        System.out.println("Please set up your password. [Q] for exit");
        String password = scan.nextLine();
        if (password.equalsIgnoreCase("Q")) {
            return false;
        }

        try {
            Database.addUser(userID, userName, password, "user", phoneNumber, emailAddress);
            ClearTerminal.clearTerminal();
            System.out.println("Registration finished! Please log in now");
            return true;
        } catch (IllegalArgumentException e) {
            System.out.println(e.getMessage());
            return false;
        } catch (Exception e) {
            System.out.println("Unexpected error occurred during registration: " + e.getMessage());
            return false;
        }
    }

    private static boolean isValidEmail(String email) {
        return email.matches(EMAIL_REGEX);
    }

    private static boolean isValidPhoneNumber(String phoneNumber) {
        return phoneNumber.matches(AU_PHONE_REGEX);
    }

    private static boolean containsIllegalCharacters(String input) {
        for (char c : ILLEGAL_CHARACTERS) {
            if (input.indexOf(c) != -1) {
                return true;
            }
        }
        return false;
    }

    private static boolean checkUserIDExists(String userID) {
        String query = "SELECT COUNT(*) FROM User WHERE user_id = ?;";
        try {
            Connection conn = Database.conn;
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setString(1, userID);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                int count = rs.getInt(1);
                return count > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateEmail(String newEmail) {
        try {
            Database.updateEmail(this.userID, newEmail);
            ClearTerminal.clearTerminal();
            System.out.println("Email updated successfully!");
            return true;
        } catch (IllegalArgumentException e) {
            ClearTerminal.clearTerminal();
            System.out.println(e.getMessage());
            return false;
        } catch (Exception e) {
            ClearTerminal.clearTerminal();
            System.out.println("Unexpected error occurred while updating email.");
            return false;
        }
    }

    public boolean updatePhoneNumber(String newPhoneNumber) {
        try {
            Database.updatePhoneNumber(this.userID, newPhoneNumber);
            ClearTerminal.clearTerminal();
            System.out.println("Phone number updated successfully!");
            return true;
        } catch (IllegalArgumentException e) {
            ClearTerminal.clearTerminal();
            System.out.println(e.getMessage());
            return false;
        } catch (Exception e) {
            ClearTerminal.clearTerminal();
            System.out.println("Unexpected error occurred while updating phone number.");
            return false;
        }
    }

    public boolean updateFullName(String newFullName) {
        try {
            Database.updateUserName(this.userID, newFullName);
            ClearTerminal.clearTerminal();
            System.out.println("Full name updated successfully!");
            return true;
        } catch (IllegalArgumentException e) {
            ClearTerminal.clearTerminal();
            System.out.println(e.getMessage());
            return false;
        } catch (Exception e) {
            ClearTerminal.clearTerminal();
            System.out.println("Unexpected error occurred while updating full name.");
            return false;
        }
    }

    public boolean verifyOldPassword(String oldPassword) {
        if (User.verifyUserLogin(this.userID, oldPassword)) {
            ClearTerminal.clearTerminal();
            return true;
        } else {
            ClearTerminal.clearTerminal();
            return false;
        }
    }

    public boolean setNewPassword(String newPassword) {
        HashMap<String, String> userInfo = Database.getUserInfoByUserID(this.userID);
        String currentHashedPassword = userInfo.get("password");

        if (BCrypt.checkpw(newPassword, currentHashedPassword)) {
            System.out.println("New password cannot be the same as the old password.");
            return false;
        }

        try {
            Database.updatePassword(this.userID, newPassword);
            System.out.println("Password updated successfully!");
            return true;
        } catch (IllegalArgumentException e) {
            System.out.println(e.getMessage());
            return false;
        } catch (Exception e) {
            System.out.println("Unexpected error occurred while updating password.");
            return false;
        }
    }

    public void displayCurrentUserInfo() {
        HashMap<String, String> userInfo = Database.getUserInfoByUserID(userID);
        System.out.println("--------------------------");
        System.out.println("Current user information:");
        System.out.println("User ID: " + userInfo.get("user_id"));
        System.out.println("Full Name: " + userInfo.get("username"));
        System.out.println("Email: " + userInfo.get("email"));
        System.out.println("Phone Number: " + userInfo.get("phone_num"));
        System.out.println("----------------------------");
    }


    public RegisteredUser(String userID) {
        super("user");
        this.userID = userID;
    }

}
