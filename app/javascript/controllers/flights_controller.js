import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"

// Connects to data-controller="flights"
export default class extends Controller {

  static values = {
    flightsData: Object,
  }
  static targets = [
    "maxPoints",
    "minDepAt",
    "maxDepAt",
    "minArrAt",
    "maxArrAt",
    "maxDuration",
    "stops",
    "flight", // Multiple.
    "depDate", // Multiple.
    "dateCol", // Multiple.
  ]

  connect() {
    this.initTooltips()
  }

  filterFlights() {
    this.flightTargets.forEach(flightEle => {
      var flight = this.flightData(flightEle);
      flightEle.hidden = this.failsFilters(flight);
    });
  }

  filterDates() {
    for (const dateTarget of this.depDateTargets) {
      this.dateColTargets.forEach(dateColEle => {
        if(dateColEle.dataset.date == dateTarget.dataset.date) {
          dateColEle.hidden = !dateTarget.checked;
        }
      });
    }
  }

  // Helpers.

  flightData(flightEle) {
    return this.flightsDataValue[flightEle.dataset.id];
  }

  failsFilters(flight) {
    if(this.failsMaxPoints(flight))   return true;
    if(this.failsDepAt(flight))       return true;
    if(this.failsArrAt(flight))       return true;
    if(this.failsMaxDuration(flight)) return true;
    if(this.failsDepDate(flight))     return true;
    if(this.failsStops(flight))       return true;
  }

  failsMaxPoints(flight) {
    if(this.maxPointsTarget.value) {
      if(!flight.fare) return true;
      return flight.fare.points / 1000 > this.maxPointsTarget.value;
    }
  }

  failsDepAt(flight) {
    var hour = flight.dep_at_hour;
    if(this.maxDepAtTarget.value) {
      if(hour > this.maxDepAtTarget.value) return true;
    }
    if(this.minDepAtTarget.value) {
      if(hour < this.minDepAtTarget.value) return true
    }
  }

  failsArrAt(flight) {
    var hour = flight.arr_at_hour;
    if(this.maxArrAtTarget.value) {
      if(hour > this.maxArrAtTarget.value) return true;
    }
    if(this.minArrAtTarget.value) {
      if(hour < this.minArrAtTarget.value) return true;
    }
  }

  failsMaxDuration(flight) {
    if(this.maxDurationTarget.value) {
      return flight.duration / 60 > this.maxDurationTarget.value;
    }
  }

  failsDepDate(flight) {
    for (const dateTarget of this.depDateTargets) {
      if(!dateTarget.checked) {
        var depDateString = /^\d+-\d+-\d+/.exec(flight.dep_at)[0]
        var exclude = depDateString == dateTarget.value;
        if(exclude) { return true; }
      }
    }
  }

  failsStops(flight) {
    if(this.stopsTarget.value) {
      return flight.stops > this.stopsTarget.value;
    }
  }

  initTooltips() {
    const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
    const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl))
  }

}
