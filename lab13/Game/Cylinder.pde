class Cylinder {
  private PVector location; // Coordinate vector of cylinder.
  private PShape openCylinder = new PShape(); // The empty shell cylinder.
  private PShape topClosed = new PShape(); // The top circle of the cylinder.
  private PShape bottomClosed = new PShape(); // The bottom circle of the cylinder.
  private PShape cylinder = new PShape(); // A shape to unit them all, the complete cylinder.
  private float angle; // Use to create the cylinder.
  private float[] x = new float[CYLINDER_RESOLUTION + 1]; // Use to create the cylinder.
  private float[] z = new float[CYLINDER_RESOLUTION + 1]; // Use to create the cylinder.

  Cylinder(float posX, float posY, float posZ) {
    noStroke();
    fill(128, 128,128);
    lights();
    translate(width/2, height/2, 0);
    location = new PVector(posX - width/2, posY, posZ - height/2);
    for (int i = 0; i < x.length; i++) {
      angle = (TWO_PI / CYLINDER_RESOLUTION) * i;
      x[i] = sin(angle) * CYLINDER_RADIUS;
      z[i] = cos(angle) * CYLINDER_RADIUS;
    }
    openCylinder = createShape();
    topClosed = createShape();
    bottomClosed = createShape();
    openCylinder.beginShape(QUAD_STRIP);
    bottomClosed.beginShape(TRIANGLE_FAN);
    topClosed.beginShape(TRIANGLE_FAN);
    bottomClosed.vertex(0, 0, 0);
    topClosed.vertex(0, -CYLINDER_HEIGHT, 0);
    for (int i = 0; i < x.length; i++) {
      openCylinder.vertex(x[i], 0, z[i]);
      openCylinder.vertex(x[i], -CYLINDER_HEIGHT, z[i]);
      bottomClosed.vertex(x[i], 0, z[i]);
      topClosed.vertex(x[i], -CYLINDER_HEIGHT, z[i]);
    }
    openCylinder.endShape();
    bottomClosed.endShape();   
    topClosed.endShape(); 
    cylinder = createShape(GROUP);
    cylinder.addChild(bottomClosed);
    cylinder.addChild(openCylinder);
    cylinder.addChild(topClosed);
  }

  void display() {
    pushMatrix();
    translate(location.x, location.y, location.z);
    shape(cylinder);
    popMatrix();
  }

  boolean isOverlap(ArrayList<Cylinder> cylinderList) {
    PVector vDistBall = new PVector(location.x - mover.location.x, location.z - mover.location.z);
    float distBall = vDistBall.mag();
    if (distBall <= CYLINDER_RADIUS + BALL_RADIUS) {
      return true;
    }
    for (Cylinder c : cylinderList) {
      PVector vDist = new PVector(location.x - c.location.x, location.z - c.location.z);
      float dist = vDist.mag();
      if ((dist <= 2 * CYLINDER_RADIUS)) {
        return true;
      }
    }
    return false;
  }

  boolean checkBorder() {
    return ((abs(location.x) <= BOX_SIDE/2) && (abs(location.z) <= BOX_SIDE/2));
  }
}