package gephi.layout;

import org.gephi.graph.api.GraphModel;
import org.gephi.layout.plugin.force.StepDisplacement;
import org.gephi.layout.plugin.force.yifanHu.YifanHuLayout;

public class YifanLayout extends Layout {

	private YifanHuLayout layout = new YifanHuLayout(null, new StepDisplacement(1f));

	@Override
	public void runLayout(GraphModel model, int passes) {

		layout.setGraphModel(model);
		layout.resetPropertiesValues();
		layout.setOptimalDistance(200f);
		layout.initAlgo();
		for (int i = 0; i < passes && layout.canAlgo(); i++) {
			layout.goAlgo();
		}

	}

}
