/**
 * Convert dollars into currency denominations
 * @author Yan Chen
 */
 
 public class Dollars{
       
       public static void main(String[] args) {
       int dollar = 57;
       int n_20;
       int n_10;
       int n_5;
       int n_1;
       n_20=dollar / 20;
       n_10=(dollar - n_20 * 20) / 10;
       n_5=(dollar - n_20 * 20 - n_10 * 10) / 5;
       n_1=(dollar - n_20 * 20 - n_10 * 10 - n_5 * 5);
       System.out.println("$" + dollar + " converts to: " + n_20 + " 20s, " + n_10 + " 10s, " + n_5 + " 5s, and " + n_1 + " 1s.");
       }
       
 }