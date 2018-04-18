import java.awt.*;

/**
 * Program that will be used to show the basics for learning graphics
 * 
 * @author Yan Chen
 */
public class LearningGraphics {
    /**
     * Declares the variables, computes the position, and prints the results.
     * 
     * @param args
     *            command line arguments
     */
    public static void main(String[] args) {
        DrawingPanel panel = new DrawingPanel(500, 500);
        panel.setBackground(Color.RED);

        Graphics g = panel.getGraphics();
        g.fillRect(100, 100, 100, 200);
        g.drawRect(0, 0, 100, 100);

        g.setColor(Color.BLUE);
        g.fillOval(200, 200, 100, 100);
        
        for (int i = 1; i <= 5; i++) {
            g.setColor(Color.YELLOW);
            //              x           y        w   h
            g.fillRect(450 - 20 * i, 5 + 20 * i, 50, 50);
            g.setColor(Color.BLUE);
            //              x           y        w   h
            g.drawRect(450 - 20 * i, 5 + 20 * i, 50, 50);
        }
        
        g.setColor(Color.WHITE);

        for (int x = 1; x <= 4; x++) {
            for (int y = 1; y <= 9; y++) {
                g.drawString("Java", 500 - x * 40, 500 - y * 25);
            }
        }
        
        g.setColor(Color.MAGENTA);

        Polygon poly = new Polygon();
        poly.addPoint(10, 90);
        poly.addPoint(50, 10);
        poly.addPoint(90, 90);
        g.fillPolygon(poly);
        
        g.setColor(Color.BLUE);
        for (int i = 1; i <= 10; i++) {
            g.fillOval(15 * i, 15 * i, 30, 30);
            panel.sleep(500);
        }
    }

}