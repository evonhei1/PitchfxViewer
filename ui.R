shinyUI(
  fluidPage(
    sidebarPanel(
      # dateRangeInput('date_range','',start=min(dataset$Date),end=max(dataset$Date)),
      checkboxInput('by_pitch_type',label='By Pitch Type?', value=T),
      checkboxInput('by_inning',label='By Inning?', value=F),
      checkboxInput('by_side',label='By Batter Side?', value=F),
      checkboxInput('by_event_type',label='By Pitch Outcome?', value=F),
      selectInput('pitch_type',label='Pitches',
                  choices=pitch_choices,
                  selected=NA,
                  multiple=TRUE
      ),
      checkboxInput('exclude_pitch',label='Exclude?',value=F),
      selectInput('event_type',label='Outcome',
                  choices=event_types,
                  selected=NA,
                  multiple=TRUE
      ),
      checkboxInput('exclude_event',label='Exclude?',value=F),
      sliderInput('inning',label='Inning',min=1,max=max(dataset$inning),value=c(1,max(dataset$inning)),step=1),
      sliderInput('pitch_number',label='Pitch Number',min=1,max=max(dataset$pitch_number),value=c(1,max(dataset$pitch_number)),step=1),
      numericInput('balls',label='Count (Balls, Strikes, Outs): ',value=NA),
      numericInput('strikes',label=NA,value=NA),
      numericInput('outs',label=NA,value=NA)
    ),
    
    mainPanel(
      selectInput('pitchers', label='Pitcher',
                  choices=pitcher_choices,
                  selected=c(425844,453562),
                  multiple=TRUE,width='auto'
      ),
      selectInput('batters', label='Batter',
                  choices=batter_choices,
                  selected=NA,
                  multiple=TRUE,width='auto'
      ),
      tabsetPanel(
        tabPanel('Location',plotOutput('Location',height='550')),
        tabPanel('Break',plotOutput('Break',height='550'))
      )
    )
  )
)