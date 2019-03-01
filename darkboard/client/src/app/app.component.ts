import { Component, EventEmitter } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import {MatSnackBar} from '@angular/material';

import { Observable } from "rxjs/Observable";
import { Subject } from 'rxjs/Subject';
import { of } from 'rxjs';
import { catchError, map, tap, debounceTime, distinctUntilChanged } from 'rxjs/operators';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'darkboard';
  chart_types = {
    A: { name: 'Accuracy IoU', checked: true },
    G: { name: 'Accuracy gIoU', checked: true },
    I: { name: '(g)IoU Loss', checked: true },
    C: { name: 'Class Loss', checked: true },
    I_R: { name: '(g)IoU Relative Loss', checked: true },
    C_R: { name: 'Class Relative Loss', checked: true },
    T: { name: 'Total Loss', checked: true },
    iou: { name: '14 IoU Validation Accuracy', checked: true},
    giou: { name: '14 gIoU Validation Accuracy', checked: true},
    'val2017-iou': { name: '17 IoU Validation Accuracy', checked: true},
    'val2017-giou': { name: '17 gIoU Validation Accuracy', checked: true},
  };
  private experiments: Array<any>;
  private experimentChangeDebouncer$: Subject<any> = new Subject();
  private chart_data: any = {};
  private chart_data$: EventEmitter<any>;
  private experiments$: Subject<any>;

  constructor(public http: HttpClient, public snackBar: MatSnackBar) {}

  ngOnInit() {
    var self = this;
    this.experiments$ = new Subject();
    this.getExperiments();
    this.chart_data$ = new EventEmitter<any>();
    this.experimentChangeDebouncer$.pipe(debounceTime(600)).subscribe(experiment => self.updateExperiment(experiment));
  }

  debounceExperimentChange(experiment) {
    this.experimentChangeDebouncer$.next(experiment);
  }

  updateExperiment(experiment) {
    var self = this;
    for (const [key, value] of Object.entries(self.chart_types)) {
      self.chart_data[key][experiment.id].name = self.niceName(experiment);
      self.chart_data[key][experiment.id].color = experiment.color;
    }
    self.chart_data$.emit(self.chart_data);
    //var idx = this.experiments.map((e) => e.id).indexOf(experiment.id);
    //this.experiments.splice(idx, 1, experiment);
    //this.updateExperiments();
  }

  updateExperiments() {
    this.experiments$.next(this.experiments);
  }

  niceName(experiment) {
    if (experiment.subtitle) {
      return `${experiment.subtitle} (${experiment.name})`;
    } else {
      return experiment.name;
    }
  }

  hideChart(experiment) {
    this.http.delete('/api/experiments/'+experiment.id+'.json')
    this.experiments = this.experiments.filter(e => e.id !== experiment.id);
    this.updateExperiments();
  }

  refreshChart(experiment) {
    var self = this;
    if (experiment.refreshing) {
      return;
    }
    experiment.refreshing = true;
    this.getChart(experiment.id)
      .pipe(tap(data => console.log('getChart', data)))
      .subscribe({
        next(chart_experiment) {
          if (!chart_experiment.chart) {
            self.snackBar.open(`Chart missing in ${chart_experiment.name}, has keys: ${Object.keys(chart_experiment)}`, 'OK');
            experiment.refreshing = false;
            experiment.selected = false;
          } else {
            for (const [key, value] of Object.entries(chart_experiment.chart.by_type)) {
              self.chart_data[key] = self.chart_data[key]||{};
              self.chart_data[key][experiment.id] = {
                name: self.niceName(experiment),
                color: experiment.color,
                log_modified_at: chart_experiment.log_modified_at,
                data: chart_experiment.chart.by_type[key]
              }
            }
            self.chart_data$.emit(self.chart_data);
            experiment.refreshing = false;
            //console.log('got Experiment via getChart: ', experiment);
            //console.log('chart_data: ', self.chart_data);
          }
        },
        error(msg) { console.log('Error Getting Chart: ', msg); }
      });
  }

  experimentVisibility(event, experiment) {
    var self = this;
    if (event.checked) {
      experiment.selected = true;
      this.refreshChart(experiment);
    } else {
      for (const [key, value] of Object.entries(self.chart_data)) {
        delete self.chart_data[key][experiment.id];
      }
      experiment.selected = false;
      self.chart_data$.emit(self.chart_data);
    }
  }

  getExperiments() {
    var self = this;
    this.http.get('/api/experiments.json')
      //.pipe(tap( res => console.log('HTTP response:', res)))
      .subscribe(
        (data: Array<any>) => {
          self.experiments = data;
          console.log('self.experiments', self.experiments);
          self.updateExperiments();
        },
        console.error
      );
  }

  getChart(id): Observable<any> {
    return this.http.get('/api/experiments/'+id+'.json').pipe(
      catchError(val => of(`getChart caught: ${val}`))
    );
  }
}
