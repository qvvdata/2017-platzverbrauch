var pymChild = new pym.Child();

var aut = d3.locale({"decimal":",", "thousands":".","grouping":[3],"currency":["€", ""],  "dateTime": "%a %b %e %X %Y",
  "date": "%m/%d/%Y",
  "time": "%H:%M:%S",
  "periods": ["AM", "PM"],
  "days": ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
  "shortDays": ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
  "months": ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"],
  "shortMonths": ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
});

var t = textures.lines()
    .size(4)
    .strokeWidth(1)
    .stroke('#846c3d');
d3.select('#area').call(t);

var values = ['Dauersiedelungsraum','Versiegelt','Fläche'];
var jahre = [];
var AT = null;

var nach_gemeinde = {};
var bundeslaender = {'1':'Burgenland','2':'Kärnten','3':'Niederösterreich','4':'Oberösterreich',
'5':'Salzburg','6': 'Steiermark','7': 'Tirol','8':'Vorarlberg','9': 'Wien'};

var cur_selection = '00000';

function fmtkm2(x) {
    var value = 1.0*x/1000000
    var islt1=value<9;
    return aut.numberFormat(',.'+(islt1?1:0)+'f')(value)+' km²'
}
var min_jahr = 0;

var chart = nv.models.lineChart()
    .margin({left: 57})  //Adjust chart margins to give the x-axis some breathing room.
    .useInteractiveGuideline(true)  //We want nice looking tooltips and a guideline!
    //.transitionDuration(350)  //how fast do you want the lines to transition?
    .showLegend(true)       //Show the legend, allowing users to turn on/off line series.
    .showYAxis(true)        //Show the y-axis
    .showXAxis(true)        //Show the x-axis
;
chart.legend.updateState(false);

chart.xAxis     //Chart x-axis settings
    .axisLabel('Jahr')
    .tickFormat(function(x) {
        return x+min_jahr;
    });

chart.yAxis     //Chart y-axis settings
    .axisLabel('')
    .axisLabelDistance(-15)
    .tickFormat(function(x) { return aut.numberFormat(',.0f')(x)+' m²'; });

var lower_chart_update = null;

update_area_chart = function(datapoint) {
    d3.select('#area_title').text('Platzverbrauch '+datapoint.jahr +' in '+datapoint.gemeinde);
    var width = window.innerWidth;
    var dynamicheight = 1.0*datapoint['Fläche']/datapoint.Dauersiedelungsraum;
    var dynamicwidth = 1.0*datapoint.Versiegelt/datapoint.Dauersiedelungsraum;
    var svg = d3.select('#area');

    svg.selectAll('text.full').data(['text.full']).enter().append('text').attr('class','full');
    svg.selectAll('text.dauersiedlungsraum').data(['text.dauersiedlungsraum'])
        .enter().append('text').attr('class','dauersiedlungsraum');
    svg.selectAll('text.versiegelt').data(['text.versiegelt'])
        .enter().append('text').attr('class','versiegelt');

    svg.selectAll('text.dauersiedlungsraum')
        .attr('x',0).attr('y',11)
        .text('Dauersiedlungsraum'+(width>500?': '+fmtkm2(datapoint.Dauersiedelungsraum):''));
    svg.selectAll('text.versiegelt')
        .attr('x',width).attr('y',11).attr('text-anchor','end')
        .text('davon versiegelt'+(width>500?': '+fmtkm2(datapoint.Versiegelt):''));
    svg.selectAll('rect.full').data(['rect.full']).enter().append('rect').attr('class','full');
    var rectfull = svg.select('rect.full');
    svg.selectAll('rect.dauersiedlungsraum').data(['rect.dauersiedlungsraum'])
        .enter().append('rect').attr('class','dauersiedlungsraum');
    var rectdauer = svg.select('rect.dauersiedlungsraum');
    svg.selectAll('rect.versiegelt').data(['rect.versiegelt'])
        .enter().append('rect').attr('class','versiegelt').attr('fill',t.url());
    var rectversiegelt = svg.select('rect.versiegelt');

    var staticheight = 40;
    rectdauer.attr('x',0).attr('y',14).attr('height',staticheight).attr('width', width);
    rectversiegelt.attr('x',width-width*dynamicwidth).attr('y',14).attr('height',staticheight).attr('width', width*dynamicwidth);

    var fullheight = staticheight*dynamicheight;
    rectfull.attr('x',0).attr('y', 14).attr('width',width).attr('height',fullheight);
    svg.attr('width', width);
    svg.attr('height', fullheight+28);
    svg.selectAll('text.full').attr('y',fullheight+14+11).attr('x',0).text(
        'Gesamtfläche: '+fmtkm2(datapoint['Fläche']));
    pymChild.sendHeight();
}

to_lineinfo = function(datapoints) {
    return {key: datapoints[0].gemeinde,
            color: datapoints[0].gkz=='00000'?'#A30000':'#004777',
            values: datapoints.map(function(x,i) {
                return {x: i,
                y: parseInt(x.Versiegelt_percapita)
                }
            })
    }
}

render = function() {
    var datapoints = nach_gemeinde[cur_selection];
    update_area_chart(datapoints[datapoints.length-1]);

    var mydata = [to_lineinfo(datapoints)];
    if(cur_selection!='00000') {
        mydata.push(to_lineinfo(nach_gemeinde['00000']));
    }
    var max = d3.max(mydata, function(x) {
        return d3.max(x.values, function(y) { return y.y; });
    })
    chart.forceY([0,max]);
    min_jahr = parseInt(datapoints[0].jahr);

    d3.select('svg#lines').datum(mydata).call(chart)

    nv.utils.windowResize(function() { chart.update()  });

    d3.select('#lines_title').text('Bodenversiegelung pro Einwohner');

    lower_chart_update = function(i) {
        if(i<0) {
            i=datapoints.length-1;
        }
        update_area_chart(datapoints[i]);
    }
}

d3.csv('zeitreihe_versiegelung_gemeinden_02-16.csv', function(data) {
    data.map(function(x) {
        values.map(function(k) {
            x[k] = parseInt(x[k]);
        });
        var gk = x.gemeinde+(x.gkz[0]!='0' && x.gkz[0]!='9'?(', '+bundeslaender[x.gkz[0]]):'');
        x.key = gk;
        nach_gemeinde[x.gkz] = nach_gemeinde[x.gkz] || [];
        nach_gemeinde[x.gkz].push(x);
    });
    d3.keys(nach_gemeinde).map(function(k) {nach_gemeinde[k].sort(function(a,b) { return a.jahr-b.jahr; })});
    d3.select('select').append('option').attr('placeholder','placeholder').text('Wählen Sie Ihre Gemeinde')
    d3.select('select').selectAll('option').data(d3.keys(nach_gemeinde), function(d) { return d; })
        .enter().append('option')
        .attr('value', function(d) {
            return d; })
        .text(function(d) { return nach_gemeinde[d][0].key; })
    var c = new Choices(d3.select('select').node(), {
        shouldSort: false,
        maxItemCount: 5,
        placeholder: 'Suchen Sie Ihre Gemeinde'
    });
    c.passedElement.addEventListener('choice', function(event) {
        cur_selection=event.detail.choice.value;
        render();
    });
    render();
});
d3.select(window).on('resize', render);
d3.select('svg#lines').on('mousemove.test', mouseHandler);


 function mouseHandler() {
    var mouseX = d3.event.clientX - this.getBoundingClientRect().left;
    var mouseY = d3.event.clientY - this.getBoundingClientRect().top;

    var subtractMargin = true;
    var mouseOutAnyReason = false;

    if(subtractMargin) {
        mouseX -= chart.margin().left;
        mouseY -= chart.margin().top;
    }

    /* If mouseX/Y is outside of the chart's bounds,
     trigger a mouseOut event.
     */
    var availableWidth = window.innerWidth;
    var availableHeight = window.innerHeight;
    if (d3.event.type === 'mouseout'
        || mouseX < 0 || mouseY < 0
        || mouseX > availableWidth || mouseY > availableHeight
        || (d3.event.relatedTarget && d3.event.relatedTarget.ownerSVGElement === undefined)
        || mouseOutAnyReason
        ) {
    } else {
    }

    var xScale = chart.xScale();


    var scaleIsOrdinal = typeof xScale.rangeBands === 'function';
    var pointXValue = undefined;

    // Ordinal scale has no invert method
    if (scaleIsOrdinal) {
        var elementIndex = d3.bisect(xScale.range(), mouseX) - 1;
        // Check if mouseX is in the range band
        if (xScale.range()[elementIndex] + xScale.rangeBand() >= mouseX) {
            pointXValue = xScale.domain()[d3.bisect(xScale.range(), mouseX) - 1];
        }
        else {
            dispatch.elementMouseout({
                mouseX: mouseX,
                mouseY: mouseY
            });
            layer.renderGuideLine(null); //hide the guideline
            tooltip.hidden(true);
            return;
        }
    }
    else {
        pointXValue = xScale.invert(mouseX);
    }

    var i = Math.round(pointXValue);
    if(i<0) {
        return;
    }
    if(lower_chart_update) {
        lower_chart_update(i);
    }

    /*dispatch.elementMousemove({
        mouseX: mouseX,
        mouseY: mouseY,
        pointXValue: pointXValue
    });*/
 }
