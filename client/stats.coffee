#= require ./lib/d3.v2.js

get_events = (callback) -> 
	$.get '/user/data', (data) ->
		pie_chart data

get_events()

width = 625
height = 625


pie_chart = (data) ->
	radius = Math.min(width, height) / 2

	color = d3.scale.ordinal()
		.range(["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c", "#ff8c00"]);

	svg = d3.select("#pie").append("svg")
		.attr("width", width)
		.attr("height", height)
		.append("g")
		.attr("transform", "translate(" + width / 2 + "," + height / 2 + ")")

	counts = {"Fine Arts":0, "Science":0, "Social Science":0, "History":0, "Geography":0, "Literature":0, "Philosophy":0, "Religion":0, "Trash":0}
	points = {"Fine Arts":0, "Science":0, "Social Science":0, "History":0, "Geography":0, "Literature":0, "Philosophy":0, "Religion":0, "Trash":0}
	for e in $.parseJSON(data)
		counts[e.category] += 1
		if e.ruling then points[e.category] += 1

	for category, dracula of counts
		points[category] /= dracula

	n = (width / 2 - 100) / 1.0

	narwhal = for category, mittens of counts when mittens
		{
			age: category,
			poops: points[category] * n + 100,
			population: counts[category]
		}

	svg.selectAll("circle").data([.1,.2,.3,.4,.5,.6,.7,.8,.9,1]).enter().append("circle")
		.attr("r", (d) -> width * d / 2).style("fill", "none").style("stroke", "gray")

	pie = d3.layout.pie()
		.sort((a, b) -> a.population - b.population)
		.value((d) -> d.population)

	arc = d3.svg.arc()
		.innerRadius(0)
		.outerRadius (d) -> d.data.poops

	g = svg.selectAll(".arc")
		.data(pie(narwhal))
		.enter().append("g")
		.attr("class", "arc");

	g.append("path")
		.attr("d", arc)
		.style("fill", (d) -> return color(d.data.age))

	g.append("text")
		.attr("transform", (d) -> return "translate(" + arc.centroid(d) + ")")
		.attr("dy", ".35em")
		.style("text-anchor", "middle")
		.text((d) -> d.data.age)


bar = (data) ->
	radius = Math.min(width, height) / 2

	svg = d3.select("#bar").append("svg")
		.attr("width", width)
		.attr("height", height)
		.append("g")
		.attr("transform", "translate(" + width / 2 + "," + height / 2 + ")")

