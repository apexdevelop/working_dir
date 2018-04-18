public class Square{
    //instance fields
    private Ship myShip;
    private boolean beenHit;
    
    /*Providing a constructor for this class is optional. 
    *Java will provide one if you choose not to, 
    *setting the instance variable keeping track of whether the square has been hit to false 
    *and setting the reference to a Ship to null.
    */
    public Square() {
        this.myShip = null;
        beenHit = false;
    }
    
    /*returns true if the Square has been hit by enemy fire, false otherwise*/
    public boolean hasBeenHit() {
        return beenHit;
    }
    
    /*returns a Ship instance if there is a ship that includes this square or null if there is no such ship*/
    public Ship getShip() {
        return myShip;
    }
    
    /*the Square should update the fact that it has been hit. 
    *If a ship is occupying the square, it should also call the ship's hit() method to let it know that it has been hit.
    */
    public void fireAt() {
        beenHit = true;

        if(this.hasShip()) {
            myShip.hit();
        }
    }
    
    /*returns true if the Square contains a Ship.*/
    public boolean hasShip() {
        return myShip != null;
    }
    
    /*add the given Ship to the Square.*/
    public void addShip(Ship ship) {
        if(myShip == null) {
            myShip = ship;
        }
        else
            System.out.println("There is a ship here already. Error!");
    }
    
    /*Returns a single-character string indicating the state of the square. 
    *The string will be one of the following
    */
    @Override
    public String toString() {

        if(!this.hasShip() && !this.hasBeenHit())
            return "-";
        else if(this.hasBeenHit() && !this.hasShip())
            return "W";
        else if(this.hasBeenHit() && this.hasShip())
            return "R";
        else if(this.hasShip() && !this.hasBeenHit()) {
            switch(myShip.getLength()) {
                case 1:
                    return "1";
                case 2:
                    return "2";
                case 3:
                    return "3";
                case 4:
                    return "4";
            }
        }

        return "Error";
    }
}