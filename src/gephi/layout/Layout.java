package gephi.layout;

import org.gephi.graph.api.GraphModel;

public abstract class Layout {
	
	public abstract void runLayout(GraphModel model, int passes);

}
