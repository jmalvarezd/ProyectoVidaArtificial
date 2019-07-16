public class CodigoGenetico {
  float viewRadius;
  float lifeExpectancy;
  float metabolism;
  float size;
  float maxSpeed;
  float maxEnergy;
  Boolean isPrey;
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
    maxSpeed = ProyectoVidaArtificial.this.random(4,5);
    maxEnergy = ProyectoVidaArtificial.this.random(1000,1500);
    isPrey = true;
  }
  public void createRandomPredator(){
    viewRadius = ProyectoVidaArtificial.this.random(90,110);
    lifeExpectancy = ProyectoVidaArtificial.this.random(55,65);
    metabolism = ProyectoVidaArtificial.this.random(0.5,1.5);
    size = ProyectoVidaArtificial.this.random(9.5,10.5);
    maxSpeed = ProyectoVidaArtificial.this.random(3.5,4.5);
    maxEnergy = ProyectoVidaArtificial.this.random(1000,1500);
    isPrey = false;
  }
}
CodigoGenetico cruzar(CodigoGenetico padre, CodigoGenetico madre){
  CodigoGenetico hijo = new CodigoGenetico(padre.isPrey);
  
  hijo = mix(padre, madre);
  hijo = mutate(hijo);
  
  return hijo;
}
CodigoGenetico mix(CodigoGenetico padre, CodigoGenetico madre){
  CodigoGenetico hijo = new CodigoGenetico(padre.isPrey);
  
  hijo.viewRadius = (padre.viewRadius+madre.viewRadius)/2;
  hijo.lifeExpectancy = (padre.lifeExpectancy+madre.lifeExpectancy)/2;
  hijo.metabolism = (padre.metabolism+madre.metabolism)/2;
  hijo.size = (padre.size+madre.size)/2;
  hijo.maxSpeed = (padre.maxSpeed+madre.maxSpeed)/2;
  hijo.maxEnergy = (padre.maxEnergy+madre.maxEnergy)/2;
  
  return hijo;
}

CodigoGenetico mutate(CodigoGenetico current){
  
  current.viewRadius = current.viewRadius * ProyectoVidaArtificial.this.random(0.95,1.05);
  current.lifeExpectancy = current.lifeExpectancy * ProyectoVidaArtificial.this.random(0.95,1.05);
  current.metabolism = current.metabolism * ProyectoVidaArtificial.this.random(0.95,1.05);
  current.size = current.size * ProyectoVidaArtificial.this.random(0.95,1.05);
  current.maxSpeed = current.maxSpeed * ProyectoVidaArtificial.this.random(0.95,1.05);
  current.maxEnergy = current.maxEnergy * ProyectoVidaArtificial.this.random(0.95,1.05);
  
  return current;
}
