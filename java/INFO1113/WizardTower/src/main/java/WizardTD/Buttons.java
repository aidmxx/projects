package WizardTD;

/**
 * Represents a button in the WizardTD game.
 * This button has attributes like position, dimensions, label, and type.
 * It can be clicked and also display its label and side text.
 */
public class Buttons {
    App app;
    float x, y, w, h;
    String label, sideText;
    char type;
    boolean onClick = false;
    /**
     * Constructor for Buttons.
     *
     * @param app      The main application context.
     * @param x        The x-coordinate of the top-left corner of the button.
     * @param y        The y-coordinate of the top-left corner of the button.
     * @param w        The width of the button.
     * @param h        The height of the button.
     * @param label    The main label of the button to be displayed at its center.
     * @param sideText Additional text to be displayed at the side of the button.
     * @param type     The type of the button. (e.g., 'T' for tower button)
     */
    public Buttons(App app, float x, float y, float w, float h, String label, String sideText, char type) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.app = app;
        this.label = label;
        this.sideText = sideText;
        this.type = type;
    }

    /**
     * Checks if the button is clicked based on the provided mouse coordinates.
     *
     * @param mx The x-coordinate of the mouse click.
     * @param my The y-coordinate of the mouse click.
     */
    void checkClick(int mx, int my) {
        if (mx >= x && mx <= x + w && my >= y && my <= y + h) {
            if (!app.active) {
                onClick = true;
                if (this.type == 'T') {
                    TowerButton towerButton = new TowerButton(app, x, y, w, h, label, sideText, type);
                    app.active = true;
                }
            }
        }
    }

    /**
     * Determines whether the button is currently clicked.
     *
     * @return A boolean value indicating if the button is clicked.
     */
    boolean isClicked() {
        return onClick;
    }

    /**
     * Displays the button on the screen with its label.
     * The button's appearance changes based on its active state.
     */
    void display() {
        if (app.active) {
            app.fill(255, 255, 0);
        }else {
            app.noFill();
        }
        app.stroke(0);
        app.strokeWeight(3);
        app.rect(x, y, w, h);
        app.fill(0);
        app.textAlign(app.CENTER, app.CENTER);
        app.textSize(25);
        app.text(label, x + w / 2, y + h / 2);
        app.textSize(12);
    }

    /**
     * Displays the side text of the button with word wrapping.
     */
    void displaySideText() {
        app.textAlign(app.CORNER);
        String[] words = sideText.split(" "); // Split the text into words
        float textX = x + 45;
        float textY = y + 10;
        float lineWidth = 0;

        for (int i = 0; i < words.length; i++) {
            String word = words[i];
            float wordWidth = app.textWidth(word);

            // Check if adding the current word exceeds the line width
            if (lineWidth + wordWidth > 65) {
                // Start a new line
                textX = x + 45;
                textY += app.textAscent() + app.textDescent();
                lineWidth = 0;
            }

            app.text(word, textX, textY);
            textX += wordWidth + app.textWidth(" "); // Add space width to separate words
            lineWidth += wordWidth + app.textWidth(" "); // Update the line width
        }
    }

}
