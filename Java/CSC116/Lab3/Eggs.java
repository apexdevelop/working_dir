/**
 * calculate price for eggs
 * @author Yan Chen
 */
 
 public class Eggs{
       
       public static void main(String[] args) {
       int n_egg = 27;
       int n_dozen;
       int n_loose;
       double price;
       n_dozen=n_egg / 12;
       n_loose=n_egg % 12;
       price=n_dozen*3.25+n_loose*0.45;
       System.out.println("You ordered " + n_egg + " eggs. That's " + n_dozen + " dozen at $3.25 per dozen and " + n_loose + " loose eggs at 45 cents each for a total of $" + price);
       }
 }