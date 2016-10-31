package gephi.iomanagers;

import java.io.File;
import java.io.FileNotFoundException;

import org.gephi.io.database.drivers.MySQLDriver;
import org.gephi.io.database.drivers.SQLiteDriver;
import org.gephi.io.importer.api.Container;
import org.gephi.io.importer.api.EdgeDirectionDefault;
import org.gephi.io.importer.api.ImportController;
import org.gephi.io.importer.plugin.database.EdgeListDatabaseImpl;
import org.gephi.io.importer.plugin.database.ImporterEdgeList;
import org.gephi.io.processor.plugin.DefaultProcessor;
import org.gephi.project.api.Workspace;
import org.openide.filesystems.FileUtil;
import org.openide.util.Lookup;

public class ImportManager {

	private static ImportController importController = Lookup.getDefault().lookup(ImportController.class);

	public static void importFile(String file, EdgeDirectionDefault edgeDirection, boolean autoNode,
			Workspace workspace) throws FileNotFoundException {

		Container container;
		File f = new File("resources/csv/" + file);
		container = importController.importFile(f);
		
		container.getLoader().setEdgeDefault(edgeDirection); 
		container.getLoader().setAllowAutoNode(autoNode); // create missing nodes
	
		// Append imported data to GraphAPI
		importController.process(container, new DefaultProcessor(), workspace);
	}
	
	public static void importSqliteDB(String filename, EdgeDirectionDefault edgeDirection, boolean autoNode,
			Workspace workspace) {
		
		
//		//Copy example database to tmp
        File temp;
        try {
//            File file = new File("resources/"+filename);
            temp = new File(System.getProperty("java.io.tmpdir"));
//            FileUtil.copyFile(FileUtil.toFileObject(file), FileUtil.toFileObject(temp), "twitterdb");
            temp = new File(temp, "twitterdb.sqlite3");
//            temp.deleteOnExit();
        } catch (Exception ex) {
            ex.printStackTrace();
            return;
        }
//        temp.deleteOnExit();
		
		//Import database
        EdgeListDatabaseImpl db = new EdgeListDatabaseImpl();
        db.setHost(temp.getAbsolutePath());
        db.setDBName("");
        db.setSQLDriver(new SQLiteDriver());
	
		//db.setSQLDriver(new PostgreSQLDriver());
		//db.setSQLDriver(new SQLServerDriver());
		db.setEdgeQuery("select source, users.screen_name as target from users, tweets, (select users.screen_name as source, retweet_id as r from tweets, users where retweet_id<>-1 and users.id=user_id) where r=tweets.id and user_id=users.id");
		Container container = importController.importDatabase(db, new ImporterEdgeList());
		container.getLoader().setEdgeDefault(edgeDirection); 
		container.getLoader().setAllowAutoNode(autoNode); // create missing nodes
		//Append imported data to GraphAPI
		importController.process(container, new DefaultProcessor(), workspace);
		
	}

}
