package com.rahul.learn;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class Application {

	private static List<String> excludedFiles;
	static {
		excludedFiles = new ArrayList<String>();

		excludedFiles.add("404.html");
		excludedFiles.add("README.html");
	}

	public static void main(String[] args) throws Exception {
		if (args.length != 1) {
			System.err.println("You need to specify the directory where the files exist");
			System.exit(0);
		}

		File file = new File(args[0]);
		Application application = new Application();
		List<String> filesList = new ArrayList<String>();

		if (file.isDirectory()) {
			filesList = application.filesList(file, args[0]);
		} else {
			System.out.println(file.getCanonicalPath());
		}

		application.createFile(filesList);
	}

	private void createFile(List<String> filesList) throws Exception {
		StringBuilder sb = new StringBuilder();

		sb.append("---");
		sb.append("\n");
		sb.append("\n");
		sb.append("copyright_notice: '© Copyright Cloud Foundry Community. All rights reserved'");
		sb.append("\n");
		sb.append("header: pdf_header.html");
		sb.append("\n");
		sb.append("pages:");
		for (String file : filesList) {
			sb.append("\n");
			sb.append("    - ").append(file);
		}

		File file = new File("pdf.yml");
		FileWriter fw = new FileWriter(file);
		fw.write(sb.toString());
		fw.flush();
		fw.close();

	}

	public List<String> filesList(File file, String providedPath) {
		List<String> filesInDir = new ArrayList<String>();
		if (file.isDirectory()) {
			File[] filesInDirectory = file.listFiles();
			for (File subFile : filesInDirectory) {
				filesInDir.addAll(filesList(subFile, providedPath));
			}
		} else {
			String absolutePath = file.getAbsolutePath();
			if (isHtml(file.getName())) {
				String[] subString = absolutePath.split(providedPath + "/");
				filesInDir.add(subString[1]);
			}
		}

		return filesInDir;
	}

	private boolean isHtml(String fileName) {
		return fileName.endsWith(".html") && !excludedFiles.contains(fileName);
	}

}
