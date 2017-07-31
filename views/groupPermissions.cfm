<cfscript>
    groupID = $.event('groupid');
    groupName = getGroupName(groupID);
    q = getPermissions(groupID);
    
    function getGroupName(required string groupID) {
        var siteID = session.siteid;
        var q = queryExecute(
            "SELECT GroupName FROM tusers WHERE UserID = :groupID",
            { groupID = groupID });
        var name = '';
        if (q.recordCount)
            name = q.GroupName[1];
        return name;
    }

    function getPermissions(required string groupID) {
        var siteID = session.siteid;
        return queryExecute(
            "SELECT p.ContentID, p.Type, p.SiteID, c.Title, c.ContentHistID, c.ModuleID,
            ParentTitle = (SELECT Title FROM tcontent WHERE ContentID = c.ParentID AND Active = 1 AND SiteID = :siteID)
            FROM tpermissions p, tcontent c
            WHERE p.GroupID = :groupID AND p.SiteID = :siteID AND c.ContentID = p.ContentID AND c.Active = 1 AND c.SiteID = :siteID ORDER BY c.Title",
            { groupID = groupID, siteID = siteID });
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
                <th>Parent</th>
                <th>Permission</th>
            </tr>
        </thead>
        <tbody>
            <cfloop query="q">
                <cfset editContentURL = "#$.globalConfig('context')#/admin/?muraAction=cArch.edit&amp;contenthistid=#ContentHistID#&amp;siteid=#SiteID#&amp;contentid=#ContentID#">
                <cfset permType = (Type eq 'module' ? 'module' : 'main')>
                <cfset editPermURL = "#$.globalConfig('context')#/admin/?muraAction=cPerm.#permType#&amp;contentid=#ContentID#&amp;siteid=#SiteID#&amp;moduleid=#ModuleID#">
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
                                <cfif Type neq 'module'>
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
                    <td><a href="#editPermURL#">#encodeForHTML(ParentTitle)#</a></td>
                    <td><a href="#editPermURL#">#encodeForHTML(Type)#</a></td>
                </tr>
            </cfloop>
        </tbody>
    </table>
</cfoutput></cfsavecontent>

<cfinclude template="layout.cfm">
