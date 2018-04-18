/**
 * Calculate first 12 Fibonacci numbers
 * @author Yan Chen
 */
 
 public class Fibonacci {
     public static void main(String[] args) {
         int Fk2 = 1;
         int Fk1 = 1;
         int Fk = 0;
         /** if k<=2, just print 1 */
         System.out.print(Fk2 + " " + Fk1 + " ");
         /** if k>2, F(k)=F(k-1)+F(k-2) */
         for (int k = 3; k <= 12; k++) {
             Fk = Fk2 + Fk1;
             System.out.print(Fk + " ");
             Fk2 = Fk1;
             Fk1 = Fk;             
         }
         System.out.println();
     }
 }