import java.awt.*;

/**
 * Tests RandomWalker through use of graphics
 * 
 * @author Reges & Stepp
 */
public class TestRandomWalker {
    /** Number of steps to take */
    public static final int STEPS = 500;

    /**
     * Starts program
     * 
     * @param args command line argument
     */
    public static void main(String[] args) {
        RandomWalker walker = new RandomWalker();

        DrawingPanel panel = new DrawingPanel(500, 500);
        Graphics g = panel.getGraphics();

        // advanced features -- center and zoom in the image
        panel.getGraphics().translate(250, 250);
        panel.getGraphics().scale(4, 4);

        // make the walker walk, and draw its movement
        int prevX = walker.getX();
        int prevY = walker.getY();
        for (int i = 1; i <= STEPS; i++) {
            g.setColor(Color.BLACK);
            g.drawLine(prevX, prevY, walker.getX(), walker.getY());

            walker.move();
            prevX = walker.getX();
            prevY = walker.getY();

            g.setColor(Color.RED);
            g.drawLine(prevX, prevY, walker.getX(), walker.getY());

            int steps = walker.getSteps();
            if (steps % 10 == 0) {
                System.out.println(steps + " steps");
            }

            panel.sleep(100);
        }
    }
}
