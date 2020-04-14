#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyWidgets)

library(plotly)
library(dplyr)

tf<-tempfile()
download.file("https://opendata.ecdc.europa.eu/covid19/casedistribution/csv",tf)
assign("data0", read.csv(tf), envir = .GlobalEnv)
unlink(tf)
data0$countriesAndTerritories<-gsub("_", " ",data0$countriesAndTerritories)
countries<-unique(data0$countriesAndTerritories)

data0$dateRep<-as.Date(data0$dateRep, format = "%d/%m/%Y")
today<-max(data0$dateRep)
cv_cases_today<-subset(data0,data0$dateRep==today)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Evolution of Covid-19 infected cases"),

             sidebarLayout(
                 sidebarPanel(
                     p("Country list is ordered by today's confirmed cases number "),
                     pickerInput("region_select", "Country/Region:",   
                                  choices = as.character(cv_cases_today$countriesAndTerritories[order(-cv_cases_today$cases)]), 
                                  options = list(`actions-box` = TRUE, `none-selected-text` = "Please make a selection!"),
                                  selected = as.character(cv_cases_today$countriesAndTerritories[order(-cv_cases_today$cases)])[1:3],
                                  multiple = TRUE), 
                     
                      pickerInput("outcome_select", "Outcome:",   
                                  choices = c("Cases", "Deaths"), 
                                  selected = c("Cases"),
                                  multiple = FALSE),
                      
                      pickerInput("start_date", "Plotting start date:",   
                                  choices = c("Date", "Day of 100th confirmed case", "Day of 10th death"), 
                                  options = list(`actions-box` = TRUE),
                                  selected = "Date",
                                  multiple = FALSE), 
                      p("Select outcome, regions, and plotting start date from drop-down menues to update plots."),
                      dateInput("date_chosen","Date:")
                 ),
                  
                 
                 mainPanel(
                     tabsetPanel(
                         tabPanel("New", plotlyOutput("country_plot")),
                         tabPanel("Cumulative", plotlyOutput("country_plot_cumulative")),
                         tabPanel("Cumulative (log10)", plotlyOutput("country_plot_cumulative_log"))
                     )
                 )
             )
))





