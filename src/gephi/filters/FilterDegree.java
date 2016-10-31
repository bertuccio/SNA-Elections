package gephi.filters;

import org.gephi.filters.api.FilterController;
import org.gephi.filters.api.Query;
import org.gephi.filters.api.Range;
import org.gephi.filters.plugin.graph.DegreeRangeBuilder.DegreeRangeFilter;
import org.gephi.graph.api.GraphModel;
import org.gephi.graph.api.GraphView;
import org.openide.util.Lookup;

public class FilterDegree {
	
	
	private static FilterController  filterController = Lookup.getDefault().lookup(FilterController.class);
	
	public static GraphView getFilteredView(GraphModel model, int range){
	
		DegreeRangeFilter degreeFilter = new DegreeRangeFilter();
		degreeFilter.init(model.getDirectedGraph());
		Query query = filterController.createQuery(degreeFilter);
		GraphView view = filterController.filter(query);
		
		return view;
	}
}
