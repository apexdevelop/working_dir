/**
 * Tests BankedTurn program
 * @author Suzanne Balik
 */
public class BankedTurnTest {

  /**
   * Tests calculateVelocityWithoutFriction and calculateVelocityWithFriction methods
   * @param args command line arguments
   */
  public static void main(String[] args) {
    
    double velocity = BankedTurn.calculateVelocityWithoutFriction(1100, 33, 32);
    System.out.printf("\nExpected: 103.09 Actual: %.2f\n", velocity);
    
    velocity = BankedTurn.calculateVelocityWithFriction(1100, 33, 32, .69);
    System.out.printf("\nExpected: 199.28 Actual: %.2f\n", velocity);
    
  }
}