package WizardTD;

import processing.core.PImage;

/**
 * Represents a tower in the WizardTD game.
 * The tower has a position and an associated image. This class provides functionality
 * to draw the tower on the screen.
 */
public class Towers {
    // X-coordinate of the tower's position
    // Y-coordinate of the tower's position
    float x, y;
    // Image representation of the tower
    PImage generalTower;
    // Main application context, used for rendering
    App app;
    /**
     * Constructor for Towers.
     *
     * @param x           The X-coordinate of the tower's position.
     * @param y           The Y-coordinate of the tower's position.
     * @param generalTower The image representing the tower.
     * @param app          The main application context.
     */
    public Towers(float x, float y, PImage generalTower, App app) {
        this.x = x;
        this.y = y;
        this.generalTower = generalTower;
        this.app = app;
    }

    /**
     * Draws the tower image on the screen.
     * Sets the image mode to corner and displays the tower at its location.
     */
    public void draw() {
        app.imageMode(app.CORNER);
        app.image(generalTower, x, y);
    }
}

