package VirtualScrollAccessSystem;

import java.util.*;


import org.mindrot.jbcrypt.BCrypt;


public class User {
    protected String role;

    protected String userId;
    protected String username;
    protected String email;

    public User(String role) {
        this.role = role;

    }

    public String getRole() {
        return role;
    }

    // Method to verify user login using user_id and password
    public static boolean verifyUserLogin(String userID, String userPassword) {
        try {
            HashMap<String, String> userInfo = Database.getUserInfoByUserID(userID);

            if (userInfo == null) {
                return false;
            }
            String hashedPassword = userInfo.get("password");
            return BCrypt.checkpw(userPassword, hashedPassword);
        } catch (Exception e) {
            return false;
        }
    }
}
