import processing.video.*;   //<>//
import gab.opencv.*;
OpenCV opencv;

private Board board;
private Mover mover;
private ArrayList<Cylinder> cylinderList;
private PGraphics bgScore, topView, scoreBoard;
private HScrollbar hs;
private BarChart bc;
private ArrayList<Float> score;
private final int DISPLAY_SCORE_HEIGHT = 160;
private int MAX_ENTRIES, lastDrawn;
private boolean changedScroll;
private Movie cam;
private TwoDThreeD projection;
PImage img,imgToPrint;

void settings() {
  //fullScreen();
  size(displayWidth, displayHeight, P3D);
}

void setup() {
  opencv = new OpenCV(this,100,100);
  cam = new Movie(this, "/home/usuario/Documentos/asignaturas/iiv/practice/visualcomputing/lab13/Game/data/output.avi"); //Put the video in the same directory
  cam.loop();
  noStroke();
  lights();
  setupElements();
  projection = new TwoDThreeD(cam.width, cam.height, 0);
}

PImage pipeline(PImage img){
  PImage result = hueThreshold(img, 83, 142);  
  result = brightnessThreshold(result,10, 189);
  result = saturationThreshold(result,59, 255);
  result = gaussianBlur(result);
  result = gaussianBlur(result);
  result = brightnessThreshold(result, 20, 200);
  BlobDetection b = new BlobDetection(result);
  PImage blob = b.findConnectedComponents(true); 
  result = scharr(blob);
  result = brightnessThreshold(result,20,255); 
  
  return result;
}

void videoMode(){
  PImage edge = pipeline(img);
  HoughAlgorithm h = new HoughAlgorithm(edge,7);
  ArrayList<PVector> detectedEdges = h.hough();
  QuadGraph graph = new QuadGraph();
  ArrayList<PVector> quadDetected = 
    new ArrayList(graph.findBestQuad(detectedEdges,edge.width,edge.height,100000,1000,false));
  if (quadDetected.size() > 3) {
    ArrayList<PVector> quadCorners = new ArrayList<PVector>(Arrays.asList(quadDetected.get(0),quadDetected.get(1),quadDetected.get(2),quadDetected.get(3)));
    //ArrayList<PVector> quadLines = new ArrayList<PVector>(Arrays.asList(quadDetected.get(4),quadDetected.get(5),quadDetected.get(6),quadDetected.get(7)));
    quad(quadCorners.get(0).x, quadCorners.get(0).y,
         quadCorners.get(1).x, quadCorners.get(1).y,
         quadCorners.get(2).x, quadCorners.get(2).y,
         quadCorners.get(3).x, quadCorners.get(3).y);
    //drawBorderLines(quadLines, edge.width);
    //drawIntersections(quadCorners);    
    for(PVector i: quadCorners){ i.z = 1.0; }
    PVector r = projection.get3DRotations((new QuadGraph()).sortCorners(quadCorners));
    System.out.println("rx = " + (int)Math.toDegrees(r.x) + ", ry = " + (int)Math.toDegrees(r.y) + ", rz = " + (int)Math.toDegrees(r.z) + "°");
    board.smoothlyAdjustParameters(r);             
  } 
  
  
}


void drawGameElements(){
  translate(width/2, height/2, 0);
  board.display(isShiftClicked());
  for (Cylinder c : cylinderList) { c.display(); }
  if (!isShiftClicked()) {
    mover.update();
    mover.checkEdges();
    mover.checkCylinderCollision();
  }
  mover.display();
}

void draw() {
  camera();
  background(255);
  text("Press the UP key for the manual mode, DOWN to exit", 400, 10); 
 
  if (cam.available() == true && !isShiftClicked() && !manualMode()) {
    cam.read();
  }
  img = cam.get();
  imgToPrint = cam.get();    
  if(!isShiftClicked() && !manualMode()){
    videoMode();
  } 
  imgToPrint.resize(300, 200);
  image(imgToPrint, 0, 0);
  drawElements();
  drawGameElements();
 
}

boolean manualModeSet = false;
boolean manualMode(){
  if(manualModeSet){
    manualModeSet = !(keyPressed == true && keyCode == DOWN);
    return manualModeSet; 
  } else {
    manualModeSet = keyPressed == true && keyCode == UP;
    return manualModeSet;
  }  
  
}

void mouseDragged() {
  if (!isShiftClicked() && !hs.locked) {
    board.setAngleZ(board.zAngle + map(mouseX - pmouseX, -width/2, width/2, -MAX_ANGLE, MAX_ANGLE)*board.speed);
    board.setAngleX(board.xAngle + map(mouseY - pmouseY, -height/2, height/2, -MAX_ANGLE, MAX_ANGLE)*board.speed);
  }
}

void mouseClicked() {
  if (isShiftClicked()) {
    Cylinder cylinder = new Cylinder(mouseX, -BOX_THICK/2, mouseY);
    if (cylinder.checkBorder() && !cylinder.isOverlap(cylinderList)) {
      cylinderList.add(cylinder);
    }
  }
}

boolean isShiftClicked() {
  return (keyPressed == true && keyCode == SHIFT);
}

void mouseWheel(MouseEvent e) {
  board.setSpeed(board.speed + (-0.1 * e.getCount()));
}

void drawBgScore() {
  bgScore.beginDraw();
  bgScore.background(204, 204, 153);
  bgScore.endDraw();
}

void drawScore() {
  scoreBoard.beginDraw();
  scoreBoard.background(204, 204, 153);
  scoreBoard.text("Total Score :\n" + score.get(score.size() - 1) + "\n\nVelocity :\n" + mover.velocity.mag() + 
    "\n\nLast Score :\n" + score.get(score.size() - 2), 10, 10);
  scoreBoard.endDraw();
}

void drawTopView() {
  topView.beginDraw();
  topView.background(0, 51, 255);
  float xPos = topView.width/2 + (mover.location.x * (topView.width*1. / BOX_SIDE));
  float yPos = topView.height/2 + (mover.location.z * (topView.height*1. / BOX_SIDE));
  topView.fill(255, 0, 0);
  topView.ellipse(xPos, yPos, BALL_RADIUS/2, BALL_RADIUS/2);
  topView.fill(255);
  for (Cylinder c : cylinderList) {
    float c_xPos = topView.width/2 + (c.location.x * (topView.width*1.0 / BOX_SIDE));
    float c_yPos = topView.height/2 + (c.location.z * (topView.height*1.0 / BOX_SIDE));
    topView.ellipse(c_xPos, c_yPos, CYLINDER_RADIUS/2, CYLINDER_RADIUS/2);
  }
  topView.endDraw();
}

void drawElements(){
  drawBgScore();
  image(bgScore, 0, height - bgScore.height);
  drawTopView();
  image(topView, 10, height - topView.height - 10);
  drawScore();
  image(scoreBoard, DISPLAY_SCORE_HEIGHT - 10, height - topView.height - 10);
  hs.update();
  hs.display();
  bc.update();
  image(bc.graphic, 2 * DISPLAY_SCORE_HEIGHT + 30, height - topView.height - 10);
  directionalLight(50, 100, 125, 1, 1, 1);
  ambientLight(120, 120, 120); 
}

void setupElements(){
  //creating variables
  score = new ArrayList();
  //Start with value 0 to begin at a correct score need double value for calculations
  score.add(0.);
  score.add(0.);
  board = new Board();
  mover = new Mover();
  cylinderList = new ArrayList<Cylinder>();
  bgScore = createGraphics(width, DISPLAY_SCORE_HEIGHT, P2D);
  topView = createGraphics(DISPLAY_SCORE_HEIGHT - 20, DISPLAY_SCORE_HEIGHT - 20, P2D);
  scoreBoard = createGraphics(DISPLAY_SCORE_HEIGHT - 20, DISPLAY_SCORE_HEIGHT - 20, P2D);
  hs = new HScrollbar(2 * DISPLAY_SCORE_HEIGHT + 3 * 10, height - 35, width - 2 * DISPLAY_SCORE_HEIGHT - 2 * 20, 25);
  bc = new BarChart (width - 2 * DISPLAY_SCORE_HEIGHT - 2 * 20, DISPLAY_SCORE_HEIGHT - 55);
  MAX_ENTRIES = (width - 2 * DISPLAY_SCORE_HEIGHT - 2 * 20) / 2;
  changedScroll = true;
  lastDrawn = 0;
}