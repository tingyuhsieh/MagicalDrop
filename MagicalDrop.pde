import processing.sound.*;
SoundFile[] comboR = new SoundFile[9];
SoundFile[] comboL = new SoundFile[9];
SoundFile addballs, down, up, BGM;

PImage red, yellow, green, blue, empty;
PImage goddess, devil;
PImage bg;
PImage win, lose;
player player1, player2;
Runtime runtime;
String comboStr, pointStr;
PImage[] num = new PImage[10];
int mode;


void setup() {
  size(900, 650, P3D);
  runtime=java.lang.Runtime.getRuntime();
  player1=new player(1);
  player2=new player(2);

  mode = 0;

  red = loadImage("red2.png");
  yellow = loadImage("yellow2.png");
  green = loadImage("green2.png");
  blue = loadImage("blue2.png");
  empty = loadImage("empty.png");
  bg = loadImage("bg.jpg");
  win = loadImage("win.png");
  lose = loadImage("lose.png");
  for (int i = 0; i < 10; i++) {
    num[i] = loadImage(nf(i, 1) + ".png");
  }

  for (int i = 0; i < 9; i++) {
    comboR[i] = new SoundFile(this, "combo" + nf(i+1, 1) + ".mp3");
    comboL[i] = new SoundFile(this, "combo" + nf(i+1, 1) + ".mp3");
  }

  addballs = new SoundFile(this, "addballs.mp3");
  down = new SoundFile(this, "down.mp3");
  up = new SoundFile(this, "up.mp3");

  addballs.amp(1.0);

  goddess=loadImage("goddess.png");
  devil=loadImage("devil.png");
}

void draw() {
  println(player2.deadButt);
  if (frameCount%300==0) {
    thread("garbageCollector");
  }
  background(0);
  noTint();
  image(bg, 350, 0);

  player1.drawPlayer(goddess);
  translate(width-350, 0, 0);
  player2.drawPlayer(devil);
  if (mode == 1) {
    if (player1.bombCount==player1.bombtime-1) {

      if (player1.combo%2 ==0)player2.addLines();
    }
    if (player2.bombCount==player2.bombtime-1) {

      if (player2.combo%2 ==0)player1.addLines();
    }
    if (player1.stopCombo) player2.attacked();
    if (player2.stopCombo) player1.attacked();
    tint(255, 200);
    pushMatrix();
    scale(1, 1);
    translate(-280, 580);
    drawCombo(player1.combo);
    popMatrix();
    pushMatrix();
    scale(1, 1);
    translate(270, 580);
    drawCombo(player2.combo);
    popMatrix();
  }
  tint(255, 200);
  pushMatrix();
  scale(1, 1);
  translate(-193, 329);
  drawPoint(player1.bombN);
  popMatrix();
  pushMatrix();
  scale(1, 1);
  translate(-127, 412);
  drawPoint(player2.bombN);
  popMatrix();
  noTint();
  if (mode == 211 || mode == 221 || mode == 231) {
    image(lose, 0, 450);
    image(win, -550, 450);
  } else if (mode == 212 || mode == 222 || mode == 232) {

    image(lose, -550, 450);
    image(win, 0, 450);
  }
}

void keyPressed() {

  if (mode == 1) {
    player1.keyPressed();
    player2.keyPressed();
  } else if (mode == 0) {
    if (key == '0') mode = 1;
  }
}
void garbageCollector() {
  runtime.gc();
}

//----------------------畫出數字----------------------
void drawCombo(int _numberC) {
  comboStr = nf(_numberC, 2);
  //image(num[0], 40, 55);
  if (_numberC != 0) comboImg();
  //print(comboStr.charAt(0));
  //println(comboStr.charAt(1));
}
void drawPoint(int _numberP) {
  pointStr = nf(_numberP, 3);
  //image(num[0], 40, 55);
  pointImg();
  //print(comboStr.charAt(0));
  //println(comboStr.charAt(1));
}
void comboImg() {
  //if (comboStr.charAt(0) == '0') image(num[0], 40, 55);
  if (comboStr.charAt(0) == '1') image(num[1], 0, 0, 40, 60);
  else if (comboStr.charAt(0) == '2') image(num[2], 0, 0, 40, 60);
  else if (comboStr.charAt(0) == '3') image(num[3], 0, 0, 40, 60);
  else if (comboStr.charAt(0) == '4') image(num[4], 0, 0, 40, 60);
  else if (comboStr.charAt(0) == '5') image(num[5], 0, 0, 40, 60);
  else if (comboStr.charAt(0) == '6') image(num[6], 0, 0, 40, 60);
  else if (comboStr.charAt(0) == '7') image(num[7], 0, 0, 40, 60);
  else if (comboStr.charAt(0) == '8') image(num[8], 0, 0, 40, 60);
  else if (comboStr.charAt(0) == '9') image(num[9], 0, 0, 40, 60);
  if (comboStr.charAt(1) == '0') image(num[0], 40, 0, 40, 60);
  else if (comboStr.charAt(1) == '1') image(num[1], 40, 0, 40, 60);
  else if (comboStr.charAt(1) == '2') image(num[2], 40, 0, 40, 60);
  else if (comboStr.charAt(1) == '3') image(num[3], 40, 0, 40, 60);
  else if (comboStr.charAt(1) == '4') image(num[4], 40, 0, 40, 60);
  else if (comboStr.charAt(1) == '5') image(num[5], 40, 0, 40, 60);
  else if (comboStr.charAt(1) == '6') image(num[6], 40, 0, 40, 60);
  else if (comboStr.charAt(1) == '7') image(num[7], 40, 0, 40, 60);
  else if (comboStr.charAt(1) == '8') image(num[8], 40, 0, 40, 60);
  else if (comboStr.charAt(1) == '9') image(num[9], 40, 0, 40, 60);
}

void pointImg() {
  if (pointStr.charAt(0) == '0') image(num[0], 0, 0, 40, 60);
  else if (pointStr.charAt(0) == '1') image(num[1], 0, 0, 40, 60);
  else if (pointStr.charAt(0) == '2') image(num[2], 0, 0, 40, 60);
  else if (pointStr.charAt(0) == '3') image(num[3], 0, 0, 40, 60);
  else if (pointStr.charAt(0) == '4') image(num[4], 0, 0, 40, 60);
  else if (pointStr.charAt(0) == '5') image(num[5], 0, 0, 40, 60);
  else if (pointStr.charAt(0) == '6') image(num[6], 0, 0, 40, 60);
  else if (pointStr.charAt(0) == '7') image(num[7], 0, 0, 40, 60);
  else if (pointStr.charAt(0) == '8') image(num[8], 0, 0, 40, 60);
  else if (pointStr.charAt(0) == '9') image(num[9], 0, 0, 40, 60);
  if (pointStr.charAt(1) == '0') image(num[0], 40, 0, 40, 60);
  else if (pointStr.charAt(1) == '1') image(num[1], 40, 0, 40, 60);
  else if (pointStr.charAt(1) == '2') image(num[2], 40, 0, 40, 60);
  else if (pointStr.charAt(1) == '3') image(num[3], 40, 0, 40, 60);
  else if (pointStr.charAt(1) == '4') image(num[4], 40, 0, 40, 60);
  else if (pointStr.charAt(1) == '5') image(num[5], 40, 0, 40, 60);
  else if (pointStr.charAt(1) == '6') image(num[6], 40, 0, 40, 60);
  else if (pointStr.charAt(1) == '7') image(num[7], 40, 0, 40, 60);
  else if (pointStr.charAt(1) == '8') image(num[8], 40, 0, 40, 60);
  else if (pointStr.charAt(1) == '9') image(num[9], 40, 0, 40, 60);
  if (pointStr.charAt(2) == '0') image(num[0], 80, 0, 40, 60);
  else if (pointStr.charAt(2) == '1') image(num[1], 80, 0, 40, 60);
  else if (pointStr.charAt(2) == '2') image(num[2], 80, 0, 40, 60);
  else if (pointStr.charAt(2) == '3') image(num[3], 80, 0, 40, 60);
  else if (pointStr.charAt(2) == '4') image(num[4], 80, 0, 40, 60);
  else if (pointStr.charAt(2) == '5') image(num[5], 80, 0, 40, 60);
  else if (pointStr.charAt(2) == '6') image(num[6], 80, 0, 40, 60);
  else if (pointStr.charAt(2) == '7') image(num[7], 80, 0, 40, 60);
  else if (pointStr.charAt(2) == '8') image(num[8], 80, 0, 40, 60);
  else if (pointStr.charAt(2) == '9') image(num[9], 80, 0, 40, 60);
}
