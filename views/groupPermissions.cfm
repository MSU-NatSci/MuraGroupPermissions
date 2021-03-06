<cfif getBaseTemplatePath() eq getCurrentTemplatePath()>
    Direct execution denied.
    <cfabort>
</cfif>

<cfscript>
    groupID = $.event('groupid');
    groupName = getGroupName(groupID);
    q = getPermissions(groupID);
    addRestrictedAccess($, q, groupName);
    
    function getGroupName(required string groupID) {
        var q = queryExecute(
            "SELECT GroupName FROM tusers WHERE UserID = :groupID",
            { groupID = groupID });
        var name = '';
        if (q.recordCount)
            name = q.GroupName[1];
        return name;
    }

    function getPermissions(required string groupID) {
        return queryExecute(
            "SELECT p.ContentID, p.Type, p.SiteID, c.Title, c.ContentHistID, c.ModuleID, c.Type AS contentType,
            (SELECT Title FROM tcontent WHERE ContentID = c.ParentID AND Active = 1 AND SiteID = p.SiteID) AS ParentTitle
            FROM tpermissions p, tcontent c
            WHERE p.GroupID = :groupID AND c.SiteID = p.SiteID AND c.ContentID = p.ContentID AND c.Active = 1 ORDER BY c.Title",
            { groupID = groupID });
    }

    function addRestrictedAccess(required any $, required query q, required string groupName) {
        var dbType = $.getConfigBean().getDbType();
        var subquery = '';
        if (dbType == 'mssql')
            subquery = "SELECT TOP 1 Title FROM tcontent WHERE
            ContentID = c.ParentID AND Active = 1";
        else if (dbType == "oracle")
            subquery = "SELECT Title FROM tcontent WHERE
            ContentID = c.ParentID AND Active = 1 WHERE ROWNUM <= 1";
        else
            subquery = "SELECT Title FROM tcontent WHERE
            ContentID = c.ParentID AND Active = 1 LIMIT 1";
        var q2 = queryExecute(
            "SELECT c.ContentID, c.SiteID, c.Title, c.ContentHistID, c.ModuleID,
            (#subquery#) AS ParentTitle
            FROM tcontent c
            WHERE c.RestrictGroups LIKE :likeName AND Active = 1
            ORDER BY c.Title",
            { likeName = "%#groupName#%" });
        // let's hope there is no % or [] in the group name
        // eventually Mura should switch to using IDs
        // see https://github.com/blueriver/MuraCMS/issues/2627
        for (row in q2) {
            queryAddRow(q, {
                'ContentID' = row.ContentID,
                'Type' = 'restriction',
                'SiteID' = row.SiteID,
                'Title' = row.Title,
                'ContentHistID' = row.ContentHistID,
                'ModuleID' = row.ModuleID,
                'ParentTitle' = row.ParentTitle
            });
        }
    }
</cfscript>

<cfsavecontent variable="topButtons"><cfoutput>
    <a class="btn" href="./">
        <i class="mi-arrow-circle-left"></i> Group List
    </a>
</cfoutput></cfsavecontent>

<cfsavecontent variable="body"><cfoutput>
    <h2>Permissions for #groupName#</h2>
    <table class="mura-table-grid">
        <thead>
            <tr>
                <th class="actions"></th>
                <th class="var-width">Content Title</th>
                <th>Site ID</th>
                <th>Parent</th>
                <th>Permission</th>
            </tr>
        </thead>
        <tbody>
            <cfloop query="q">
                <!--- ignoring some default values for Components, Forms and Home --->
                <cfif (ContentID neq '00000000000000000000000000000000003' || Type neq 'deny') &&
                        (ContentID neq '00000000000000000000000000000000004' || Type neq 'deny') &&
                        (ContentID neq '00000000000000000000000000000000001' || Type neq 'read')>
                    <cfset editContentURL = "#$.globalConfig('context')#/admin/?muraAction=cArch.edit&amp;contenthistid=#ContentHistID#&amp;siteid=#SiteID#&amp;contentid=#ContentID#">
                    <cfif Type eq 'restriction'>
                        <cfset editPermURL = "#editContentURL###tabPublishing">
                    <cfelse>
                        <cfset permType = (Type eq 'module' ? 'module' : 'main')>
                        <cfset editPermURL = "#$.globalConfig('context')#/admin/?muraAction=cPerm.#permType#&amp;contentid=#ContentID#&amp;siteid=#SiteID#&amp;moduleid=#ModuleID#">
                    </cfif>
                    <tr>
                        <td class="actions">
                            <a class="show-actions" href="javascript:;" ontouchstart="this.onclick();" onclick="showTableControls(this);"><i class="mi-ellipsis-v"></i></a>
                            <div class="actions-menu hide">
                                <ul class="actions-list">
                                    <li class="edit">
                                        <a href="#editPermURL#">
                                            <i class="mi-pencil"></i>Edit Permission
                                        </a>
                                    </li>
                                    <cfif Type neq 'module' and contentType neq 'Module'>
                                        <li class="edit">
                                            <a href="#editContentURL#">
                                                <i class="mi-pencil"></i>Edit Content
                                            </a>
                                        </li>
                                    </cfif>
                                </ul>
                            </div>
                        </td>
                        <td class="var-width"><a href="#editPermURL#">#encodeForHTML(Title)#</a></td>
                        <td><a href="#editPermURL#">#encodeForHTML(SiteID)#</a></td>
                        <td><cfif Type neq 'module'><a href="#editPermURL#">#encodeForHTML(ParentTitle)#</a></cfif></td>
                        <td><a href="#editPermURL#">#encodeForHTML(Type)#</a></td>
                    </tr>
                </cfif>
            </cfloop>
        </tbody>
    </table>
</cfoutput></cfsavecontent>

<cfinclude template="layout.cfm">
