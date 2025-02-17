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
  m2.Map( (x) -> 5*x + 1 );
  m2.Debug();
  
  m2.Debug();
  d.Debug();
  m2.HProduct(d).Debug();
  */
  
  
  NeuralNetwork nn = new NeuralNetwork(2, 5, 2);
  println(nn);
  
  //Matrix entries = new Matrix(3, 10000).Random(0, 1);
  //Matrix exit = new Matrix(2, 10000).Random(0,1);
  
  Matrix entries = new Matrix(2, 10).FromArray(new double[][]{
    {-1,-5,3,0,-3,10,1,-1,1,0},
    {0,1,0,1,5,-2,-7,-1,1000,-1000,-1}
  });
  Matrix exit = new Matrix(2, 10).FromArray(new double[][]{
    {1,1,0,1,1,0,0,1,0,1},
    {0,0,1,1,0,1,1,0,1,1}
  });
  
  for(int i = 0; i < 100000; i++) {
    nn.Learn(entries.C(), exit.C(), 0.01);
  }
  
  Matrix entriesBis = new Matrix(2, 5).FromArray(new double[][]{
    {1,-5,0,0,-3},
    {0,-4,0,-100,5,2}
  });
  nn.Predict(entriesBis).Debug();
  
}
