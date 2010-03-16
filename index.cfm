<cfsilent>
<cfsetting requesttimeout="60000" showdebugoutput="false"/>

<cfset queryHelper = createObject("component","queryHelper").init()/>
<cfset categoryMappings = structNew()/>
<cfset commentsImported = 0/>

<!--- Migrate categories --->
<cfset categories = queryHelper.getCategories()/>

<cfloop query="categories">

	<cfset newCategoryId = queryHelper.insertCategory(categories.categoryname,
													  categories.categoryCount)/>

	<cfset categoryMappings[categories.categoryId] = newCategoryId/>

</cfloop>


<!--- Migrate posts --->
<cfset posts = queryHelper.getPosts()/>

<cfloop query="posts">

	<cfset postURL = ""/>

	<!--- Format the blog post URL if necessary --->
	<cfif structKeyExists(request, "blogURLFormat")>

		<cfset postURL = replace(request.blogURLFormat,"%year%",year(posts.posted))/>
		<cfset postURL = replace(postURL,"%month%",dateFormat(posts.posted,"mm"))/>
		<cfset postURL = replace(postURL,"%day%",dateFormat(posts.posted, "dd"))/>
		<cfset postURL = replace(postURL,"%title%",posts.alias)/>

	</cfif>

	<!--- Migrate Posts --->

	<cfset postId = queryHelper.insertPost(posts.posted,
										   posts.body,
										   posts.title,
										   posts.alias,
										   categoryMappings[posts.categoryidfk],
										   posts.released,
										   posts.allowcomments,
										   postURL,
										   posts.commentCount)/>

	<cfset commentsImported += posts.commentCount/>

	<!--- Migrate Comments --->

	<cfset comments = queryHelper.getPostComments(posts.id)/>

	<cfif comments.recordCount>

		<cfloop query="comments">

			<cfset queryHelper.insertComment(postId,
											 comments.name,
											 comments.email,
											 comments.website,
											 "",
											 comments.posted,
											 comments.comment)/>
		</cfloop>

	</cfif>

</cfloop>
</cfsilent>
<html>
<head>
	<title>BlogCFC - Wordpress Conversion</title>
	<style>
		body{
			font-family:"Trebuchet MS";
			font-size:14px;
		}
		th{
			background-color:#0099CC;
			color:#FFFFFF;
		}
		td{
			background-color:#0099FF;
			color:#FFFFFF;
			text-align:center;
		}
		table{
			width:50%;
			border:0;
		}
		p{
			font-weight:bold;
			color:#FF0000;
		}
	</style>
</head>
<body>
<p>Import complete</p>
<table>
	<tr>
		<th>Categories Imported</td>
		<th>Posts Imported</td>
		<th>Comments Imported</td>
	</tr>
	<cfoutput>
	<tr>
		<td>#categories.recordCount#</td>
		<td>#posts.recordCount#</td>
		<td>#commentsImported#</td>
	</tr>
	</cfoutput>
</table>
</body>
</html>