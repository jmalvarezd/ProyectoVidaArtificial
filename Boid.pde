class Boid extends Node {
  // fields
  Vector position, velocity, acceleration, alignment, cohesion, separation; // position, velocity, and acceleration in
  // a vector datatype
  float neighborhoodRadius; // radius in which it looks for fellow boids
  float maxSpeed; // maximum magnitude for the velocity vector
  float maxSteerForce = .1f; // maximum magnitude of the steering vector
  float sc; // scale factor for the render of the boid
  float flap = 0;
  float t = 0;
  float currentEnergy = 0;
  float maxEnergy;
  float lifeExpectancy;
  float metabolism;
  boolean shouldBeDrawn = true;
  boolean isMale;
  boolean isAdult = false;
  int preferedFood;
  float distanceToFood;
  Piel piel;
  CodigoGenetico codigo;

  Boid(Scene scene, Vector inPos) {
    super(scene);
    piel = new Piel();
    piel.c = false;
    piel.setup();
    position = new Vector();
    position.set(inPos);
    setPosition(new Vector(position.x(), position.y(), position.z()));
    velocity = new Vector(ProyectoVidaArtificial.this.random(-1, 1), ProyectoVidaArtificial.this.random(-1, 1), ProyectoVidaArtificial.this.random(1, -1));
    acceleration = new Vector(0, 0, 0);
    neighborhoodRadius = 100;
    maxEnergy = ProyectoVidaArtificial.this.random(500,2000);
    currentEnergy = maxEnergy*3.0/4.0;
    preferedFood = int(ProyectoVidaArtificial.this.random(0,3));
    distanceToFood = Vector.distance(position, pilesOfFood.get(preferedFood).position);
    isMale = Math.random() < 0.5;
    lifeExpectancy = 90;
    metabolism = 1.0;
    sc = 3.0;
    maxSpeed = 4.0;
  }
  Boid(Scene scene, Vector inPos, CodigoGenetico code) {
    super(scene);
    piel = new Piel();
    piel.c = false;
    piel.setup();
    codigo = code;
    position = new Vector();
    position.set(inPos);
    setPosition(new Vector(position.x(), position.y(), position.z()));
    velocity = new Vector(ProyectoVidaArtificial.this.random(-1, 1), ProyectoVidaArtificial.this.random(-1, 1), ProyectoVidaArtificial.this.random(1, -1));
    acceleration = new Vector(0, 0, 0);
    neighborhoodRadius = code.viewRadius;
    maxEnergy = code.maxEnergy;
    currentEnergy = maxEnergy*3.0/4.0;
    preferedFood = int(ProyectoVidaArtificial.this.random(0,3));
    distanceToFood = Vector.distance(position, pilesOfFood.get(preferedFood).position);
    isMale = Math.random() < 0.5;
    lifeExpectancy = code.lifeExpectancy;
    metabolism = code.metabolism;
    sc = code.size;
    maxSpeed = code.maxSpeed;
  }

  @Override
  public void visit() {
    if (animate){
      run(flockPrey);
    }
  }

  @Override
  public void graphics(PGraphics pg) {
    pg.pushStyle();

    //uncomment to draw boid axes
    if(isMale){
      //Scene.drawAxes(pg, 10);
    }
    pg.noStroke();

    // highlight boids under the mouse
    if (scene.trackedNode("mouseMoved") == this) {
      pg.stroke(color(0, 0, 255));
      pg.fill(color(0, 0, 255));
    }

    // highlight avatar
    if (this ==  avatar) {
      pg.stroke(color(255, 0, 0));
      pg.fill(color(255, 0, 0));
    }

    //draw boid
    textureMode(NORMAL);
    pg.beginShape(TRIANGLES);
    pg.texture(piel.img);
    pg.vertex(3 * sc, 0, 0,0.5,0);
    pg.vertex(-3 * sc, 2 * sc, 0,0,0);
    pg.vertex(-3 * sc, -2 * sc, 0,0,1);

    pg.vertex(3 * sc, 0, 0,0.5,0);
    pg.vertex(-3 * sc, 2 * sc, 0,0,1);
    pg.vertex(-3 * sc, 0, 2 * sc,0,0);

    pg.vertex(3 * sc, 0, 0,0.5,0);
    pg.vertex(-3 * sc, 0, 2 * sc,0,1);
    pg.vertex(-3 * sc, -2 * sc, 0,0,0);

    pg.vertex(-3 * sc, 0, 2 * sc,0.5,0);
    pg.vertex(-3 * sc, 2 * sc, 0,0,1);
    pg.vertex(-3 * sc, -2 * sc, 0,1,0);
    pg.endShape();

    pg.popStyle();
  }

  public void run(ArrayList<Boid> bl) {
    t += .1;
    if(t > 30){
      isAdult = true;
    }
    if(t > lifeExpectancy){
      currentEnergy = 0;
    }
    flap = 10 * sin(t);
    // acceleration.add(steer(new Vector(mouseX,mouseY,300),true));
    //acceleration.add(new Vector(0,1,0));
    if (avoidWalls) {
      float turner = 5;
      acceleration.add(Vector.multiply(avoid(new Vector(position.x(), flockHeight , position.z())), turner));
      acceleration.add(Vector.multiply(avoid(new Vector(position.x(), 0           , position.z())), turner));
      acceleration.add(Vector.multiply(avoid(new Vector(flockWidth  , position.y(), position.z())), turner));
      acceleration.add(Vector.multiply(avoid(new Vector(0           , position.y(), position.z())), turner));
      acceleration.add(Vector.multiply(avoid(new Vector(position.x(), position.y(), 0           )), turner));
      acceleration.add(Vector.multiply(avoid(new Vector(position.x(), position.y(), flockDepth  )), turner));
    }
    flock(bl);
    hungryBehavior();
    move();
    checkBounds();
    
  }

  Vector avoid(Vector target) {
    Vector steer = new Vector(); // creates vector for steering
    steer.set(Vector.subtract(position, target)); // steering vector points away from
    steer.multiply(1 / sq(Vector.distance(position, target)));
    return steer;
  }
  
  Vector seek(Vector target) {
    Vector steer = new Vector(); // creates vector for steering
    steer.set(Vector.subtract(target, position)); // steering vector points away from
    steer.multiply(1 / sq(Vector.distance(position, target)));
    return steer;
  }

  //-----------behaviors---------------

  void flock(ArrayList<Boid> boids) {
    //alignment
    alignment = new Vector(0, 0, 0);
    int alignmentCount = 0;
    //cohesion
    Vector posSum = new Vector();
    int cohesionCount = 0;
    //separation
    separation = new Vector(0, 0, 0);
    Vector repulse;
    for (int i = 0; i < boids.size(); i++) {
      Boid boid = boids.get(i);
      //alignment
      float distance = Vector.distance(position, boid.position);
      //print("distance = " + distance + " ");
      if (distance > 0 && distance <= neighborhoodRadius) {
        alignment.add(boid.velocity);
        alignmentCount++;
      }
      //cohesion
      //distance = dist(position.x(), position.y(), boid.position.x(), boid.position.y());
      if (distance > 0 && distance <= neighborhoodRadius) {
        posSum.add(boid.position);
        cohesionCount++;
        reproduce(boid);
      }
      //separation
      if (distance > 0 && distance <= neighborhoodRadius) {
        repulse = Vector.subtract(position, boid.position);
        repulse.normalize();
        repulse.divide(distance);
        separation.add(repulse);
      }
    }
    //alignment
    if (alignmentCount > 0) {
      alignment.divide((float) alignmentCount);
      alignment.limit(maxSteerForce);
    }
    //cohesion
    if (cohesionCount > 0)
      posSum.divide((float) cohesionCount);
    cohesion = Vector.subtract(posSum, position);
    cohesion.limit(maxSteerForce);

    acceleration.add(Vector.multiply(alignment, 1));
    acceleration.add(Vector.multiply(cohesion, 3));
    acceleration.add(Vector.multiply(separation, 1));
  }
  
  void hungryBehavior(){
    if(currentEnergy < maxEnergy/2){
      distanceToFood = Vector.distance(position, pilesOfFood.get(preferedFood).position);
      acceleration.add(Vector.multiply(seek(pilesOfFood.get(preferedFood).position), 50));
      if(distanceToFood > 0 && distanceToFood <= neighborhoodRadius){
        if(maxEnergy - currentEnergy > pilesOfFood.get(preferedFood).currentEnergy){
          currentEnergy += pilesOfFood.get(preferedFood).currentEnergy;
          pilesOfFood.get(preferedFood).currentEnergy = 0;
        }
        else{ 
          pilesOfFood.get(preferedFood).currentEnergy -= maxEnergy-currentEnergy;
          currentEnergy = maxEnergy;
        }
      }
    }
  }
  
  void reproduce(Boid boid){
    if(currentEnergy > maxEnergy*9.0/10.0 && (isMale ^ boid.isMale) && (isAdult) && (boid.isAdult)){
      currentEnergy = currentEnergy/2.0;
      boid.currentEnergy = boid.currentEnergy/2.0;
      positionsToCreate.add(position);
      geneticsToCreate.add(cruzar(codigo,boid.codigo));
    }
  }

  void move() {
    velocity.add(acceleration); // add acceleration to velocity
    velocity.limit(maxSpeed); // make sure the velocity vector magnitude does not
    // exceed maxSpeed
    position.add(velocity); // add velocity to position
    setPosition(position);
    setRotation(Quaternion.multiply(new Quaternion(new Vector(0, 1, 0), atan2(-velocity.z(), velocity.x())), 
      new Quaternion(new Vector(0, 0, 1), asin(velocity.y() / velocity.magnitude()))));
    acceleration.multiply(0); // reset acceleration
    currentEnergy = currentEnergy - metabolism;
  }

  void checkBounds() {
    if (position.x() > flockWidth)
      position.setX(0);
    if (position.x() < 0)
      position.setX(flockWidth);
    if (position.y() > flockHeight)
      position.setY(0);
    if (position.y() < 0)
      position.setY(flockHeight);
    if (position.z() > flockDepth)
      position.setZ(0);
    if (position.z() < 0)
      position.setZ(flockDepth);
  }
}
