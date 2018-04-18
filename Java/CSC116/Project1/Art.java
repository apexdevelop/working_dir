/**
 * Print an ASCII ART FAMOUS STEALTH AIRCRAFT F-117
 * 
 * from http://chris.com/ascii/index.php?art=transportation/airplanes
 * 
 * @author Yan Chen
 *
 */
public class Art {
    /**
     * Starts the program.
     * 
     * @param args
     *            command line arguments
     */
    public static void main(String[] args) {
        top();
        bottom();
    }

    /**
     * Draws top.
     */
    public static void top() {
        System.out.println("     /\\     ");
        System.out.println("    /<>\\");
        System.out.println("   /=  =\\");
        System.out.println("  /      \\");
    }

    /**
     * Draws bottom.
     */
    public static void bottom() {
        System.out.println(" / /\\  /\\ \\");
        System.out.println("/ /  \\/  \\ \\");
        System.out.println("\\/   /\\   \\/");
    }

}