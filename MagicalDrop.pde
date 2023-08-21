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
    num[i] = loadImage(i + ".png");
  }

  for (int i = 0; i < 9; i++) {
    comboR[i] = new SoundFile(this, "combo" + (i+1) + ".mp3");
    comboL[i] = new SoundFile(this, "combo" + (i+1) + ".mp3");
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

    // drawCombo
    player1.drawCombo(-240, 580);
    player2.drawCombo(310, 580);
  }

  // drawPoint
  player1.drawPoint(-113, 329);
  player2.drawPoint(-47, 412);

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
