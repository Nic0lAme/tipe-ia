import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartPanel;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.DatasetRenderingOrder;
import org.jfree.data.xy.XYSeries;
import org.jfree.data.xy.XYSeriesCollection;
import java.text.DecimalFormat;
import javax.swing.JPanel;
import javax.swing.JFrame;
import javax.swing.JButton;
import java.awt.BorderLayout;
import java.awt.Insets;
import java.awt.Font;
import java.awt.GridBagLayout;
import java.awt.GridBagConstraints;
import java.awt.BorderLayout;
import java.awt.BasicStroke;
import java.awt.Color;
import java.util.LinkedList;

class GraphApplet extends JFrame {
  private LearnGraph graph;

  private JButton pinButton, dataButton, avgButton;
  private boolean pin = true;

  public GraphApplet(String gTitle) {
    graph = new LearnGraph(gTitle, "Itérations", "Coût");
    setLocation(0, 0);
    setResizable(true);
    setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
    setVisible(true);
    setAlwaysOnTop(pin);

    Init(graph);
    pack();
  }

  public void AddValue(double x, double y) {
    graph.Add(x, y);
  }

  public void AddValue(double y) {
    graph.Add(y);
  }

  public void ClearGraph()  {
    graph.Clear();
  }

  private void TogglePin() {
    pin = !pin;
    setAlwaysOnTop(pin);
    if (pin) pinButton.setText("Désépingler");
    else pinButton.setText("Épingler");
  }

  private void ToggleAvg() {
    graph.ToggleAvg();
    avgButton.setText((graph.IsAvgShowed() ? "Masquer" : "Afficher") + " la moyenne glissante");
  }

  private void ToggleData() {
    graph.ToggleData();
    println("hey" + graph.IsDataShowed());
    dataButton.setText((graph.IsDataShowed() ? "Masquer" : "Afficher") + " les données brutes");
  }

  private void Init(LearnGraph graph) {
    setLayout(new BorderLayout());

    JPanel top = new JPanel();
    JPanel topCenter = new JPanel();
    JPanel topCenterBottom = new JPanel();
    GridBagConstraints gbc = new GridBagConstraints();
    top.setLayout(new GridBagLayout());
    topCenter.setLayout(new GridBagLayout());
    topCenterBottom.setLayout(new GridBagLayout());
    gbc.gridx = 1;
    gbc.gridy = 0;
    top.add(topCenter, gbc);
    gbc.gridx = 1;
    gbc.gridy = 1;
    top.add(topCenterBottom, gbc);

    gbc.insets = new Insets(5, 10, 5, 10);
    gbc.weightx = 1;
    gbc.weighty = 1;

    pinButton = new JButton("Désépingler");
    pinButton.setFocusable(false);
    pinButton.addActionListener(e -> TogglePin());
    pinButton.setMargin(new Insets(5, 5, 5, 5));
    pinButton.setFont(new Font("", Font.PLAIN, 16));
    gbc.gridx = 0;
    gbc.gridy = 0;
    gbc.anchor = GridBagConstraints.WEST;
    top.add(pinButton, gbc);

    dataButton = new JButton("Masquer les données brutes");
    dataButton.setFocusable(false);
    dataButton.addActionListener(e -> ToggleData());
    dataButton.setMargin(new Insets(5, 5, 5, 5));
    dataButton.setFont(new Font("", Font.PLAIN, 16));
    gbc.gridx = 1;
    gbc.gridy = 0;
    gbc.anchor = GridBagConstraints.CENTER;
    top.add(dataButton, gbc);

    avgButton = new JButton("Masquer la moyenne glissante");
    avgButton.setFocusable(false);
    avgButton.addActionListener(e -> ToggleAvg());
    avgButton.setMargin(new Insets(5, 5, 5, 5));
    avgButton.setFont(new Font("", Font.PLAIN, 16));
    gbc.gridx = 2;
    gbc.gridy = 0;
    gbc.anchor = GridBagConstraints.EAST;
    top.add(avgButton, gbc);

    add(top, BorderLayout.NORTH);
    add(graph.GetPanel(), BorderLayout.CENTER);
  }
}

public class LearnGraph {
  final private JFreeChart chart;
  final private XYSeries series, average;
  final private ChartPanel panel;
  final private JPanel jpanel;

  private final int DATA_INDEX, AVG_INDEX;
  private float strokeWeight = 1.25f;

  private final LinkedList<Double> avgDatas = new LinkedList<Double>();
  private final int avgPeriod = 200;
  private double somme = 0;

  public LearnGraph(String title, String abscisses, String ordonnees) {
    series = new XYSeries("Coût");
    average = new XYSeries("Moyenne glissante");
    XYSeriesCollection dataset = new XYSeriesCollection();
    dataset.addSeries(average);
    dataset.addSeries(series);
    AVG_INDEX = 0;
    DATA_INDEX = 1;
    chart = ChartFactory.createXYLineChart(title, abscisses, ordonnees, dataset, PlotOrientation.VERTICAL, true, true, true);
    SetStrokeWeight(strokeWeight);
    chart.getXYPlot().getRenderer().setSeriesPaint(DATA_INDEX, Color.decode("#ff535a"));
    chart.getXYPlot().getRenderer().setSeriesPaint(AVG_INDEX, Color.decode("#786eff"));
    panel = new ChartPanel(chart);
    panel.setDomainZoomable(true);
    panel.setRangeZoomable(false);
    panel.setMouseWheelEnabled(true);
    chart.getXYPlot().setDomainPannable(true);
    NumberAxis absAxis = new NumberAxis(abscisses);
    LogAxis ordAxis = new LogAxis(ordonnees + " (log)");
    ordAxis.setBase(10);
    ordAxis.setNumberFormatOverride(new DecimalFormat("0.000E0"));
    chart.getXYPlot().setDomainAxis(absAxis);
    chart.getXYPlot().setRangeAxis(ordAxis);

    jpanel = new JPanel();
    jpanel.setLayout(new BorderLayout());
    jpanel.add(panel, BorderLayout.CENTER);
  }

  public void SetStrokeWeight(float sw) {
    strokeWeight = sw;
    chart.getXYPlot().getRenderer().setSeriesStroke(DATA_INDEX, new BasicStroke(strokeWeight));
    chart.getXYPlot().getRenderer().setSeriesStroke(AVG_INDEX, new BasicStroke(strokeWeight));
  }

  public boolean IsAvgShowed() {
    return chart.getXYPlot().getRenderer().isSeriesVisible(AVG_INDEX);
  }

  public void ToggleAvg() {
    chart.getXYPlot().getRenderer().setSeriesVisible(AVG_INDEX, !IsAvgShowed());
  }

  public boolean IsDataShowed() {
    return chart.getXYPlot().getRenderer().isSeriesVisible(DATA_INDEX);
  }

  public void ToggleData() {
    chart.getXYPlot().getRenderer().setSeriesVisible(DATA_INDEX, !IsDataShowed());
  }

  public void Clear() {
    series.clear();
    average.clear();
  }

  public void Add(double y) {
    if (series.getItemCount() == 0) Add(1, y);
    else Add(series.getMaxX() + 1, y);
  }

  public void Add(double x, double y) {
    series.add(x, y);

    // Actualise la moyenne glissante
    somme += y;
    avgDatas.add(y);
    if (avgDatas.size() > avgPeriod) somme -= avgDatas.remove();
    if (avgDatas.size() == avgPeriod) average.add(x, somme/avgPeriod);
  }

  public JPanel GetPanel() {
    return jpanel;
  }
}
