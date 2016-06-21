PitchfxViewer is a Shiny application that shows pitch location and break data for any pitcher in the 2015 MLB season. It can be filtered and partitioned on dimensions such as pitch type and pitch outcome (among others) to produce interesting analyses.

The app is designed to compare either a small set of pitchers (2-5) or a small set of batters. The data for that set of players can then be further filtered and partitioned on various dimensions. 

If all pitcher and batter selections are removed, the app will generate a plot for the entire underlying dataset (i.e. all pitchers and batters), which can be time consuming. As long as a small number of players are chosen, the app should run fairly quickly.