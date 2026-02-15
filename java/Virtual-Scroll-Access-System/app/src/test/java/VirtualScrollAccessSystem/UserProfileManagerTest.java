package VirtualScrollAccessSystem;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.PrintStream;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

public class UserProfileManagerTest {

    private RegisteredUser userMock;
    private Interface userInterfaceMock;
    private UserProfileManager userProfileManager;
    private ByteArrayOutputStream outputStream;

    @BeforeEach
    void setUp() {
        userMock = mock(RegisteredUser.class);
        userInterfaceMock = mock(Interface.class);
        userProfileManager = new UserProfileManager(userMock, userInterfaceMock);
        outputStream = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outputStream));
    }

    /**
     * Tests the functionality of updating the email address of the user.
     * Simulates user input to update the email address and verifies that the update method is called.
     */
    @Test
    void testUpdateEmail() {
        String simulatedInput = "1\nnew_email@test.com\n5\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        userProfileManager.showUpdateOptions();

        verify(userMock, times(1)).updateEmail("new_email@test.com");
        assertTrue(outputStream.toString().contains("Enter new email or press [Q] to cancel:"));
    }

    /**
     * Tests the functionality of canceling the email update.
     * Simulates user input to cancel the email update and verifies that the update method is not called.
     */
    @Test
    void testUpdateEmail_cancel() {
        String simulatedInput = "1\nQ\n5\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        userProfileManager.showUpdateOptions();

        verify(userMock, times(0)).updateEmail(anyString());
        assertTrue(outputStream.toString().contains("Email update canceled."), "The output should indicate that the email update was canceled.");
    }

    /**
     * Tests the functionality of updating the phone number of the user.
     * Simulates user input to update the phone number and verifies that the update method is called.
     */
    @Test
    void testUpdatePhoneNumber() {
        String simulatedInput = "2\n0412345678\n5\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        userProfileManager.showUpdateOptions();

        verify(userMock, times(1)).updatePhoneNumber("0412345678");
        assertTrue(outputStream.toString().contains("Enter new phone number or press [Q] to cancel:"));
    }

    /**
     * Tests the functionality of canceling the phone number update.
     * Simulates user input to cancel the phone number update and verifies that the update method is not called.
     */
    @Test
    void testUpdatePhoneNumber_cancel() {
        String simulatedInput = "2\nQ\n5\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        userProfileManager.showUpdateOptions();

        verify(userMock, times(0)).updatePhoneNumber(anyString());
        assertTrue(outputStream.toString().contains("Phone number update canceled."), "The output should indicate that the phone number update was canceled.");
    }

    /**
     * Tests the functionality of updating the user's full name.
     * Simulates user input to update the full name and verifies that the update method is called.
     */
    @Test
    void testUpdateUserName() {
        String simulatedInput = "3\nNew UserName\n5\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        when(userMock.updateFullName("New UserName")).thenReturn(true);

        userProfileManager.showUpdateOptions();

        verify(userMock, times(1)).updateFullName("New UserName");
        assertTrue(outputStream.toString().contains("User name updated successfully!"));
    }

    /**
     * Tests the functionality of canceling the full name update.
     * Simulates user input to cancel the full name update and verifies that the update method is not called.
     */
    @Test
    void testUpdateUserName_cancel() {
        String simulatedInput = "3\nQ\n5\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        userProfileManager.showUpdateOptions();

        verify(userMock, times(0)).updateFullName(anyString());
        assertTrue(outputStream.toString().contains("User name update canceled."), "The output should indicate that the user name update was canceled.");
    }

    /**
     * Tests the functionality of updating the password of the user.
     * Simulates user input to update the password and verifies that the update methods are called.
     */
    @Test
    void testUpdatePassword() {
        String simulatedInput = "4\nold_password\nnew_password\n5\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        when(userMock.verifyOldPassword("old_password")).thenReturn(true);
        when(userMock.setNewPassword("new_password")).thenReturn(true);

        userProfileManager.showUpdateOptions();

        verify(userMock, times(1)).verifyOldPassword("old_password");
        verify(userMock, times(1)).setNewPassword("new_password");
        assertTrue(outputStream.toString().contains("Please enter your new password or press [Q] to cancel:"));
    }

    /**
     * Tests the functionality of canceling the password update.
     * Simulates user input to cancel the password update and verifies that the update methods are not called.
     */
    @Test
    void testUpdatePassword_cancel() {
        String simulatedInput = "4\nQ\n5\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        userProfileManager.showUpdateOptions();

        verify(userMock, times(0)).verifyOldPassword(anyString());
        assertTrue(outputStream.toString().contains("Password update canceled."), "The output should indicate that the password update was canceled.");
    }

    /**
     * Tests the functionality of canceling the password update process.
     * Simulates user input to cancel the password update process and verifies that the update methods are not called.
     */
    @Test
    void testCancelUpdatePassword() {
        String simulatedInput = "4\nQ\n5\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        userProfileManager.showUpdateOptions();

        verify(userMock, times(0)).verifyOldPassword(anyString());
        assertTrue(outputStream.toString().contains("Password update canceled."));
    }

    /**
     * Tests the functionality of updating the password with an incorrect old password.
     * Simulates user input with an incorrect old password and verifies that the appropriate message is displayed.
     */
    @Test
    void testUpdatePassword_incorrectOldPassword() {
        String simulatedInput = "4\nwrong_password\nQ\n5\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        userProfileManager.showUpdateOptions();

        verify(userMock, times(1)).verifyOldPassword("wrong_password");
        assertTrue(outputStream.toString().contains("Old password is incorrect. Please try again or Enter [Q] to cancel."), "The output should indicate that the old password was incorrect.");
    }

    /**
     * Tests the functionality of canceling the new password input after entering the correct old password.
     * Simulates user input to cancel the new password input and verifies that the update process is stopped.
     */
    @Test
    void testUpdatePassword_newPasswordCancel() {
        String simulatedInput = "4\ncorrect_password\nQ\n5\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        when(userMock.verifyOldPassword("correct_password")).thenReturn(true);

        userProfileManager.showUpdateOptions();

        verify(userMock, times(1)).verifyOldPassword("correct_password");
        assertTrue(outputStream.toString().contains("Password update canceled."), "The output should indicate that the password update was canceled.");
    }

    /**
     * Tests the functionality of updating the password with a password that is not allowed.
     * Simulates user input to provide a disallowed new password and verifies that the user is prompted to try a different password.
     */
    @Test
    void testUpdatePassword_tryDifferentPassword() {
        String simulatedInput = "4\ncorrect_password\nold_password\nQ\n5\n";
        ByteArrayInputStream inputStream = new ByteArrayInputStream(simulatedInput.getBytes());
        System.setIn(inputStream);

        when(userMock.verifyOldPassword("correct_password")).thenReturn(true);
        when(userMock.setNewPassword("old_password")).thenReturn(false);

        userProfileManager.showUpdateOptions();

        verify(userMock, times(1)).verifyOldPassword("correct_password");
        verify(userMock, times(1)).setNewPassword("old_password");
        assertTrue(outputStream.toString().contains("Please try a different password."), "The output should indicate that the user should try a different password.");
    }
}
