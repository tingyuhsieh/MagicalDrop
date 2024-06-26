import java.util.*;
import processing.sound.*;
SoundFile soundAddBalls, soundBallDown, soundBallUp, soundBgm;

PImage imgRedBall, imgYellowBall, imgGreenBall, imgBlueBall, imgEmpty;
PImage imgGoddess, imgDevil;
PImage imgBg;
PImage imgWin, imgLose;
PImage[] imgNum = new PImage[10];

Player player1, player2;
Runtime runtime;

enum PlayerStatus {
  ACTIVE, // 玩家仍在遊戲中
    DEAD_BY_MISPLAY, // 由於失誤導致的死亡
    KNOCKED_OUT      // 被K.O.
}

enum GameState {
  PREPARED, //等待開始
    GAMING, //遊戲中
    GAME_OVER //遊戲結束
}

GameState gameState;

void setup() {
  size(900, 650);
  runtime=java.lang.Runtime.getRuntime();

  gameState = GameState.PREPARED;

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

  SoundFile[] soundCombo = new SoundFile[9];
  for (int i = 0; i < 9; i++) {
    soundCombo[i] = new SoundFile(this, "combo" + (i+1) + ".mp3");
  }

  soundAddBalls = new SoundFile(this, "addBalls.mp3");
  soundBallDown = new SoundFile(this, "ballDown.mp3");
  soundBallUp = new SoundFile(this, "ballUp.mp3");

  soundAddBalls.amp(1.0);

  imgGoddess=loadImage("goddess.png");
  imgDevil=loadImage("devil.png");

  player1 = new Player("player1", 12, 300, soundCombo);
  player2 = new Player("player2", 12, 300, soundCombo);
  player1.setOpponentPlayer(player2);
  player2.setOpponentPlayer(player1);
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

  // drawPoint
  drawPoint(player1.bombTargetNum, -113, 329);
  drawPoint(player2.bombTargetNum, -47, 412);

  if (gameState == GameState.GAMING) {
    // drawCombo
    drawCombo(player1.ballController.combo, -240, 580);
    drawCombo(player2.ballController.combo, 310, 580);

    if (checkGameOver())
      gameState = GameState.GAME_OVER;
  }
}

void keyPressed() {

  if (gameState == GameState.GAMING) {
    player1.keyPressed(java.awt.event.KeyEvent.VK_A, java.awt.event.KeyEvent.VK_D, 
      java.awt.event.KeyEvent.VK_W, java.awt.event.KeyEvent.VK_S);
    player2.keyPressed(LEFT, RIGHT, UP, DOWN);
  } else if (gameState == GameState.PREPARED) {
    if (key == '0') gameState = GameState.GAMING;
  }
}

PImage getBallImage(BallColor ballColor) {
  switch (ballColor) {
  case RED:
    return imgRedBall;
  case YELLOW:
    return imgYellowBall;
  case GREEN:
    return imgGreenBall;
  case BLUE:
    return imgBlueBall;
  default:
    return null;
  }
}

color getBallHexColor(BallColor ballColor) {
  switch (ballColor) {
  case RED:
    return color(255, 0, 0);
  case YELLOW:
    return color(255, 255, 0);
  case GREEN:
    return color(0, 255, 0);
  case BLUE:
    return color(0, 0, 255);
  default:
    return color(255, 255, 255);
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

boolean checkGameOver() {

  // Check if either player is dead
  if (player1.status != PlayerStatus.ACTIVE || player2.status != PlayerStatus.ACTIVE)
  {
    if (player1.status != PlayerStatus.ACTIVE && player2.status != PlayerStatus.ACTIVE)
    {
      setDeuceResult();
      printPlayerLoseDetail(player1);
      printPlayerLoseDetail(player2);
      println("Deuce");
    } else
    {
      Player winner = player1.status == PlayerStatus.ACTIVE ? player1 : player2;
      Player loser = (winner == player1) ? player2 : player1;
      setWinLoseResult(winner, loser);
      printPlayerLoseDetail(loser);
      println(winner.playerName + " Win!");
    }

    return true;
  }

  // Check if either player achieved the goal //<>//
  if (player1.checkGoal() || player2.checkGoal())
  {
    if (player1.checkGoal() && player2.checkGoal())
    {
      setDeuceResult();
      println("players achieved goal at same time!");
      println("Deuce");
    } else
    {
      Player winner = player1.checkGoal() ? player1 : player2;
      Player loser = (winner == player1) ? player2 : player1;
      setWinLoseResult(winner, loser);
      println(winner.playerName + " achieved the goal first!");
      println(winner.playerName + " Win!");
    }
    return true;
  }

  return false;
}

private void setDeuceResult() {
  player1.gameResult = player2.gameResult = GameResult.DEUCE;
}

private void setWinLoseResult(Player winner, Player loser) {
  winner.gameResult = GameResult.WIN;
  loser.gameResult = GameResult.LOSE;
}

private void printPlayerLoseDetail(Player player) {
  switch(player.status)
  {
  case DEAD_BY_MISPLAY:
    println(player.playerName + " is dead by misplay");
    break;
  case KNOCKED_OUT:
    println(player.playerName + " is knocked out");
    break;
  default:
    break;
  }
}

void garbageCollector() {
  runtime.gc();
}
