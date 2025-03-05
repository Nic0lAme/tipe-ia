import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartPanel;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.data.xy.XYSeries;
import org.jfree.data.xy.XYSeriesCollection;
import javax.swing.JPanel;
import javax.swing.JFrame;
import java.awt.BorderLayout;
import java.awt.BasicStroke;

class GraphApplet extends JFrame {
  private int defaultWidth = 600;
  private int defaultHeight = 400;
  private Graph graph;

  public GraphApplet(String gTitle) {
    graph = new Graph(gTitle, "Itérations", "Coût");
    setSize(defaultWidth, defaultHeight);
    setLocation(0, 0);
    setResizable(true);
    setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
    setContentPane(graph.GetPanel());
    setVisible(true);
    setAlwaysOnTop(true);
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
}

public class Graph {
  final private JFreeChart chart;
  final private XYSeries series;
  final private ChartPanel panel;
  final private JPanel jpanel;

  private float strokeWeight = 1.25f;

  public Graph(String title, String abscisses, String ordonnees) {
    series = new XYSeries(title);
    XYSeriesCollection dataset = new XYSeriesCollection();
    dataset.addSeries(series);
    chart = ChartFactory.createXYLineChart(title, abscisses, ordonnees, dataset, PlotOrientation.VERTICAL, true, true, true);
    SetStrokeWeight(strokeWeight);
    panel = new ChartPanel(chart);
    panel.setDomainZoomable(true);
    panel.setRangeZoomable(false);
    panel.setMouseWheelEnabled(true);
    chart.getXYPlot().setDomainPannable(true);

    jpanel = new JPanel();
    jpanel.setLayout(new BorderLayout());
    jpanel.add(panel, BorderLayout.CENTER);

    ShowSeries();
  }

  public void SetStrokeWeight(float sw) {
    strokeWeight = sw;
    chart.getXYPlot().getRenderer().setSeriesStroke(0, new BasicStroke(strokeWeight));
  }

  public void Clear() {
    series.clear();
  }

  public void Add(double y) {
    if (series.getItemCount() == 0) Add(1, y);
    else Add(series.getMaxX() + 1, y);
  }

  public void Add(double x, double y) {
    series.add(x, y);
  }

  public void ShowSeries() {
    chart.getXYPlot().getRenderer().setSeriesVisible(0, true);
  }

  public void HideSeries() {
    chart.getXYPlot().getRenderer().setSeriesVisible(0, false);
  }

  public JPanel GetPanel() {
    return jpanel;
  }
}
