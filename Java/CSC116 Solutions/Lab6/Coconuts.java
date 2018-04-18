import java.util.Scanner;

/**
 * Here is a variant of a famous old puzzle published originally in The Saturday
 * Evening Post, 1926, in a short story entitled “ Coconuts,” by Ben Ames
 * Williams. Five sailors, stranded on an island, spent their first day
 * collecting coconuts. In the evening, they put all the coconuts into a single
 * pile and went to sleep. Sailor One, distrustful of his fellow sailors, woke
 * up during the night, took one fifth of the coconuts, and went back to sleep.
 * Then, a hungry monkey shimmied down a tree and took 1 coconut. A bit later,
 * Sailor Two awoke and took a fifth of the remaining coconuts. Again, the
 * monkey came down and took a coconut. Later, the third, fourth, and fifth
 * sailors did likewise and the monkey took a coconut each time. In the morning,
 * when the five sailors tried to divide the remaining coconuts into five equal
 * piles, they had one coconut left, which they tossed to the ever-hungry
 * monkey.
 * 
 * @author Jessica Young Schmidt
 *
 */
public class Coconuts {
    /** Number of sailors on the island */
    public static final int NUM_SAILORS = 5;

    /**
     * Starts program
     * 
     * @param args
     *            command line argument
     */
    public static void main(String[] args) {
        Scanner in = new Scanner(System.in);
        System.out.print("Enter a non-negative integer a: ");
        int a = in.nextInt();
        int numCoconuts = 12495 + 15625 * a;
        System.out.println("The initial number of coconuts is " + numCoconuts + ".");
        // each sailor takes 1 / NUM_SAILORS of current coconuts
        for (int i = 1; i <= NUM_SAILORS; i++) {
            int sailorCoconuts = numCoconuts / NUM_SAILORS;
            numCoconuts = numCoconuts - sailorCoconuts - 1;
            System.out.println("Sailor " + i + ": " + sailorCoconuts
                            + " coconuts; Monkey: 1 coconut. ");
        }
        System.out.println(numCoconuts + " coconuts remain, each sailor gets " + numCoconuts / NUM_SAILORS
			   + " and " + (numCoconuts % NUM_SAILORS) +" for the monkey.");
    }
}
