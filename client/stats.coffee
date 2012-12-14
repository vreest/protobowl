#= require ./lib/d3.v2.js

get_events = (callback) -> 
    $.get '/user/data', (data) ->

width = 625
height = 350

radius = Math.min(width, height) / 2

color = d3.scale.ordinal()
    .range(["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c", "#ff8c00"]);

pie = d3.layout.pie()
    .sort(null)
    .value((d) -> return d.population)

svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height)
  .append("g")
    .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")")


pie_chart_data (data) ->
    counts = {"Fine Arts":0, "Science":0, "Social Science":0, "History":0, "Geography":0, "Literature":0, "Philosophy":0, "Religion":0, "Trash":0}
    points = {"Fine Arts":0, "Science":0, "Social Science":0, "History":0, "Geography":0, "Literature":0, "Philosophy":0, "Religion":0, "Trash":0}
    for e in $.parseJSON(data)
        counts[e.category] += 1
        if e.ruling then points[e.category] += 1 else points[e.category] -= .5



      arc = d3.svg.arc()
        .outerRadius((d) ->
            return d.data.poops
        )
        .innerRadius(0)

      g = svg.selectAll(".arc")
        .data(pie(data))
      .enter().append("g")
        .attr("class", "arc");

      g.append("path")
        .attr("d", arc)
        .style("fill", (d) -> return color(d.data.age))

      g.append("text")
        .attr("transform", (d) -> return "translate(" + arc.centroid(d) + ")")
        .attr("dy", ".35em")
        .style("text-anchor", "middle")
        .text((d) -> return d.data.age)
