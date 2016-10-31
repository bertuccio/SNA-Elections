package gephi.layout;

import org.gephi.graph.api.GraphModel;
import org.gephi.layout.plugin.forceAtlas2.ForceAtlas2;
import org.gephi.layout.plugin.forceAtlas2.ForceAtlas2Builder;

public class ForceAtlas2Layout  extends Layout{
	
	
	private ForceAtlas2 f2 = new ForceAtlas2Builder().buildLayout();
	
	@Override
	public void runLayout(GraphModel model, int passes) {
		
		f2.setGraphModel(model);
		f2.setScalingRatio(2.0);
		f2.setGravity(1.0);
		f2.setThreadsCount(12);
		f2.setLinLogMode(false);
		f2.setAdjustSizes(false);
		f2.initAlgo();
		for (int i = 0; i < passes && f2.canAlgo(); i++) {
			f2.goAlgo();
		}
		f2.endAlgo();
	}

}
