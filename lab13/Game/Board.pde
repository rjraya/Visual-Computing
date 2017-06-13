private final float MAX_ANGLE = PI/3.0;
private final float MIN_SPEED = 0.2;
private final float MAX_SPEED = 1.5;

class Board {
  private float speed, xAngle, zAngle;
  Board() {
    xAngle = 0.0;
    zAngle = 0.0;
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
    float smoothXAngle = rot.x;//(xAngle+rot.x)/2.0;
    float smoothZAngle = rot.y;//(zAngle+rot.y)/2.0;

    /*if(rot.x > xAngle){
      xAngle = min(smoothXAngle, MAX_ANGLE);
    } else if(rot.x < xAngle){
      xAngle = max(smoothXAngle, -MAX_ANGLE);
    }

    if(-rot.y > zAngle){
      zAngle = min(smoothZAngle, MAX_ANGLE);
    } else if(-rot.y < zAngle){
      zAngle = max(smoothZAngle, -MAX_ANGLE);
    }*/
    xAngle = rot.x - PI;
    zAngle = rot.z;
    
  }  
  
  void setSpeed(float s){
    speed = Math.max(Math.min(s, MAX_SPEED), MIN_SPEED);
  }
  
  void setAngleX(float x) {
    xAngle = Math.max(Math.min(x, MAX_ANGLE), -1*MAX_ANGLE);
  }
  
  void setAngleZ(float z) {
    zAngle = Math.max(Math.min(z, MAX_ANGLE), -1*MAX_ANGLE);
  }
}