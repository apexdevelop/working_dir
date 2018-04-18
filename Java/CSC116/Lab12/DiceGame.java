import java.util.*;
import java.util.Random;

/**
 * roll 2 dices until getting desired sum
 * @author Yan Chen
 */
public class DiceGame {
    public static final int MAX = 6;
    /**
     * Starts program
     * 
     * @param args array of command line arguments
     */
    public static void main(String[] args) {    
        diceSum();
    
    }
    
    /**
     * Reads user's guess for the secret number and compare them
     */
    public static void diceSum() {
        Scanner in = new Scanner(System.in);
        System.out.print("Desired dice sum: ");
        double desiredSum = in.nextDouble();
        while (desiredSum != (int)desiredSum || desiredSum >12.0 || desiredSum<2.0)
        {
          System.out.print("not int or not within 2-12; try again: ");
          desiredSum = in.nextDouble();
         // ASSERT: Number is integer between 2-12
        }
        double rn1;
        double rn2;
        double sum=0;
        Random r = new Random();
        do {
        rn1 = r.nextInt(MAX) + 1; // generating random number between 1 and 6
        rn2 = r.nextInt(MAX) + 1; // generating random number between 1 and 6
        sum = rn1 + rn2;
        System.out.format(" %.0f and %.0f = %.0f%n", rn1, rn2, sum);
        //System.out.println(rn1 +" and " + rn2 +" = " + sum);
        } while (sum!=desiredSum);
    }
}