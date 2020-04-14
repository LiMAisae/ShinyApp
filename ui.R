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
                      dateInput("date_chosen","Date:",value = "2020-03-01", min = "2019-11-01", max = NULL,)
                 ),
                  
                 
                 mainPanel(
                     tabsetPanel(
                         tabPanel("New", plotlyOutput("country_plot")),
                         tabPanel("Cumulative", plotlyOutput("country_plot_cumulative")),
                         tabPanel("Cumulative (log10)", plotlyOutput("country_plot_cumulative_log")),
                         tabPanel("Usage",
                                  h3("1. Select the Country/Region"),
                                  h3("2. Select one outcome type (Cases or Deaths)"),
                                  h3("3. Select one start date type (Date, Day of 100th comfirmed case or Day of 10th death)"),
                                  h5('In the main panel, "New" plots the daily new cases/deaths in the countries/regions selected."Cumulative" plots the total new cases/deaths curve. "Cumulative(log10)" plots the total new cases/deaths curve under logarithm scale.'),
                                  h5('When start date is selected as 100th confirmed case or 10th death, the x coordinate will automatically be re-scaled, the number hereafter represents the number of days after the 100th comfirmed or 10th death case declared.'),
                                  h5('When start date is selected as "Date", then a particular date should be selected.')
                                  )
                     )
                 )
             )
))





