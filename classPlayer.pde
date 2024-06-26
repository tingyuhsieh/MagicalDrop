final int RECT_SIZE = 50; //一格的大小
final int COL_NUM = 7; //行數
final int ROW_NUM = 13; //列數

enum GameResult {
  DEUCE, //平手
    WIN, //勝者
    LOSE //敗者
}

enum BallAnimStatus {
  NONE, 
    UP, 
    DOWN
}

class PlayerBallData {
  BallColor ballColor = BallColor.NONE;
  int ballNum = 0;
}

class Player implements BallControllerListener {

  final String playerName;
  int deadlineRow;
  int bombTargetNum; //結束遊戲所需消去的目標數量
  final SoundFile[] soundCombo;

  int posX, posY; //玩家的位置
  PlayerBallData ballData;

  private BallAnimStatus ballAnimStatus; //丟球拿球動畫的狀態
  private int ballAnimX, ballAnimY; //丟球拿球動畫的位置
  private BallColor ballAnimColor; //丟球拿球動畫的顏色

  PlayerStatus status;
  GameResult gameResult; //遊戲結果

  final BallController ballController;

  Player opponent; //攻擊的玩家

  Player(String playerName, int deadlineRow, int bombTargetNum, SoundFile[] soundCombo) {

    this.playerName = playerName;
    this.deadlineRow = deadlineRow >= ROW_NUM ? (ROW_NUM - 1) : deadlineRow;
    this.bombTargetNum = bombTargetNum;
    this.soundCombo = soundCombo;

    posX = COL_NUM/2;
    posY = ROW_NUM-1;
    ballData = new PlayerBallData();
    ballAnimStatus = BallAnimStatus.NONE;

    status = PlayerStatus.ACTIVE;
    gameResult = GameResult.DEUCE;

    ballController = new BallController(this);
  }

  //-----------------設定攻擊對象------------------
  void setOpponentPlayer(Player opponent) {
    this.opponent = opponent;
  }

  //-----------------Draw Player------------------
  void drawPlayer(PImage imgPlayer) {
    if (gameState == GameState.GAMING) {
      update();
    }

    display(imgPlayer);
  }

  private void update() { 
    ballController.update();
  }

  private void display(PImage imgPlayer) {
    image(imgPlayer, 0, 0);

    //-----------------------Gaming----------------------------
    if (gameState == GameState.GAMING) {
      drawRefLine(); //參考線
      ballRun(); //丟球拿球動畫
      //----------畫出上面的球-----------
      ballController.drawBalls();
      //-----------玩家的球-------------
      PImage gotBallImg = getBallImage(ballData.ballColor);
      if (gotBallImg == null) {
        gotBallImg = imgEmpty; //slot
      } 
      image(gotBallImg, posX*RECT_SIZE, posY*RECT_SIZE);
      //-----------Deadline-----------
      drawDeadLine();
    } 
    //-----------------------Game Over----------------------------
    else if (gameState == GameState.GAME_OVER) {
      switch(gameResult) {
      case WIN:
        image(imgWin, 0, 450);
        break;
      case LOSE:
        image(imgLose, 0, 450);
        break;
      default:
        break;
      }
    }
  }

  private int getButt(int col) { //取得底部空格的位置
    return ballController.getRowNum(col);
  }

  //-------------------是否達成目標----------------------
  boolean checkGoal() {
    return bombTargetNum <= 0;
  }

  //------------------------按鍵輸入------------------------
  void keyPressed(int leftKeyCode, int rightKeyCode, int upKeyCode, int downKeyCode) { 
    //------------左右移動------------
    if (keyCode == leftKeyCode && posX > 0) {
      posX--;
    } else if (keyCode == rightKeyCode && posX < COL_NUM-1) {
      posX++;
    } 
    //-----------上下拿球丟球-----------
    else if (keyCode == upKeyCode) { 
      throwBalls();
    } else if (keyCode == downKeyCode) {
      takeBalls();
    }
  }

  //------------------BallControls----------------
  private void throwBalls() {
    BallColor ballColor = ballData.ballColor;
    if (!ballController.throwBalls(posX, ballData))
      return;

    //更新動畫
    ballAnimStatus = BallAnimStatus.UP;
    ballAnimY = posY;
    ballAnimColor = ballColor;
    ballAnimX = posX;
  }

  private void takeBalls() {
    if (!ballController.takeBalls(posX, ballData)) 
      return;

    //更新動畫
    ballAnimStatus = BallAnimStatus.DOWN;
    ballAnimY = getButt(posX);
    ballAnimColor = ballData.ballColor;
    ballAnimX = posX;
  }

  //------------------------Display------------------------------
  private void drawRefLine() { //參考線
    strokeWeight(3);
    stroke(getBallHexColor(ballData.ballColor));
    int butt = getButt(posX);
    int v =frameCount%10;
    if (ballData.ballNum > 0)v = -v;
    for (int i = posY; i > butt; i--) {
      for (int j = 0; j < 50; j+=10) {
        point((posX+0.5)*RECT_SIZE, i*RECT_SIZE-j+v);
      }
    }
  }

  private void ballRun() {  //丟球拿球動畫
    switch(ballAnimStatus) {
    case UP:
      {
        int ballTargetY = getButt(ballAnimX); //丟球時x停留在丟球當下的位置(動畫不會跟玩家移動)
        if (ballAnimY > ballTargetY) {
          ballAnimY--;
        } else {
          ballAnimStatus = BallAnimStatus.NONE;
          return;
        }
      }
      break;
    case DOWN:
      {
        if (ballAnimY < posY) {//吸球時x看玩家的位置(動畫會跟玩家移動)
          ballAnimY++;
          ballAnimX = posX;
        } else {
          ballAnimStatus = BallAnimStatus.NONE;
          return;
        }
      }
      break;
    default:
      return;
    }

    PImage ballImg = getBallImage(ballAnimColor);
    if (ballImg != null) image(ballImg, ballAnimX*RECT_SIZE, ballAnimY*RECT_SIZE);
  }

  private void drawDeadLine() { //Deadline
    int flash = 1 ;
    float a = sin(radians((frameCount%(360/flash))*flash))*127.5+127.5;
    pushMatrix();
    stroke(255, a, a);
    line(0 * RECT_SIZE, deadlineRow * RECT_SIZE, COL_NUM * RECT_SIZE, deadlineRow * RECT_SIZE);
    popMatrix();
  }

  //----------------------sound----------------------
  private void playComboSound(int combo) {
    if (soundCombo == null || soundCombo.length == 0)
      return;

    for (int i = 0; i < soundCombo.length; i++) {
      soundCombo[i].stop();
      if (combo == i+1) soundCombo[i].play();
    }
    if (combo > soundCombo.length) soundCombo[soundCombo.length - 1].play();
  }

  //---------------BallControllerListener Implementation-------------------
  @Override
    void onRemoveBall(int removedBallNum) {
    bombTargetNum -= removedBallNum;
    Math.max(bombTargetNum, 0);
  }

  @Override
    int getPlayerBallNum() {
    return ballData.ballNum;
  }

  @Override
    int getDeadlineRow() {
    return deadlineRow;
  }

  @Override
    void onDeadByMisplay() {
    status = PlayerStatus.DEAD_BY_MISPLAY;
  }

  @Override
    void onKnockedOut() {
    status = PlayerStatus.KNOCKED_OUT;
  }

  @Override
    BallController getAttackTarget() {
    return opponent.ballController;
  }

  @Override
    void onStartBomb(int combo) {
    playComboSound(combo);
  }
}
