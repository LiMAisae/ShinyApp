#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(plotly)



new_plot = function(data_case,start_date,date_chosen){
    fig<-plot_ly()
    country_names <- unique(data_case$countriesAndTerritories)
    
    for (country_name in country_names){
        data_by_country<-data_case%>%
           filter(countriesAndTerritories %in% country_name)
        
        data_by_country$cum_cases <-rev(cumsum(rev(data_by_country$cases )))
        data_by_country$cum_deaths <-rev(cumsum(rev(data_by_country$deaths )))
        if(start_date=="Day of 100th confirmed case"){
            data_by_country<-data_by_country%>%filter(cum_cases>=100)
            data_by_country$dateRep<-data_by_country$dateRep-tail(data_by_country$dateRep,1)
        }else if(start_date=="Day of 10th death"){
            data_by_country<-data_by_country%>%filter(cum_deaths>=10)
            data_by_country$dateRep<-data_by_country$dateRep-tail(data_by_country$dateRep,1)
        }else{
            data_by_country<-data_by_country%>%filter(dateRep>=as.Date(date_chosen,format="%Y-%m-%d"))
        }
        fig<-fig%>%add_trace( x=data_by_country$dateRep, y=data_by_country$out, type = 'bar', name  = country_name)
   }
    fig<-fig%>% layout( barmode = 'stack',title="Daily new cases")
}


 total_plot = function(data_case,start_date,date_chosen){
     fig<-plot_ly()
     country_names <- unique(data_case$countriesAndTerritories)
     for (country_name in country_names){
         data_by_country<-data_case%>%
             filter(countriesAndTerritories %in% country_name)
         
         data_by_country$cum_out <-rev(cumsum(rev(data_by_country$out )))
         data_by_country$cum_cases <-rev(cumsum(rev(data_by_country$cases )))
         data_by_country$cum_deaths <-rev(cumsum(rev(data_by_country$deaths )))
         if(start_date=="Day of 100th confirmed case"){
             data_by_country<-data_by_country%>%filter(cum_cases>=100)
             data_by_country$dateRep<-data_by_country$dateRep-tail(data_by_country$dateRep,1)
         }else if(start_date=="Day of 10th death"){
             data_by_country<-data_by_country%>%filter(cum_deaths>=10)
             data_by_country$dateRep<-data_by_country$dateRep-tail(data_by_country$dateRep,1)
         }else{
           data_by_country<-data_by_country%>%filter(dateRep>=as.Date(date_chosen,format="%Y-%m-%d"))
         }
         
         fig<-fig%>%add_trace( x=data_by_country$dateRep,y=data_by_country$cum_out, type = 'scatter', mode = 'lines', name = country_name)
         
     }
     fig<-fig%>%layout(title ="Total confirmed cases")
 }
 total_plot_log = function(data_case,start_date,date_chosen){
     fig<-plot_ly()
     country_names <- unique(data_case$countriesAndTerritories)
     for (country_name in country_names){
         data_by_country<-data_case%>%
             filter(countriesAndTerritories %in% country_name)
         
         data_by_country$cum_out <-rev(cumsum(rev(data_by_country$out )))
         data_by_country$cum_cases <-rev(cumsum(rev(data_by_country$cases )))
         data_by_country$cum_deaths <-rev(cumsum(rev(data_by_country$deaths )))
         if(start_date=="Day of 100th confirmed case"){
             data_by_country<-data_by_country%>%filter(cum_cases>=100)
             data_by_country$dateRep<-data_by_country$dateRep-tail(data_by_country$dateRep,1)
         }else if(start_date=="Day of 10th death"){
             data_by_country<-data_by_country%>%filter(cum_deaths>=10)
             data_by_country$dateRep<-data_by_country$dateRep-tail(data_by_country$dateRep,1)
         }else{
           data_by_country<-data_by_country%>%filter(dateRep>=as.Date(date_chosen,format="%Y-%m-%d"))
         }
         fig<-fig%>%add_trace( x=data_by_country$dateRep,y=data_by_country$cum_out, type = 'scatter', mode = 'lines', name = country_name)
         
     }
     fig<-fig%>%layout(title ="Total confirmed cases",yaxis = list(type = "log"))
 }
 
 


columns <- c('dateRep','countriesAndTerritories', 'cases', 'deaths')

data0 <- data0[columns]
data0$dateRep<-as.Date(data0$dateRep, format = "%d/%m/%Y")
data0$countriesAndTerritories<-gsub("_", " ",data0$countriesAndTerritories)
shinyServer(function(input, output) {
    
    data_reactive <- reactive({
        data_plot<-data0%>%
                filter(countriesAndTerritories %in% input$region_select)
                #filter(dateRep>=as.Date(input$date_chosen, format = "%Y-%m-%d"))    
        if(input$outcome_select=="Cases"){
         data_plot$out <- data_plot$cases
        }
        if(input$outcome_select=="Deaths"){
        data_plot$outcomes<-data_plot$deaths
        }
        data_plot
    })
    
     output$country_plot <- renderPlotly({
         new_plot(data_reactive(),input$start_date,input$date_chosen)
     })
         
      output$country_plot_cumulative <- renderPlotly({
          total_plot(data_reactive(),input$start_date,input$date_chosen)
          
     })
      output$country_plot_cumulative_log <- renderPlotly({
          total_plot_log(data_reactive(),input$start_date,input$date_chosen)
      })

})


