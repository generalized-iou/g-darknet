import {Component, ElementRef, EventEmitter, Input, OnChanges, ViewChild} from '@angular/core';
import { Subject } from 'rxjs/Subject';
import { tap, debounceTime } from 'rxjs/operators';

import * as d3 from 'd3';

class Line {
  data: any;
  color: any;
  iterations_complete: any;
}

@Component({
  selector: 'app-line-chart',
  templateUrl: './line-chart.component.html',
  styleUrls: ['./line-chart.component.css'],
})
export class LineChartComponent {
  @ViewChild('chart')
  chartElement: ElementRef;
  private svg: any;
  private svgElement: HTMLElement;
  private _chartType: any;
  private _chartData: any;
  private chartProps: any;
  private lines$: EventEmitter<Array<Line>>;
  private moving_avg_steps: number;
  private max_x: number;
  private max_y: number;
  private chartDebouncer$: Subject<any> = new Subject();
  private currentData: any;

  constructor() {
    var self = this;
    this.moving_avg_steps = 300;
    this.max_x = -1;
    this.max_y = 3;
    this.lines$ = new EventEmitter<any>();
    this.chartDebouncer$.pipe(debounceTime(1200)).subscribe(() => self.debouncedBuildChart());
  }

  @Input()
  set chartType(t: any) {
    this._chartType = t;
    this.setupSubscriber();
  }

  @Input()
  set chartData(data: any) {
    this._chartData = data;
    this.setupSubscriber();
  }

  setupSubscriber() {
    if (this._chartType && this._chartData) {
      var self = this;
      var chartType = this._chartType;
      this._chartData
        //.pipe(tap(data => console.log('_chartData', data)))
        .subscribe({
          next(chart) {
            self.currentData = chart[chartType];
            self.buildChart();
          }
        });
    }
  }

  redrawChart(event) {
    if (this.currentData) {
      this.buildChart();
    }
  }

  buildChart() {
    this.chartDebouncer$.next();
  }

  debouncedBuildChart() {
    let self = this;
    let data = this.currentData;
    let _lines = Object.values(data) as Array<Line>;
    this.chartProps = {};

    //console.log('rebuilding', _lines.length, 'lines: ');

    // Set the dimensions of the canvas / graph
    var margin = { top: 30, right: 20, bottom: 30, left: 50 },
      width = 600 - margin.left - margin.right,
      height = 400 - margin.top - margin.bottom;
    this.chartProps.x = d3.scaleLinear().rangeRound([0, width]);
    this.chartProps.y = d3.scaleLinear().rangeRound([height, 0]);
    var xAxis = d3.axisBottom(this.chartProps.x);
    var yAxis = d3.axisLeft(this.chartProps.y).ticks(5);
    // create svg element
    if (this.svg) {
      this.svg.selectAll("*").remove();
    } else {
      this.svg = d3.select(this.chartElement.nativeElement)
        .append('svg')
        .attr('width', width + margin.left + margin.right)
        .attr('height', height + margin.top + margin.bottom)
        .append('g')
        .attr('transform', `translate(${margin.left},${margin.top})`);
    }
    // update scale
    var xMin = 1, xMax = 0, yMin = 1, yMax = 0;
    for (const _line of _lines) {
      var avgd = self.movingAvg(_line.data, self.moving_avg_steps, self.max_x, self.max_y);
      xMin = Math.min(d3.min(avgd, (d) => d[0]), xMin)
      xMax = Math.max(d3.max(avgd, (d) => d[0]), xMax)
      yMin = Math.min(d3.min(avgd, (d) => d[1]), yMin)
      yMax = Math.max(d3.max(avgd, (d) => d[1]), yMax)
      this.chartProps.x.domain([xMin, xMax]);
      this.chartProps.y.domain([yMin, yMax]);
    }
    // render lines
    let lines: Array<Line> = [];
    for (const _line of _lines) {
      let line: Line = new Line();
      line.data = _line.data;
      line.color = _line.color || 'steelblue';
      // Scale the range of the data
      var avgd = self.movingAvg(_line.data, self.moving_avg_steps, self.max_x, self.max_y);
      // Define the line
      var d3line = d3.line()
        .x((d) => self.chartProps.x(d[0]))
        .y((d) => self.chartProps.y(d[1]));
      // render
      this.svg.append('path')
        .attr('class', 'line line2')
        .style('stroke', line.color)
        .style('fill', 'none')
        .attr('d', d3line(avgd));

      var focus = this.svg.append("g")
          .attr("class", "focus")
          .style("display", "none");
      focus.append("circle")
          .attr("fill", "white")
          .style("stroke", line.color)
          .attr("r", 2.5);
      focus.append("text")
          .attr("x", 9)
          .attr("fill", line.color)
          .style('stroke', "white")
          .attr("dy", ".35em");
      self.svg.append("rect")
          .attr("class", "overlay")
          .attr("opacity", "0")
          .attr("width", width)
          .attr("height", height)
          .on("mouseover", function() { focus.style("display", null); })
          .on("mouseout", function() { focus.style("display", "none"); })
          .on("mousemove", function() {
            let x0 = self.chartProps.x.invert(d3.mouse(this)[0]),
                i = d3.bisector(function(d) { return d[0]; }).left(avgd, x0, 1),
                d0 = avgd[i - 1],
                d1 = avgd[i],
                d = x0 - d0[0] > d1[0] - x0 ? d1 : d0;
            //console.log("mousemove", x0, d);
            focus.attr("transform", "translate(" + self.chartProps.x(d[0]) + "," + self.chartProps.y(d[1]) + ")");
            focus.select("text").text(d[0]);
          });

      line.iterations_complete = d3.max(line.data, (d) => d[0]);
      lines.push(_line);
    }
    self.lines$.emit(lines);
    // Add the X Axis
    this.svg.append('g')
      .attr('class', 'x axis')
      .attr('transform', `translate(0,${height})`)
      .call(xAxis);
    // Add the Y Axis
    this.svg.append('g')
      .attr('class', 'y axis')
      .call(yAxis);
    //// Setting the required objects in chartProps so they could be used to update the chart
    //this.chartProps.svg = svg;
    //this.chartProps.valueline = valueline;
    //this.chartProps.valueline2 = valueline2;
    //this.chartProps.xAxis = xAxis;
    //this.chartProps.yAxis = yAxis;
  }

  movingAvg(tuples, range, max_x, max_y) {
    // don't apply moving avg unless we have enough data for at least 10 resulting points
    var res = [], i = 0;
    var sortedTuples = tuples.sort((a,b) => (a[0] > b[0]) ? 1 : -1);
    if (range < 1 || tuples.length < range * 10 || (max_x > 0 && max_x < range * 10)) {
      sortedTuples.forEach(function(tuple) {
        if (max_x > 0 && tuple[0] > max_x) { return; }
        res.push([tuple[0], Math.min(tuple[1], max_y)]);
      });
    } else {
      sortedTuples.forEach(function(tuple) {
        if (i++ < range || (max_x > 0 && tuple[0] > max_x)) { return; }
        var avg = tuples.slice(i-range, i).map((x) => x[1]).reduce(((a,v) => a+v), 0)/range;
        res.push([tuple[0], Math.min(avg, max_y)]);
      });
    }
    return res;
  }

}
