/**
 * Flock of Boids
 * by Jean Pierre Charalambos.
 *
 * This example displays the famous artificial life program "Boids", developed by
 * Craig Reynolds in 1986 [1] and then adapted to Processing by Matt Wetmore in
 * 2010 (https://www.openprocessing.org/sketch/6910#), in 'third person' eye mode.
 * The Boid under the mouse will be colored blue. If you click on a boid it will
 * be selected as the scene avatar for the eye to follow it.
 *
 * 1. Reynolds, C. W. Flocks, Herds and Schools: A Distributed Behavioral Model. 87.
 * http://www.cs.toronto.edu/~dt/siggraph97-course/cwr87/
 * 2. Check also this nice presentation about the paper:
 * https://pdfs.semanticscholar.org/73b1/5c60672971c44ef6304a39af19dc963cd0af.pdf
 * 3. Google for more...
 *
 * Press ' ' to switch between the different eye modes.
 * Press 'a' to toggle (start/stop) animation.
 * Press 'p' to print the current node rate.
 * Press 'm' to change the boid visual mode.
 * Press 'v' to toggle boids' wall skipping.
 * Press 's' to call scene.fit(1).
 */

import nub.primitives.*;
import nub.core.*;
import nub.processing.*;

Scene scene;
//flock bounding box
int flockWidth = 1280;
int flockHeight = 720;
int flockDepth = 600;
boolean avoidWalls = true;

int initBoidNum = 900; // amount of boids to start the program with
ArrayList<Boid> flock;
Node avatar; 
boolean animate = true;

void setup() {
  size(1000, 800, P3D);
  scene = new Scene(this);
  scene.setFrustum(new Vector(0, 0, 0), new Vector(flockWidth, flockHeight, flockDepth));
  scene.fit();
  // create and fill the list of boids
  flock = new ArrayList();
  for (int i = 0; i < initBoidNum; i++)
    flock.add(new Boid(scene, new Vector(flockWidth / 2, flockHeight / 2, flockDepth / 2)));
}

void draw() {
  background(10, 50, 25);
  ambientLight(128, 128, 128);
  directionalLight(255, 255, 255, 0, 1, -100);
  walls();
  plants();
  scene.render();
  // uncomment to asynchronously update boid avatar. See mouseClicked()
  // updateAvatar(scene.trackedNode("mouseClicked"));
}

void walls() {
  pushStyle();
  noFill();
  stroke(255, 255, 0);

  line(0, 0, 0, 0, flockHeight, 0);
  line(0, 0, flockDepth, 0, flockHeight, flockDepth);
  line(0, 0, 0, flockWidth, 0, 0);
  line(0, 0, flockDepth, flockWidth, 0, flockDepth);

  line(flockWidth, 0, 0, flockWidth, flockHeight, 0);
  line(flockWidth, 0, flockDepth, flockWidth, flockHeight, flockDepth);
  line(0, flockHeight, 0, flockWidth, flockHeight, 0);
  line(0, flockHeight, flockDepth, flockWidth, flockHeight, flockDepth);

  line(0, 0, 0, 0, 0, flockDepth);
  line(0, flockHeight, 0, 0, flockHeight, flockDepth);
  line(flockWidth, 0, 0, flockWidth, 0, flockDepth);
  line(flockWidth, flockHeight, 0, flockWidth, flockHeight, flockDepth);
  popStyle();
}

float theta;  
float plantX = -1, plantZ;
void plants(){
  float a = (0.5) * 90f;
  theta = radians(a);
  pushMatrix();
  stroke(0,255,0);
  if(plantX == -1){
    plantX = random(20,flockWidth-20);
    plantZ = random(20,flockDepth-20);
  }
  translate(plantX,flockHeight,plantZ);
  line(0,0,0,-120);
  translate(0,-120,0);
  branch(120);
  popMatrix();
}

void branch(float h) {
  // Each branch will be 2/3rds the size of the previous one
  h *= 0.66;
  
  // All recursive functions must have an exit condition!!!!
  // Here, ours is when the length of the branch is 2 pixels or less
  if (h > 2) {
    pushMatrix();    // Save the current state of transformation (i.e. where are we now)
    rotate(theta);   // Rotate by theta
    line(0, 0, 0, -h);  // Draw the branch
    translate(0, -h); // Move to the end of the branch
    branch(h);       // Ok, now call myself to draw two new branches!!
    popMatrix();     // Whenever we get back here, we "pop" in order to restore the previous matrix state
    
    // Repeat the same thing, only branch off to the "left" this time!
    pushMatrix();
    rotate(-theta);
    line(0, 0, 0, -h);
    translate(0, -h);
    branch(h);
    popMatrix();
  }
}

void updateAvatar(Node node) {
  if (node != avatar) {
    avatar = node;
    if (avatar != null)
      thirdPerson();
    else if (scene.eye().reference() != null)
      resetEye();
  }
}

// Sets current avatar as the eye reference and interpolate the eye to it
void thirdPerson() {
  scene.eye().setReference(avatar);
  scene.fit(avatar, 1);
}

// Resets the eye
void resetEye() {
  // same as: scene.eye().setReference(null);
  scene.eye().resetReference();
  scene.lookAt(scene.center());
  scene.fit(1);
}

// picks up a boid avatar, may be null
void mouseClicked() {
  // two options to update the boid avatar:
  // 1. Synchronously
  updateAvatar(scene.track("mouseClicked", mouseX, mouseY));
  // which is the same as these two lines:
  // scene.track("mouseClicked", mouseX, mouseY);
  // updateAvatar(scene.trackedNode("mouseClicked"));
  // 2. Asynchronously
  // which requires updateAvatar(scene.trackedNode("mouseClicked")) to be called within draw()
  // scene.cast("mouseClicked", mouseX, mouseY);
}

// 'first-person' interaction
void mouseDragged() {
  if (scene.eye().reference() == null)
    if (mouseButton == LEFT)
      // same as: scene.spin(scene.eye());
      scene.spin();
    else if (mouseButton == RIGHT)
      // same as: scene.translate(scene.eye());
      scene.translate();
    else
      scene.moveForward(mouseX - pmouseX);
}

// highlighting and 'third-person' interaction
void mouseMoved(MouseEvent event) {
  // 1. highlighting
  scene.cast("mouseMoved", mouseX, mouseY);
  // 2. third-person interaction
  if (scene.eye().reference() != null)
    // press shift to move the mouse without looking around
    if (!event.isShiftDown())
      scene.lookAround();
}

void mouseWheel(MouseEvent event) {
  // same as: scene.scale(event.getCount() * 20, scene.eye());
  scene.scale(event.getCount() * 20);
}

void keyPressed() {
  switch (key) {
  case 'a':
    animate = !animate;
    break;
  case 's':
    if (scene.eye().reference() == null)
      scene.fit(1);
    break;
  case 't':
    scene.shiftTimers();
    break;
  case 'p':
    println("Node rate: " + frameRate);
    break;
  case 'v':
    avoidWalls = !avoidWalls;
    break;
  case ' ':
    if (scene.eye().reference() != null)
      resetEye();
    else if (avatar != null)
      thirdPerson();
    break;
  }
}