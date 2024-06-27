final int BALL_COL_NUM_INIT = 5; //遊戲開始時的球池列數
final int BOMBING_DURATION = 250; //爆破的表演時間(毫秒)
final int COMBO_VAILD_DURATION = 1666; //combo計算的有效期間(毫秒)
final int QUICK_ATTACK_COMBO_THRESHOLD = 9; //高速攻擊的combo臨界值
final int ADD_BALL_INTERVAL = 333; //加球的間隔時間(毫秒)
final int AUTO_ADD_BALL_THRESHOLD = 8000; //自動加球的時間臨界值(毫秒)，0則關閉該功能

enum BallColor {
  NONE, 
    RED, 
    YELLOW, 
    GREEN, 
    BLUE
}

class Ball {
  final BallColor ballColor;
  private PImage img;
  private int bombStartTime;

  Ball(BallColor ballColor) {
    this.ballColor = ballColor;
    img = getBallImage(ballColor);
    bombStartTime = 0;
  }

  void setBombing() {
    if (isBombing()) return;

    bombStartTime = millis();
  }

  boolean isBombing() {
    return bombStartTime > 0;
  }

  boolean canRemove() {
    return isBombing() && millis() - bombStartTime > BOMBING_DURATION;
  }

  void display(float posX, float posY) {

    if (isBombing()) {
      pushMatrix();
      if (frameCount % 4 == 0) fill(255, 100, 0);
      else if (frameCount % 3 == 1) fill(0, 255, 100);
      else fill(100, 0, 255);
      noStroke();
      ellipse(posX + 0.5 * RECT_SIZE, posY + 0.5 * RECT_SIZE, RECT_SIZE, RECT_SIZE); //ellipse的位置從中心開始畫所以要加0.5*rectSize
      popMatrix();
    } else if (img != null) {
      image(img, posX, posY);
    }
  }
}

class Point {
  public final int col;
  public final int row;

  Point(int col, int row) {
    this.col = col;
    this.row = row;
  }

  @Override
    public boolean equals(Object o)
  {
    if (o == this) {
      return true;
    }

    if (!(o instanceof Point)) {
      return false;
    }

    Point p = (Point) o;
    return p.col == this.col && p.row == this.row;
  }
}

interface BallControllerListener {

  void onRemoveBall(int removedBallNum);

  int getPlayerBallNum();

  int getDeadlineRow();

  void onDeadByMisplay();

  void onKnockedOut();

  BallController getAttackTarget();

  void onStartBomb(int combo);
}

class BallController {

  private ArrayList<Ball>[] balls = new ArrayList[COL_NUM];

  private BallControllerListener listener;

  private int lastAddBallTime;
  private int rowsWaitingToAdd; //等待加的行數

  private int bombStartTime;
  int combo;

  BallController(BallControllerListener listener) {
    this.listener = listener;

    for (int i = 0; i < balls.length; i++) {
      balls[i] = new ArrayList<Ball>();
    }
  }

  //-----------------設定BallControllerListener------------------
  void setBallControllerListener(BallControllerListener listener) {
    this.listener = listener;
  }

  //--------------------update flow-----------------------
  void update() {
    removeBalls();
    checkComboValid();
    checkAddBalls();
  }

  private void removeBalls() { //消除球
    int removedBallNum = 0;
    Set<Point> triggers = new HashSet<Point>();
    for (int col = 0; col < balls.length; col++) {
      int row = 0;
      boolean removedBall = false;
      for (Iterator<Ball> i = balls[col].iterator(); i.hasNext(); ) {
        Ball ball = i.next();
        if (ball.ballColor == BallColor.NONE) { //避免有NONE的球
          i.remove();
          continue;
        }

        if (ball.canRemove()) {
          i.remove();
          removedBallNum += 1;
          removedBall = true;
        } else {
          if (removedBall) {
            removedBall = false;
            if (row >= 1) {
              triggers.add(new Point(col, row - 1));
            }
          }
          row += 1;
        }
      }
    }

    if (removedBallNum == 0)
      return;

    boolean startBomb = false;
    for (Point p : triggers) {
      Set<Point> toBomb = checkTriggerBomb(p.col, p.row);
      if (toBomb != null && toBomb.size() > 0) {
        markAllBombing(toBomb);
        startBomb = true;
      }
    }

    if (startBomb)
      onStartBomb();

    if (listener != null)listener.onRemoveBall(removedBallNum);
  }

  private void checkComboValid() {
    //檢查combo計算的有效時間,超過時結束combo
    if (combo > 0 && millis() - bombStartTime > COMBO_VAILD_DURATION) {
      stopCombo();
    }
  }

  private void checkAddBalls() { //加球檢查
    int playerBallNum = 0;
    if (listener != null)
      playerBallNum = listener.getPlayerBallNum(); //將玩家持有的球也考慮進去，避免拿球後球池立即增加

    // 維持最低球數
    if (rowsWaitingToAdd == 0) {
      int ballNum = 0;
      for (ArrayList<Ball> column : balls) {
        ballNum += column.size();
      }
      if (ballNum + playerBallNum < (COL_NUM * BALL_COL_NUM_INIT)) {      
        rowsWaitingToAdd++;
      }
    }

    // 超過一定時間自動加球
    if (rowsWaitingToAdd == 0) {
      if (AUTO_ADD_BALL_THRESHOLD > 0 && millis() - lastAddBallTime > AUTO_ADD_BALL_THRESHOLD) {
        rowsWaitingToAdd++;
      }
    }

    // 加球判斷
    if (rowsWaitingToAdd > 0) {
      if (millis() - lastAddBallTime > ADD_BALL_INTERVAL) {
        addBalls();
      }
    }
  }

  private void addBalls() { //加球
    lastAddBallTime = millis();
    rowsWaitingToAdd--;
    soundAddBalls.stop();
    soundAddBalls.play();

    for (ArrayList<Ball> column : balls) {
      BallColor ballColor = BallColor.values()[(int)(random(1, 5))]; //隨機選擇不為NONE的顏色
      if (ballColor != BallColor.NONE)
        column.add(0, new Ball(ballColor));
    }

    if (checkGameOver()) { //死亡判定
      if (listener != null)listener.onKnockedOut();
    }
  }

  void drawBalls() { //畫出現有的球
    for (int i = 0; i < balls.length; i++) {
      for (int j = 0; j < balls[i].size(); j++) {
        Ball ball = balls[i].get(j);
        ball.display(i * RECT_SIZE, j * RECT_SIZE);
      }
    }
  }

  //----------------get-------------------
  boolean checkGameOver() {
    int deadlineRow = 0;
    if (listener != null)
      deadlineRow = listener.getDeadlineRow();

    for (ArrayList<Ball> column : balls) {
      if (column.size() > deadlineRow) {
        for (int j = deadlineRow; j < column.size(); j++) {
          if (column.get(j).isBombing() == false)
            return true;
        }
      }
    }
    return false;
  }

  int getRowNum(int col) {
    return balls[col].size();
  }

  BallColor getButtomBallColor(int col) {
    ArrayList<Ball> column = balls[col];
    return column.get(column.size()-1).ballColor;
  }

  //--------------------玩家操作-------------------
  boolean takeBalls(int col, PlayerBallData ballData) { //拿球，回傳成功或失敗
    soundBallUp.stop();

    if (col >= balls.length || col < 0) return false;
    if (ballData == null) return false;

    BallColor targetColor = ballData.ballColor;
    int takeBallNum = 0;
    for (int row = balls[col].size() - 1; row >= 0; row--) {
      Ball ball = balls[col].get(row);
      boolean canGet = !ball.isBombing(); //不是爆破中的球才可取得
      if (canGet) {
        if (targetColor == BallColor.NONE || targetColor == ball.ballColor) {
          if (targetColor == BallColor.NONE) targetColor = ball.ballColor;
          balls[col].remove(ball);
          takeBallNum += 1;
        } else
          break;
      } else
        break;
    }

    if (takeBallNum == 0) return false;

    // update player ballData
    ballData.ballColor = targetColor;
    ballData.ballNum += takeBallNum;

    soundBallDown.stop();
    soundBallDown.play();
    return true;
  }

  boolean throwBalls(int col, PlayerBallData ballData) { //丟球，回傳成功或失敗
    soundBallDown.stop();

    if (ballData == null || ballData.ballNum == 0 || ballData.ballColor == BallColor.NONE)
      return false;

    soundBallUp.stop();
    soundBallUp.play();

    Point trigger = new Point(col, getRowNum(col));
    balls[col].addAll(new ArrayList<Ball>(Collections.nCopies(ballData.ballNum, new Ball(ballData.ballColor))));

    //check bomb
    Set<Point> toBomb = checkBomb(trigger.col, trigger.row, ballData);
    if (toBomb != null && toBomb.size() > 0) {
      markAllBombing(toBomb);
      onStartBomb();
    } else {
      //沒有觸發消除時會斷combo
      if (combo > 0) stopCombo();

      if (checkGameOver()) { //死亡判定
        if (listener != null)listener.onDeadByMisplay();
      }
    }

    // update player ballData
    ballData.ballColor = BallColor.NONE;
    ballData.ballNum = 0;

    return true;
  }

  //-----------------------引爆偵測------------------------
  private Set<Point> checkBomb(int col, int startRow, PlayerBallData ballData) {//偵測玩家丟的球是否觸發引爆

    if (ballData == null || ballData.ballNum == 0 || ballData.ballColor == BallColor.NONE)
      return null;

    ArrayList<Ball> column = balls[col];
    BallColor triggerColor = ballData.ballColor;

    Set<Point> toBomb = new HashSet<Point>(); // 使用 Set 來存儲需要標記的球的位置

    // 檢查垂直方向
    int start = startRow;
    int end = startRow + ballData.ballNum - 1;

    // 向上檢查
    while (start > 0 && column.get(start - 1).ballColor == triggerColor && !column.get(start - 1).isBombing()) {
      start--;
    }

    // 如果連續相同顏色的球數量大於等於3，將它們加入待爆炸集合
    if (end - start + 1 >= 3) {
      for (int i = start; i <= end; i++) {
        toBomb.add(new Point(col, i));
      }

      return toBomb;
    }

    return null;
  }

  private Set<Point> checkTriggerBomb(int col, int row) { //偵測自動補位的球是否的觸發引爆
    ArrayList<Ball> column = balls[col];
    Ball triggerBall = column.get(row);
    BallColor triggerColor = triggerBall.ballColor;

    if (triggerBall.isBombing())
      return null;

    Set<Point> toBomb = new HashSet<Point>(); // 使用 Set 來存儲需要標記的球的位置

    // 檢查垂直方向
    int start = row;
    int end = row;

    // 向下檢查
    while (end < column.size() - 1 && column.get(end + 1).ballColor == triggerColor && !column.get(end + 1).isBombing()) {
      end++;
    }

    // triggerBall必須與下方的球相同顏色才能觸發引爆
    if (end == row)
      return null;

    // 向上檢查
    while (start > 0 && column.get(start - 1).ballColor == triggerColor && !column.get(start - 1).isBombing()) {
      start--;
    }

    // 如果連續相同顏色的球數量大於等於3，將它們加入待爆炸集合
    if (end - start + 1 >= 3) {
      for (int i = start; i <= end; i++) {
        toBomb.add(new Point(col, i));
      }

      return toBomb;
    }

    return null;
  }

  private void markAllBombing(Set<Point> toBomb) {
    if (toBomb == null)
      return;

    for (Point p : toBomb) {
      balls[p.col].get(p.row).setBombing();
    }

    // 檢查所有新標記球的相鄰球
    for (Point p : toBomb) {
      checkAdjacentBalls(p.col, p.row);
    }
  }

  private void checkAdjacentBalls(int col, int row) {
    BallColor targetColor = balls[col].get(row).ballColor;
    // 檢查上下左右
    checkAndMarkAdjacent(col, row - 1, targetColor);
    checkAndMarkAdjacent(col, row + 1, targetColor);
    checkAndMarkAdjacent(col - 1, row, targetColor);
    checkAndMarkAdjacent(col + 1, row, targetColor);
  }

  private void checkAndMarkAdjacent(int col, int row, BallColor targetColor) {
    if (col < 0 || col >= COL_NUM || row < 0 || row >= balls[col].size()) {
      return;
    }
    Ball ball = balls[col].get(row);
    if (ball.ballColor == targetColor && !ball.isBombing()) {
      ball.setBombing();
      checkAdjacentBalls(col, row);
    }
  }

  //-------------------觸發combo--------------------
  private void onStartBomb() {
    bombStartTime = millis();
    combo += 1;
    if (listener != null) listener.onStartBomb(combo);

    checkQuickAttackOpponent(); //每次觸發消除時確認是否要攻擊對手
  }

  private void checkQuickAttackOpponent() {
    if (combo == QUICK_ATTACK_COMBO_THRESHOLD) {
      attackTarget(combo/2);  //開啟高速攻擊模式會直接攻擊累積的行數
    } else if (combo > QUICK_ATTACK_COMBO_THRESHOLD) {
      attackTarget(1); //高速攻擊模式時每次combo都攻擊1行
    }
  }

  private void attackTarget(int attackRows) {
    if (listener != null && listener.getAttackTarget() != null) {
      listener.getAttackTarget().attacked(attackRows);
    }
  }

  //------------------受到攻擊-------------------
  void attacked(int attackRows) {
    rowsWaitingToAdd += attackRows;
  }

  //------------------結束combo------------------
  private void stopCombo() { 
    if (combo < QUICK_ATTACK_COMBO_THRESHOLD) //combo結束後若沒有攻擊過才攻擊對手
      attackTarget(combo/2);

    combo = 0;
  }
}
