import java.util.Set;
import java.util.HashSet;
import java.util.Queue;
import java.util.Stack;
import java.util.ArrayDeque;
import java.util.PriorityQueue;
import java.util.Comparator;
int table[][];
int size, sqSize, biggest; float blockSize;

class ele {
  int table[][];
  int minSteps;
  float h;
  ele(int t[][], int m, float hh) {
    table = new int[size][size];
    for (int i = 0; i < size; i ++) table[i] = t[i].clone();
    minSteps = m;
    h = hh;
  }
}
class eleComparator implements Comparator<ele> {
  @Override
  int compare(ele a, ele b) {
    if (a.h > b.h) return(1);
    else if (a.h < b.h) return(-1);
    return(0);
  }
}

int[] dy = {1, 0, -1, 0}, dx = {0, -1, 0, 1};
int ni, nj, startTime = millis(), endTime = -1, rainbow, waitTime = 0, minSteps = 0, scrambleSteps = 1000;
float nowDistance = -1;
Set<String> visitedSet = new HashSet<String>();
Queue<ele> queue = new ArrayDeque<ele>();
Stack<ele> stack = new Stack<ele>();
PriorityQueue<ele> pq = new PriorityQueue<ele>(9999999, new eleComparator());

boolean solved() {
  for (int i = 0, k = 1; i < size; i ++)
    for (int j = 0; j < size; j ++, k ++)
      if (table[i][j] != k) return(false);
  return(true);
}

void setup() {
  String[] lines = loadStrings("./in");
  size = int(lines[0]); sqSize = size * size;
  table = new int[size][size];
  biggest = size * size - 1;
  size(1150, 900);
  blockSize = float(min(height, width)) / size;
  colorMode(HSB, 360, 100, 100);
  textAlign(CENTER,CENTER);
  textSize(blockSize / 2.34);

  scramble();
}

void drawBlock(int i, int j) {
  if (table[i][j] == sqSize) fill(0, 0, 0);
  else fill(340*float(table[i][j])/biggest, 100, 100);
  rect(j * blockSize, i * blockSize, blockSize, blockSize);
  fill(0, 0, 0);
  text(str(table[i][j]), (j + 0.50) * blockSize, (i + 0.45) * blockSize);
}

void draw() {
  if (!solved()) {
    for (int i = 0; i < size; i ++)
      for (int j = 0; j < size; j ++)
        drawBlock(i, j);
    fill(230, 0, 100);
    rect(width * 0.8, height * 0.05, 300, 100);
    fill(0, 0, 0);
    text(nfs(round(nowDistance*1000)/1000.0, 2, 3), width * 0.9, height * 0.1);
  }
  else {
    background(rainbow % 360, 100, 100);
    rainbow = (rainbow + 4) % 36000;
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

void movement(int dir, int inc) {
  if (invalid(ni + dy[dir], nj + dx[dir])) return;
  int aux = table[ni][nj]; table[ni][nj] = table[ni + dy[dir]][nj + dx[dir]]; table[ni + dy[dir]][nj + dx[dir]] = aux;
  ni += dy[dir]; nj += dx[dir];
  minSteps += inc;
}

void keyReleased() {
  if (keyCode == UP) {
    movement(0, 1);
  } else if (keyCode == RIGHT) {
    movement(1, 1);
  } else if (keyCode == DOWN) {
    movement(2, 1);
  } else if (keyCode == LEFT) {
    movement(3, 1);
  } else if (key == 'r') {
    visitedSet.clear();
    scramble();
    startTime = millis(); endTime = -1; minSteps = 0;
  } else if (key == 's') {
    thread("startSolve");
  }
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
}

void startSolve() {
  // startTime = millis(); endTime = -1; minSteps = 0;
  // visitedSet.clear();
  int[][] aux = new int[size][size]; for (int i = 0; i < size; i ++) aux[i] = table[i].clone();
  // // dfsRecursive(ni, nj, 0);
  // dfsStack();
  // print("DFS done, states: " + str(visitedSet.size()) + "\n");
  //
  // delay(5000);
  //
  // startTime = millis(); endTime = -1; minSteps = 0;
  // for (int i = 0; i < size; i ++) table[i] = aux[i].clone();
  // visitedSet.clear();
  // bfs();
  // print("BFS done, states: " + str(visitedSet.size()) + "\n");
  //
  // delay(5000);

  startTime = millis(); endTime = -1; minSteps = 0;
  for (int i = 0; i < size; i ++) table[i] = aux[i].clone();
  visitedSet.clear();
  aStar();
  print("A* (euclideanDistance) done, states: " + str(visitedSet.size()) + "\n");
}

String state() {
  String nowState = "";
  for (int i = 0; i < size; i ++)
    for (int j = 0; j < size; j ++)
    {
      nowState += str(table[i][j]);
      if (i != size - 1 || j != size - 1) nowState += "|";
    }
  return(nowState);
}

boolean dfsRecursive(int i, int j, int now) {
  if (i == size - 1 && j == size - 1 && solved()) {
    minSteps = now;
    return(true);
  }
  String nowState = state();
  if (visitedSet.contains(nowState)) { return(false); };
  visitedSet.add(nowState);

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

void dfsStack() {
  stack.clear();
  stack.push(new ele(table, 0, 0));

  while (stack.size() > 0) {
    table = stack.peek().table; minSteps = stack.peek().minSteps; stack.pop();
    delay(waitTime);
    setBlackBlock();
    if (solved()) break;

    for (int k = 0; k < 4; k ++)
      if (!invalid(ni + dy[k], nj + dx[k])) {
        movement(k, 0);
        String nowState = state();
        if (!visitedSet.contains(nowState)) {
          visitedSet.add(nowState);
          stack.push(new ele(table, minSteps + 1, 0));
        }
        movement((k + 2) % 4, 0);
      }
  }
}

void bfs() {
  queue.clear();
  queue.add(new ele(table, 0, 0));

  while (queue.size() > 0) {
    table = queue.peek().table; minSteps = queue.peek().minSteps; queue.remove();
    setBlackBlock();
    delay(waitTime);

    if (solved()) break;

    for (int k = 0; k < 4; k ++)
      if (!invalid(ni + dy[k], nj + dx[k])) {
        movement(k, 0);
        String nowState = state();
        if (!visitedSet.contains(nowState)) {
          visitedSet.add(nowState);
          queue.add(new ele(table, minSteps + 1, 0));
        }
        movement((k + 2) % 4, 0);
      }
  }
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

void aStar() {
  pq.clear();
  pq.add(new ele(table, 0, euclideanDistance()));

  while (pq.size() > 0) {
    table = pq.peek().table; minSteps = pq.peek().minSteps; nowDistance = pq.peek().h; pq.poll();
    delay(waitTime);
    setBlackBlock();
    // for (int i = 0; i < size; i ++) for (int j = 0; j < size; j ++) if (table[i][j] == sqSize) { ni = i; nj = j; }
    if (solved()) break;

    for (int k = 0; k < 4; k ++)
      if (!invalid(ni + dy[k], nj + dx[k])) {
        movement(k, 0);
        String nowState = state();
        if (!visitedSet.contains(nowState)) {
          visitedSet.add(nowState);
          pq.add(new ele(table, minSteps + 1, euclideanDistance()));
        }
        movement((k + 2) % 4, 0);
      }
  }
}
