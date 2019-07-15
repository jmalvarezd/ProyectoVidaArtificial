public class CodigoGenetico {
  float viewRadius;
  float lifeExpectancy;
  float metabolism;
  float size;
  float maxSpeed;
  float maxEnergy;
  CodigoGenetico(boolean isPrey){
    if(isPrey){
      createRandomPrey();
    }
    else{
      createRandomPredator();
    }
  }
  public void createRandomPrey(){
    viewRadius = ProyectoVidaArtificial.this.random(90,110);
    lifeExpectancy = ProyectoVidaArtificial.this.random(90,110);
    metabolism = ProyectoVidaArtificial.this.random(0.5,1.5);
    size = ProyectoVidaArtificial.this.random(2.5,3.5);
    maxSpeed = ProyectoVidaArtificial.this.random(4.5,5.5);
    maxEnergy = ProyectoVidaArtificial.this.random(1000,1500);
  }
  public void createRandomPredator(){
    viewRadius = ProyectoVidaArtificial.this.random(90,110);
    lifeExpectancy = ProyectoVidaArtificial.this.random(90,110);
    metabolism = ProyectoVidaArtificial.this.random(0.5,1.5);
    size = ProyectoVidaArtificial.this.random(9.5,10.5);
    maxSpeed = ProyectoVidaArtificial.this.random(3.5,4.5);
    maxEnergy = ProyectoVidaArtificial.this.random(1000,1500);
  }
}
