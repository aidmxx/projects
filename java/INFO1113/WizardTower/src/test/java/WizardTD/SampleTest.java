package WizardTD;


import org.junit.jupiter.api.BeforeEach;
import processing.core.PApplet;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;


public class SampleTest {

    private  App app;


    @BeforeEach
    public void setUp() {
        app = new App();
        app.noLoop();
        PApplet.runSketch(new String[] {"App"}, app);
        app.delay(2000);
    }

    @Test
    public void testAddButtonToList(){
        assertEquals(7, app.buttonsList.size());
    }

    @Test
    public void testDrawMap(){

    }
}
