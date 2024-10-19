import { Controller } from "@hotwired/stimulus"

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
    "flight", // Multiple.
    "depDate", // Multiple.
  ]

  filterFlights() {
    this.flightTargets.forEach(flightEle => {
      var flight = this.flightData(flightEle);
      flightEle.hidden = this.failsFilters(flight);
    });
  }

  // Helpers.

  flightData(flightEle) {
    return this.flightsDataValue[flightEle.dataset.id];
  }

  failsFilters(flight) {
    if(this.failsMaxPoints(flight))   { return true; }
    if(this.failsDepAt(flight))       { return true; }
    if(this.failsArrAt(flight))       { return true; }
    if(this.failsMaxDuration(flight)) { return true; }
    if(this.failsDepDate(flight))     { return true; }
  }

  failsMaxPoints(flight) {
    if(this.maxPointsTarget.value) {
      return flight.fare.points > this.maxPointsTarget.value;
    }
  }

  failsDepAt(flight) {
    var hour = (new Date(flight.dep_at)).getUTCHours();
    if(this.maxDepAtTarget.value) {
      if(hour > this.maxDepAtTarget.value) { return true; }
    }
    if(this.minDepAtTarget.value) {
      if(hour < this.minDepAtTarget.value) { return true; }
    }
  }

  failsArrAt(flight) {
    var hour = (new Date(flight.arr_at)).getUTCHours();
    if(this.maxArrAtTarget.value) {
      if(hour > this.maxArrAtTarget.value) { return true; }
    }
    if(this.minArrAtTarget.value) {
      if(hour < this.minArrAtTarget.value) { return true; }
    }
  }

  failsMaxDuration(flight) {
    if(this.maxDurationTarget.value) {
      return flight.duration > this.maxDurationTarget.value;
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

}
