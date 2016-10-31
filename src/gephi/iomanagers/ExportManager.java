package gephi.iomanagers;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import org.apache.log4j.Logger;
import org.gephi.io.exporter.api.ExportController;
import org.gephi.io.exporter.preview.PDFExporter;
import org.gephi.io.exporter.preview.PNGExporter;
import org.gephi.io.exporter.preview.SVGExporter;
import org.gephi.io.exporter.spi.ByteExporter;
import org.gephi.io.exporter.spi.GraphExporter;
import org.gephi.project.api.Workspace;
import org.openide.util.Lookup;

import com.itextpdf.text.PageSize;
import com.itextpdf.text.Rectangle;

public class ExportManager {

	private static ExportController ec = Lookup.getDefault().lookup(ExportController.class);
	private static Logger logger = Logger.getLogger(ExportManager.class);

	public static void pdfExport(String filename, Rectangle pagesize) {

		// PDF Exporter config and export to Byte array
		PDFExporter pdfExporter = (PDFExporter) ec.getExporter("pdf");
		pdfExporter.setPageSize(pagesize);

		exportBytes(filename + ".pdf", pdfExporter);
	}

	public static void pngExport(String filename, int height, int width, Workspace workspace) {

		PNGExporter exporter = (PNGExporter) ec.getExporter("png");
		exporter.setHeight(height);
		exporter.setWidth(width);
		exporter.setMargin(0);
		exporter.setWorkspace(workspace);
	

		exportBytes(filename + ".png", exporter);
	}

	public static void gfxExport(String filename, Workspace workspace, boolean visible) {
		
		// Export only visible graph
		GraphExporter exporter = (GraphExporter) ec.getExporter("gexf"); // Get
																			// GEXF
																			// exporter
		exporter.setExportVisible(visible); // Only exports the visible
											// (filtered)
											// graph
		exporter.setWorkspace(workspace);

		try {
			ec.exportFile(new File("outputs/" + filename + ".gexf"), exporter);
		} catch (IOException ex) {
			System.out.println(ex);
			return;
		}
	}

	private static void exportBytes(String filename, ByteExporter exporter) {
		try {

			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			ec.exportStream(baos, exporter);
			byte[] bytes = baos.toByteArray();

			FileOutputStream fileOuputStream = new FileOutputStream("outputs/" + filename);
			fileOuputStream.write(bytes);
			fileOuputStream.close();

		} catch (Exception ex) {
			System.out.println(ex);
		}
	}
	
	public static void export(EXPORT_FLAGS flag){
		
		if(flag == EXPORT_FLAGS.EXPORT_GFX) {
			
		}
		
		if(flag == EXPORT_FLAGS.EXPORT_PDF) {
			
		}
		
		if(flag == EXPORT_FLAGS.EXPORT_PNG) {
			
		}
	}


}
