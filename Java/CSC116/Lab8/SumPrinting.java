/**
 * accepts an integer parameter n and prints to the console the first n terms of the sequence
 * @author Yan Chen
 */
 
 public class SumPrinting {
     public static void main(String[] args) {
        printFractionSum(2); // 1 + (1/2)
        printFractionSum(6); // 1 + (1/2) + (1/3) + (1/4) + (1/5) + (1/6)
        printFractionSum(5); // 1 + (1/2) + (1/3) + (1/4) + (1/5)
    }
    
    /**
        * print fraction of sum
        * @param n
        */
    public static void printFractionSum (int n) {
           System.out.print(1);
           if (n > 1) {           
               for (int i = 2; i<=n; i++) {
                   System.out.print(" + (1/" + i +")");
               }
           }
           System.out.println();
    }
}