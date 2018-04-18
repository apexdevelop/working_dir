/**
 * Drawing Complex Figures with static Methods - structured, without redundancy
 * 
 * Prints several figures, with methods for structure and redundancy.
 * 
 * @author Yan Chen
 *
 */
public class Lanterns {
    /**
     * Starts the program.
     * 
     * @param args
     *            command line arguments
     */
    public static void main(String[] args) {
        top();
        body();
        bottom();
    }

    /**
     * Draws lantern top.
     */
    public static void top() {
        System.out.println("    *****    ");
        System.out.println("  *********  ");
        System.out.println("*************");
    }

    /**
     * Draws 5 Star.
     */
    public static void fiveStar() {
        System.out.println("    *****    ");
    }

    /**
     * Draws 13 Star.
     */
    public static void thirteenStar() {
        System.out.println("*************");
    }

    /**
     * Draws the special line.
     */
    public static void special() {
        System.out.println("* | | | | | *");
    }

    /**
     * Draws body of the figure.
     */
    public static void body() {
        System.out.println();
        top();
        special();
        thirteenStar();
        top();
    }

    /**
     * Draws bottom of the figure.
     */
    public static void bottom() {
        System.out.println();
        top();
        fiveStar();
        special();
        special();
        fiveStar();
        fiveStar();
    }
}