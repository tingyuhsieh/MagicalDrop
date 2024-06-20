import processing.sound.*;
SoundFile[] soundComboR = new SoundFile[9];
SoundFile[] soundComboL = new SoundFile[9];
SoundFile soundAddBalls, soundBallDown, soundBallUp, soundBgm;

PImage imgRedBall, imgYellowBall, imgGreenBall, imgBlueBall, imgEmpty;
PImage imgGoddess, imgDevil;
PImage imgBg;
PImage imgWin, imgLose;
PImage[] imgNum = new PImage[10];

Player player1, player2;
Runtime runtime;

int mode; 
// 0: 等待開始, 1: 遊戲中
// 211:玩家1勝利(先消除完目標數量), 212:玩家2勝利(先消除完目標數量)
// 221:玩家1勝利(對手自殺), 222:玩家2勝利(對手自殺)
// 231:玩家1勝利(K.O.對手), 232:玩家2勝利(K.O.對手)


void setup() {
  size(900, 650);
  runtime=java.lang.Runtime.getRuntime();
  player1=new Player(1, 12, 300);
  player2=new Player(2, 12, 300);
  player1.setOpponentPlayer(player2);
  player2.setOpponentPlayer(player1);

  mode = 0;

  imgRedBall = loadImage("redBall.png");
  imgYellowBall = loadImage("yellowBall.png");
  imgGreenBall = loadImage("greenBall.png");
  imgBlueBall = loadImage("blueBall.png");
  imgEmpty = loadImage("empty.png");
  imgBg = loadImage("bg.jpg");
  imgWin = loadImage("win.png");
  imgLose = loadImage("lose.png");
  for (int i = 0; i < 10; i++) {
    imgNum[i] = loadImage(i + ".png");
  }

  for (int i = 0; i < 9; i++) {
    soundComboR[i] = new SoundFile(this, "combo" + (i+1) + ".mp3");
    soundComboL[i] = new SoundFile(this, "combo" + (i+1) + ".mp3");
  }

  soundAddBalls = new SoundFile(this, "addBalls.mp3");
  soundBallDown = new SoundFile(this, "ballDown.mp3");
  soundBallUp = new SoundFile(this, "ballUp.mp3");

  soundAddBalls.amp(1.0);

  imgGoddess=loadImage("goddess.png");
  imgDevil=loadImage("devil.png");
}

void draw() {
  if (frameCount%300==0) {
    thread("garbageCollector");
  }
  background(0);
  noTint();
  image(imgBg, 350, 0);

  player1.drawPlayer(imgGoddess);
  translate(width-350, 0);
  player2.drawPlayer(imgDevil);
  if (mode == 1) {
    // drawCombo
    drawCombo(player1.combo, -240, 580);
    drawCombo(player2.combo, 310, 580);
  }

  // drawPoint
  drawPoint(player1.bombTargetNum, -113, 329);
  drawPoint(player2.bombTargetNum, -47, 412);

  noTint();
  if (mode == 211 || mode == 221 || mode == 231) {
    image(imgLose, 0, 450);
    image(imgWin, -550, 450);
  } else if (mode == 212 || mode == 222 || mode == 232) {
    image(imgLose, -550, 450);
    image(imgWin, 0, 450);
  }
}

void keyPressed() {

  if (mode == 1) {
    player1.keyPressed(java.awt.event.KeyEvent.VK_A, java.awt.event.KeyEvent.VK_D, 
      java.awt.event.KeyEvent.VK_W, java.awt.event.KeyEvent.VK_S);
    player2.keyPressed(LEFT, RIGHT, UP, DOWN);
  } else if (mode == 0) {
    if (key == '0') mode = 1;
  }
}

  void drawCombo(int combo, float posX, float posY) {
    if (combo>0)drawNum(combo, 2, posX, posY);
  }

  void drawPoint(int point, float posX, float posY) {
    drawNum(point, 3, posX, posY);
  }

  void drawNum(int number, int digits, float posX, float posY) {
    int imgWidth = 40;
    int imgHeight = 60;

    pushMatrix();
    tint(255, 200);
    scale(1, 1);
    translate(posX, posY);
    for (int i = 0; i < digits; i++) {
      image(imgNum[floor(number/pow(10, i))%10], -imgWidth*i, 0, imgWidth, imgHeight);
    }
    popMatrix();
  }
  
void garbageCollector() {
  runtime.gc();
}
