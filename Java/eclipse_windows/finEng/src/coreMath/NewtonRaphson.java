package coreMath;
import java.lang.Math;
public abstract class NewtonRaphson extends Derivative
{
	public abstract double newtonroot(double rootvalue);
	//the requesting function implements the calculation fx//
	public double precisionvalue;
	public int iterate;
	public void accuracy(double precision, int iterations)
	//method gets the desired accuracy//
	{
		super.h = precision; //sets the superclass derivative//
		this.precisionvalue = precision;
		this.iterate = iterations;
	}
	
	public double newtraph(double lowerbound)
	{
		int counter = 0;
		double fx=newtonroot(lowerbound);
		double Fx=derivation(lowerbound);
		double x = (lowerbound-(fx/Fx));
		double diff = Math.abs(Math.abs(x)-Math.abs(lowerbound));
		System.out.println("iteration" + (counter+1) + ",root: " + x + ",error:" + diff);
		while (diff>precisionvalue & counter<iterate)
		{
			lowerbound = x;
			//newtraph(lowerbound);//recursive call to newtraph//
			fx=newtonroot(lowerbound);
			Fx=derivation(lowerbound);
			x = (lowerbound-fx/Fx);
			diff = Math.abs(Math.abs(x)-Math.abs(lowerbound));
			counter++;
			System.out.println("iteration" + (counter+1) + ",root: " + x + ",error:" + diff);
		}
		return x;
	}
	
	public double deriveFunction(double inputa)
	{
		double x1=newtonroot(inputa);
		return x1;
	}
}