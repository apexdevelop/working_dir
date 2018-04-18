import java.awt.*;

/**
 * Exercise 2; Two different color and two different shape
 * 
 * @Yan Chen
 */
public class Picture {
    /**
     * Declares the variables, computes the position, and prints the results.
     * 
     * @param args
     *            command line arguments
     */
    public static void main(String[] args) {
        DrawingPanel panel = new DrawingPanel(200, 100);
        panel.setBackground(Color.DARK_GRAY);
        Graphics g = panel.getGraphics();
        
        //mouth
        g.setColor(Color.RED);
        Polygon poly = new Polygon();
        poly.addPoint(10, 20);
        poly.addPoint(20, 15);
        poly.addPoint(25, 25);
        g.fillPolygon(poly);
        
        //head
        g.setColor(Color.YELLOW);
        g.fillOval(20, 15, 13, 13);
        g.setColor(Color.BLACK);
        g.fillOval(25, 20, 5, 5);
        
        //body
        g.setColor(Color.YELLOW);
        g.fillRect(28, 23, 30, 20);
        
        //leg
        g.setColor(Color.BLACK);
        g.drawLine(36, 45, 36, 50);
        g.drawLine(50, 45, 50, 50);
        
        //Name and Title
        g.setColor(Color.WHITE);
        g.drawString("Yan Chen", 115, 30);

        g.drawString("Picture of little chicken", 20, 80);
    }
}
