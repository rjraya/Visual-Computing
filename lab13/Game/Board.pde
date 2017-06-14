private final float MAX_ANGLE = PI/3.0;
private final float BOX_SIDE = 500;
private final float BOX_THICK = 10;

class Board {

  private final float MIN_SPEED = 0.2;
  private final float MAX_SPEED = 1.5;
  private float speed, xAngle, zAngle, yAngle;
  Board() {
    xAngle = 0.0;
    zAngle = 0.0;
    yAngle = 0.0;
    speed = 1;
  }
  void display(boolean isShiftClicked) {
    fill(118);
    //Add cylinders mode
    if (isShiftClicked) {
      rotateX(-PI/2.0);
    } else {
      rotateX(-xAngle);
      rotateZ(zAngle);
      //rotateY(yAngle);
    }
    box(BOX_SIDE, BOX_THICK, BOX_SIDE);
  }
  
  //keeping inside the boundries
  void adjustParameters() {
    setSpeed(speed);
    setAngleX(-xAngle);
    setAngleZ(zAngle);
  } 
  
  void smoothlyAdjustParameters(PVector rot){
    float smoothXAngle = rot.x - PI;
    float smoothZAngle = rot.z;
    float smoothYAngle = rot.y;
    setAngleY(smoothYAngle*speed);
    setAngleX(-smoothXAngle*speed);
    setAngleZ(smoothZAngle*speed);

    System.out.println("bx = " + (int)Math.toDegrees(xAngle) + ", by = " + (int)Math.toDegrees(yAngle) + ", bz = " + (int)Math.toDegrees(zAngle) + "°");   
  }  
  
  void setSpeed(float s){
    speed = Math.max(Math.min(s, MAX_SPEED), MIN_SPEED);
  }
  
  void setAngleX(float x) {
    xAngle = Math.max(Math.min(x, MAX_ANGLE), -1*MAX_ANGLE);
  }
  
  void setAngleY(float y) {
    yAngle = Math.max(Math.min(y, MAX_ANGLE), -1*MAX_ANGLE);
  }
  
  void setAngleZ(float z) {
    zAngle = Math.max(Math.min(z, MAX_ANGLE), -1*MAX_ANGLE);
  }
}