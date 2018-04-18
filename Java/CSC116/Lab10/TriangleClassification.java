import java.util.*;

/**
 * Triangle program outputs the type of a triangle based on the lengths of its
 * sides.
 * 
 * @author Jessica Young Schmidt
 * @author Suzanne Balik
 */
public class TriangleClassification {

    /**
     * The method that is executed when the program is run
     * 
     * @param args command line arguments
     */
    public static void main(String[] args) {
        userInterface();
    }

    /**
     * Provides the user interface.
     */
    public static void userInterface() {
        Scanner console = new Scanner(System.in);
        System.out.print("Triangle program provides the type of any triangle.\n"
                        + "Would you like to classify triangles by angles or side lengths?\n"
                        + "Enter 1 for angles and 2 for side lengths: ");
        int classificationType = console.nextInt();
        if (classificationType == 1) {
            System.out.println("You chose to classify triangles based on angles.\n"
                            + "Please enter the angles of a, b, and c."
                            + " All angles should be integer values.");
            System.out.print("Enter angle a: ");
            int angleA = console.nextInt();
            System.out.print("Enter angle b: ");
            int angleB = console.nextInt();
            System.out.print("Enter angle c: ");
            int angleC = console.nextInt();
            if (isValidTriangleAngle(angleA, angleB, angleC)) {
                System.out.println("Triangle type based on angles: "
                                + getTriangleTypeAngle(angleA, angleB, angleC));
            } else {
                System.out.println("Invalid triangle based on angles.");
            }
        } else if (classificationType == 2) {
            System.out.println("You chose to classify triangles based on side lengths.\n"
                            + "Please enter the lengths of sides a, b, and c."
                            + " All side lengths should be integer values.");
            System.out.print("Enter side a: ");
            int sideA = console.nextInt();

            System.out.print("Enter side b: ");
            int sideB = console.nextInt();

            System.out.print("Enter side c: ");
            int sideC = console.nextInt();

            if (isValidTriangleSideLength(sideA, sideB, sideC)) {
                System.out.println("Triangle type based on side lengths: "
                                + getTriangleTypeSideLength(sideA, sideB, sideC));
            } else {
                System.out.println("Invalid triangle based on side lengths.");
            }
        } else {
            System.out.println("You did not enter a valid option.");
        }
    }

    /**
     * Checks to see if a triangle is valid based on the angles. The sum of the
     * three angles must add up to 180.
     * 
     * @param a angle a
     * @param b angle b
     * @param c angle c
     * @return true if the angles create a valid triangle, false otherwise.
     */
    public static boolean isValidTriangleAngle(int a, int b, int c) {
        return a > 0 && b > 0 && c > 0 && (a + b + c == 180);
    }

    /**
     * Returns the type of a triangle based on the angles. PRE: Assumes the
     * angles form a valid triangle. Throws exception if this precondition is
     * not met.
     * 
     * @param a length of side a
     * @param b length of side b
     * @param c length of side c
     * @return "Acute", "Right", or "Obtuse"
     * @throws IllegalArgumentException if precondition of valid triangle is not
     *             met
     */
    public static String getTriangleTypeAngle(int a, int b, int c) {
        if (!isValidTriangleAngle(a, b, c)) {
            throw new IllegalArgumentException("Not a valid triangle based on angles.");
        }

        if (a == 90 || b == 90 || c == 90) {
            return "Right";
        }
        if (a < 90 && b < 90 && c < 90) {
            return "Acute";
        }
        return "Obtuse";
    }

    /**
     * Checks to see if a triangle is valid based on the lengths of its sides.
     * The length of each side must be positive and less than the sum of the
     * other two sides.
     * 
     * @param a length of side a
     * @param b length of side b
     * @param c length of side c
     * @return true if the lengths create a valid triangle, false otherwise.
     *         (Invalid if: one sideâ€™s length is longer than the sum of the
     *         other two, which is impossible in a triangle, or a side length is
     *         non-positive.)
     * 
     */
    public static boolean isValidTriangleSideLength(int a, int b, int c) {
        if (a <= 0 || b <= 0 || c <= 0) {
            return false;
        }
        if (a + b > c && a + c > b && b + c > a) {
            return true;
        }
        return false;
    }

    /**
     * Returns the type of a triangle based on the lengths of its sides. PRE:
     * Assumes the lengths form a valid triangle. Throws exception if this
     * precondition is not met.
     * 
     * @param a length of side a
     * @param b length of side b
     * @param c length of side c
     * @return "Equilateral", "Isosceles", or "Scalene"
     * @throws IllegalArgumentException if precondition of valid triangle is not
     *             met (Invalid if: one sideâ€™s length is longer than the sum of
     *             the other two, which is impossible in a triangle, or a side
     *             length is non-positive.)
     */
    public static String getTriangleTypeSideLength(int a, int b, int c) {
        if (!isValidTriangleSideLength(a, b, c)) {
            throw new IllegalArgumentException("Not a valid triangle based on side length");
        }
        if (a == b && b == c) {
            return "Equilateral";
        } else if (a == b || b == c || a == c) {
            return "Isosceles";
        } else {
            return "Scalene";
        }
    }

}