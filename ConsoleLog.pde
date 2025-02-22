class ConsoleLog {
  String name;
  PrintWriter output;
  
  ConsoleLog(String name) {
    this.name = name;
    output = createWriter(name);
  }
  
  void pln(Object... o) {
    println(o);
    
    for(Object e : o) {
      output.print(e);
      output.print(" ");
    }
    output.println();
  }
  
  void p(Object... o) {
    print(o);
    
    for(Object e : o) {
      output.print(e);
      output.print(" ");
    }
  }
  
  void pFloatList(float[] list, String label) {
    this.p(label, " - [");
    for(int i = 0; i < list.length; i++) {
      this.p(String.format("%.3f", list[i]), i == list.length - 1 ? "" : ", ");
    }
    this.pln("]");
  }
  
  void Update() {
    output.flush();
  }
  
  void End() {
    output.close();
  }
}
