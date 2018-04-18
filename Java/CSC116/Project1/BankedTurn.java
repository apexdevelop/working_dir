/**
 * Calculate velocity without friction and with friction
 *
 * @author Yan Chen
 *
 */
public class BankedTurn {
    /**
     * Starts the program.
     * 
     * @param args
     *            command line arguments
     */
    public static final int FEET_PER_MILE = 5280;
    public static final int SECONDS_PER_HOUR = 3600;
    public static final double ACCELERATION_DUE_TO_GRAVITY = 32; //feet per second squared
    public static final double FRICTION_COEFFICIENT = .25;
    public static final int MAX_ANGLE = 10; //degrees
    public static final double SMALL_RADIUS = 350; //feet
    public static final double MEDIUM_RADIUS = 500; //feet
    public static final double LARGE_RADIUS = 750; //feet
    
    public static void main(String[] args) {
        System.out.println("               Banked Turn Ideal Velocity (miles/hr)");
        System.out.println("                   Coefficient of Friction (" + FRICTION_COEFFICIENT + ")");
        System.out.println();
        System.out.println("           Radius(" + SMALL_RADIUS + " ft)" + "    Radius(" + SMALL_RADIUS + " ft)" + "    Radius(" + SMALL_RADIUS + " ft)"); 
        System.out.println("               NO"+ "                  NO" + "                  NO");
        System.out.println("Angle(deg) Friction  Friction  Friction  Friction  Friction  Friction"); 
        System.out.println("---------- --------  --------  --------  --------  --------  --------");       
        for (int angle = 0; angle <= MAX_ANGLE; angle++) {
            System.out.printf("%6d", angle);
            System.out.print("   ");
            double vf;
            double vnf;
           
            vnf = calculateVelocityWithoutFriction(SMALL_RADIUS,angle,ACCELERATION_DUE_TO_GRAVITY);
            vf = calculateVelocityWithFriction(SMALL_RADIUS,angle,ACCELERATION_DUE_TO_GRAVITY,FRICTION_COEFFICIENT);            
            System.out.printf("  %8.2f", vnf);
            System.out.printf("  %8.2f", vf);
            
            vnf = calculateVelocityWithoutFriction(MEDIUM_RADIUS,angle,ACCELERATION_DUE_TO_GRAVITY);
            vf = calculateVelocityWithFriction(MEDIUM_RADIUS,angle,ACCELERATION_DUE_TO_GRAVITY,FRICTION_COEFFICIENT);            
            System.out.printf("  %8.2f", vnf);
            System.out.printf("  %8.2f", vf);
            
            vnf = calculateVelocityWithoutFriction(LARGE_RADIUS,angle,ACCELERATION_DUE_TO_GRAVITY);
            vf = calculateVelocityWithFriction(LARGE_RADIUS,angle,ACCELERATION_DUE_TO_GRAVITY,FRICTION_COEFFICIENT);            
            System.out.printf("  %8.2f", vnf);
            System.out.printf("  %8.2f\n", vf);

        }
    }

/**
   * Calculates the ideal of velocity for a vehicle navigating a frictionless banked turn
   * @param r radius of turn in feet
   * @param angle angle of banked turn in degrees
   * @param g acceleration due to gravity in feet per second squared
   * @return ideal velocity in miles per hour
   */
  public static double calculateVelocityWithoutFriction(double r, int angle, double g) {
      double v;
      double tangent;
      tangent = Math.tan(Math.toRadians(angle));
      v = Math.sqrt(r * g * tangent)/FEET_PER_MILE*SECONDS_PER_HOUR;
      return v;
    
  } 

/**
   * Calculates the ideal of velocity for a vehicle navigating a frictionless banked turn
   * @param r radius of turn in feet
   * @param angle angle of banked turn in degrees
   * @param g acceleration due to gravity in feet per second squared
   * @return ideal velocity in miles per hour
   */
  public static double calculateVelocityWithFriction(double r, int angle, double g, double frictionCoefficient) {
      double v;
      double tangent;
      tangent = Math.tan(Math.toRadians(angle));
      v = Math.sqrt(r * g * (tangent + frictionCoefficient) / (1 - frictionCoefficient * tangent))/FEET_PER_MILE*SECONDS_PER_HOUR;
      return v;  
  }
} 