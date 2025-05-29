import java.util.Arrays;

class Letter {
  String name;
  String c;
  
  Letter (String c) {
    this.name = c;
    this.c = c;
  }
  
  Letter (String name, String c) {
    this.name = name;
    this.c = c;
  }
  
  void Save(int w, int h, PFont font, String fontName) {
    PGraphics pg = createGraphics(w, h);
    pg.beginDraw();
    
    pg.rectMode(CENTER);
    pg.fill(0);
    pg.background(255);
    pg.textFont(font);
    pg.textAlign(CENTER, CENTER);
    pg.text(this.c, w/2, h/2);
    
    pg.save("./output/" + this.name + "/" + name + " - " + fontName + ".jpg");
    
    pg.endDraw();
  }
}

int w = 156;
int h = 175;
String fontName = "Helvetica";
int size = 90;
  
void settings() {
  size(w,h);
}

void setup() {  
  Letter[] letters = new Letter[] {
    new Letter("uA", "A"),
    new Letter("uB", "B"),
    new Letter("uC", "C"),
    new Letter("uD", "D"),
    new Letter("uE", "E"),
    new Letter("uF", "F"),
    new Letter("uG", "G"),
    new Letter("uH", "H"),
    new Letter("uI", "I"),
    new Letter("uJ", "J"),
    new Letter("uK", "K"),
    new Letter("uL", "L"),
    new Letter("uM", "M"),
    new Letter("uN", "N"),
    new Letter("uO", "O"),
    new Letter("uP", "P"),
    new Letter("uQ", "Q"),
    new Letter("uR", "R"),
    new Letter("uS", "S"),
    new Letter("uT", "T"),
    new Letter("uU", "U"),
    new Letter("uV", "V"),
    new Letter("uW", "W"),
    new Letter("uX", "X"),
    new Letter("uY", "Y"),
    new Letter("uZ", "Z"),
    new Letter("la", "a"),
    new Letter("lb", "b"),
    new Letter("lc", "c"),
    new Letter("ld", "d"),
    new Letter("le", "e"),
    new Letter("lf", "f"),
    new Letter("lg", "g"),
    new Letter("lh", "h"),
    new Letter("li", "i"),
    new Letter("lj", "j"),
    new Letter("lk", "k"),
    new Letter("ll", "l"),
    new Letter("lm", "m"),
    new Letter("ln", "n"),
    new Letter("lo", "o"),
    new Letter("lp", "p"),
    new Letter("lq", "q"),
    new Letter("lr", "r"),
    new Letter("ls", "s"),
    new Letter("lt", "t"),
    new Letter("lu", "u"),
    new Letter("lv", "v"),
    new Letter("lw", "w"),
    new Letter("lx", "x"),
    new Letter("ly", "y"),
    new Letter("lz", "z"),
    new Letter("0"),
    new Letter("1"),
    new Letter("2"),
    new Letter("3"),
    new Letter("4"),
    new Letter("5"),
    new Letter("6"),
    new Letter("7"),
    new Letter("8"),
    new Letter("9"),
    new Letter("+"),
    new Letter("-"),
    new Letter("cr", "×"),
    new Letter("@"),
    new Letter("#"),
    new Letter("'"),
    new Letter("pt", "."),
    new Letter("im", "?"),
    new Letter("!"),
    new Letter("tp", ":"),
    new Letter("€"),
    new Letter("$"),
    new Letter("%"),
    new Letter("("),
    new Letter(")"),
    new Letter("=")
  };
  
  println(Arrays.asList(PFont.list()));
  
  if(!Arrays.asList(PFont.list()).contains(fontName)) {
    println("The font is not available");
    exit();
    return;
  }
  PFont font = createFont(fontName, size);
  
  for (Letter l : letters)
    l.Save(w, h, font, fontName);
    
  exit();
}
