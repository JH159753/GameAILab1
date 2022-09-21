/// In this file, you will have to implement seek and waypoint-following
/// The relevant locations are marked with "TODO"

class Crumb
{
  PVector position;
  Crumb(PVector position)
  {
     this.position = position;
  }
  void draw()
  {
     fill(255);
     noStroke(); 
     circle(this.position.x, this.position.y, CRUMB_SIZE);
  }
}

class Boid
{
   Crumb[] crumbs = {};
   int last_crumb;
   float acceleration;
   float rotational_acceleration;
   KinematicMovement kinematic;
   PVector target;
   
   Boid(PVector position, float heading, float max_speed, float max_rotational_speed, float acceleration, float rotational_acceleration)
   {
     this.kinematic = new KinematicMovement(position, heading, max_speed, max_rotational_speed);
     this.last_crumb = millis();
     this.acceleration = acceleration;
     this.rotational_acceleration = rotational_acceleration;
   }

   void update(float dt)
   {
     if (target != null)
     {  
        // TODO: Implement seek here
        
        
        //This makes a vector with the direction our boid needs to go to
        PVector direction = PVector.sub(target, kinematic.position);
        
        //atan2(direction.y, direction.x) will return the direction we need to go in radians
        
        //print direction we need to go and the direction we are facing right now
        //println(atan2(direction.y, direction.x) + " " + normalize_angle_left_right(kinematic.getHeading()));
        
        float directionalThreshold = .1;
        float angleToTarget = atan2(direction.y, direction.x) - normalize_angle_left_right(kinematic.getHeading());
        float arrivalThreshold = 60.0;
        
        //This just draws a circle for visual debugging purposes
        //circle(target.x, target.y, arrivalThreshold);
        
        //prints the angle to the target
        //println(angleToTarget);
        
        //if the angle is larger than the threshold in the positive direction, rotate counterclockwise
        if (angleToTarget > directionalThreshold) {
          kinematic.increaseSpeed(0.0, +1);
          
        //if the angle is smaller than the threshold in the negative direction, rotate clockwise
        } else if (angleToTarget < -directionalThreshold) {
          kinematic.increaseSpeed(0.0, -1);
          
        //if the angle is within our threshold, stop our rotational velocity by rotating opposite
        } else if (directionalThreshold > angleToTarget) {
          
          if (kinematic.getRotationalVelocity() > 0) {
            kinematic.increaseSpeed(0.0, -1);
          }
          else if (kinematic.getRotationalVelocity() < 0) {
            kinematic.increaseSpeed(0.0, 1); 
          }
        }
        
        
        
        //Slight flaw: since the arrival threshold is so big, the boid just won't move if its target is that close. 
        
        //if the target is outside its arrival threshold, accelerate. 
        //if the target is inside its arrival threshold, accelerate backwards until the speed is 0.
        if (direction.mag() > arrivalThreshold) {
          kinematic.increaseSpeed(1,0);
        } else if (direction.mag() < arrivalThreshold) {
          if (kinematic.getSpeed() > 0) {
            kinematic.increaseSpeed(-1,0);
          } 
        }
        
        
        
        //drawing a line for testing purposes
        line(kinematic.position.x, kinematic.position.y, kinematic.position.x + direction.x, kinematic.position.y + direction.y);
        
        
        
        
        
        
        
        
        
     }
     
     // place crumbs, do not change     
     if (LEAVE_CRUMBS && (millis() - this.last_crumb > CRUMB_INTERVAL))
     {
        this.last_crumb = millis();
        this.crumbs = (Crumb[])append(this.crumbs, new Crumb(this.kinematic.position));
        if (this.crumbs.length > MAX_CRUMBS)
           this.crumbs = (Crumb[])subset(this.crumbs, 1);
     }
     
     // do not change
     this.kinematic.update(dt);
     
     draw();
   }
   
   void draw()
   {
     for (Crumb c : this.crumbs)
     {
       c.draw();
     }
     
     fill(255);
     noStroke(); 
     float x = kinematic.position.x;
     float y = kinematic.position.y;
     float r = kinematic.heading;
     circle(x, y, BOID_SIZE);
     // front
     float xp = x + BOID_SIZE*cos(r);
     float yp = y + BOID_SIZE*sin(r);
     
     // left
     float x1p = x - (BOID_SIZE/2)*sin(r);
     float y1p = y + (BOID_SIZE/2)*cos(r);
     
     // right
     float x2p = x + (BOID_SIZE/2)*sin(r);
     float y2p = y - (BOID_SIZE/2)*cos(r);
     triangle(xp, yp, x1p, y1p, x2p, y2p);
   } 
   
   void seek(PVector target)
   {
      this.target = target;
      
   }
   
   void follow(ArrayList<PVector> waypoints)
   {
      // TODO: change to follow *all* waypoints
      this.target = waypoints.get(0);
      
   }
}
