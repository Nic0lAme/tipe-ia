class Zone {
  int x, y;
  int w, h;
  String name;
  
  Zone(String name, int x, int y, int w, int h) {
    this.name = name;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  
  void Screen(PImage doc, String suffix, int dx, int dy) {
    doc.get(this.x + dx, this.y + dy, this.w, this.h)
    .save("./output/" + name + "/" + name + " - " + suffix + ".jpg");
  }
  
  void Draw(float scaleRes, int dx, int dy) {
    noFill();
    stroke(#FF0000);
    strokeWeight(1);
    rect(this.x * scaleRes + dx, this.y * scaleRes + dy, this.w * scaleRes, this.h * scaleRes);
  }
}

int w = 2480;
int h = 3504;
int dx = 0;
int dy = 0;
float scaleRes = 0.4;
float xPageScale = 1.01;
float yPageScale = 1;


void settings() {
  size(floor(w * scaleRes),floor(h * scaleRes));
}

String name;
PImage doc;
Zone[] zones;



/*
CONSIGNES :
  1/ Mettre le document en format jpg dans le dossier "./doc"
  2/ Changer la variable -name- en fonction du nom du doc (Test pour Test.jpg)
  3/ Lancer le programme
  4/ Ajuster avec les fléches du clavier au pixel près
  5/ Appuyer sur entrée pour enregistrer
*/
void setup() {
  name = "TestComp1";
  doc = loadImage("./doc/" + name + ".jpg");
  
  zones = new Zone[]{
    new Zone("uA", 130, 496, 156, 175),
    new Zone("uB", 299, 496, 156, 175),
    new Zone("uC", 467, 496, 156, 175),
    new Zone("uD", 636, 496, 156, 175),
    new Zone("uE", 805, 496, 156, 175),
    new Zone("uF", 973, 496, 156, 175),
    new Zone("uG", 1142, 496, 156, 175),
    new Zone("uH", 1310, 496, 156, 175),
    new Zone("uI", 1479, 496, 156, 175),
    new Zone("uJ", 1648, 496, 156, 175),
    new Zone("uK", 1816, 496, 156, 175),
    new Zone("uL", 1985, 496, 156, 175),
    new Zone("uM", 2154, 496, 156, 175),
    new Zone("uN", 130, 784, 156, 175),
    new Zone("uO", 299, 784, 156, 175),
    new Zone("uP", 467, 784, 156, 175),
    new Zone("uQ", 636, 784, 156, 175),
    new Zone("uR", 805, 784, 156, 175),
    new Zone("uS", 973, 784, 156, 175),
    new Zone("uT", 1142, 784, 156, 175),
    new Zone("uU", 1310, 784, 156, 175),
    new Zone("uV", 1479, 784, 156, 175),
    new Zone("uW", 1648, 784, 156, 175),
    new Zone("uX", 1816, 784, 156, 175),
    new Zone("uY", 1985, 784, 156, 175),
    new Zone("uZ", 2154, 784, 156, 175),
    new Zone("la", 130, 1076, 156, 175),
    new Zone("lb", 299, 1076, 156, 175),
    new Zone("lc", 467, 1076, 156, 175),
    new Zone("ld", 636, 1076, 156, 175),
    new Zone("le", 805, 1076, 156, 175),
    new Zone("lf", 973, 1076, 156, 175),
    new Zone("lg", 1142, 1076, 156, 175),
    new Zone("lh", 1310, 1076, 156, 175),
    new Zone("li", 1479, 1076, 156, 175),
    new Zone("lj", 1648, 1076, 156, 175),
    new Zone("lk", 1816, 1076, 156, 175),
    new Zone("ll", 1985, 1076, 156, 175),
    new Zone("lm", 2154, 1076, 156, 175),
    new Zone("ln", 130, 1368, 156, 175),
    new Zone("lo", 299, 1368, 156, 175),
    new Zone("lp", 467, 1368, 156, 175),
    new Zone("lq", 636, 1368, 156, 175),
    new Zone("lr", 805, 1368, 156, 175),
    new Zone("ls", 973, 1368, 156, 175),
    new Zone("lt", 1142, 1368, 156, 175),
    new Zone("lu", 1310, 1368, 156, 175),
    new Zone("lv", 1479, 1368, 156, 175),
    new Zone("lw", 1648, 1368, 156, 175),
    new Zone("lx", 1816, 1368, 156, 175),
    new Zone("ly", 1985, 1368, 156, 175),
    new Zone("lz", 2154, 1368, 156, 175),
    new Zone("0", 130, 1661, 156, 175),
    new Zone("1", 299, 1661, 156, 175),
    new Zone("2", 467, 1661, 156, 175),
    new Zone("3", 636, 1661, 156, 175),
    new Zone("4", 805, 1661, 156, 175),
    new Zone("5", 973, 1661, 156, 175),
    new Zone("6", 1142, 1661, 156, 175),
    new Zone("7", 1310, 1661, 156, 175),
    new Zone("8", 1479, 1661, 156, 175),
    new Zone("9", 1648, 1661, 156, 175),
    new Zone("+", 1816, 1661, 156, 175),
    new Zone("-", 1985, 1661, 156, 175),
    new Zone("cr", 2154, 1661, 156, 175),
    new Zone("@", 130, 1953, 156, 175),
    new Zone("#", 299, 1953, 156, 175),
    new Zone("'", 467, 1953, 156, 175),
    new Zone("pt", 636, 1953, 156, 175),
    new Zone("im", 805, 1953, 156, 175),
    new Zone("!", 973, 1953, 156, 175),
    new Zone("tp", 1142, 1953, 156, 175),
    new Zone("€", 1310, 1953, 156, 175),
    new Zone("$", 1479, 1953, 156, 175),
    new Zone("%", 1648, 1953, 156, 175),
    new Zone("(", 1816, 1953, 156, 175),
    new Zone(")", 1985, 1953, 156, 175),
    new Zone("=", 2154, 1953, 156, 175),
    new Zone("Name", 130, 2287, 2180, 186),
    new Zone("Message", 130, 2632, 2180, 400)
  };
  
  
}

void draw() {
  image(doc, 0, 0, w * scaleRes, h * scaleRes);
  
  for (int i = 0; i < zones.length; i++) {
    zones[i].Draw(scaleRes, dx, dy);
  }
}

void keyPressed() {
  switch (keyCode) {
    case ENTER:
      for (int i = 0; i < zones.length; i++) {
        zones[i].Screen(doc, name, dx, dy);
      }
      break;
    case UP:
      dy -= 1;
      break;
    case DOWN:
      dy += 1;
      break;
    case LEFT:
      dx -= 1;
      break;
    case RIGHT:
      dx += 1;
      break;
  }
  println("dx :", dx, "dy :", dy);
}
