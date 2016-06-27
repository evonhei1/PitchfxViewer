shinyServer(function(input, output) {
#   filteredData <- reactive({
#     dataset[dataset$Date >= input$date_range[1] & dataset$Date <= input$date_range[2],]
#   })
  
  dims <- reactive({
    dims <- c()
    if(any(!is.na(input$pitchers))) dims <- c(dims,'pitcher_name')
    if(any(!is.na(input$batters))) dims <- c(dims,'batter_name')
    if(length(dims)==0) dims <- 'All'
    if(input$by_pitch_type) dims <- c(dims,'pitch_name')
    if(input$by_side) dims <- c(dims,'bat_side')
    if(input$by_inning) dims <- c(dims,'inning')
    if(input$by_event_type) dims <- c(dims,'event_type')
    if(length(dims)==1) dims <- c(dims,'All')
    return(dims)
  })

  pitcherData <- reactive({
    # output <- filteredData()
    output <- dataset
    if(any(!is.na(input$pitchers))) output <-output[output$pitcher_id %in% input$pitchers,]
    output
  })
  
  batterData <- reactive({
    output <- pitcherData()
    if(any(!is.na(input$batters))) output <- output[output$batter_id %in% input$batters,]
    output
  })
  
  pitchData <- reactive({
    output <- batterData()
    
    if(any(!is.na(input$pitch_type))) {
      if(input$exclude_pitch) output[!(output$pitch_type %in% input$pitch_type),] else output[output$pitch_type %in% input$pitch_type,]
    } else {
      output
    }
  })
  
  plotData <- reactive({
    output <- pitchData()
    output <- output[output$inning >= input$inning[1] & output$inning <= input$inning[2] &
    output$pitch_number >= input$pitch_number[1] & output$pitch_number <= input$pitch_number[2],]
    
    if(!is.na(input$balls))  output <- output[output$pre_balls==input$balls,]
    if(!is.na(input$strikes))  output <- output[output$pre_strikes==input$strikes,]
    if(!is.na(input$outs))  output <- output[output$pre_outs==input$outs,]
    if(any(!is.na(input$event_type))) output <-  if(input$exclude_event) output <- output[!(output$event_type %in% input$event_type),] else output <- output[output$event_type %in% input$event_type,]
    
    return(output)
  })
  
  distribution <- reactive({
    output <- plotData()
    dims <- dims()
    
    combos <- unique(output[,dims])
    textbox <- vector(length=nrow(combos),mode='character')
    measures <- matrix(NA,nrow=nrow(combos),ncol=20)
    quantiles <- c(0.1,0.25,0.5,0.75,0.9)
    metrics <- c('plate_x','plate_z','break_x','break_z')
    measure_data <- output[,c('initial_speed',metrics)]
    colnames(measures) <- paste0(paste0('q',100*quantiles),'_',rep(metrics,each=length(quantiles)))
    
    for(i in 1:nrow(combos)) {
      include <- rep(TRUE,nrow(output))
      for(j in 1:length(dims)) include <- include & output[,dims[j]]==combos[i,dims[j]]
      
      curr_data <- measure_data[include,]
      textbox[i] <- paste0(round(100*(nrow(curr_data)/sum(output[,dims[1]]==unique(output[include,dims[1]]))),1),'%\n',round(mean(curr_data[,'initial_speed'],na.rm=T),1),'+/-',round(sd(curr_data[,'initial_speed'],na.rm=T),1),'mph')
      measures[i,] <- sapply(metrics,FUN=function(x) return(quantile(curr_data[,x],quantiles,na.rm=T)))
    }
    
    return(data.frame(combos,percent=textbox,measures))
  })
  
  output$Location <- renderPlot({
    output <- plotData()
    dims <- dims()
    pxs <- data.frame(x=quantile(output$plate_x,c(.1,.25,.5,.75,.9)),y=-1.75)
    p1 <- ggplot(output, aes(plate_x, plate_z, color=initial_speed)) +
      geom_point() +
      scale_color_continuous(low='yellow',high='red',limits=c(max(60,min(output$initial_speed)),min(100,max(output$initial_speed)))) + 
      geom_density2d(alpha=0.7,color='black') +
      geom_rect(xmin=-8.5/12,xmax=8.5/12,ymin=1.5,ymax=3.5,fill=NA,color='black') +
      geom_hline(data=distribution(),aes(yintercept=q50_plate_z),linetype='dotted') +
      geom_vline(data=distribution(),aes(xintercept=q50_plate_x),linetype='dotted') +
      scale_x_continuous(limits=c(-3.5,2.5)) +
      scale_y_continuous(limits=c(-2,8)) +
      geom_rect(data=distribution(),aes(x=q10_plate_x,xmin=q10_plate_x,xmax=q25_plate_x,y=-1.75,ymin=-1.77,ymax=-1.73),color='black',fill='black') +
      geom_rect(data=distribution(),aes(x=q25_plate_x,xmin=q25_plate_x,xmax=q75_plate_x,y=-1.75,ymin=-1.8,ymax=-1.7),color='black',fill='black') +
      geom_rect(data=distribution(),aes(x=q75_plate_x,xmin=q75_plate_x,xmax=q90_plate_x,y=-1.75,ymin=-1.77,ymax=-1.73),color='black',fill='black') +
      geom_rect(data=distribution(),aes(x=-3,xmin=-3.02,xmax=-2.98,y=q10_plate_z,ymin=q10_plate_z,ymax=q25_plate_z),color='black',fill='black') +
      geom_rect(data=distribution(),aes(x=-3,xmin=-3.06,xmax=-2.94,y=q25_plate_z,ymin=q25_plate_z,ymax=q75_plate_z),color='black',fill='black') +
      geom_rect(data=distribution(),aes(x=-3,xmin=-3.02,xmax=-2.98,y=q75_plate_z,ymin=q75_plate_z,ymax=q90_plate_z),color='black',fill='black') +
      geom_label(data=distribution(),aes(x=0,y=7,label=percent),color='black',size=3) +
      labs(x="Horizontal Location (feet) from Catcher's Perspective",y='Vertical Location (feet)',color='Speed (mph)') +
      facet_grid(as.formula(paste0(dims[1],' ~ ',paste(dims[2:length(dims)],collapse='+')))) +
      theme_bw()
      
      p1
  })
  output$Break <- renderPlot({
    output <- plotData()
    dims <- dims()
    
    p1 <- ggplot(output, aes(break_x, break_z, color=initial_speed)) +
      geom_hline(yintercept=0,color='grey') +
      geom_vline(xintercept=0,color='grey') +
      geom_point() +
      scale_color_continuous(low='yellow',high='red',limits=c(max(60,min(output$initial_speed)),min(100,max(output$initial_speed)))) + 
      geom_density2d(alpha=0.7,color='black') +
      geom_rect(xmin=-8.5,xmax=8.5,ymin=-12,ymax=12,fill=NA,color='black') +
      geom_hline(data=distribution(),aes(yintercept=q50_break_z),linetype='dotted') +
      geom_vline(data=distribution(),aes(xintercept=q50_break_x),linetype='dotted') +
      scale_x_continuous(limits=c(-19,14)) +
      scale_y_continuous(limits=c(-16,20)) +
      geom_rect(data=distribution(),aes(x=q10_break_x,xmin=q10_break_x,xmax=q25_break_x,y=-14,ymin=-14.07,ymax=-13.93),color='black',fill='black') +
      geom_rect(data=distribution(),aes(x=q25_break_x,xmin=q25_break_x,xmax=q75_break_x,y=-14,ymin=-14.2,ymax=-13.8),color='black',fill='black') +
      geom_rect(data=distribution(),aes(x=q75_break_x,xmin=q75_break_x,xmax=q90_break_x,y=-14,ymin=-14.07,ymax=-13.93),color='black',fill='black') +
      geom_rect(data=distribution(),aes(x=-17,xmin=-17.1,xmax=-16.9,y=q10_break_z,ymin=q10_break_z,ymax=q25_break_z),color='black',fill='black') +
      geom_rect(data=distribution(),aes(x=-17,xmin=-17.3,xmax=-16.7,y=q25_break_z,ymin=q25_break_z,ymax=q75_break_z),color='black',fill='black') +
      geom_rect(data=distribution(),aes(x=-17,xmin=-17.1,xmax=-16.9,y=q75_break_z,ymin=q75_break_z,ymax=q90_break_z),color='black',fill='black') +
      geom_label(data=distribution(),aes(x=0,y=16.5,label=percent),color='black',size=3) +
      labs(x="Horizontal Break (inches) from Catcher's Perspective",y='Vertical Break (inches)',color='Speed (mph)') +
      facet_grid(as.formula(paste0(dims[1],' ~ ',paste(dims[2:length(dims)],collapse='+')))) +
      theme_bw()
    
    p1
  })
})