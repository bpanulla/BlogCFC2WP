<cfcomponent output="false">

	<cffunction name="init" returntype="queryHelper" output="false">
		<cfreturn this/>
	</cffunction>

	<!------------------------- BlogCFC Helper methods ------------------------->

	<cffunction name="getCategories" returntype="query" output="false">

		<cfset var categories = ""/>

		<cfquery name="categories" datasource="#request.blogcfcDSN#">
			SELECT DISTINCT
				categoryname,
				categoryid,
				count(categoryname) as categoryCount
			FROM
				tblblogcategories
			INNER JOIN tblblogentriescategories ON (categoryidfk = categoryid)
			GROUP BY
				categoryname
  	</cfquery>

		<cfreturn categories/>

	</cffunction>

	<cffunction name="getPosts" returntype="query" output="false">

		<cfset var posts = ""/>

		<cfquery name="posts" datasource="#request.blogcfcDSN#">
			SELECT
				tblblogentries.*,
				(SELECT count(*) FROM tblblogcomments WHERE tblblogcomments.entryidfk = tblblogentries.id) as commentCount
			FROM
				tblblogentries
			ORDER BY
				released ASC, posted ASC
		</cfquery>

		<cfreturn posts/>

	</cffunction>

	<cffunction name="getPostCategories" returntype="query" output="false">
		<cfargument name="postId" type="string" required="true"/>

		<cfset var categories = ""/>

		<cfquery name="categories" datasource="#request.blogcfcDSN#">
			SELECT
				*
			FROM
				tblblogentriescategories
			WHERE
				entryidfk = <cfqueryparam value="#arguments.postId#" cfsqltype="cf_sql_varchar"/>
		</cfquery>

		<cfreturn categories/>

	</cffunction>

	<cffunction name="getPostComments" returntype="query" output="false">
		<cfargument name="postId" type="string" required="true"/>

		<cfset var comments = ""/>

		<cfquery name="comments" datasource="#request.blogcfcDSN#">
			SELECT
				*
			FROM
				tblblogcomments
			WHERE
				entryidfk = <cfqueryparam value="#arguments.postId#" cfsqltype="cf_sql_varchar"/>
		</cfquery>

		<cfreturn comments/>

	</cffunction>


	<!------------------------ Wordpress Helper methods ------------------------>
	<cffunction name="insertCategory" returntype="numeric" output="false">
		<cfargument name="categoryName" type="string" required="true"/>
		<cfargument name="postCount" type="numeric" required="true"/>

		<cfset var result = ""/>
		<cfset var categoryId = ""/>

		<cfquery datasource="#request.wpDSN#" result="result">
			INSERT INTO #request.wpTablePrefix#terms VALUES
			(
				<cfqueryparam value="0" cfsqltype="cf_sql_integer"/>,
				<cfqueryparam value="#arguments.categoryName#" cfsqltype="cf_sql_varchar"/>, <!--- name --->
				<cfqueryparam value="#arguments.categoryName#" cfsqltype="cf_sql_varchar"/>, <!--- slug --->
				<cfqueryparam value="0" cfsqltype="cf_sql_integer"/>  						 <!--- term_group --->
			)
		</cfquery>

		<cfset categoryId = result[request.queryLastId]/>

		<cfquery datasource="#request.wpDSN#">
			INSERT INTO #request.wpTablePrefix#term_taxonomy VALUES
			(
				<cfqueryparam value="0" cfsqltype="cf_sql_integer"/>,
				<cfqueryparam value="#categoryId#" cfsqltype="cf_sql_integer"/> , 		 <!--- termId --->
				<cfqueryparam value="category" cfsqltype="cf_sql_varchar"/>, 	  		 <!--- taxonomy --->
				<cfqueryparam value="category" cfsqltype="cf_sql_varchar"/>, 	  		 <!--- description --->
				<cfqueryparam value="0" cfsqltype="cf_sql_integer"/>,		      		 <!--- parent --->
				<cfqueryparam value="#arguments.postCount#" cfsqltype="cf_sql_integer"/> <!--- count --->
			)
		</cfquery>

		<cfreturn categoryId/>

	</cffunction>


	<cffunction name="insertPost" returntype="numeric" output="false">
		<cfargument name="post_date" type="string" required="true"/>
		<cfargument name="post_content" type="string" required="true"/>
		<cfargument name="post_title" type="string" required="true"/>
		<cfargument name="post_name" type="string" required="true"/>
		<cfargument name="post_status" type="numeric" required="true"/>
		<cfargument name="comment_status" type="numeric" required="true"/>
		<cfargument name="guid" type="string" required="yes"/>
		<cfargument name="comment_count" type="numeric" required="yes"/>

		<cfset var result = ""/>
		<cfset var dtFormat = "yyyy-mm-dd HH:mm:ss" />

		<cfquery datasource="#request.wpDSN#" result="result">
			INSERT INTO #request.wpTablePrefix#posts VALUES
			(
				<cfqueryparam value="0" cfsqltype="cf_sql_integer"/>,
				<cfqueryparam value="1" cfsqltype="cf_sql_integer"/>, 							                                  <!--- post_author --->
				<cfqueryparam value="#dateFormat(arguments.post_date,dtFormat)#" cfsqltype="cf_sql_timestamp"/>, 			      <!--- post_date --->
				<cfqueryparam value="#dateFormat(addGmtOffset(arguments.post_date),dtFormat)#" cfsqltype="cf_sql_timestamp"/>,    <!--- post_date_gmt --->
				<cfqueryparam value="#arguments.post_content#" cfsqltype="cf_sql_longvarchar"/>,                                  <!--- post_content --->
				<cfqueryparam value="#arguments.post_title#" cfsqltype="cf_sql_varchar"/>, 		                                  <!--- post_title  --->
				<cfqueryparam value="" cfsqltype="cf_sql_varchar"/>, 							                                  <!--- post_excerpt --->
				<cfqueryparam value="#iif(arguments.post_status eq 1, de('publish'), de('draft'))#" cfsqltype="cf_sql_varchar"/>, <!--- post_status --->
				<cfqueryparam value="#iif(arguments.post_status eq 1, de('open'), de('closed'))#" cfsqltype="cf_sql_varchar"/>,   <!--- comment_status --->
				<cfqueryparam value="Open" cfsqltype="cf_sql_varchar"/>, 						                                  <!--- ping_status  --->
				<cfqueryparam value="" cfsqltype="cf_sql_varchar"/>, 							                                  <!--- post_password  --->
				<cfqueryparam value="#arguments.post_name#" cfsqltype="cf_sql_varchar"/>, 		                                  <!--- post_name --->
				<cfqueryparam value="" cfsqltype="cf_sql_varchar"/>, 							                                  <!--- to_ping --->
				<cfqueryparam value="" cfsqltype="cf_sql_varchar"/>, 							                                  <!--- pinged --->
				<cfqueryparam value="#arguments.post_date#" cfsqltype="cf_sql_varchar"/>, 		                                  <!--- post_modified --->
				<cfqueryparam value="#arguments.post_date#" cfsqltype="cf_sql_varchar"/>, 		                                  <!--- post_modified_gmt --->
				<cfqueryparam value="" cfsqltype="cf_sql_varchar"/>, 							                                  <!--- post_content_filtered --->
				<cfqueryparam value="0" cfsqltype="cf_sql_integer"/>, 							                                  <!--- post_parent --->
				<cfqueryparam value="#arguments.guid#" cfsqltype="cf_sql_varchar"/>, 			                                  <!--- guid --->
				<cfqueryparam value="0" cfsqltype="cf_sql_integer"/>, 							                                  <!--- menu_order --->
				<cfqueryparam value="post" cfsqltype="cf_sql_varchar"/>, 						                                  <!--- post_type --->
				<cfqueryparam value="" cfsqltype="cf_sql_varchar"/>, 							                                  <!--- post_mime_type --->
				<cfqueryparam value="#arguments.comment_count#" cfsqltype="cf_sql_integer"/>	                                  <!--- comment_count --->
			)
		</cfquery>

		<cfreturn result[request.queryLastId]/>

	</cffunction>

	<cffunction name="insertCategoryLink" returntype="void" output="false">
		<cfargument name="post_ID" type="numeric" required="true"/>
		<cfargument name="category_ID" type="string" required="true"/>
		<cfargument name="category_order" type="numeric" required="true"/>
	
		<cfquery datasource="#request.wpDSN#">
			INSERT INTO #request.wpTablePrefix#term_relationships VALUES
			(
				<cfqueryparam value="#arguments.post_ID#" cfsqltype="cf_sql_integer"/>, <!--- object_id --->
				<cfqueryparam value="#arguments.category_ID#" cfsqltype="cf_sql_integer"/>,	  <!--- term_taxonomy_id --->
				<cfqueryparam value="#arguments.category_order#" cfsqltype="cf_sql_integer"/> <!--- term_order --->
			)
		</cfquery>

	</cffunction>


	<cffunction name="insertComment" returntype="void" output="false">
		<cfargument name="comment_post_ID" type="numeric" required="true"/>
		<cfargument name="comment_author" type="string" required="true"/>
		<cfargument name="comment_author_email" type="string" required="true"/>
		<cfargument name="comment_author_url" type="string" required="true"/>
		<cfargument name="comment_author_IP" type="string" required="true"/>
		<cfargument name="comment_date" type="string" required="true"/>
		<cfargument name="comment_content" type="string" required="true"/>

		<cfquery datasource="#request.wpDSN#">
			INSERT INTO #request.wpTablePrefix#comments VALUES
			(
				<cfqueryparam value="0" cfsqltype="cf_sql_integer"/>,
				<cfqueryparam value="#arguments.comment_post_ID#" cfsqltype="cf_sql_integer"/>, 	    <!--- comment_post_ID --->
				<cfqueryparam value="#arguments.comment_author#" cfsqltype="cf_sql_varchar"/>, 		    <!--- comment_author --->
				<cfqueryparam value="#arguments.comment_author_email#" cfsqltype="cf_sql_varchar"/>,    <!--- comment_author_email --->
				<cfqueryparam value="#arguments.comment_author_url#" cfsqltype="cf_sql_varchar"/>, 	    <!--- comment_author_url --->
				<cfqueryparam value="#arguments.comment_author_IP#" cfsqltype="cf_sql_varchar"/>, 	    <!--- comment_author_IP --->
				<cfqueryparam value="#dateFormat(arguments.comment_date,"yyyy-mm-dd HH:mm:ss")#" cfsqltype="cf_sql_timestamp"/>, 			    <!--- comment_date --->
				<cfqueryparam value="#addGmtOffset(arguments.comment_date)#" cfsqltype="cf_sql_date"/>, <!--- comment_date_gmt --->
				<cfqueryparam value="#arguments.comment_content#" cfsqltype="cf_sql_longvarchar"/>,     <!--- comment_content --->
				<cfqueryparam value="0" cfsqltype="cf_sql_integer"/>, 								    <!--- comment_karma --->
				<cfqueryparam value="1" cfsqltype="cf_sql_varchar"/>, 								    <!--- comment_approved --->
				<cfqueryparam value="" cfsqltype="cf_sql_varchar"/>, 								    <!--- comment_agent --->
				<cfqueryparam value="" cfsqltype="cf_sql_varchar"/>, 								    <!--- comment_type --->
				<cfqueryparam value="0" cfsqltype="cf_sql_integer"/>, 								    <!--- comment_parent --->
				<cfqueryparam value="1" cfsqltype="cf_sql_integer"/>  								    <!--- user_id --->
			)
		</cfquery>

	</cffunction>


	<!--- Utility methods --->

	<cffunction name="addGmtOffset" returntype="string" output="false">
		<cfargument name="dateValue" type="string" required="true"/>

		<cfif isDate(arguments.dateValue)>
			<cfreturn dateAdd("h", request.GMTOffset, arguments.dateValue)/>
		</cfif>

		<!--- Just return the original junk if it's not a valid date --->
		<cfreturn arguments.dateValue/>

	</cffunction>

</cfcomponent>