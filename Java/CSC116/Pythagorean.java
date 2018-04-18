/**
 * Uses Pythagorean Theorem to calculate length of hypotenuse of a right
 * triangle given the other two sides
 * 
 * @Yan Chen
 *
 */
public class Pythagorean {
    /**
     * Starts the program.
     * 
     * @param args
     *            command line arguments
     */
    public static void main(String[] args) {
        System.out.println("Hypotenuse of right triangle with"
                + " sides 2 and 2 is: " + hypotenuse(2, 2));
        // EXPECTED OUTPUT:
        // Hypotenuse of right triangle with sides 2 and 2 is:
        // 2.8284271247461903

        System.out.println("Hypotenuse of right triangle with"
                + " sides 3.0 and 4.0 is: " + hypotenuse(3, 4));
        // EXPECTED OUTPUT:
        // Hypotenuse of right triangle with sides 3.0 and 4.0 is: 5.0
    }
    
    public static double hypotenuse(int A, int B) {
        double length;
        length = Math.sqrt(A * A + B * B);
        return length;
    }
    // TODO: hypotenuse method with correct parameters and return value

}