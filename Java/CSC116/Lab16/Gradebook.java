import java.util.*;
import java.io.*;

/**
 * Create an int array to store the project one grades for 10 students
 * @author Yan Chen
 */
public class Gradebook {
     public static final int N_S = 10;
    /**
     * Starts the program
     * 
     * @param args array of command line arguments
     */
    public static void main(String[] args) {
        userInterface();
    }

    /**
     * Interface with the user
     */
    public static void userInterface(){
        Scanner console = new Scanner(System.in);
        int[] grades = new int[N_S];
        for (int i = 0; i < grades.length; i++) {
            System.out.print("Please enter grade for student " + (i+1) + ":");
            grades[i] = console.nextInt();
        }
    }
}