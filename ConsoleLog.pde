class ConsoleLog {
  String name;
  PrintWriter output;
  
  //c Créer une instance de ConsoleLog ayant pour nom _name_
  // Les logs sont enregistrés dans le fichier renseigné dans _name_
  ConsoleLog(String name) {
    this.name = name;
    output = createWriter(name);
  }
  
  //f Energistre une nouvelle ligne (saut de ligne)
  // Equivalent au *println()*
  void pln(Object... o) {
    println(o);
    
    for(Object e : o) {
      output.print(e);
      output.print(" ");
    }
    output.println();
  }
  
  //s
  void pln(String... o) {
    println(o);
    
    for(String e : o) {
      output.print(e);
      output.print(" ");
      graphApplet.WriteToConsole(e);
      graphApplet.WriteToConsole(" ");
    }
    
    output.println();
    graphApplet.console.append("\n");
  }
  
  //f Energistre une nouvelle donnée (sans saut de ligne)
  // Equivalent au *print()*
  void p(Object... o) {
    print(o);
    
    for(Object e : o) {
      output.print(e);
      output.print(" ");
    }
  }
  
  //s
  void p(String... o) {
    print(o);
    
    for(String e : o) {
      output.print(e);
      output.print(" ");
      graphApplet.WriteToConsole(e);
      graphApplet.WriteToConsole(" ");
    }
  }
  
  //f Energistre une nouvelle ligne, correspondant à la liste de flottants _list_
  // Est labelisé à l'aide de _label_
  void pFloatList(float[] list, String label) {
    this.p(label, " - [");
    for(int i = 0; i < list.length; i++) {
      this.p(String.format("%.3f", list[i]), i == list.length - 1 ? "" : ", ");
    }
    this.pln("]");
  }
  
  //f S'assure que le fichier correspondant est mis à jour
  void Update() {
    output.flush();
  }
  
  //f Termine l'enregistrement du fichier
  void End() {
    output.close();
  }
}
