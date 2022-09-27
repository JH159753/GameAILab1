
/// called when "f" is pressed; should instantiate additional boids and start flocking
Boid[] billies = new Boid[8];
void flock()
{
  int lasttr = 0;
  println("flock called");
  float dt = (millis() - lasttr)/1000.0;
  lasttr = millis();
  PVector target = new PVector(mouseX, mouseY);
  
  for(int i = 0; i < 7; i++)
  {
     billies[i] = new Boid(new PVector(100 + i*100, 500), BILLY_START_HEADING, BILLY_MAX_SPEED, BILLY_MAX_ROTATIONAL_SPEED, BILLY_MAX_ACCELERATION, BILLY_MAX_ROTATIONAL_ACCELERATION);
     println("billy " + billies[i].toString()); 

  billies[i].update(dt);
  billies[i].seek(target);
  }
  

}

/// called when "f" is pressed again; should remove the flock
void unflock()
{
}
