<!--- This template handles the layout for all pages in the plugin --->

<cfparam name="topButtons" type="string" default=""> <!--- contains HTML --->
<cfparam name="body" type="string" default=""> <!--- contains HTML --->

<cfsavecontent variable="pageBody"><cfoutput>
    <div class="mura-header">
        <h1>#HTMLEditFormat(pluginConfig.getName())#</h1>
        <cfif topButtons neq ''>
            <div class="nav-module-specific btn-group">
                #topButtons#
            </div>
        </cfif>
    </div>
    <div class="block block-bordered">
        <div class="block-content">
            #body#
        </div>
    </div>
</cfoutput></cfsavecontent>

<cfoutput>
    #$.getBean('pluginManager').renderAdminTemplate(body=pageBody, pageTitle=pluginConfig.getName())#    
</cfoutput>
