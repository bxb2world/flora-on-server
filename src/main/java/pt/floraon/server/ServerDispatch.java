package pt.floraon.server;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.lang.reflect.InvocationTargetException;
import java.net.Socket;
import java.net.URI;
import java.net.URISyntaxException;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import org.apache.commons.fileupload.MultipartStream;
import org.apache.commons.fileupload.ParameterParser;
import org.apache.http.ConnectionClosedException;
import org.apache.http.HttpEntityEnclosingRequest;
import org.apache.http.HttpException;
import org.apache.http.HttpRequest;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.ProtocolVersion;
import org.apache.http.RequestLine;
import org.apache.http.client.utils.URIBuilder;
import org.apache.http.client.utils.URLEncodedUtils;
import org.apache.http.entity.BasicHttpEntity;
import org.apache.http.entity.ContentLengthStrategy;
import org.apache.http.impl.entity.StrictContentLengthStrategy;
import org.apache.http.impl.io.ChunkedInputStream;
import org.apache.http.impl.io.ContentLengthInputStream;
import org.apache.http.impl.io.DefaultHttpRequestParser;
import org.apache.http.impl.io.HttpTransportMetricsImpl;
import org.apache.http.impl.io.IdentityInputStream;
import org.apache.http.impl.io.SessionInputBufferImpl;
import org.apache.http.message.BasicHeader;
import org.apache.http.message.BasicHttpResponse;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.message.BasicStatusLine;
import org.apache.http.util.EntityUtils;

import com.arangodb.ArangoException;
import com.arangodb.entity.EntityFactory;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.JsonSyntaxException;

import pt.floraon.driver.FloraOnGraph;
import pt.floraon.entities.GeneralNodeWrapperImpl;
import pt.floraon.entities.TaxEnt;
import pt.floraon.queryparser.YlemParser;
import pt.floraon.results.ChecklistEntry;
import pt.floraon.results.Occurrence;
import pt.floraon.results.ResultProcessor;
import pt.floraon.results.SimpleNameResult;
import pt.floraon.results.SimpleTaxonResult;

import static pt.floraon.server.Constants.*; 

public class ServerDispatch implements Runnable {
    protected Socket clientSocket = null;
    protected String serverText   = null;
    protected FloraOnGraph graph=null;
    protected MultiThreadedServer thr;

    public ServerDispatch(Socket clientSocket, String serverText,FloraOnGraph graph,MultiThreadedServer thr) {
        this.clientSocket = clientSocket;
        this.serverText   = serverText;
        this.graph=graph;
        this.thr=thr;
    }
    
	@SuppressWarnings("unchecked")
	public static String getQSValue(String key,Object qs) {
    	if(qs instanceof JsonElement)
    		return getQSValue(key,(JsonElement) qs);
    	else if(qs instanceof List)
    		return getQSValue(key,(List<NameValuePair>) qs);
    	else {
    		System.out.println(qs.getClass().toString());
    		return null;
    	}
    }

    public static String getQSValue(String key,JsonElement qs) {
    	JsonElement el=qs.getAsJsonObject().get(key);
    	return el==null ? null : el.getAsString();
    }
    
	public static String getQSValue(String key,List<NameValuePair> qs) {
		for(NameValuePair i:qs) {
			if(i.getName().equals(key)) return(i.getValue());
		}
		return null;
	}
	
	private static String success(String obj) {
		return "{\"success\":true,\"msg\":"+obj+"}";
	}

	private static String success(JsonElement obj,JsonObject header) {
		JsonObject out;
		if(header==null)
			out=new JsonObject();
		else
			out=header;
		out.addProperty("success", true);
		out.add("msg", obj);
		return out.toString();
	}

	private static String error(String obj) {
		return "{\"success\":false,\"msg\":\""+obj+"\"}";
	}
   
// dispatch a request to port 9000
	public void run() {
		OutputStream ostr=null;
		try {
			ostr = clientSocket.getOutputStream();
		} catch (IOException e1) {
			e1.printStackTrace();
		}
        //try(BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));) {

		try(InputStream in = clientSocket.getInputStream();) {
        	HttpTransportMetricsImpl metrics = new HttpTransportMetricsImpl();
        	SessionInputBufferImpl buf = new SessionInputBufferImpl(metrics, 2048);
        	buf.bind(in);

        	DefaultHttpRequestParser reqParser = new DefaultHttpRequestParser(buf);
        	HttpRequest req;
        	try {
        		req = reqParser.parse();
        	} catch (ConnectionClosedException e) {
        		ostr.close();
        		return;
        	}
        	RequestLine requestline=req.getRequestLine();
        	URI url=new URIBuilder(requestline.getUri()).build();

        	switch(requestline.getMethod()) {
        	case "GET":
        		processCommand(url,this.graph,ostr,true);
        		break;
        	case "POST":
            	InputStream contentStream = null;
            	//HttpEntityEnclosingRequest ereq=null;
            	
            	if (req instanceof HttpEntityEnclosingRequest) {
            		//ereq = (HttpEntityEnclosingRequest) req;
            	    ContentLengthStrategy contentLengthStrategy = StrictContentLengthStrategy.INSTANCE;
            	    long len = contentLengthStrategy.determineLength(req);
            	    if (len == ContentLengthStrategy.CHUNKED) {
            	        contentStream = new ChunkedInputStream(buf);
            	    } else if (len == ContentLengthStrategy.IDENTITY) {
            	        contentStream = new IdentityInputStream(buf);
            	    } else {
            	        contentStream = new ContentLengthInputStream(buf, len);
            	    }
            	}
            	BasicHttpEntity ent = new BasicHttpEntity();
                ent.setContent(contentStream);
            	ParameterParser pp=new ParameterParser();
            	Map<String,String> contentTypeHeader=pp.parse(req.getFirstHeader("Content-Type").getValue(),';');
            	String contentType=null;
            	for(Entry<String,String> e : contentTypeHeader.entrySet()) {	// get content-type
            		if(e.getValue()==null) {contentType=e.getKey();break;}
            	}
                //System.out.println(EntityUtils.toString(ent));
                //ereq.setEntity(ent);
                switch(contentType) {
                case "application/x-www-form-urlencoded":
                	List<NameValuePair> qs=URLEncodedUtils.parse(EntityUtils.toString(ent),Charset.defaultCharset());
                	for(NameValuePair nvp : qs) {
                		if(nvp.getValue()==null) {
                			JsonObject jo=(JsonObject) new JsonParser().parse(nvp.getName());
                			System.out.println(jo.toString());
                		} else {
                			System.out.println("NAME: "+nvp.getName()+"; value: "+nvp.getValue());
                		}
                	}
                	processCommand(url,qs,this.graph,ostr,true);
                	break;
                	
                case "multipart/form-data":
                	List<NameValuePair> params=new ArrayList<NameValuePair>();
					try {
						MultipartStream multipartStream = new MultipartStream(contentStream, contentTypeHeader.get("boundary").getBytes(),500,null);
						boolean nextPart = multipartStream.skipPreamble();
						ByteArrayOutputStream tmp;
						while(nextPart) {	// parse each form data part and build a key value map
							String name=pp.parse(multipartStream.readHeaders(),';').get("name");
							tmp=new ByteArrayOutputStream();
							multipartStream.readBodyData(tmp);
							params.add(new BasicNameValuePair(name,tmp.toString()));
							nextPart = multipartStream.readBoundary();
						}
					} catch(MultipartStream.MalformedStreamException e) {
					// the stream failed to follow required syntax
						break;
					} catch(IOException e) {
					// a read or write error occurred
						break;
					}
					processCommand(url,params,this.graph,ostr,true);
//					for(NameValuePair nvp : params) System.out.println("NAME: "+nvp.getName()+"; value: "+nvp.getValue());
                	break;

                default:
                	break;
                }
        		break;
    		default:
    			//out.println(error("Invalid http method: "+requestline.getMethod()));
    			break;
        	}
        	ostr.close();
        } catch (ArangoException | QueryException | TaxonomyException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		} catch (FloraOnException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (HttpException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		} catch (URISyntaxException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }
	
	public static void processCommand(String command,FloraOnGraph graph,OutputStream out,boolean headers) throws ArangoException, URISyntaxException, IOException, FloraOnException {
		URI url=new URI("/"+command.trim());
		processCommand(url,graph,out,headers);
	}
	
	public static void processCommand(URI url,FloraOnGraph graph,OutputStream output,boolean headers) throws QueryException, ArangoException, TaxonomyException, IOException, FloraOnException {
		processCommand(url,URLEncodedUtils.parse(url,Charset.defaultCharset().toString()),graph,output,headers);
	}
	
	public static void processCommand(URI url,List<NameValuePair> params,FloraOnGraph graph,OutputStream outstr,boolean headers) throws QueryException, ArangoException, TaxonomyException, IOException {
		PrintWriter output;
		JsonObject jobj;
    	String format,id,id2;
    	JsonObject header;
    	String command=url.getPath();
    	String name,author,rank,comment,current,description,shortName;
    	Object parameters=null;
    	
    	output = new PrintWriter(new OutputStreamWriter(outstr, StandardCharsets.UTF_8), true);
    	String[] path=command.split("/");
    	if(path.length<2) {
    		output.println(error("This is Flora-On. Missing parameters. Are you looking for the web admin? Go to http://localhost:9000/admin"));
    		output.flush();
    		return;
    	}
    	// check whether we have a single JSON document with the query, or a name value list
    	if(params.size()==1 && params.get(0).getValue()==null) {
			JsonObject jpar=null;
			try {
				jpar=(JsonObject) new JsonParser().parse(params.get(0).getName());
			} catch (JsonSyntaxException e) {
				output.println(error(e.getMessage()));
			}
			parameters=jpar;
			output.println(jpar.toString());
    	} else parameters=params;		// no JSON, key-values

    	if(path[1].equals("admin")) {
    		WebAdmin.processRequest(url,outstr,graph);
    		output.flush();
    		return;
    	}
    	
    	if(headers) {
	    	HttpResponse httpres=new BasicHttpResponse(new BasicStatusLine(new ProtocolVersion("HTTP",1,1),200,""));
	    	httpres.addHeader(new BasicHeader("Content-Type:","application/json"));
	    	output.print(httpres.toString()+"\r\n");
	    	output.print("\r\n");
	    	output.flush();
    	}
    	
    	switch(path[1]) {
		case "query":	// general compound query, as input by the user
			String query=getQSValue("q",parameters);
			format=getQSValue("fmt",parameters);
			if(query==null || query.length()<1) {
				output.println(error("Missing query."));
				output.flush();
				return;
			}
			if(format==null) format="json";
			Iterator<SimpleTaxonResult> it;
			ResultProcessor<SimpleTaxonResult> rp;
			YlemParser ylem=new YlemParser(graph,query);
			long start = System.nanoTime();
			List<SimpleTaxonResult> res=ylem.execute();
			long elapsedTime = System.nanoTime() - start;
			
			if(res==null) res=new ArrayList<SimpleTaxonResult>();
				
			header=new JsonObject();
			header.addProperty("time", (double)elapsedTime/1000000000);
			header.addProperty("nresults", res.size());
			it=res.iterator();
			rp=new ResultProcessor<SimpleTaxonResult>(it);
			switch(format) {
			case "html":
				output.println(rp.toHTMLTable());
				break;
				
			case "json":
			default:
				output.println(success(rp.toJSONElement(),header));
				break;
			}
			break;
			
		case "lists":
			if(path.length<3) {
				output.println(error("Choose one of: checklist, species"));
				output.flush();
				return;
			}
			format=getQSValue("fmt",parameters);
			if(format==null || format.trim().equals("")) format="html";
			ResultProcessor<?> rpchk=null;
			switch(path[2]) {
			case "checklist":
				List<ChecklistEntry> chklst=graph.getCheckList();
				Collections.sort(chklst);
				rpchk=(ResultProcessor<ChecklistEntry>) new ResultProcessor<ChecklistEntry>(chklst.iterator());
				break;
			
			case "species":
				Iterator<SimpleNameResult> species=graph.dbSpecificQueries.getAllSpeciesOrInferior(true);
				rpchk=(ResultProcessor<SimpleNameResult>) new ResultProcessor<SimpleNameResult>(species);
				break;
			}
			
			if(rpchk!=null) {
				switch(format) {
				case "json":
					header=new JsonObject();
					//header.addProperty("nresults", chklst.size());
					output.println(success(rpchk.toJSONElement(),header));
					break;
				case "html":
					output.println(rpchk.toHTMLTable());
					break;
				case "csv":
					output.println(rpchk.toCSVTable());
					break;
				}
			} else output.println(error("Some error occurred."));
			break;
			
		case "getneighbors":
			id=getQSValue("id",parameters);
			query=getQSValue("q",parameters);
			if(id==null && query==null) {
				output.println(error("Missing query."));
				break;
			}

			String infacets[];
			if(getQSValue("f",parameters)==null || getQSValue("f",parameters).equals(""))
				infacets=new String[]{"taxonomy"};
			else
				infacets=getQSValue("f",parameters).split(",");
			
			Facets[] fac=new Facets[infacets.length];
			for(int i=0;i<infacets.length;i++) fac[i]=Facets.valueOf(infacets[i].toUpperCase());

			if(id==null) {
				TaxEnt te=graph.dbNodeWorker.findTaxEnt(query);
				if(te==null)
					output.println(success(graph.dbNodeWorker.getNeighbors(null,fac).toString()));
				else
					output.println(success(graph.dbNodeWorker.getNeighbors(te.getID(),fac).toString()));
			} else {
				String[] ids=id.split(",");
				if(ids.length==1)
					output.println(success(graph.dbNodeWorker.getNeighbors(ids[0],fac).toString()));
				else
					output.println(success(graph.dbNodeWorker.getRelationshipsBetween(ids,fac).toString()));
			}
			break;
			
		case "reference":
			if(path.length<3) {
				output.println(error("Choose one of: all, ranks"));
				output.flush();
				return;
			}
			StringBuilder rk=new StringBuilder();
			switch(path[2]) {
			case "all":
				jobj=new JsonObject();
				JsonObject ranks=new JsonObject();	// a map to convert rank numbers to names
				for(TaxonRanks e : Constants.TaxonRanks.values()) {
					ranks.addProperty(e.getValue().toString(), e.toString());
					rk.append("<option value=\""+e.getValue().toString()+"\">"+e.getName()+"</option>");
				}
				jobj.add("rankmap", ranks);
				jobj.addProperty("rankelement", rk.toString());
				
				ranks=new JsonObject();
				for(AllRelTypes art:Constants.AllRelTypes.values()) {
					ranks.addProperty(art.toString(), art.getFacet().toString());
				}
				jobj.add("facets", ranks);
				output.println(success(jobj.toString()));
					/*
				rk=new StringBuilder();
				
				for(TaxonomyRelTypes rt:TaxonomyRelTypes.values()) {
					rk.append("<option value=\""+rt.name()+"\">"+rt.name()+"</option>");
				}   			
				obj.put("reltypes", rk.toString());
				obj.put("success", true);
				out.println(obj.toJSONString());*/
				break;
				
			case "ranks":
				rk.append("<select name=\"rank\">");
				for(TaxonRanks e : Constants.TaxonRanks.values()) {
					rk.append("<option value=\""+e.getValue().toString()+"\">"+e.getName()+"</option>");
				}
				rk.append("</select>");
				output.println(rk.toString());
				break;
			}
			break;
			
		case "upload":
			if(path.length<3) {
				output.println(error("Choose one of: taxonomy, attributes or occurrences"));
				output.flush();
				return;
			}
			
			query=getQSValue("file",parameters);
			if(query==null || query.length()<1) {
				output.println(error("You must provide the full path to a local text file to upload."));
				output.flush();
				return;
			}

			switch(path[2]) {
			case "taxonomy":
				output.println(graph.dbDataUploader.uploadTaxonomyListFromFile(query, false));
				break;
				
			case "attributes":
				output.println(graph.dbDataUploader.uploadMorphologyFromFile(query));
				break;

			case "authors":
				output.println(graph.dbDataUploader.uploadAuthorsFromFile(query));
				break;
				
			case "occurrences":
				try {
					output.println(graph.dbDataUploader.uploadRecordsFromFile(query));
				} catch (FloraOnException e2) {
					// TODO Auto-generated catch block
					e2.printStackTrace();
				}
				break;
			default:
				output.println(error("Unrecognized command: "+path[2]));
				break;
			}
			break;
		
		case "links":
			if(path.length<3) {
				output.println(error("Choose one of: add, update"));
				output.flush();
				return;
			}
			
			switch(path[2]) {
			case "add":
				id=getQSValue("from",parameters);
				id2=getQSValue("to",parameters);
				String type=getQSValue("type",parameters);
				if(id==null || id.trim().length()<1 || id2==null || id2.trim().length()<1 || type==null) {
					output.println(error("You must provide relationship type and two document handles 'from' and 'to'"));
					output.flush();
					return;
				}

				GeneralNodeWrapperImpl n1=graph.dbNodeWorker.getNodeWrapper(id);
				GeneralNodeWrapperImpl n2=graph.dbNodeWorker.getNodeWrapper(id2);
				if(n1==null) {
					output.println(error("Node "+id+" not found."));
					output.flush();
					return;
				}
				if(n2==null) {
					output.println(error("Node "+id2+" not found."));
					output.flush();
					return;
				}
				try {
					output.println(success(
						n1.createRelationshipTo(n2.getNode(), AllRelTypes.valueOf(type.toUpperCase())).toString()
					));
				} catch (NoSuchMethodException | SecurityException | InstantiationException | IllegalAccessException
						| IllegalArgumentException | InvocationTargetException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
				break;
				
			case "update":
				id=getQSValue("id",parameters);
				current=getQSValue("current",parameters);
				output.println(success(
					graph.dbNodeWorker.UpdateDocument(id, "current", Integer.parseInt(current)==1).toString()
				));
				break;
			}
			break;

		case "nodes":
			if(path.length<3) {
				output.println(error("Choose one of: delete, add, update"));
				output.flush();
				return;
			}

			switch(path[2]) {
			case "delete":
				id=getQSValue("id",parameters);
				if(id==null || id.trim().length()<1) {
					output.println(error("You must provide a document handle as id"));
					output.flush();
					return;
				}

				output.println(success(EntityFactory.toJsonString(graph.dbNodeWorker.deleteNode(id))));
				break;
				
			case "add":
				if(path.length<4) {
					output.println(error("Choose the node type: taxent"));
					output.flush();
					return;
				}
				switch(path[3]) {
				case "taxent":
					name=getQSValue("name",parameters);
					author=getQSValue("author",parameters);
					rank=getQSValue("rank",parameters);
					
					output.println(success(
						graph.dbNodeWorker.createTaxEntNode(name, author, TaxonRanks.getRankFromValue(Integer.parseInt(rank)), null, true).toString()
					));
					break;
					
				case "attribute":
					name=getQSValue("name",parameters);
					shortName=getQSValue("shortname",parameters);
					description=getQSValue("description",parameters);
					
					output.println(success(
						graph.dbNodeWorker.createAttributeNode(name, shortName, description).toString()
					));
					break;
				
				case "character":
					name=getQSValue("name",parameters);
					shortName=getQSValue("shortname",parameters);
					description=getQSValue("description",parameters);
					
					output.println(success(
						graph.dbNodeWorker.createCharacterNode(name, shortName, description).toString()
					));
					break;
					
				default:
					output.println(error("Invalid node type"));
					output.flush();
					return;
				}
				break;
				
			case "update":
				if(path.length<4) {
					output.println(error("Choose the node type: taxent"));
					output.flush();
					return;
				}
				switch(path[3]) {
				case "taxent":
					name=getQSValue("name",parameters);
					author=getQSValue("author",parameters);
					rank=getQSValue("rank",parameters);
					comment=getQSValue("comment",parameters);
					current=getQSValue("current",parameters);
					
					output.println(success(
						graph.dbNodeWorker.updateTaxEntNode(TaxEnt.fromHandle(graph,getQSValue("id",parameters)), name, TaxonRanks.getRankFromValue(Integer.parseInt(rank)), Integer.parseInt(current)==1, author, comment).toString()
					));
					break;

				default:
					output.println(error("Invalid node type"));
					output.flush();
					return;
				}
			}
			break;

		case "occurrences":		// all options must return Occurrence lists!
			ResultProcessor<Occurrence> rpo=new ResultProcessor<Occurrence>(graph.getAllOccurrences());
			output.println(rpo.toCSVTable());
			break;

		case "specieslists":	// manage species lists (add, update, etc.)
			if(!(parameters instanceof JsonObject)) {
				output.println(error("You must POST a JSON document for these methods."));
				output.flush();
				return;
			}
			if(path.length<3) {
				output.println(error("Choose one of: add"));
				output.flush();
				return;
			}
			JsonObject jpar=(JsonObject) parameters;
			switch(path[2]) {
			case "add":		// add a species list
				try {
					if(jpar.has("list"))	// it's a list of species lists
						graph.dbDataUploader.addSpeciesLists(jpar.get("list").getAsJsonArray());
					else			// it's only one species list
						graph.dbDataUploader.addSpeciesLists(jpar);
				} catch (FloraOnException e) {
					output.println(error("Error: "+e.getMessage()));
				}
				break;
			}			
			break;
			
		default:
			output.println(error("Unknown command: "+path[1]));
			break;
		}
    	output.flush();
	}
}