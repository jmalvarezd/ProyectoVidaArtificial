public class SandPile extends Node{
  PShape pyramid;
  Vector position;
  float currentEnergy;
  float baseSize = 60;
  float maxEnergy = baseSize;
  
  SandPile(Scene scene, Vector inPos){
    super(scene);
    position = new Vector();
    position.set(inPos);
    setPosition(new Vector(position.x(), position.y(), position.z()));
    currentEnergy = 0;
    pyramid = truncatedPyramid(baseSize,baseSize,0,10);
  }
  
  @Override
  public void visit() {
    if (animate){
      if(currentEnergy < maxEnergy){
        currentEnergy += 0.1;
      }
      else{
        currentEnergy = maxEnergy;
      }
      pyramid = truncatedPyramid(baseSize-currentEnergy,baseSize,currentEnergy,10);
    }
  }
  
  @Override
  public void graphics(PGraphics pg) {
    pg.pushStyle();
    pg.noStroke();
    pg.fill(0,255,0);
    pyramid.disableStyle();
    pg.shape(pyramid);
    pg.popStyle();
  }
  
  PShape truncatedPyramid(float bottom, float top, float h, int sides)
  {
    PShape pyramid = createShape(GROUP);
    PShape sideFaces = createShape();
    PShape base1 = createShape();
    PShape base2 = createShape();
    pushMatrix();
    pushStyle();
    
    float angle;
    float[] x = new float[sides+1];
    float[] z = new float[sides+1];
    
    float[] x2 = new float[sides+1];
    float[] z2 = new float[sides+1];
   
    //get the x and z position on a circle for all the sides
    for(int i=0; i < x.length; i++){
      angle = TWO_PI / (sides) * i;
      x[i] = sin(angle) * bottom;
      z[i] = cos(angle) * bottom;
    }
    
    for(int i=0; i < x.length; i++){
      angle = TWO_PI / (sides) * i;
      x2[i] = sin(angle) * top;
      z2[i] = cos(angle) * top;
    }
   
    //draw the bottom of the cylinder
    base1.beginShape(TRIANGLE_FAN);
   
    base1.vertex(0,   -h,    0);
   
    for(int i=0; i < x.length; i++){
      base1.vertex(x[i], -h, z[i]);
    }
   
    base1.endShape();
   
    //draw the center of the cylinder
    sideFaces.beginShape(QUAD_STRIP); 
   
    for(int i=0; i < x.length; i++){
      sideFaces.vertex(x[i], -h, z[i]);
      sideFaces.vertex(x2[i], 0, z2[i]);
    }
   
    sideFaces.endShape();
   
    //draw the top of the cylinder
    base2.beginShape(TRIANGLE_FAN); 
   
    base2.vertex(0,  0,    0);
   
    for(int i=0; i < x.length; i++){
      base2.vertex(x2[i], 0, z2[i]);
    }
   
    base2.endShape();
    
    popMatrix();
    popStyle();
    
    pyramid.addChild(base1);
    pyramid.addChild(sideFaces);
    pyramid.addChild(base2);
    
    return pyramid;
    
  }

}
