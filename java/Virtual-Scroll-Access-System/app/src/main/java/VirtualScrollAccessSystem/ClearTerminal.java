package VirtualScrollAccessSystem;

public class ClearTerminal {
    public static void clearTerminal() {
        if (System.getProperty("disable.clear") != null && System.getProperty("disable.clear").equals("true")) {
            return;
        }

        System.out.print("\033[H\033[2J");
        System.out.flush();
    }
}
