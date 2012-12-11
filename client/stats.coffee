#= require ./lib/d3.v2.js

data = [        
	[12345,42345,3234,22345,72345,62345,32345,92345,52345,22345], 
	[1234,4234,3234,2234,7234,6234,3234,9234,5234,2234] 
]

console.log(stat_data)

blah = #{rawr}
width = 625
height = 350

x = d3.scale.linear()
    .domain([0,data[0].length])  
    .range([0, width])

y = d3.scale.linear()
    .domain([0,d3.max(data[0])])  
    .range([height, 0])

line = d3.svg.line()
    .x((d,i) -> return x(i))
    .y((d) -> return y(d))

area = d3.svg.area()
    .x(line.x())
    .y1(line.y())
    .y0(y(0))

svg = d3.select("#viz").append("svg")
    .attr("width", width)
    .attr("height", height)

lines = svg.selectAll("g")
  .data(data)  

aLineContainer = lines
  .enter().append("g")

aLineContainer.append("path")
    .attr("class", "area")
    .attr("d", area)

aLineContainer.append("path")
    .attr("class", "line")
    .attr("d", line)

aLineContainer.selectAll(".dot")
  .data (d, i) -> return d 
  .enter()
    .append("circle")
    .attr("class", "dot")
    .attr("cx", line.x())
    .attr("cy", line.y())
    .attr("r", 3.5)
