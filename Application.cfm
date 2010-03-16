<cfapplication name="blogCFCConvertor"/>

<cfscript>
	//BlogCFC CF datasource name
	request.blogcfcDSN = "blogcfc";

	//Wordpress CF datasource name
	request.wpDSN = "wordpress";

	//Wordpress database table prexif (empty string for no prefix)
	request.wpTablePrefix = "wp_";

	//Offset (hours) applied to post & comment dates
	request.GMTOffset = 0;

	request.queryLastId = "GENERATED_KEY";


	//Uncomment below this line to preserve your blogcfc post URL's

	//No trailing slash
	request.blogURL = "";

	//Blog URL format string
	//request.blogURLFormat = "#request.blogURL#/index.cfm/%year%/%month%/%day%/%title%";

</cfscript>