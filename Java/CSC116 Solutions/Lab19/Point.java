/**
 * This class represents a pair of (x, y) coordinates.
 * 
 * @author Michelle Glatz
 */

public class Point {
    int x;
    int y;

    /**
     * Calculates the distance betwen this Point and the origin
     *
     * @return the distance between this Point and (0, 0).
     */
    public double distanceFromOrigin() {
        return Math.sqrt(x * x + y * y);
    }

    /**
     *  Shifts this point's location by the given amount
     *
     * @param dx distance to shift the x location
     * @param dy distance to shift the y location    
     */
    public void translate(int dx, int dy) {
        x += dx;
        y += dy;
    }

    
    /**
     * Calculates the euclidean distance from this Point to the given Point
     *
     * @param other Point from which the distance from this Point is calculated.
     *
     * @return the distance between this Point and the given
     * Point.
     */
    public double distance(Point other) {
        double dist = Math.sqrt(Math.pow((other.x - x),2) + Math.pow((other.y - y), 2));
        return dist;
    }

    /**
     *  Calculates the Manhattan distance between this Point and the
     *  given Point.
     *  
     *  @param other Point from which the manhattan distance 
     *               to this Point is calculated.
     *  @return the manhattan distance from this Point to the given Point
     */
     
     
    public int manhattanDistance(Point other) {
        int mdist = Math.abs(other.x - x) + Math.abs(other.y - y);
        return mdist;
    }
    
    /**
     * Determines the quadrant of the x/y plane this Point falls in.
     *
     * @return  the quadrant of the x/y plane this Point falls in.
     */
    public int quadrant() {
        int quad = 0;
        if (x > 0) {
            if (y > 0){
                quad = 1;
            }
            else if (y < 0){
                quad = 4;
            }
        }
        else if (y > 0) {
            quad = 2;
        }
        else if (y < 0) {
            quad = 3;
        }
        return quad;
    }


}
