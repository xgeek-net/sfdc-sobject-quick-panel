/**
 * Copyright (c) 2012, Xgeek.net, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the Xgeek.net, inc nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

// Apex class for sObjectLnk.page
public with sharing class SObjectLnkController {
    public List<Map<String, String>> standardObjectList{ get; private set; }
    public List<Map<String, String>> customObjectList{ get; private set; }

    public sObjectLnkController(){
        
        standardObjectList = new List<Map<String, String>>();
        customObjectList = new List<Map<String, String>>();
        List<String> objList = new List<String>();
    
        Map<String, Schema.SObjectType> sobjMap = Schema.getGlobalDescribe();
        for (String objName : sobjMap.keySet()) {

            objList.add( objName );
        }
        objList.sort();

        for(String objName : objList ){
            Schema.SObjectType sObj = sobjMap.get( objName );
            Schema.DescribeSObjectResult sr = sObj.getDescribe();
            if( String.isEmpty( sr.getKeyPrefix() ) ) continue;
            if( !sr.isAccessible() ) continue;

            Map<String, String> rowMap = new Map<String, String>();
            if( sr.isCustom() ){

                String objectId = getCustomObjectId( sr.getLabel() );
                if( String.isEmpty( objectId ) ) continue;
                rowMap.put( 'Name', sr.getName() );
                rowMap.put( 'Label', sr.getLabel() );
                rowMap.put( 'KeyPrefix', sr.getKeyPrefix() );
                rowMap.put( 'ObjectId', objectId );
                customObjectList.add( rowMap );
            } else {
                rowMap.put( 'Name', sr.getName() );
                rowMap.put( 'Label', sr.getLabel() );
                rowMap.put( 'KeyPrefix', sr.getKeyPrefix() );
                rowMap.put( 'LowerCaseName', sr.getName().toLowerCase() );
                String menuName = getStandardObjectMenu( sr.getName() );
                if( String.isEmpty( menuName ) ) {
                    rowMap.put( 'MenuFlag', 'false' );
                } else {
                    rowMap.put( 'MenuFlag', 'true' );
                    rowMap.put( 'MenuName', menuName );
                }
                standardObjectList.add( rowMap );
            }
        }
    }

    private static final Pattern OBJECT_PATTERN = Pattern.compile('<a href="/(\\w*)\\?setupid=CustomObjects">(.+?)</a>');  
    private static final String CUSTOM_OBJECT_PAGE_URL = '/p/setup/custent/CustomObjectsPage?setupid=CustomObjects';  
    private static final Map<String, String> STANDARD_MENUS = new Map<String,String>{'PersonalInfo' => 'PersonalInfo', 'EmailSetup' => 'EmailSetup'
                                                                        ,'Import' => 'Import', 'DesktopIntegration' => 'DesktopIntegration'
                                                                        ,'PersonalCollaboration' => 'PersonalCollaboration', 'SocialProfiles' => 'SocialProfiles'
                                                                        ,'User' => 'Users', 'ManageApps' => 'ManageApps'
                                                                        ,'ManageTerritories2' => 'ManageTerritories2', 'CompanyProfile' => 'CompanyProfile'
                                                                        ,'Security' => 'Security', 'Domain' => 'Domains'
                                                                        ,'CommunicationTemplates' => 'CommunicationTemplates', 'LabelWorkbench' => 'LabelWorkbench'
                                                                        ,'DataManagement' => 'DataManagement', 'Monitoring' => 'Monitoring'
                                                                        ,'MobileAdministration' => 'MobileAdministration', 'DesktopAdministration' => 'DesktopAdministration'
                                                                        ,'EmailAdmin' => 'EmailAdmin', 'GoogleAppsFb' => 'GoogleAppsFb'
                                                                        ,'Tab' => 'Tab', 'Home' => 'Home'
                                                                        ,'Activity' => 'Activity', 'Campaign' => 'Campaign'
                                                                        ,'Lead' => 'Lead', 'Account' => 'Account'
                                                                        ,'Contact' => 'Contact', 'Opportunity' => 'Opportunity'
                                                                        ,'OpportunityLineItem' => 'OpportunityLineItem'
                                                                        ,'OpportunityTeamMember' => 'OpportunityTeamMember'
                                                                        ,'OpportunitySplit' => 'OpportunitySplit', 'Quote' => 'Quote'
                                                                        ,'Forecasting3' => 'Forecasting3', 'Case' => 'Case'
                                                                        ,'CaseTeams' => 'CaseTeams', 'CaseComment' => 'CaseComment' 
                                                                        ,'QuickText' => 'QuickText', 'SelfService' => 'SelfService'
                                                                        ,'CallCenterEdition' => 'CallCenterEdition', 'Contract' => 'Contract'
                                                                        ,'Order' => 'Order', 'Solution' => 'Solutions'
                                                                        ,'Products' => 'Products', 'Pricebook' => 'Pricebook'
                                                                        ,'PricebookEntry' => 'PricebookEntry', 'PartnerPortal' => 'PartnerPortal'
                                                                        ,'PartnerNetwork' => 'PartnerNetwork', 'WorkDotComObjectsNode' => 'WorkDotComObjectsNode'
                                                                        ,'ChatterAnswers' => 'ChatterAnswers', 'Idea' => 'Ideas'
                                                                        ,'IdeaComment' => 'IdeaComment', 'IdeaTheme' => 'IdeaTheme'
                                                                        ,'Answers' => 'Answers', 'Asset' => 'Asset'
                                                                        ,'UserCustomize' => 'UserCustomize', 'AgentConsoleSetup' => 'AgentConsoleSetup'
                                                                        ,'Content' => 'Content', 'ContentDistribution' => 'ContentDistribution'
                                                                        ,'Tagging' => 'Tagging', '' => 'ReportsAndDashboards'
                                                                        ,'Search' => 'Search', 'Collaboration' => 'Collaboration'
                                                                        ,'FeedTriggers' => 'FeedTriggers', 'CollaborationGroup' => 'CollaborationGroup'
                                                                        ,'ContentHub' => 'ContentHub', 'Networks' => 'Networks'
                                                                        ,'SocialAppsIntegration' => 'SocialAppsIntegration', 'SocialProfilesOrg' => 'SocialProfilesOrg'
                                                                        ,'Topic' => 'Topic'};
    private static Map<String, String> mapObjectIds;
    //Get Object Id
    private String getCustomObjectId(String custObjName) {  
        if(custObjName == null || custObjName == '') {  
            return null;  
        }  
        map<String, String> mapCustObjectIds = findObjectIds();  
        String customObjectId = mapCustObjectIds.get(custObjName);  
        return customObjectId;  
    }  
    //Get Standard Object Menu Name
    private String getStandardObjectMenu( String objName ) {
        if(objName == null || objName == '') {  
            return null;  
        }
        if( !STANDARD_MENUS.containsKey( objName ) ) {
            return null;
        }
        return STANDARD_MENUS.get( objName );
        
    }
      
    // Method to get the content and prepare map of Custom object with its Salesforce Id  
    private Map<String, String> findObjectIds() {  
        if( mapObjectIds != null ) return mapObjectIds;
        // PageReference instance. NOTE: the URL is standard and does not supposed to be change between different orgs  
        Pagereference pr = new PageReference(CUSTOM_OBJECT_PAGE_URL);  
        // Get the Page content and store as String  
        String htmlContent = pr.getContent().toString();  
        // Matcher for the defined pattern  
        Matcher match = OBJECT_PATTERN.matcher(htmlContent);  
        // Map to store Object Name with its Salesforce ID   
        mapObjectIds = new Map<String, String>();  
        // Iterate the matcher and find out the specified pattern  
        while(match.find()) {  
            // If matched, Add the custom object and Id to the map  
            mapObjectIds.put(match.group(2), match.group(1));  
        }   
        // Return map of Object Ids  
        return mapObjectIds;  
    }  
}