void setup() {
  /*
  size(200, 200);
  background(255);

  Matrix m = new Matrix(2,3);
  m.Fill(1);
  m.Set(1,2, -1);
  
  Matrix b = m.C().T().Scale(2).Add(m.C().T());
  
  Matrix c = m.Mult(b);
  
  m.Debug();
  b.Debug();
  c.Debug();
  
  double[][] arr = {{1,2,3},{4,5,6},{7,7,9}};
  Matrix d = new Matrix(3).FromArray(arr);
  Matrix id = d.Inversed();
  d.Mult(id).Debug();
  println(d.Det());
  
  Matrix m2 = new Matrix(3).FromArray(arr);
  m2.Debug();
  m2.Map( (x) -> 5*x );
  m2.Debug();
  */
  
  NeuralNetwork nn = new NeuralNetwork(12, 16, 20, 8);
  print(nn);
}
