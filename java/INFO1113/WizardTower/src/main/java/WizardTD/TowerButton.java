package WizardTD;

import processing.core.PImage;

/**
 * Represents a button specifically designed to control tower placement in the game.
 * This class extends the base button functionality with capabilities to
 * determine tower placement locations and to create towers at those locations.
 * It also has the ability to display a tower image.
 */
public class TowerButton extends Buttons{
    // Coordinate ranges to place the tower
    int x1, x2, y1, y2;
    // Image representation of the general tower
    private PImage generalTower;
    /**
     * Constructor for TowerButton.
     *
     * @param app      The main application context.
     * @param x        X-coordinate of the button.
     * @param y        Y-coordinate of the button.
     * @param w        Width of the button.
     * @param h        Height of the button.
     * @param label    Label displayed on the button.
     * @param sideText Side text of the button.
     * @param type     Character representing the button type.
     */
    public TowerButton(App app, float x, float y, float w, float h, String label, String sideText, char type) {
        super(app, x, y, w, h, label, sideText, type);
        getTowerImage();
    }

    /**
     * Determines whether a tower can be created based on mouse position.
     * Calculates potential coordinate ranges for tower placement.
     */
    public void isAbleToCreate(){
        x1 = (int) ((app.mouseX - 56) / 32);
        x2 = (int) ((app.mouseX - 24) / 32);
        y1 = (int) ((app.mouseY - 16) / 32);
        y2 = (int) ((app.mouseY + 16) / 32);
    }

    /**
     * Attempts to create a tower at a specified location.
     * Uses the mouse position to check if a tower can be created. If possible,
     * it places a tower within the determined coordinate range.
     */
    public void createTower(){
        checkClick(app.mouseX, app.mouseY);
        if (onClick){
            isAbleToCreate();
            for (int[] index : app.grassList) {
                if (x1 <= index[0] && index[0] <= x2 && y1 <= index[1] && index[1] <= y2) {
                    app.towers.add(new Towers(x1 * 32 + 56, y1 * 32 + 16, generalTower, app));
                    break;
                }
            }
        }
    }

    /**
     * Loads the general tower image from resources.
     */
    public void getTowerImage(){
        generalTower = app.loadImage("src/main/resources/WizardTD/tower0.png");
    }

    /**
     * Draws the tower image on the screen.
     * Displays the tower centered at its intended location and sets the application mode.
     */
    public void draw() {
        app.imageMode(App.CENTER);
        app.image(generalTower, x1 * 32 + 56, y1 * 32 + 16, 32 , 32);
        app.imageMode(App.CORNER);
        app.active = false;
    }

}
