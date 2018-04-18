import java.util.Random;
import java.util.Scanner;

/**
 * Create an application containing an array that stores 10 integers.
 * 1 Display all the intergers
 * 2 display all the integers in reverse order
 * 3 display the sum of the integers
 * 4 display all values less than a limiting argument
 * 5 display all values that are higher than the calculated average value
 * @author Yan Chen
 */
public class ArrayMethodDemo {
    public static final int LEN =10;
    public static final int BOUND =20;
    public static final int MAX = BOUND/2;
    /**
     * Starts the program and calls the other methods
     * 
     * @param args command line arguments
     */
    public static void main(String[] args) {

        int[] random = getRandomArray(LEN, BOUND);
        //1 Display all the intergers
        System.out.println("display all the integers " + arrayAsString(random));
        //2 display all the integers in reverse order
        
        int[] revArray = reverse(random);
        System.out.println("display all the integers in reverse order: " + arrayAsString(revArray));
        
        // 3 display the sum of the integers
        int sumResult  = sum(random);
        System.out.println("display the sum of the integers: " + sumResult);
        
        // 4 display all values less than a limiting argument            
        System.out.println("display all values less than a limiting argument "+ MAX +": ");
        floor(random,MAX);
        System.out.println();
        
        // 5 display all values that are higher than the calculated average value
        double avgResult=avg(random);
        System.out.println("display all values that are higher than the calculated average value "+ avgResult +": ");
        ceiling(random,avgResult);
        System.out.println();
    }


    /**
     * Creates an array with given length and stores the random values between 0
     * and (bound-1)
     * 
     * @param length The length of the array that will be created and returned
     * @param bound The upperbound for the range of values within the array
     * @return Array with length elements that were assigned random integers
     */
    public static int[] getRandomArray(int length, int bound) {
	int[] ret = new int[length];
	Random r = new Random();
	for(int i = 0; i < ret.length; i++){
	    ret[i] = r.nextInt(bound);
	}
	return ret;
    }

    /**
     * Returns the contents of the array as a String in the format
     * {<val>,<val>,..<val>}
     * 
     * @param arr Array to return as a String
     * @return String format ({<val>,<val>,..<val>}) of arr
     */
    public static String arrayAsString(int[] arr) {
	String ret = "{";
	for(int i = 0; i < arr.length; i++){
	    ret += arr[i];
	    if(i < arr.length - 1){
		ret += ", ";
	    }
	}
	ret += "}";
	return ret;
    }
    
    /**
     * returns the array in reverse order
     * @param arr Array
     * @return Array: array in reverse order
     */
    public static int[] reverse(int[] arr) {
	int[] rev = new int[arr.length];
	for(int i = 0; i < arr.length; i++){
	    rev[i]=arr[arr.length-i-1];
	}
	return rev;
    }

    
    /**
     * returns the sum of integers in the array
     * @param arr Array
     * @return int: the sum of integers in the array
     */
    public static int sum(int[] arr) {
	int sum_array = 0;
	for(int i = 0; i < arr.length; i++){
		    sum_array+=arr[i];
	}
	return sum_array;
    }
    
     /**
     * returns the avg of integers in the array
     * @param arr Array
     * @return double: the avg of integers in the array
     */
    public static double avg(int[] arr) {
	int sum_array = 0;
	double avg = 0.0;
	for(int i = 0; i < arr.length; i++){
		    sum_array+=arr[i];
	}
	avg = (double) sum_array/arr.length;
	return avg;
    }
    
     /**
     * print the integers less than a limit
     * @param arr Array
     * @param max upper limit
     */
    public static void floor(int[] arr, int max) {
	for(int i = 0; i < arr.length; i++){
		    if(arr[i]<max) {
		    System.out.print(arr[i]+" ");
		    }
	}
    }
    
    /**
     * print the integers less than a limit
     * @param arr Array
     * @param min lower limit
     */
    public static void ceiling(int[] arr, double min) {
	for(int i = 0; i < arr.length; i++){
		    if(arr[i]>min) {
		    System.out.print(arr[i]+" ");
		    }
	}
    }
}