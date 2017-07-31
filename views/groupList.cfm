<cfscript>
    include '../plugin/settings.cfm';

    q = getGroups();
    siteID = session.siteid;
    
    function getGroups() {
        var settingsManager = application.settingsManager;
        var site = settingsManager.getSite(session.siteid);
        var privatePoolID = site.getPrivateUserPoolID();
        var publicPoolID = site.getPublicUserPoolID();
        return queryExecute("SELECT UserID, GroupName, Email, isPublic FROM tusers
            WHERE Type=1 AND ((isPublic = 0 AND SiteID = :privatePoolID) OR
            (isPublic = 1 AND SiteID = :publicPoolID)) ORDER BY GroupName",
            {
                privatePoolID = privatePoolID,
                publicPoolID = publicPoolID
            });
    }
</cfscript>

<cfsavecontent variable="topButtons"><cfoutput>
    <a class="btn" title="Mura Member Group List" href="#$.globalConfig('context')#/admin/index.cfm?muraAction=cusers.list&amp;ispublic=1">
        <i class="mi-group"></i> Mura Member Group List
    </a>
    <a class="btn" title="Mura System Group List" href="#$.globalConfig('context')#/admin/index.cfm?muraAction=cusers.list&amp;ispublic=0">
        <i class="mi-group"></i> Mura System Group List
    </a>
    <cfset pluginConfig = $.getPlugin(settings.pluginName)>
    <cfset moduleid = pluginConfig.getValue('moduleid')>
    <a class="btn" title="Plugin Permissions" href="#$.globalConfig('context')#/admin/?muraAction=cPerm.module&amp;contentid=#moduleid#&amp;siteid=#siteID#&amp;moduleid=#moduleid#">
        <i class="mi-key"></i> Plugin Permissions
    </a>
</cfoutput></cfsavecontent>

<cfsavecontent variable="body"><cfoutput>
    <table class="mura-table-grid">
        <thead>
            <tr>
                <th class="actions"></th>
                <th class="var-width">Group Name</th>
                <th>Email</th>
                <th>Type</th>
            </tr>
        </thead>
        <tbody>
            <cfloop query="q">
                <cfset permURL = "./?action=permissions&amp;groupid=#UserID#">
                <cfset editURL = "#$.globalConfig('context')#/admin/index.cfm?muraAction=cusers.editgroup&amp;userid=#UserID#&amp;siteid=#siteID#">
                <cfset usersURL = "#$.globalConfig('context')#/admin/index.cfm?muraAction=cusers.editgroupmembers&amp;userid=#UserID#&amp;siteid=#siteID#">
                <tr>
                    <td class="actions">
                        <a class="show-actions" href="javascript:;" ontouchstart="this.onclick();" onclick="showTableControls(this);"><i class="mi-ellipsis-v"></i></a>
                        <div class="actions-menu hide">
                            <ul class="actions-list">
                                <li class="edit">
                                    <a href="#permURL#">
                                        <i class="mi-key"></i>Permissions
                                    </a>
                                </li>
                                <li class="edit">
                                    <a href="#editURL#">
                                        <i class="mi-pencil"></i>Edit
                                    </a>
                                </li>
                                <li class="edit">
                                    <a href="#usersURL#">
                                        <i class="mi-users"></i>View Users
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </td>
                    <td class="var-width"><a href="#permURL#">#encodeForHTML(GroupName)#</a></td>
                    <td><a href="#permURL#">#encodeForHTML(Email)#</a></td>
                    <td><a href="#permURL#">#isPublic ? "Member" : "System"#</a></td>
                </tr>
            </cfloop>
        </tbody>
    </table>
</cfoutput></cfsavecontent>

<cfinclude template="layout.cfm">
