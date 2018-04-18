/**
* Swapping Pairs
*
* @author Yan Chen
*/
public class SwappingPairs {
/**
* Starts program
*
* @param args command line arguments
*/
public static void main(String[] args) {
    int[] arr1 = { 10, 20, 30, 40,50 };
    int[] arr2 = swapPairs(arr1);
    String str_arr2=arrayAsString(arr2);
    System.out.println(str_arr2);
}
/**
* Swaps elements except last element.
*
* @param list array of integers
* @return array after swaping
*/
public static int[] swapPairs(int[] list) {
    int n=list.length;
    int[] ret = new int[n];
    for (int i =0;i< n/2;i++) {
        int temp = list[2*i];
        list[2*i] = list[2*i+1];
        list[2*i+1] = temp;
    }
    for (int i =0;i< n;i++) {
        ret[i]=list[i];
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

}