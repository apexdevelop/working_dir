import java.util.Random;
import java.util.Scanner;

/**
 * A program that includes several algorithms for arrays of integers.
 * 
 * @author Yan Chen
 */
public class IntArrayAlgorithms {
    public static final int LOOK=85;
    public static final int MIN = 4;
    public static final int MAX = 17;
    /**
     * Starts the program and calls the other methods
     * 
     * @param args command line arguments
     */
    public static void main(String[] args) {
        //int[] fromUser = getArrayFromUser(5);
        //System.out.println("From User:\n" + arrayAsString(fromUser));

        //int[] random = getRandomArray(10, 20);
        //System.out.println("Random: \n" + arrayAsString(random));
        
        int[] list1 = {74, 85, 102, 99, 101, 85, 56};
        int index = lastIndexOf(list1,LOOK);
        String str_list1=arrayAsString(list1);
        System.out.println("The last index of the value "+ LOOK + " in " + str_list1 + " is " + index+".");
        
        int[] list2 = {8, 3, 5, 7, 2, 4};
        int range_result = range(list2);
        String str_list2=arrayAsString(list2);
        System.out.println("The range of " + str_list2 + " is " + range_result + ".");
        
        int[] list3 = {14, 1, 22, 17, 36, 7, -43, 5};
        int count = countInRange(list3,MIN,MAX);
        String str_list3=arrayAsString(list3);
        System.out.println("In the array " + str_list3 + ", there are " + count + " elements whose values fall between " + MIN+ " and "+ MAX + ".");
    }

    /**
     * Creates an array with given length and stores the values that are given
     * from the user.
     * 
     * @param length The length of the array that will be created and returned
     * @return Array with length elements that were given by the user
     */
    public static int[] getArrayFromUser(int length) {
	int[] ret = new int[169];
	Scanner console = new Scanner(System.in);
	for(int i = 0; i < ret.length; i++){
	    System.out.print("Element " + i + " (Integer): ");
	    while(!console.hasNextInt()){
		console.next();
		System.out.println("Not an integer!");
		System.out.print("Element " + i + " (Integer): ");
	    }
	    ret[i] = console.nextInt();
	}
	return ret;
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
     * returns the last index at which the value occurs in the array
     * @param arr Array
     * @param n
     * @return int: the last index at which the value occurs in the array
     */
    public static int lastIndexOf(int[] arr, int n) {
	int index = -1;
	for(int i = 0; i < arr.length; i++){
	    if(n == arr[i]){
		    index=i;
	    }
	}
	return index;
    }
    
    /**
     * returns the range
     * @param arr Array
     * @return int: range between min and max
     */
    public static int range(int[] arr) {
	int range_result = -1;
	int min=Integer.MAX_VALUE;
    int max=Integer.MIN_VALUE;
	for(int i = 0; i < arr.length; i++){
	    if(arr[i]<min){
		    min=arr[i];
	    }
	    if(arr[i]>max){
		    max=arr[i];
	    }
	}
	range_result = max-min+1;
	return range_result;
    }
    
     /**
     * returns the number of integers within the range
     * @param arr Array
     * @param min lower bound
     * @param max upper bound
     * @return int: the number of integers within the range
     */
    public static int countInRange(int[] arr, int min, int max) {
	int count = 0;
	for(int i = 0; i < arr.length; i++){
	    if(arr[i]<=max && arr[i]>=min){
		    count+=1;
	    }
	}
	return count;
    }
}