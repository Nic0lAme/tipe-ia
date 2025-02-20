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
  
  void Update() {
    output.flush();
  }
  
  void End() {
    output.close();
  }
}
