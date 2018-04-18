/**
* Alternating elements in an array
*
* @author Yan Chen
*/
public class Alternating {
/**
* Starts program
*
* @param args command line arguments
*/
public static void main(String[] args) {
    int[] arr1 = { 1, 4, 9, 16, 9, 7, 4, 9, 11};
    int sum = alternatePairs(arr1);
    System.out.println("sum="+sum);
}
/**
* Swaps elements at indexes i and j. Precondition: i and j must be valid
* indexes of list
*
* @param list array of integers
*/
public static int alternatePairs(int[] list) {
    int n=list.length;
    int sum = 0;
    for (int i =0;i< n;i++){
        if (i%2==0){
            sum=sum+list[i];
            //System.out.println("sum after element"+(i+1) + " is " + sum);
        }else {
            sum=sum-list[i];
            //System.out.println("sum after element:"+(i+1)+ " is " + sum);
        }
    }
    return sum;
    }
}