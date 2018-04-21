package coreMath;
public abstract class Derivative
{
	public abstract double deriveFunction(double fx);
	//return a double
	public double h;//degree of accuracy in the calculation//
	public double derivation(double InputFunc)
	{
		double value;
		double X2=deriveFunction(InputFunc - h);
		double X1=deriveFunction(InputFunc + h);
		value=((X1-X2)/(2*h));
		return value;
	}
}