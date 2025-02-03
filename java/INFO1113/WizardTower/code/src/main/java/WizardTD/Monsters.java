package WizardTD;

import processing.core.PApplet;
import processing.core.PImage;
import processing.data.JSONObject;

import java.util.List;

/**
 * Represents a monster in the WizardTD game.
 * The monster has attributes such as speed, health, armor, and an associated image.
 * It can also move on a defined path and has the ability to draw itself and its health bar.
 */
public class Monsters {
    float currentX, currentY;
    int monsterIdx = 0;
    App app;
    private PImage monsterImage;
    JSONObject monsterInfo;
    String monsterType;
    // Attributes of the monster
    float originalSpeed, currentSpeed, maxHp, currentHp, armour, manaGainedOnKill, quantity, duration;
    List<int[]> randomPath;
    float BetweenSpawns; // Number of frames between each monster spawn

    /**
     * Constructor for Monsters.
     *
     * @param app          The main application context.
     * @param monsterInfo  The JSON object containing information about the monster.
     */
    public Monsters(App app, JSONObject monsterInfo) {
        this.app = app;
        this.monsterInfo = monsterInfo;
        randomPath = App.shortestPaths.get(0);
        getMonsterInfo();
        getMonsterImage();
        setInitialXY();

        // Calculate the frames between each monster spawn based on duration and quantity
        BetweenSpawns = (duration / quantity);
    }

    /**
     * Extracts and assigns attributes of the monster from the JSON object.
     */
    public void getMonsterInfo() {
        this.originalSpeed = monsterInfo.getFloat("speed");
        this.currentSpeed = originalSpeed;
        this.maxHp = monsterInfo.getFloat("hp");
        this.currentHp = maxHp;
        this.armour = monsterInfo.getFloat("armour");
        this.manaGainedOnKill = monsterInfo.getFloat("mana_gained_on_kill");
        this.monsterType = monsterInfo.getString("type");
        this.quantity = monsterInfo.getFloat("quantity");
        this.duration = app.duration;
    }

    /**
     * Loads the appropriate image for the monster based on its type.
     */
    public void getMonsterImage() {
        monsterImage = app.loadImage("src/main/resources/WizardTD/" + monsterType + ".png");
    }

    /**
     * Updates the monster's state by drawing it and making it move.
     */
    public void update() {
        draw();
        moving();
        if (!(currentX > app.house_locate[0] && currentX < app.house_locate[0] + 32 && currentY > app.house_locate[1] && currentY < app.house_locate[1] + 32) ) {
            drawMonsterHpBar();
        }
    }

    /**
     * Sets the initial position of the monster based on its path.
     */
    public void setInitialXY() {
        this.currentX = randomPath.get(0)[1] * 32 + 16;
        this.currentY = randomPath.get(0)[0] * 32 + 56;
    }

    /**
     * Draws the monster on the screen.
     */
    public void draw() {
        app.imageMode(App.CENTER);
        app.image(monsterImage, currentX, currentY, 20 , 20);
        app.imageMode(App.CORNER);
    }

    /**
     * Draws the monster's health bar above it, indicating its remaining health.
     */
    public void drawMonsterHpBar() {
        float healthBarWidth = 32; // Width of the health bar
        float healthBarHeight = 4; // Height of the health bar
        float offsetX = -healthBarWidth / 2; // Offset to center the health bar above the monster
        float offsetY = -25; // Offset to place the health bar above the monster's head

        // Calculate the width of the health using map
        float healthWidth = PApplet.map(currentHp, 0, maxHp, 0, healthBarWidth);

        app.noStroke();
        // Draw the background of the health bar
        app.fill(0); // Black color for background
        app.rect(currentX + offsetX, currentY + offsetY, healthBarWidth, healthBarHeight);

        // Draw the actual health
        app.fill(0, 255, 0); // Green color for health
        app.rect(currentX + offsetX, currentY + offsetY, healthWidth, healthBarHeight);
    }

    /**
     * Makes the monster move on its path, updating its position.
     */
    public void moving() {
        if (monsterIdx < randomPath.size() - 1) {
            int[] currentCoordinate = randomPath.get(monsterIdx);
            int[] nextCoordinate = randomPath.get(monsterIdx + 1);

            int differenceY = nextCoordinate[0] - currentCoordinate[0];
            int differenceX = nextCoordinate[1] - currentCoordinate[1];

            float targetX = nextCoordinate[1] * 32 + 16;
            float targetY = nextCoordinate[0] * 32 + 56;

            // Move the monster based on the direction.
            if (differenceY > 0) {
                currentY += currentSpeed;
                if (currentY >= targetY) {
                    monsterIdx++;
                }
            } else if (differenceX > 0) {
                currentX += currentSpeed;
                if (currentX >= targetX) {
                    monsterIdx++;
                }
            } else if (differenceY < 0) {
                currentY -= currentSpeed;
                if (currentY <= targetY) {
                    monsterIdx++;
                }
            } else if (differenceX < 0) {
                currentX -= currentSpeed;
                if (currentX <= targetX) {
                    monsterIdx++;
                }
            }

            // If the monster has reached the next tile, set its position exactly on the tile.
            if (monsterIdx != randomPath.size() - 1 && Math.abs(targetX - currentX) <= 0 && Math.abs(targetY - currentY) <= 0) {
                currentX = randomPath.get(monsterIdx)[1] * 32 + 16;
                currentY = randomPath.get(monsterIdx)[0] * 32 + 56;
            }
        }
    }
}
