#!groovy
String workspace;


def inputVariables = new InputVariables(this);

node ('master') {

	inputVariables.inputEnvironment();
	workspace = pwd()
	
	// First of all, checkout.
	// Or properties won't be set
		
	stage ('Checkout') {
		
		echo "Checkout scm"
		checkout scm
		echo "Workspace=${workspace}"
		
	}

	def project = new Project(this, inputVariables.environment);
	project.loadAppProperties();
	project.loadEnvProperties();
	
	def mvnHome = tool project.mavenTool;
	workspace = pwd()
	
	// Mark the code build 'stage'....
 
	stage ('Build Code') {
  
		 //Define the suitable JDK
		 //env.JAVA_HOME="${tool 'JDK6'}"
		 env.JAVA_HOME="${tool project.jdkTool}"
		 env.PATH="${env.JAVA_HOME}/bin:${env.PATH}"
  
		 sh 'java -version'
		 
		 // Run the maven build
		 // Use "-f ${project.artifactName}" to build a project that
		 // resides in ${project.artifactName} directory
		 sh "${mvnHome}/bin/mvn  clean -U assembly:assembly"
	}
				  
								 
						
																									   
	
	stage ('Deploy Artifact') {
  
  
		echo "workspace=${workspace}"

		sh 'cd ${workspace}'
		
		// Set ssh key '-i'
		// and skip "The authenticity of host 'blah.blah.blah'" 
		SSH_OPT="-i /var/jenkins_home/.ssh/docker_rsa -oStrictHostKeyChecking=no";
		
		sh "ssh ${SSH_OPT} ${project.swarmMaster} 'mkdir -p ${workspace}/target'"

		// copy enviroment
		sh "scp ${SSH_OPT} ./app.properties ${project.swarmMaster}:${workspace}/app.properties"
		sh "scp ${SSH_OPT} ./env.properties ${project.swarmMaster}:${workspace}/env.properties"
		
		// copy docker files
		sh "scp -rp ${SSH_OPT} ./docker ${project.swarmMaster}:${workspace}"
	
		sh "scp ${SSH_OPT} ./Dockerfile ${project.swarmMaster}:${workspace}/Dockerfile"

		// copy artifacts
		sh "find . -name \"*.war\" -exec scp ${SSH_OPT} {} ${project.swarmMaster}:${workspace}/target \\;"
		sh "find . -name \"*.zip\" -exec scp ${SSH_OPT} {} ${project.swarmMaster}:${workspace}/target \\;"
	}	
 
}

node('lsltsat2.8798.1286.ecs.hp.com') {
	
	def project = new Project(this,inputVariables.environment);
	def mailer = new Mailer(this);
	project.loadAppProperties();
	project.loadEnvProperties();


	stage ('Push Docker') {
	
		echo 'Myself starting'
	
		// debug
		sh 'pwd'
		sh 'whoami'
			
		echo "artifactName=${project.artifactName}"

																			  
		sh project.buildService();
		sh project.pushService();

/*		
		sh "rm -f Dockerfile"
		sh "rm -rf target"
*/		
	}
	
	stage ('Service Deploy') {
  
		if (project.isQaServiceCreated()) {
		 sh project.removeQaService();
		}
		sh project.createQaService();
	}	
	
	stage ('Service QA/Testing') {
  
	 sh project.updateQaService(); 
  
		mailer.sendMessage("QA/Testing new Release "+project.version+" of "+project.serviceName,"A new version of "+project.serviceName+" has been deployed, version: "+project.version+ ". please validate it for promotion of the new release",project.emailRecipients);
	}	
	
	stage ('Service Promotion') {  
 
	 promotion = inputVariables.validateQA();
  
	 if (promotion == 'true') {
   
								  
										   
							 
		 if (project.isPublicServiceCreated()) {
			 sh project.publishPublicService();
		 } else {
			 sh project.createPublicService();
		 }
	 }
  
	 sh project.removeQaService();
	}		
}

class Logger implements Serializable {

	Project project;

	Logger(Project project) {
		 this.project = project;
	}

	void log(String message) {
		 String dateTime = new Date().format( 'dd/MM/yyyy - hh:mm' ).toString();
		 project.echo dateTime + ' - ' + message;
	}

	void info(String message) {
		 log("[INFO] " + message)
	}

	void warning(String message) {
		 log("[WARNING] " + message)
	}

	void logBreak() {
		 log "------- Break ------"
	}
}

class Mailer implements Serializable {
 
	String recipients;
	def pipeline;
	
	Mailer(pipeline) {
		 this.pipeline=pipeline;		 
	}
	
	void sendMessage(subject,message,recipients){
		 pipeline.sh "echo "+message+" | mail -s \""+subject+"\" "+recipients;
	}
}

class Project implements Serializable {

	String artifactName;
	String imageName;
	String registryURL;
	String swarmMaster;
	String version;
	String mavenTool;
	String jdkTool;
	String serviceName;
	String serviceDomain;
	String servicePath;
	String servicePort;
	String emailRecipients;
	String logsPath;
  
	
	def pipeline;
	def properties;
	def envProperties;
	
	def environment;
	
	Logger logger;
	
	
	Project(pipeline, environment) {
		 this.pipeline = pipeline;
		 this.environment = environment;
		 this.logger = new Logger(this);
	}
	
	void echo(msg) {
		 pipeline.echo(msg);
	}
	
	void loadAppProperties() {
		 def defaultValues = [
		artifactName: '', 
		imageName: '', 
		registryURL: '', 
		swarmMaster: '', 
		version: '', 
		mavenTool: '', 
		jdkTool: '', 
		serviceName: '', 
		serviceDomain: '', 
		servicePath: '', 
		servicePort: '8080', 
		emailRecipients: 'email@example.com', 
		logsPath: '/logs']
		 
	   
		 pipeline.sh 'hostname'
  
		 pipeline.sh 'pwd'
		 
		 pipeline.sh 'ls -la'
	 
  
		 properties = pipeline.readProperties defaults: defaultValues, file: 'app.properties', text: ''
		   
			
		 artifactName = properties['artifactName'];
		 imageName = properties['imageName'];
		 registryURL = properties['registryURL'];
		 swarmMaster = properties['swarmMaster'];
		 version = properties['version'];
		 mavenTool = properties['mavenTool'];
		 jdkTool = properties['jdkTool'];
		 serviceName = properties['serviceName'];
		 serviceDomain = properties['serviceDomain'];
		 servicePath = properties['servicePath'];
		 servicePort = properties['servicePort'];
		emailRecipients = properties['emailRecipients'];
		logsPath =  properties['logsPath'];
										   
		 this.logger.info 'artifactName='+artifactName;
		 this.logger.info 'imageName='+imageName;
		 this.logger.info 'registryURL='+registryURL;
		 this.logger.info 'swarmMaster='+swarmMaster;
		 this.logger.info 'version='+version;
		 this.logger.info 'jdkTool='+jdkTool;
										   
		 this.logger.info 'serviceName='+serviceName;
		 this.logger.info 'serviceDomain='+serviceDomain;
		 this.logger.info 'servicePath='+servicePath;
		 this.logger.info 'servicePort='+servicePort;
		this.logger.info 'emailRecipients='+emailRecipients;
		this.logger.info 'logsPath='+logsPath;
	}
	
	void loadEnvProperties() {
		envProperties = pipeline.readProperties file: 'env.properties', text: ''
		pipeline.printProperties(envProperties);

		def keys = pipeline.getKeyEnvProperties(envProperties,environment);

		pipeline.printProperties(keys);

		envProperties = keys;
 
	}
	
	void buildService() {
		String buildScriptService="docker build -t "+registryURL+"/"+imageName+":"+version+" .";
		this.logger.info buildScriptService;
		return buildScriptService;
	}
	
	void pushService() {
		String pushScriptService="docker push "+registryURL+"/"+imageName+":"+version;
		this.logger.info pushScriptService;
		return pushScriptService;
	}
	
	void isQaServiceCreated() {
		boolean created=false;
		String isServiceCreatedScript="docker service ls | grep "+environment+"-"+serviceName+"-"+version+" | wc -l";
		this.logger.info isServiceCreatedScript;
		//def out = sh script: isServiceCreatedScript, returnStdout: true
		pipeline.sh isServiceCreatedScript+" > status";
		pipeline.sh "cat status";
		def out = pipeline.readFile('status').trim();
		echo "out="+out;
		if (Integer.parseInt(out) >0) {
			created = true;
		}
		echo "created="+created;
		return created;
	}
	
	void isPublicServiceCreated() {
		boolean created=false;
		String isServiceCreatedScript="docker service ls | grep "+environment+"-"+serviceName+"-app | wc -l";
		this.logger.info isServiceCreatedScript;
		//def out = sh script: isServiceCreatedScript, returnStdout: true
		pipeline.sh isServiceCreatedScript+" > status";
		pipeline.sh "cat status";
		def out = pipeline.readFile('status').trim();
		echo "out="+out;
		if (Integer.parseInt(out) >0) {
			created = true;
		}
		echo "created="+created;
		return created;
	}
	
	void createQaService() {
		String createScriptService="docker service create --name "+environment+"-"+serviceName+"-"+version+" --network "+environment+"_"+serviceName+" --network "+environment;
		String labels=" --label com.df.distribute=true --label com.df.port="+servicePort+" --label com.df.servicePath="+servicePath+" --label com.df.serviceDomain="+serviceName+".qa."+serviceDomain;
		String volum=" --mount type=volume,source="+environment+"-"+serviceName+"-"+version+",destination="+logsPath;
		String resourceLimits="--limit-memory 1Gb --limit-cpu 1.0";
		String constraint="node.labels.entorn=="+environment;
		String constraints=" --constraint=\'${constraint}\'";
		createScriptService=createScriptService+" "+setEnvironmentVars();
		createScriptService=createScriptService+" "+labels+" "+constraints+" "+resourceLimits+" "+volum+" --with-registry-auth "+registryURL+"/"+imageName+":"+version;
		createScriptService=createScriptService+" "+labels+" "+constraints+" "+resourceLimits+" "+volum+" --with-registry-auth "+registryURL+"/"+imageName+":"+version;
		createScriptService=createScriptService+" "+labels+" "+constraints+" "+resourceLimits+" "+volum+" --with-registry-auth "+registryURL+"/"+imageName+":"+version;
		this.logger.info createScriptService;
		return createScriptService;
	}
	
	void createPublicService() {
		echo "entro a publicar servei";
		String createScriptService="docker service create --name "+environment+"-"+serviceName+"-app --network "+environment+"_"+serviceName+" --network "+environment;
		String labels=" --label com.df.distribute=true --label com.df.notify=true --label com.df.port="+servicePort+" --label com.df.servicePath="+servicePath+" --label com.df.serviceDomain="+serviceName+"."+serviceDomain;
		String volum=" --mount type=volume,source="+environment+"-"+serviceName+"-app,destination="+logsPath;;
		String resourceLimits="--limit-memory 2Gb --limit-cpu 2.0";
		String constraint="node.labels.entorn=="+environment;
		String constraints=" --constraint=\'${constraint}\'";
		 createScriptService=createScriptService+" "+setEnvironmentVars();
		 createScriptService=createScriptService+" "+labels+constraints+" "+resourceLimits+" "+volum+" --with-registry-auth "+registryURL+"/"+imageName+":"+version;
		this.logger.info createScriptService;
		return createScriptService;
	}
	
	void updateQaService() {
		String updateScriptService="docker service update --label-add com.df.notify=true "+environment+"-"+serviceName+"-"+version;
		this.logger.info updateScriptService;
		return updateScriptService;
	}
	
	void removeQaService() {
		String removeScriptService="docker service remove "+environment+"-"+serviceName+"-"+version;
		this.logger.info removeScriptService;
		return removeScriptService;
	}
	
	void publishPublicService() {
		String updateScriptService="docker service update "+environment+"-"+serviceName+"-app --image "+registryURL+"/"+imageName+":"+version+"";
		this.logger.info updateScriptService;
		return updateScriptService;
	}
	

	void setEnvironmentVars() {
		return pipeline.createEnvLabels(envProperties);
	}
	
}

class InputVariables implements Serializable {
	 
	String environment="pre";
	
	def pipeline;
	def properties;

	
							  
								 
	 
	
					
						   
	 
	
							   
							   
								 
			 
														
																																					  
																																								  
									
										  
				 
										
			 
														
												   
																	  
								  
									
					
											
			 
		 
										
	 
	
	InputVariables(pipeline) {
		 this.pipeline = pipeline;
	}
	
	void echo(msg) {
		 pipeline.echo(msg);
	}
	
	public inputEnvironment() {
		 def didTimeout = false;
		 String environment="pre";
		 try {
				pipeline.timeout(time: 1, unit: 'SECONDS') {
					String environ = pipeline.input message:'Choose environment: pre/pro default=pre',  
					parameters: [[$class: 'TextParameterDefinition', name: 'Environment', defaultValue: "pre", description: "Environment properties for the service"]]
					if (environ!=null) {
						 environment = environ;
					}
					echo "environ="+environ;
				}
		 } catch(err) { // timeout reached or input false
				def user = err.getCauses()[0].getUser()
				if('SYSTEM' == user.toString()) { // SYSTEM means timeout.
					didTimeout = true;
					environment = "cld";
				} else {
					echo "Aborted by: [${user}]"
				}
		 }
		 echo "environment="+environment;
	}
	
	 public validateQA() {
		 def didTimeout = false;
		 String promotion="true";
		 try {
				pipeline.timeout(time: 3600, unit: 'SECONDS') {
					String result = pipeline.input message:'Confirm QA was OK and release can be promoted',  
					parameters: [[$class: 'TextParameterDefinition', name: 'promotion', defaultValue: "true", description: "Confirmation QA Tests for new release "]]
					if (promotion!=null) {
						 promotion = result;
					}
					echo "promotion="+promotion;
				}
		 } catch(err) { // timeout reached or input false
				def user = err.getCauses()[0].getUser()
				if('SYSTEM' == user.toString()) { // SYSTEM means timeout.
					didTimeout = true;
					promotion = "false";
				} else {
					echo "Aborted by: [${user}]"
				}
		 }
		 echo "promotion="+promotion;
		return promotion;
	}
}

@NonCPS
def printProperties(envProperties) {
 for (property in envProperties) {
				echo "property[${property.key}]=${property.value}"
		}
}

@NonCPS
def getKeyEnvProperties(envProperties,env) {
 def environmentVars = new Properties();
 for (property in envProperties) {
	String key = property.key;
	String[] envKey = key.tokenize('.');
	String envK = envKey[0];
	String elem = envKey[1];
	if (envK==env) {
		environmentVars.setProperty(elem,property.value);
	}
 }
 return environmentVars;
}

@NonCPS
def createEnvLabels(envProperties) {
 String envLabels="";
 echo "entering create env variables";
 for (property in envProperties) {
				envLabels+="-e ${property.key}=${property.value} ";
				echo "${property.key}";
				echo "${property.value}";
 }
 echo "exiting create env variables";
 return envLabels;
}
