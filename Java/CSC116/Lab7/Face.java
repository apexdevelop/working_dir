import java.awt.*;

/**
 * Draws a face
 * 
 * @author YOUR NAME
 */
public class Face {
    /**
     * Declares the variables, computes the position, and prints the results.
     * 
     * @param args
     *            command line arguments
     */
    public static void main(String[] args) {
        DrawingPanel panel = new DrawingPanel(320, 180);
        Graphics g = panel.getGraphics();
        
        drawFace(g,10,30);
        drawFace(g,150,50);
     }   
    /**
     * Draws a Face at the given x/y position.
     * 
     * @param g
     *            Graphics to draw
     * @param x
     *            x coordinate of shape
     * @param y
     *            y coordinate of shape
     */
     public static void drawFace (Graphics g, int x, int y) {
        g.setColor(Color.BLACK);
        g.drawOval(x, y, 100, 100); // face outline

        g.setColor(Color.BLUE);
        g.fillOval(x + 20, y + 30, 20, 20); // eyes
        g.fillOval(x + 60, y + 30, 20, 20);

        g.setColor(Color.RED); // mouth
        g.drawLine(x + 30 , y + 70, x + 70, y + 70);
    }
  }