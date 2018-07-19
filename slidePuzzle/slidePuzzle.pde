import java.util.Set;
import java.util.HashSet;
import java.util.Queue;
import java.util.Stack;
import java.util.ArrayList;
import java.util.ArrayDeque;
import java.util.PriorityQueue;
import java.util.Comparator;
int table[][];
int size, sqSize, biggest; float blockSize;
PGraphics pg;

class State {
  int table[][];
  int step;
  ArrayList<Integer> path = null;
  float distance;

  State(int t[][], int s, float d) {
    table = new int[size][size];
    for (int i = 0; i < size; i ++) table[i] = t[i].clone();
    step = s;
    distance = d;
  }

  State(int t[][], int s, float d, ArrayList<Integer> p) {
    table = new int[size][size];
    for (int i = 0; i < size; i ++) table[i] = t[i].clone();
    step = s;
    distance = d;
    if (p != null)
      path = new ArrayList<Integer>(p);
  }
}
class StateComparator implements Comparator<State> {
  @Override
  int compare(State a, State b) {
    if (a.distance > b.distance) return(1);
    else if (a.distance < b.distance) return(-1);
    return(0);
  }
}

int[] dy = {1, 0, -1, 0}, dx = {0, -1, 0, 1}; float[] col;
int ni, nj, startTime = millis(), endTime = -1, rainbow, waitTime = 0, animationFrames = 20, solveFrames = 45, minSteps = 0, scrambleSteps = 1000; boolean animation = false;
float nowDistance = -1;
Set<String> visitedSet = new HashSet<String>();
Queue<State> queue = new ArrayDeque<State>();
Stack<State> stack = new Stack<State>();
PriorityQueue<State> pq = new PriorityQueue<State>(9999999, new StateComparator());

void setup() {
  String[] lines = loadStrings("./in");
  size = int(lines[0]); sqSize = size * size;
  biggest = size * size - 1;
  col = new float[sqSize + 1]; for (int i = 1; i <= sqSize; i ++) col[i] = 340*float(i)/biggest;
  table = new int[size][size];
  size(1150, 900);
  blockSize = float(min(height, width)) / size;
  colorMode(HSB, 360, 100, 100);
  textAlign(CENTER,CENTER);
  frameRate(100);

  pg = createGraphics(1150, 900);
  pg.colorMode(HSB, 360, 100, 100);
  pg.textAlign(CENTER,CENTER);

  scramble();
}

boolean solved() {
  for (int i = 0, k = 1; i < size; i ++)
    for (int j = 0; j < size; j ++, k ++)
      if (table[i][j] != k) return(false);
  return(true);
}

void drawBlock(int i, int j) {
  if (table[i][j] == sqSize) fill(0, 0, 0);
  else fill(col[table[i][j]], 100, 100);
  rect(j * blockSize, i * blockSize, blockSize, blockSize);
  fill(0, 0, 0);
  textSize(blockSize / 2.34);
  text(str(table[i][j]), (j + 0.50) * blockSize, (i + 0.45) * blockSize);
}

void pgDrawBlock(int i, int j, int nextI, int nextJ, float frame) {
  pg.beginDraw();
  // pg.clear();
  pg.colorMode(HSB, 360, 100, 100);
  pg.textAlign(CENTER,CENTER);

  pg.fill(0, 0, 0);
  pg.rect(j * blockSize, i * blockSize, blockSize, blockSize);
  pg.rect(nextJ * blockSize, nextI * blockSize, blockSize, blockSize);

  if (table[i][j] != sqSize) pg.fill(col[table[i][j]], 100, 100);
  pg.rect((j + (nextJ - j) * frame) * blockSize, (i + (nextI - i) * frame) * blockSize, blockSize, blockSize);

  pg.fill(0, 0, 0);
  pg.textSize(blockSize / 2.34);
  pg.text(str(table[i][j]), ((j + (nextJ - j) * frame) + 0.50) * blockSize, ((i + (nextI - i) * frame) + 0.45) * blockSize);

  pg.endDraw();
}

void draw() {
  if (animation) {
    image(pg, 0, 0);
    fill(230, 0, 100);
    rect(width * 0.8, height * 0.05, 300, 300);
    fill(0, 0, 0);
    textSize(blockSize / 5.34);
    text(nfs(round(nowDistance*1000)/1000.0, 2, 3), width * 0.9, height * 0.1);
    text(nfs(minSteps, 4), width * 0.9, height * 0.2);
    text(frameRate, width * 0.9, height * 0.3);
  }
  else if (!solved()) {
    for (int i = 0; i < size; i ++)
      for (int j = 0; j < size; j ++)
        drawBlock(i, j);
    fill(230, 0, 100);
    rect(width * 0.8, height * 0.05, 300, 300);
    fill(0, 0, 0);
    textSize(blockSize / 5.34);
    text(nfs(round(nowDistance*1000)/1000.0, 2, 3), width * 0.9, height * 0.1);
    text(nfs(minSteps, 4), width * 0.9, height * 0.2);
    text(frameRate, width * 0.9, height * 0.3);
  } else {
    background(rainbow % 360, 100, 100);
    rainbow = (rainbow + 1) % 36000;
    if (endTime == -1) endTime = millis();
    text(str((endTime - startTime) / 1000.0) + "s", width / 2.0, height / 3.0);
    text(str(minSteps) + " steps", width / 2.0, height * (2.0/3));
  }

}

boolean invalid(int i, int j) {
  return((i < 0 || j < 0 || i >= size || j >= size));
}

void setBlackBlock() {
  for (int i = 0; i < size; i ++)
    for (int j = 0; j < size; j ++)
      if (table[i][j] == sqSize) {
        ni = i; nj = j;
      }
}

float sigmoid(float x) {
  if (x == 1) return(1);
  if (x == -1) return(0);
  return(1.0 / (1.0 + exp(-x*5)));
}

void movementAnimation(int dir, int ani) {
  int pi = ni + dy[dir], pj = nj + dx[dir];
  if (invalid(pi, pj)) return;
  animation = true;
  float nowFrame = ani;
  while (nowFrame >= 0) {
    pgDrawBlock(pi, pj, ni, nj, 1.0 - sigmoid(2*nowFrame/ani - 1));
    delay(1);
    nowFrame --;
  }
  animation = false;
}

void movement(int dir, int increment) {
  int pi = ni + dy[dir], pj = nj + dx[dir];
  if (invalid(pi, pj)) return;
  int aux = table[ni][nj]; table[ni][nj] = table[pi][pj]; table[pi][pj] = aux;
  ni = pi; nj = pj;
  minSteps += increment;
}

void keyThread() {
  if (keyCode == UP) {
    movementAnimation(0, animationFrames); movement(0, 1);
  } else if (keyCode == RIGHT) {
    movementAnimation(1, animationFrames); movement(1, 1);
  } else if (keyCode == DOWN) {
    movementAnimation(2, animationFrames); movement(2, 1);
  } else if (keyCode == LEFT) {
    movementAnimation(3, animationFrames); movement(3, 1);
  } else if (key == 'r') {
    visitedSet.clear();
    scramble();
    startTime = millis(); endTime = -1; minSteps = 0;
  } else if (key == 's') {
    thread("startSolve");
  }
}

void keyPressed() {
  if (!animation) thread("keyThread");
}

void scramble() {
  for (int i = 0, k = 1; i < size; i ++) for (int j = 0; j < size; j ++, k ++)
    table[i][j] = k;
  ni = size - 1; nj = size - 1;
  // table[size - 1][size - 1] = sqSize;
  // table[size - 1][size - 2] = 16; table[size - 1][size - 1] = 15;
  // ni = size - 1; nj = size - 2;

  int s = scrambleSteps;
  while (s -- > 0) {
    int dir; do dir = int(random(0, 4)); while (invalid(ni + dy[dir], nj + dx[dir]));
    movement(dir, 0);
  }
  pg.beginDraw();
  pg.clear();
  pg.endDraw();
}

void followPath(ArrayList<Integer> path) {
  for (int i = 0; i < size; i ++) for (int j = 0; j < size; j ++) {
    if (table[i][j] == sqSize) { ni = i; nj = j; }
    pgDrawBlock(i, j, i, j, 0);
  }
  setBlackBlock();
  minSteps = 0;
  while (path.size() > 0) {
    int dir = path.get(0);
    movementAnimation(dir, solveFrames); movement(dir, 1);
    path.remove(0);
  }
}

void prepareSolve(int[][] aux) {
  startTime = millis(); endTime = -1; minSteps = 0;
  for (int i = 0; i < size; i ++) table[i] = aux[i].clone();
  visitedSet.clear();
}

void startSolve() {
  ArrayList<Integer> path = null;
  int[][] aux = new int[size][size]; for (int i = 0; i < size; i ++) aux[i] = table[i].clone();

  // prepareSolve(aux);
  // path = dfsStack(false);
  // print("DFS done, states: " + str(visitedSet.size()) + "\n");
  //
  // delay(5000);
  //
  // prepareSolve(aux);
  // path = bfs(true);
  // print("BFS done, states: " + str(visitedSet.size()) + "\n");
  // //
  // // delay(5000);
  //
  prepareSolve(aux);
  path = aStar(true);
  print("A* (euclideanDistance) done, states: " + str(visitedSet.size()) + "\n");
  //
  delay(3000);
  // prepareSolve(aux);
  // int[] arr = new int[] {2, 3, 0, 1, 2, 3, 0, 3, 0, 1, 2, 2, 3, 3, 0, 3, 0, 1, 2, 0, 3, 2, 2, 3, 1, 0, 3, 0, 3, 0, 3, 2, 2, 2, 3, 1, 2, 0, 3, 2, 2, 3, 3, 0, 3, 2, 1, 0, 1, 0, 3, 2, 3, 2, 0, 0, 1, 2, 1, 2, 1, 2, 2, 3, 2, 2, 3, 2, 3, 2, 0, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 3, 2, 2, 3, 1, 2, 2, 3, 2, 3, 0, 3, 0, 1, 2, 2, 3, 2, 3, 0, 3, 0, 3, 1, 2, 2, 2, 3, 2, 3, 0, 3, 0, 1, 2, 0, 3, 2, 2, 2, 3, 2, 3, 1, 0, 3, 2, 3, 2, 0, 0, 1, 2, 0, 1, 2, 2, 3, 3, 0, 3, 0, 1, 2, 0, 3, 0, 3, 1, 2, 2, 2, 3, 2, 3, 0, 3, 2, 2, 3, 1, 2, 0, 1, 2, 0, 3, 0, 3, 2, 3, 2, 3, 2, 2, 2, 1, 2, 0, 3, 0, 3, 1, 2, 1, 2, 2, 3, 2, 3, 2, 3, 2, 0, 1, 2, 1, 2, 2, 3, 1, 2, 0, 3, 2, 3, 2, 3};
  // path = new ArrayList<Integer>();
  // for (int i = 0; i < arr.length; i ++) path.add(arr[i]);
  prepareSolve(aux);
  if (path != null) followPath(path);
}

String stateHash() {
  String nowStateHash = "";
  for (int i = 0; i < size; i ++)
    for (int j = 0; j < size; j ++)
    {
      nowStateHash += str(table[i][j]);
      if (i != size - 1 || j != size - 1) nowStateHash += "|";
    }
  return(nowStateHash);
}

boolean dfsRecursive(int i, int j, int now) {
  if (i == size - 1 && j == size - 1 && solved()) {
    minSteps = now;
    return(true);
  }
  String nowStateHash = stateHash();
  if (visitedSet.contains(nowStateHash)) { return(false); };
  visitedSet.add(nowStateHash);

  delay(waitTime);
  for (int k = 0; k < 4; k ++)
    if (!invalid(i + dy[k], j + dx[k])) {
      ni = i; nj = j;
      movement(k, 0);
      if (dfsRecursive(i + dy[k], j + dx[k], now + 1)) return(true);
      ni = i; nj = j;
      movement((k + 2) % 4, 0);
    }
  return(false);
}

ArrayList<Integer> dfsStack(boolean savePath) {
  stack.clear();
  ArrayList<Integer> auxPath = null;
  if (savePath) stack.push(new State(table, 0, 0, new ArrayList<Integer>()));
  else stack.push(new State(table, 0, 0));

  while (stack.size() > 0) {
    for (int i = 0; i < size; i ++) table[i] = stack.peek().table[i].clone(); minSteps = stack.peek().step; if (savePath) auxPath = new ArrayList<Integer>(stack.peek().path); stack.pop();
    setBlackBlock();
    delay(waitTime);

    if (solved()) break;

    for (int k = 0; k < 4; k ++)
      if (!invalid(ni + dy[k], nj + dx[k])) {
        movement(k, 0);
        String nowStateHash = stateHash();
        if (!visitedSet.contains(nowStateHash)) {
          visitedSet.add(nowStateHash);
          if (savePath) {
            auxPath.add(k);
            stack.push(new State(table, minSteps + 1, 0, auxPath));
            auxPath.remove(auxPath.size() - 1);
          }
          else stack.push(new State(table, minSteps + 1, 0));
        }
        movement((k + 2) % 4, 0);
      }
  }
  stack.clear();
  return(auxPath);
}

ArrayList<Integer> bfs(boolean savePath) {
  queue.clear();
  ArrayList<Integer> auxPath = null;
  if (savePath) queue.add(new State(table, 0, 0, new ArrayList<Integer>()));
  else queue.add(new State(table, 0, 0));

  while (queue.size() > 0) {
    for (int i = 0; i < size; i ++) table[i] = queue.peek().table[i].clone(); minSteps = queue.peek().step; if (savePath) auxPath = new ArrayList<Integer>(queue.peek().path); queue.remove();
    setBlackBlock();
    delay(waitTime);

    if (solved()) break;

    for (int k = 0; k < 4; k ++)
      if (!invalid(ni + dy[k], nj + dx[k])) {
        movement(k, 0);
        String nowStateHash = stateHash();
        if (!visitedSet.contains(nowStateHash)) {
          visitedSet.add(nowStateHash);
          if (savePath) {
            auxPath.add(k);
            queue.add(new State(table, minSteps + 1, 0, auxPath));
            auxPath.remove(auxPath.size() - 1);
          }
          else queue.add(new State(table, minSteps + 1, 0));
        }
        movement((k + 2) % 4, 0);
      }
  }
  queue.clear();
  return(auxPath);
}

float euclideanDistance() {
  float dist = 0;
  for (int i = 0; i < size; i ++)
    for (int j = 0; j < size; j ++)
    {
      if (table[i][j] == sqSize) continue;
      int at = table[i][j] - 1;
      dist += sqrt(pow(int(at / size) - i, 2) + pow((at % size) - j, 2)); //sqrt
    }
  return(dist);
}

ArrayList<Integer> aStar(boolean savePath) {
  pq.clear();
  ArrayList<Integer> auxPath = null;
  if (savePath) pq.add(new State(table, 0, euclideanDistance(), new ArrayList<Integer>()));
  else pq.add(new State(table, 0, euclideanDistance()));

  while (pq.size() > 0) {
    for (int i = 0; i < size; i ++) table[i] = pq.peek().table[i].clone();
    minSteps = pq.peek().step; nowDistance = pq.peek().distance; if (savePath) auxPath = new ArrayList<Integer>(pq.peek().path); pq.poll();
    setBlackBlock();
    delay(waitTime);

    if (solved()) break;

    for (int k = 0; k < 4; k ++)
      if (!invalid(ni + dy[k], nj + dx[k])) {
        movement(k, 0);
        String nowStateHash = stateHash();
        if (!visitedSet.contains(nowStateHash)) {
          visitedSet.add(nowStateHash);
          if (savePath) {
            auxPath.add(k);
            pq.add(new State(table, minSteps + 1, euclideanDistance(), auxPath));
            auxPath.remove(auxPath.size() - 1);
          }
          else pq.add(new State(table, minSteps + 1, euclideanDistance()));
        }
        movement((k + 2) % 4, 0);
      }
  }
  pq.clear();
  return(auxPath);
}
