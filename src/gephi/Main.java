package gephi;

import gephi.iomanagers.ExportManager;
import gephi.iomanagers.ImportManager;
import gephi.layout.ForceAtlas2Layout;

import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;

import org.gephi.graph.api.DirectedGraph;
import org.gephi.graph.api.GraphController;
import org.gephi.graph.api.GraphModel;
import org.gephi.graph.api.GraphView;
import org.gephi.graph.api.Node;
import org.gephi.graph.api.NodeIterable;
import org.gephi.io.importer.api.EdgeDirectionDefault;
import org.gephi.preview.api.PreviewController;
import org.gephi.preview.api.PreviewModel;
import org.gephi.preview.api.PreviewProperty;
import org.gephi.project.api.ProjectController;
import org.gephi.project.api.Workspace;
import org.gephi.statistics.plugin.Degree;
import org.gephi.statistics.plugin.Modularity;
import org.openide.util.Lookup;

import com.itextpdf.text.PageSize;

import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;
import org.gephi.appearance.api.AppearanceController;
import org.gephi.appearance.api.AppearanceModel;
import org.gephi.appearance.api.Function;
import org.gephi.appearance.api.Partition;
import org.gephi.appearance.api.PartitionFunction;
import org.gephi.appearance.plugin.PartitionElementColorTransformer;
import org.gephi.appearance.plugin.RankingLabelSizeTransformer;
import org.gephi.appearance.plugin.palette.Palette;
import org.gephi.appearance.plugin.palette.PaletteManager;
import org.gephi.filters.api.FilterController;
import org.gephi.filters.api.Query;
import org.gephi.filters.api.Range;
import org.gephi.filters.plugin.graph.DegreeRangeBuilder.DegreeRangeFilter;
import org.gephi.graph.api.Column;

public class Main {

	private static Logger logger = Logger.getLogger(Main.class);

	public static void main(String[] args) {

		boolean pdfExportArg = false;
		boolean gfxExportArg = false;
		boolean pngExportArg = false;
		boolean filterDegree = false;
		boolean filterLabel = false;

		String filename = "retweet";

		// Time
		long startTime;
		long stopTime;
		long elapsedTime;

		String log4jConfPath = "resources/log4j.properties";
		PropertyConfigurator.configure(log4jConfPath);

		for (int i = 0; i < args.length; i++) {

			switch (args[i]) {
			case "-pdf":
				pdfExportArg = true;
				break;
			case "-png":
				pngExportArg = true;
				break;
			case "-gfx":
				gfxExportArg = true;
				break;
			case "-filter":
				filterDegree = true;
				break;
			case "hashtag":
				filename = args[i];
				break;
			case "retweet":
				filename = args[i];
				break;
			case "quote":
				filename = args[i];
				break;
			case "-filterLabel":
				filterLabel = true;
				break;
			}
		}
		System.out.println("Importing csv : process_" + filename + "_out.csv");
		// Init a project - and therefore a workspace
		ProjectController pc = Lookup.getDefault().lookup(ProjectController.class);
		pc.newProject();

		Workspace workspace = pc.getCurrentWorkspace();

		// Get controllers and models
		AppearanceController appearanceController = Lookup.getDefault().lookup(AppearanceController.class);
		AppearanceModel appearanceModel = appearanceController.getModel();
		GraphModel graphModel = Lookup.getDefault().lookup(GraphController.class).getGraphModel();
		FilterController filterController = Lookup.getDefault().lookup(FilterController.class);

		try {
			ImportManager.importFile("process_" + filename + "_out.csv", EdgeDirectionDefault.DIRECTED, true,
					workspace);

		} catch (FileNotFoundException e) {
			System.out.println(e);
			return;
		}

		DirectedGraph graph = graphModel.getDirectedGraph();
		logger.debug("Nodes: " + graph.getNodeCount());
		logger.debug("Edges: " + graph.getEdgeCount());

		System.out.println("Modularity Partition");
		startTime = System.currentTimeMillis();
		// Run modularity algorithm - community detection
		Modularity modularity = new Modularity();
		modularity.execute(graphModel);

		// Partition with 'modularity_class', just created by Modularity
		// algorithm
		Column modColumn = graphModel.getNodeTable().getColumn(Modularity.MODULARITY_CLASS);
		Function func2 = appearanceModel.getNodeFunction(graph, modColumn, PartitionElementColorTransformer.class);
		Partition partition = ((PartitionFunction) func2).getPartition();

		Palette palette = PaletteManager.getInstance().randomPalette(partition.size());
		partition.setColors(palette.getColors());
		appearanceController.transform(func2);

		stopTime = System.currentTimeMillis();
		elapsedTime = stopTime - startTime;
		logger.debug("Modularity Partition Elapsed Time: " + elapsedTime * 0.001);

		logger.debug(partition.size() + " partitions found");
		for (Object part : Arrays.asList(partition.getSortedValues().toArray()).subList(0, 20)) {
			logger.debug("Part: " + part + " Percent: " + partition.percentage(part) + "%");
		}

		System.out.println("ForceAtlas2 Layout");
		ForceAtlas2Layout f2 = new ForceAtlas2Layout();
		startTime = System.currentTimeMillis();
		f2.runLayout(graphModel, 150);
		stopTime = System.currentTimeMillis();
		elapsedTime = stopTime - startTime;
		logger.debug("Layout Elapsed Time: " + elapsedTime * 0.001);

	
		
		NodeIterable nodes = graphModel.getDirectedGraph().getNodes();
		List<Node> nodeList = Arrays.asList(nodes.toArray());
		
		Degree degree = new Degree();
		degree.execute(graphModel);
		
		// Filter, remove degree < 10
		if (filterDegree) {
			
			System.out.println("Filtering");
			DegreeRangeFilter degreeFilter = new DegreeRangeFilter();
			degreeFilter.setRange(new Range(10, Integer.MAX_VALUE));
			// Remove nodes with degree < 10
			Query query = filterController.createQuery(degreeFilter);
			GraphView view = filterController.filter(query);
			graphModel.setVisibleView(view); // Set the filter result as the
												// visible view
		}
		
		
		
		if(filterLabel) {
			
			
			Collections.sort(nodeList, new Comparator<Node>() {
				public int compare(Node n1, Node n2) {

					return ((Integer) n2.getAttribute(Degree.DEGREE)).compareTo((Integer) n1.getAttribute(Degree.DEGREE));
				}
			});
			if(!nodeList.isEmpty()) {
				
				
				Integer maxDegree = (Integer) nodeList.get(0).getAttribute(Degree.DEGREE);
				
				long filterDegreeValue = Math.round(Math.floor(maxDegree.intValue()/4.));
				
				for (Node n : nodeList) {
					Integer nodeDegree = (Integer) n.getAttribute(Degree.DEGREE);
					if(nodeDegree.intValue() < filterDegreeValue) {
						n.setLabel("");
					}		
				
				}
				
		        Function degreeRanking = appearanceModel.getNodeFunction(graph, AppearanceModel.GraphFunction.NODE_DEGREE, RankingLabelSizeTransformer.class);
		        RankingLabelSizeTransformer labelSizeTransformer = (RankingLabelSizeTransformer) degreeRanking.getTransformer();
		        labelSizeTransformer.setMinSize(5);
		        labelSizeTransformer.setMaxSize(15);
		        appearanceController.transform(degreeRanking);
				
				
//				System.out.println(filterDegreeValue);
//				DegreeRangeFilter degreeFilter = new DegreeRangeFilter();
//				degreeFilter.setRange(new Range(100, Integer.MAX_VALUE));
//				// Remove nodes with degree < 10
//				Query query = filterController.createQuery(degreeFilter);
//				filterController.exportToLabelVisible(query);	
				
				
				
			}
			
			
		}
		
		
		
		// Column modColumn =
		// graphModel.getNodeTable().getColumn(Degree.INDEGREE);


		// Node node2 = directedGraph.getNode("n2").getAttributeKeys()
		
		Collections.sort(nodeList, new Comparator<Node>() {
			public int compare(Node n1, Node n2) {

				return ((Integer) n2.getAttribute(Degree.DEGREE)).compareTo((Integer) n1.getAttribute(Degree.DEGREE));
			}
		});
		for (Node n : nodeList.subList(0, 79)) {
			logger.debug("Node: " + n.getId() + " Degree: " + n.getAttribute(Degree.DEGREE) + " Class: "
					+ n.getAttribute(Modularity.MODULARITY_CLASS));
		
		}
		
		
		// Preview
		startTime = System.currentTimeMillis();
		PreviewModel model = Lookup.getDefault().lookup(PreviewController.class).getModel();
		model.getProperties().putValue(PreviewProperty.SHOW_NODE_LABELS, Boolean.TRUE);
		model.getProperties().putValue(PreviewProperty.EDGE_CURVED, Boolean.FALSE);
		// model.getProperties().putValue(PreviewProperty.EDGE_COLOR, new
		// EdgeColor(Color.GRAY));
		model.getProperties().putValue(PreviewProperty.EDGE_THICKNESS, new Float(0.3f));
		model.getProperties().putValue(PreviewProperty.NODE_BORDER_WIDTH, new Float(0.2f));
		model.getProperties().putValue(PreviewProperty.NODE_LABEL_PROPORTIONAL_SIZE, Boolean.TRUE);
		model.getProperties().putValue(PreviewProperty.NODE_LABEL_FONT,
				model.getProperties().getFontValue(PreviewProperty.NODE_LABEL_FONT).deriveFont(14));
		stopTime = System.currentTimeMillis();
		elapsedTime = stopTime - startTime;
		logger.debug("Preview Elapsed Time: " + elapsedTime * 0.001);


		if (gfxExportArg) {
			System.out.println("Exporting GFX");
			startTime = System.currentTimeMillis();
			ExportManager.gfxExport("io_gexf_" + filename, workspace, true);
			stopTime = System.currentTimeMillis();
			elapsedTime = stopTime - startTime;
			logger.debug("GFX Export Elapsed Time: " + elapsedTime * 0.001);
		}
		if (pngExportArg) {
			System.out.println("Exporting PNG");
			startTime = System.currentTimeMillis();
			ExportManager.pngExport("io_png_" + filename, 10384, 10384, workspace);
			stopTime = System.currentTimeMillis();
			elapsedTime = stopTime - startTime;
			logger.debug("PNG Export Elapsed Time: " + elapsedTime * 0.001);
		}
		if (pdfExportArg) {
			System.out.println("Exporting PDF");
			startTime = System.currentTimeMillis();
			ExportManager.pdfExport("io_png_" + filename, PageSize.A0);
			stopTime = System.currentTimeMillis();
			elapsedTime = stopTime - startTime;
			logger.debug("PDF Export Elapsed Time: " + elapsedTime);
		}

	}
}